local _Trade = require("common/objects/trade")

AllTradesContainer = inheritsFrom(Disposable, {
  new = function(self)
    self.container = { buffer = {}, trades = {} }
    self.codes = {}
  end
}).new()

function AllTradesContainer:fileName(code, date)
  if date == nil then
    date = DateTime.Now()
  end
  local outFilePostfix = '_'..date:DateNumber()..'.csv'
  return _app_path..'trades/'..code..'_'..outFilePostfix
end

function AllTradesContainer:Init(codes, dates)
  self:dispose(self)
  --self.container = { buffer = {}, trades = {} }
  if dates == nil then dates = { DateTime.Now() } end
  for i, v in ipairs(codes) do
    self.codes[v] = v
    for di, dv in ipairs(dates) do
      local trades = self.container.trades[v]
      if trades == nil then
        trades = {}
        self.container.trades[v] = trades
      end
      trades[dv:DateNumber()] = self:ReadTradesForDate(v, dv)
    end
  end
end

function AllTradesContainer:ReadTradesForDate(code, date)
  local lines = {}
  local file = io.open(self:fileName(code, date), "r")
  if file ~= nil then
    for line in file:lines() do
      local trade = _Trade.FromString(line, date)
      trade['saved'] = true
      lines[trade.trade_num] = trade
    end
    file:close()
  end
  return lines
end

function AllTradesContainer:PushTrade(code, trade)
  if self.codes[code] == nil then return end
  local _trade = _Trade.FromQuik(trade)
  for k, v in pairs(self.container) do
    local buffer = v[code]
    if buffer == nil then
      buffer = {}
      v[code] = buffer
    end
    local _buffer = buffer[_trade.datetime:DateNumber()]
    if _buffer == nil then
      _buffer = {}
      buffer[_trade.datetime:DateNumber()] = _buffer
    end
    if _buffer[_trade.trade_num] == nil then
      _buffer[_trade.trade_num] = _trade
    end
  end
  if self.codes[code] ~= nil then
    self.codes[code] = code
  end
end

function AllTradesContainer:Trades(code, date)
  local trades = self.container.trades[code]
  if date == nil then return trades end
  if trades == nil then
    self:Init({ code })
    trades = self.container.trades[code]
  end

  trades = trades[date:DateNumber()]
  if trades == nil then
    self:Init({ code }, { date })
    trades = self.container.trades[code][date:DateNumber()]
  --else
  --  trades = self:ReadTradesForDate(code, date)
  end
  return trades
end

function AllTradesContainer:FlushBuffer()
  local buffer = self.container.buffer
  self.container.buffer = {}

  for i, v in pairs(self.codes) do
    local buff = buffer[i]
    if buff ~= nil then
      local files = {}
      for bi, bv in pairs(buff) do
        for ti, tv in pairs(bv) do
          local trade = self.container.trades[i][bi][tv.trade_num]
          if trade['saved'] ~= true then
            local fileName = self:fileName(v, trade.datetime)
            local file = files[fileName]
            if file == nil then
              file = io.open(fileName, "a+")
              files[fileName] = file
            end
            trade['saved'] = true
            file:write(_Trade.ToString(tv)..'\n')
          end
        end
      end
      for fi, fv in pairs(files) do
        fv:flush()
        fv:close()
      end
    end
  end
end

function AllTradesContainer:dispose()
  self:FlushBuffer(self)
end
