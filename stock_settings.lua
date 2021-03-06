StockCodes = {
  SBER  = { 'SBER', 'SRZ8', 'SRH9', 'SRM9', 'SRU9' },
  SBERP = {'SBERP', 'SPZ8', 'SPH9', 'SPM9', 'SPU9' },
  GAZP  = { 'GAZP', 'GZZ8', 'GZH9', 'GZM9', 'GZU9' },
  LKOH  = { 'LKOH', 'LKZ8', 'LKH9', 'LKM9', 'LKU9' },
  VTBR  = { 'VTBR', 'VBZ8', 'VBH9', 'VBM9', 'VBU9' },
  AFLT  = { 'AFLT', 'AFZ8', 'AFH9', 'AFM9', 'AFU9' },
  MGNT  = { 'MGNT', 'MNZ8', 'MNH9', 'MNM9', 'MNU9' },
  RTS   = {         'RIZ8', 'RIH9', 'RIM9', 'RIU9' }
}

StockSettings = inheritsFrom(Class, {
  new = function(self)
    self.stocks = {
      SBER = {
        lotSize = 10
      },
      SBERP =  {
        lotSize = 10
      },
      GAZP =  {
        lotSize = 10
      },
      VTBR =  {
        lotSize = 10000
      },
      MGNT =  {
        lotSize = 1
      },
      AFLT =  {
        lotSize = 10
      },
      LKOH =  {
        lotSize = 1
      },
      RTS = {}
    }

    local futureSettings = {
      SBER = {
        lotSize = 10,
        comission = 2.6+0.6
      },
      SBERP =  {
        lotSize = 10,
        comission = 2.3+0.6
      },
      GAZP =  {
        lotSize = 10,
        comission = 2.15+0.6
      },
      VTBR =  {
        lotSize = 10,
        comission = 0.48+0.6
      },
      MGNT =  {
        lotSize = 1,
        comission = 0.48+0.6
      },
      AFLT =  {
        lotSize = 10,
        comission = 1.6+0.6
      },
      LKOH =  {
        lotSize = 10,
        comission = 6.4+0.6
      },
      RTS = {
        lotSize = 1,
        comission = 6.6+0.6
      }
    }

    self.futures = {}
    for k, v in pairs(StockCodes) do
      for i, sv in ipairs(v) do
        if sv ~= k then
          self.futures[sv] = futureSettings[k]
          self.futures[sv].stockCode = k
        end
      end
    end
  end
}).new()

function StockSettings:Get()
end

function StockSettings:GetFixedTrade(code, trade)
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
  local stockSetting = self.stocks[code]
  if stockSetting ~= nil then
    _trade.price = _trade.price * stockSetting.lotSize
  end
  stockSetting = self.futures[code]
  if stockSetting ~= nil then
    _trade.price = _trade.price / stockSetting.lotSize
    _trade.qty = _trade.qty * stockSetting.lotSize
  end
  return _trade;
end

function StockSettings:IsStock(code)
  return self.stocks[code] ~= nil
end

function StockSettings:IsFutures(code)
  return self.futures[code] ~= nil
end