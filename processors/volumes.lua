Processors:Add('volumes', {
  groupFunc = function(code, period, prevData, trade)
    trade = StockSettings:GetFixedTrade(code, trade)
    local volume = trade.qty
    local spent = trade.qty * trade.price;
    local stockPrices = prevData.stockPrices or {}
    local futuresPrices = prevData.futuresPrices or {}
    if trade.flags == 0 then
      spent = -spent
      volume = -volume
    end
    if StockSettings:IsStock(code) then stockPrices[#stockPrices + 1] = trade.price end
    if StockSettings:IsFutures(code) then futuresPrices[#futuresPrices + 1] = trade.price end
    return {
      spent = (prevData.spent or 0) + spent,
      volume = (prevData.volume or 0) + volume,
      time = period,
      code = code,
      stockPrices = stockPrices,
      futuresPrices = futuresPrices
    }
  end,
  resFunc = function(prevValue, curValue)
    local avgPrice = (
      (curValue.stockPrices[#curValue.stockPrices] or curValue.futuresPrices[#curValue.futuresPrices])
      +
      (curValue.futuresPrices[#curValue.futuresPrices] or curValue.stockPrices[#curValue.stockPrices])
    ) / 2
    local volume = (prevValue.volume or 0) + curValue.volume
    local needSpent = math.floor(volume * avgPrice)
    local spent = math.floor((prevValue.spent or 0) + curValue.spent)
    return {
      spent = spent,
      needSpent = needSpent,
      moneyDelta = needSpent - spent,
      volume = volume,
      time = math.floor(curValue.time / 100000),
      price = curValue.stockPrices[#curValue.stockPrices] or curValue.futuresPrices[#curValue.futuresPrices]
    }
  end  
})