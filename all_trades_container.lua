dofile(_app_path..'trade.lua')

AllTradesContainer = Disposable:new({
  new = function(self)
    self.container = { buffer = {}, trades = {} }
    self.codes = {}
  end,
  fileName = function(self, code)
    local outFilePostfix = '_'..os.date('%x'):gsub('/', '-')..'.csv'
    return _app_path..'trades/'..code..'_'..outFilePostfix
  end,
  Init = function(self, codes)
    self:dispose(self)
    self.container = { buffer = {}, trades = {} }
    for i, v in ipairs(codes) do
      self.codes[v] = v
      local file = io.open(self:fileName(v), "r")
      local lines = {}
      if file ~= nil then
        for line in file:lines() do
          local trade = Trade:FromString(line)
          trade['saved'] = true
          lines[trade.trade_num] = trade
        end
        file:close()
      end
      self.container.trades[v] = lines
    end
  end,
  PushTrade = function(self, code, trade)
    if self.codes[code] == nil then return end
    local _trade = Trade:FromQuik(trade)
    for i, v in pairs(self.container) do
      local buffer = v[code]
      if buffer == nil then
        v[code] = {}
        buffer = v[code]
      end
      if buffer[_trade.trade_num] == nil then
        buffer[_trade.trade_num] = _trade
      end
    end
    if self.codes[code] ~= nil then
      self.codes[code] = code
    end
  end,
  Trades = function(self, code)
    return self.container.trades[code]
  end,
  FlushBuffer = function(self)
    local buffer = self.container.buffer
    self.container.buffer = {}

    for i, v in pairs(self.codes) do
      local buff = buffer[i]
      if buff ~= nil then
        local file = io.open(self:fileName(v), "a+")
        for bi, bv in pairs(buff) do
          local trade = self.container.trades[i][bv.trade_num]
          if trade['saved'] ~= true then
            trade['saved'] = true
            file:write(Trade:ToString(bv)..'\n')
          end
        end
        file:flush()
        file:close()
      end
    end
  end,
  dispose = function(self)
    self:FlushBuffer(self)
  end
})