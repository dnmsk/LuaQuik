if getScriptPath then _app_path = getScriptPath()..'\\' else _app_path = '' end
dofile(_app_path..'common.lua')

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
  while IsRun do
    loopIndex = loopIndex + 1
    if loopIndex > 100000 then loopIndex = 0 end
    if loopIndex % 10 == 0 then Tables:Update() end
    if loopIndex % 20 == 0 then StockProcessor:Calculate() end
    if loopIndex % 200 == 0 then AllTradesContainer:FlushBuffer() end
    sleep(50)
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
  StockProcessor:Calculate()
  local result = StockProcessor:Results('SBER')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
end

if getScriptPath == nil then Sandbox() end
