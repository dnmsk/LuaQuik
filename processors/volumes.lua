local Processor = {}

function Processor.groupFunc(code, period, prevData, trade)
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
end

function Processor.resFunc(prevValue, curValue)
  local stock = prevValue.stock or {}
  local futures = prevValue.futures or {}
  stock = { volume = stock.volume or 0, needSpent = stock.needSpent or 0 }
  futures = { volume = futures.volume or 0, needSpent = futures.needSpent or 0 }
  stock.volume = stock.volume + curValue.stock.volume
  futures.volume = futures.volume + curValue.futures.volume
  local needSpentStock = table.average(curValue.stock.prices) * stock.volume
  local needSpentFutures = table.average(curValue.futures.prices) * futures.volume
  if needSpentStock == 0 then
    needSpentStock = stock.needSpent or 0
  end
  if needSpentFutures == 0 then
    needSpentFutures = futures.needSpent or 0
  end
  local needSpent = math.floor(needSpentStock + needSpentFutures)
  stock.needSpent = needSpentStock
  futures.needSpent = needSpentFutures
  local volume = (prevValue.volume or 0) + curValue.stock.volume + curValue.futures.volume
  local spent = math.floor((prevValue.spent or 0) + curValue.stock.spent + curValue.futures.spent)
  return {
    spent = spent,
    moneyDelta = needSpent - spent,
    stock = stock,
    futures = futures,
    volume = stock.volume + futures.volume,
    time = math.floor((curValue.time / 100000) % 10000),
    price = curValue.stock.prices[#curValue.stock.prices] or table.average(curValue.futures.prices)
  }
end

return Processor