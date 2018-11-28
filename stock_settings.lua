StockSettings = Class:new({
  new = function(self)
    self.stocks = {
      SBER = 'SBER',
      SBERP = 'SBERP',
      GAZP = 'GAZP',
      VTBR = 'VTBR'
    }
  end,
  Get = function(self)
  end,
  GetFixedTrade = function(self, code, trade)
    local _trade = {
      trade_num = trade.trade_num,
      date = trade.date,
      time = trade.time,
      datetime = trade.datetime,
      flags = trade.flags,
      price = trade.price,
      qty = trade.qty,
      value = trade.value,
    }
    if self.stocks[code] ~= nil then
      _trade.price = _trade.price * 10
    else
      _trade.price = _trade.price / 10
      _trade.qty = _trade.qty * 10
    end
    return _trade;
  end
})