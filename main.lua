if getScriptPath then _app_path = getScriptPath()..'\\' else _app_path = '' end
dofile(_app_path..'common.lua')
dofile(_app_path..'all_trades_container.lua')

function OnInit(path)
  AllTradesContainer:Init({
    'SBER', 'SBERP', 'GAZP', 'VTBR',
    'SRZ8', 'SPZ8', 'GZZ8', 'VBZ8',
    'SRH9', 'SPH9', 'GZH9', 'VBH9',
    'SRM9', 'SPM9', 'GZM9', 'VBM9',
    'SRU9', 'SPU9', 'GZU9', 'VBU9'
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
    if loopIndex % 200 == 0 then AllTradesContainer:FlushBuffer() end
    sleep(50)
  end
end
