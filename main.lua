if getScriptPath then _app_path = getScriptPath()..'\\' else _app_path = '' end
dofile(_app_path..'common.lua')

Codes = {
  SberBank = { 'SBER', 'SRZ8', 'SRH9', 'SRM9', 'SRU9' },
  SberBankPrev = { 'SBERP', 'SPZ8', 'SPH9', 'SPM9', 'SPU9' },
  Gazp = { 'GAZP', 'GZZ8', 'GZH9', 'GZM9', 'GZU9' },
  Lkoh = { 'LKOH', 'LKZ8', 'LKH9', 'LKM9', 'LKU9' },
  Vtbr = { 'VTBR', 'VBZ8', 'VBH9', 'VBM9', 'VBU9' },
  Aflt = { 'AFLT', 'AFZ8', 'AFH9', 'AFM9', 'AFU9' },
  Mgnt = { 'MGNT', 'MNZ8', 'MNH9', 'MNM9', 'MNU9' },
}

function OnInit(path)
  local codesArray = {}
  for k, v in pairs(Codes) do
    for _, cv in ipairs(v) do codesArray[#codesArray+1] = cv end
  end
  AllTradesContainer:Init(codesArray, { '20181128' })

  StockProcessor:Init(Codes)
  StockProcessor:SetProcessors({
    Volumes = Processors:Get('volumes', {
      period = 1000 * 100,--1 mins
      groups = Codes,
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
      groups = { SberBank = true, Gazp = true, Lkoh = true },
    })
  })
  StockProcessor:Calculate('20181128')
  local result = StockProcessor:Results('SberBank')
  local data = result.Volumes
  for k, v in ipairs(table.sortKeys(data)) do
    print(v..'='..table.tostring(data[v]))
  end
end

if getScriptPath == nil then Sandbox() end
