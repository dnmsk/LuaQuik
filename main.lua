if getScriptPath then _app_path = getScriptPath()..'\\' else _app_path = '' end
dofile(_app_path..'common.lua')
dofile(_app_path..'all_trades_container.lua')
dofile(_app_path..'stock_processor.lua')
dofile(_app_path..'stock_settings.lua')

function OnInit(path)
  AllTradesContainer:Init({
    'SBER', 'SBERP', 'GAZP', 'VTBR',
    'SRZ8', 'SPZ8', 'GZZ8', 'VBZ8',
    'SRH9', 'SPH9', 'GZH9', 'VBH9',
    'SRM9', 'SPM9', 'GZM9', 'VBM9',
    'SRU9', 'SPU9', 'GZU9', 'VBU9'
  })

  StockProcessor:Init({
    SberBank = { 'SBER', 'SRZ8', 'SRH9', 'SRM9', 'SRU9' }
  })
  IsRun = true
end

function OnStop(signal)
  IsRun = false
  Tables:dispose()
  AllTradesContainer:dispose()
  Logs:dispose()
end

function OnAllTrade(alltrade)
  AllTradesContainer:PushTrade(alltrade.sec_code, alltrade)
end

function main()
  local loopIndex = 0
  while IsRun do
    loopIndex = loopIndex + 1
    if loopIndex > 100000 then loopIndex = 0 end
    if loopIndex % 100 == 0 then StockProcessor:Calculate() end
    if loopIndex % 200 == 0 then AllTradesContainer:FlushBuffer() end
    sleep(50)
  end
end

function Sandbox()
  OnInit()
  StockProcessor:SetProcessors({
    Volumes = {
      period = 1000 * 100,--1 mins
      groups = { SberBank = true },
      groupFunc = function(code, prevData, trade)
        trade = StockSettings:GetFixedTrade(code, trade)
        local volume = trade.qty
        local moneyTrade = trade.qty * trade.price;
        if trade.flags == 0 then
          moneyTrade = -moneyTrade
          volume = -volume
        end
        prevData.money = (prevData.money or 0) + moneyTrade
        prevData.volume = (prevData.volume or 0) + volume
      end,
      resFunc = function(prevValue, curValue)
        return {
          money = (prevValue.money or 0) + curValue.money,
          volume = (prevValue.volume or 0) + curValue.volume
        }
      end
    }
  })
  StockProcessor:Calculate()
  local result = StockProcessor:Results('SberBank')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
end

if getScriptPath == nil then Sandbox() end
