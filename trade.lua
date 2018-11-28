Trade = Class:new({
  new = function()end,
  FromQuik = function(self, trade)
    local _trade = {
      trade_num = trade.trade_num,
      flags = trade.flags - 1025, --0 - sell, 1 - buy
      price = trade.price,
      qty = trade.qty,
      value = trade.value,
      sec_code = trade.sec_code,
      class_code = trade.class_code,
      date = trade.datetime.year * 10000 + trade.datetime.month * 100 + trade.datetime.day,
      time = trade.datetime.hour * 10000000 + trade.datetime.min * 100000 + trade.datetime.sec * 1000 + trade.datetime.ms
    }
    _trade['datetime'] = _trade.date * 1000000000 + _trade.time
    return _trade
  end,
  FromString = function(self, str, date)
    local splitted = split(str, ';')
    local trade = {
      trade_num = tonumber(splitted[1]),
      date = tonumber(date),
      time = tonumber(splitted[2]),
      datetime = tonumber(date..splitted[2]),
      flags = tonumber(splitted[3]),
      price = tonumber(splitted[4]),
      qty = tonumber(splitted[5]),
      value = tonumber(splitted[6]),
    }
    trade['value'] = trade.qty * trade.price
    return trade
  end,
  ToString = function(self, trade)
    return trade.trade_num..';'..trade.time..';'..
      trade.flags..';'..trade.price..';'..trade.qty
  end
})