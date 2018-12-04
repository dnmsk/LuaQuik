if getScriptPath ~= nil then
  _app_path = getWorkingFolder()..'\\lua\\my\\'
  dofile(_app_path..'common\\index.lua')
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

local Instances = require('instances/index')

function OnInit(path)
  local codesArray = {}
  for k, v in pairs(StockCodes) do
    for _, cv in ipairs(v) do codesArray[#codesArray+1] = cv end
  end
  Instances.AllTradesContainer:Init(codesArray)

  Instances.StockProcessor:Init(StockCodes)
  Instances.StockProcessor:SetProcessors({
    Volumes = Instances.Processors:Get('volumes', {
      period = DateTime.new({ min = 1 }),
      groups = StockCodes,
    })
  })
  IsRun = true
end

function OnStop(signal)
  IsRun = false
  Instances.Tables:dispose()
  Instances.AllTradesContainer:dispose()
  Logs:dispose()
end

function OnAllTrade(alltrade)
  Instances.AllTradesContainer:PushTrade(alltrade.sec_code, alltrade)
end

function main()
  local loopIndex = 0
  Instances.StockProcessor:Calculate()
  Instances.Tables:Create()
  while IsRun do
    loopIndex = loopIndex + 1
    if loopIndex > 60000 then loopIndex = 0 end
    if loopIndex % 10 == 0 then Instances.ProcessInteraction:Watch() end
    if loopIndex % 500 == 0 then Instances.Tables:Update() end
    if loopIndex % 1000 == 0 then Instances.StockProcessor:Calculate() end
    if loopIndex % 20000 == 0 then Instances.AllTradesContainer:FlushBuffer() end
    delay(1)
  end
end

function Sandbox()
  OnInit()
  Instances.StockProcessor:SetProcessors({
    Volumes = Instances.Processors:Get('volumes', {
      period = DateTime.new({ min = 1 }),
      groups = StockCodes,
    })
  })
  Instances.StockProcessor:Calculate('20181128')
  local result = Instances.StockProcessor:Results('SBER')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
  Logs:Write('test', os.date())
end

if getScriptPath == nil then Sandbox() end
