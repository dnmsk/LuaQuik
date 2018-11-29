Processors:Add('volumes', {
  groupFunc = function(code, period, prevData, trade)
    trade = StockSettings:GetFixedTrade(code, trade)
    local volume = trade.qty
    local spent = trade.qty * trade.price;
    local prices = prevData.prices or {}
    if trade.flags == 0 then
      spent = -spent
      volume = -volume
    end
    prices[#prices+1] = trade.price
    return {
      spent = (prevData.spent or 0) + spent,
      volume = (prevData.volume or 0) + volume,
      time = period,
      prices = prices
    }
  end,
  resFunc = function(prevValue, curValue)
    local price = curValue.prices[#curValue.prices]
    local needSpent = (prevValue.moneyVirt or 0) +
      math.floor(curValue.volume * price)
    local spent = math.floor((prevValue.spent or 0) + curValue.spent)
    return {
      spent = spent,
      moneyVirt = needSpent,
      moneyDelta = spent - needSpent,
      volume = (prevValue.volume or 0) + curValue.volume,
      time = math.floor(curValue.time / 1000),
      price = price
    }
  end  
})