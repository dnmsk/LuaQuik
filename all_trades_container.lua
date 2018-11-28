dofile(_app_path..'trade.lua')

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
      local lines = {}
      for di, dv in ipairs(dates) do
        local file = io.open(self:fileName(v, dv), "r")
        if file ~= nil then
          for line in file:lines() do
            local trade = Trade:FromString(line, dv)
            trade['saved'] = true
            lines[trade.trade_num] = trade
          end
          file:close()
        end
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
        local files = {}
        for bi, bv in pairs(buff) do
          local trade = self.container.trades[i][bv.trade_num]
          if trade['saved'] ~= true then
            local fileName = self:fileName(v, trade.date)
            local file = files[fileName]
            if file == nil then
              file = io.open(fileName, "a+")
              files[fileName] = file
            end
            trade['saved'] = true
            file:write(Trade:ToString(bv)..'\n')
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