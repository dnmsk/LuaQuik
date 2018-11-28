if getScriptPath then _app_path = getScriptPath()..'\\' else _app_path = '' end
dofile(_app_path..'common.lua')
dofile(_app_path..'all_trades_container.lua')
dofile(_app_path..'stock_processor.lua')
dofile(_app_path..'stock_settings.lua')
if getScriptPath == nil then
  dofile(_app_path..'./processors/index.lua')
  dofile(_app_path..'./tables/index.lua')
else
  dofile(_app_path..'processors\\index.lua')
  dofile(_app_path..'tables\\index.lua')
end

function OnInit(path)
  AllTradesContainer:Init({
    'SBER', 'SBERP', 'GAZP', 'VTBR', 'LKOH', 'AFLT', 'MGNT',
    'SRZ8', 'SPZ8', 'GZZ8', 'VBZ8', 'LKZ8', 'AFZ8', 'MNZ8',
    'SRH9', 'SPH9', 'GZH9', 'VBH9', 'LKH9', 'AFH9', 'MNH9',
    'SRM9', 'SPM9', 'GZM9', 'VBM9', 'LKM9', 'AFM9', 'MNM9',
    'SRU9', 'SPU9', 'GZU9', 'VBU9', 'LKU9', 'AFU9', 'MNU9'
  })

  StockProcessor:Init({
    SberBank = { 'SBER', 'SRZ8', 'SRH9', 'SRM9', 'SRU9' }
  })
  StockProcessor:SetProcessors({
    Volumes = Processors:Get('volumes', {
      period = 1000 * 100,--1 mins
      groups = { SberBank = true },
    })
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
  StockProcessor:Calculate()
  while IsRun do
    loopIndex = loopIndex + 1
    if loopIndex > 100000 then loopIndex = 0 end
    if loopIndex % 10 == 0 then Tables:Update() end
    if loopIndex % 100 == 0 then StockProcessor:Calculate() end
    if loopIndex % 200 == 0 then AllTradesContainer:FlushBuffer() end
    sleep(50)
  end
end

function Sandbox()
  local t = os.time()

  OnInit()
  StockProcessor:SetProcessors({
    Volumes = Processors:Get('volumes', {
      period = 1000 * 100,--1 mins
      groups = { SberBank = true },
    })
  })
  StockProcessor:Calculate()
  local result = StockProcessor:Results('SberBank')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
end

if getScriptPath == nil then Sandbox() end

