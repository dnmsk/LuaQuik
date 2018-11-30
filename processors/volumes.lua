Processors:Add('volumes', {
  groupFunc = function(code, period, prevData, trade)
    trade = StockSettings:GetFixedTrade(code, trade)
    local volume = trade.qty
    local spent = trade.qty * trade.price;
    if trade.flags == 0 then
      spent = -spent
      volume = -volume
    end

    local stock = prevData.stock or {
      prices={}, volume=0, spent = 0
    }
    local futures = prevData.futures or {
      prices={}, volume=0, spent = 0
    }
    local spentStock = prevData.spentStock or 0
    local spentFutures = prevData.spentFutures or 0
    if StockSettings:IsStock(code) then
      stock.prices[#stock.prices + 1] = trade.price
      stock.volume = stock.volume + volume
      stock.spent = stock.spent + spent
    end
    if StockSettings:IsFutures(code) then
      futures.prices[#futures.prices + 1] = trade.price
      futures.volume = futures.volume + volume
      futures.spent = futures.spent + spent
    end
    return {
      stock = stock,
      futures = futures,
      time = period,
      code = code
    }
  end,
  resFunc = function(prevValue, curValue)
    local stock = prevValue.stock or { volume = 0 }
    local futures = prevValue.futures or { volume = 0 }
    stock.volume = stock.volume + curValue.stock.volume
    futures.volume = futures.volume + curValue.futures.volume
    local needSpent = (prevValue.needSpent or 0) + math.floor(
      table.average(curValue.stock.prices) * stock.volume +
      table.average(curValue.futures.prices) * futures.volume
    )
    local volume = (prevValue.volume or 0) + curValue.stock.volume + curValue.futures.volume
    local spent = math.floor((prevValue.spent or 0) + curValue.stock.spent + curValue.futures.spent)
    return {
      spent = spent,
      needSpent = needSpent,
      moneyDelta = needSpent - spent,
      volume = (prevValue.volume or 0) + stock.volume + futures.volume,
      time = math.floor(curValue.time / 100000),
      price = curValue.stock.prices[#curValue.stock.prices] or table.average(curValue.futures.prices)
    }
  end  
})