if getScriptPath then
  _app_path = getScriptPath()..'\\'
  dofile(_app_path..'common\\index.lua')
  DoFiles({{'external_connector', 'index.lua'}})
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

DoFiles({
  { 'common', 'all_trades_container.lua' },
  { 'processors', 'index.lua' },
  { 'tables', 'index.lua' },
})

function OnInit(path)
  local codesArray = {}
  for k, v in pairs(StockCodes) do
    for _, cv in ipairs(v) do codesArray[#codesArray+1] = cv end
  end
  AllTradesContainer:Init(codesArray)

  StockProcessor:Init(StockCodes)
  StockProcessor:SetProcessors({
    Volumes = Processors:Get('volumes', {
      period = 1000 * 100,--1 mins
      groups = StockCodes,
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
  Tables:Create()
  while IsRun do
    --connector.checkForConnection()
    loopIndex = loopIndex + 1
    if loopIndex > 60000 then loopIndex = 0 end
    if loopIndex % 1000 == 0 then Tables:Update() end
    if loopIndex % 2000 == 0 then StockProcessor:Calculate() end
    if loopIndex % 20000 == 0 then AllTradesContainer:FlushBuffer() end
    delay(1)
  end
end

function Sandbox()
  OnInit()
  StockProcessor:SetProcessors({
    Volumes = Processors:Get('volumes', {
      period = 1000 * 100,--1 mins
      groups = StockCodes,
    })
  })
  StockProcessor:Calculate('20181128')
  local result = StockProcessor:Results('SBER')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
end

if getScriptPath == nil then Sandbox() end
