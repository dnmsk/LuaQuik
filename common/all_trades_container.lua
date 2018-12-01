if getScriptPath then
  dofile(_app_path..'common\\trade.lua')
else
  dofile('./common/trade.lua')
end

AllTradesContainer = Disposable:new({
  new = function(self)
    self.container = { buffer = {}, trades = {} }
    self.codes = {}
  end,
  fileName = function(self, code, date)
    if date == nil then
      date = os.date('%Y%m%d')
    end
    local outFilePostfix = '_'..date..'.csv'
    return _app_path..'trades/'..code..'_'..outFilePostfix
  end,
  Init = function(self, codes, dates)
    self:dispose(self)
    self.container = { buffer = {}, trades = {} }
    if dates == nil then dates = { os.date('%Y%m%d') } end
    for i, v in ipairs(codes) do
      self.codes[v] = v
      for di, dv in ipairs(dates) do
        local lines = {}
        local file = io.open(self:fileName(v, dv), "r")
        if file ~= nil then
          for line in file:lines() do
            local trade = Trade:FromString(line, dv)
            trade['saved'] = true
            lines[trade.trade_num] = trade
          end
          file:close()
        end
        local trades = self.container.trades[v]
        if trades == nil then
          trades = {}
          self.container.trades[v] = trades
        end
        trades[tonumber(dv)] = lines
      end
    end
  end,
  PushTrade = function(self, code, trade)
    if self.codes[code] == nil then return end
    local _trade = Trade:FromQuik(trade)
    for k, v in pairs(self.container) do
      local buffer = v[code]
      if buffer == nil then
        buffer = {}
        v[code] = buffer
      end
      local _buffer = buffer[_trade.date]
      if _buffer == nil then
        _buffer = {}
        buffer[_trade.date] = _buffer
      end
      if _buffer[_trade.trade_num] == nil then
        _buffer[_trade.trade_num] = _trade
      end
    end
    if self.codes[code] ~= nil then
      self.codes[code] = code
    end
  end,
  Trades = function(self, code, date)
    local trades = self.container.trades[code]
    if date == nil then return trades end
    if trades == nil then
      self:Init({ code })
      trades = self.container.trades[code]
    end
    trades = trades[tonumber(date)]
    if trades == nil then
      self:Init({ code }, { date })
      trades = self.container.trades[code][tonumber(date)]
    end
    return trades
  end,
  FlushBuffer = function(self)
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
              local fileName = self:fileName(v, trade.date)
              local file = files[fileName]
              if file == nil then
                file = io.open(fileName, "a+")
                files[fileName] = file
              end
              trade['saved'] = true
              file:write(Trade:ToString(tv)..'\n')
            end
          end
        end
        for fi, fv in pairs(files) do
          fv:flush()
          fv:close()
        end
      end
    end
  end,
  dispose = function(self)
    self:FlushBuffer(self)
  end
})