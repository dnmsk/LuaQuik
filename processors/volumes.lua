Processors:Add('volumes', {
  groupFunc = function(code, period, prevData, trade)
    trade = StockSettings:GetFixedTrade(code, trade)
    local volume = trade.qty
    local moneyTrade = trade.qty * trade.price;
    if trade.flags == 0 then
      moneyTrade = -moneyTrade
      volume = -volume
    end
    return {
      money = (prevData.money or 0) + moneyTrade,
      volume = (prevData.volume or 0) + volume,
      time = period
    }
  end,
  resFunc = function(prevValue, curValue)
    return {
      money = math.floor((prevValue.money or 0) + curValue.money),
      volume = (prevValue.volume or 0) + curValue.volume,
      time = math.floor(curValue.time / 1000)
    }
  end  
})