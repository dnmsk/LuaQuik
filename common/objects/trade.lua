local trade = {}

function trade.FromQuik(trade)
  local flags = trade.flags
  if flags > 1024 then flags = flags - 1024 end
  local _trade = {
    trade_num = trade.trade_num,
    flags = flags - 1, --0 - sell, 1 - buy
    price = trade.price,
    qty = trade.qty,
    value = trade.value,
    sec_code = trade.sec_code,
    class_code = trade.class_code,
    datetime = DateTime.FromQuik(trade.datetime)
  }

  return _trade
end

function trade.FromString(str, date)
  local splitted = split(str, ';')
  local trade = {
    trade_num = tonumber(splitted[1]),
    datetime = DateTime.FromStrings(date, splitted[2]),
    flags = tonumber(splitted[3]),
    price = tonumber(splitted[4]),
    qty = tonumber(splitted[5]),
    value = tonumber(splitted[6]),
  }
  trade['value'] = trade.qty * trade.price
  return trade
end

function trade.ToString(trade)
  return trade.trade_num..';'..trade.time..';'..
    trade.flags..';'..trade.price..';'..trade.qty
end

return trade