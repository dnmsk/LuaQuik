if getScriptPath then
  _app_path = getScriptPath()..'\\'
  dofile(_app_path..'common\\index.lua')
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

local json = require (_app_path..'dkjson')

function main()
  local client = require('external_connector/index').http
  local body, code, header = client.request('http://192.168.0.75:82/grouped_data/volumes?seccode=sber')
  print(body)
  print(code)
  print(table.tostring(header))
  print(table.tostring(json.decode(body, 1, nil)['Aggregate']))
end

function main1()
  local Indicator = require('common/objects/indicator')
  local indicator = Indicator.new('Volumes', { key = 'value11' })
  local RedisInteraction = require('services/redis_interaction')
  local redis_interaction = RedisInteraction.new()
  local requestResult = redis_interaction.Request(indicator)
  redis_interaction:AddWatch(indicator, function(_indicator)
    return Indicator.new('Volumes', { key = 'response_'.._indicator.data.key })
  end)
  redis_interaction:Watch()
  requestResult = redis_interaction.Request(indicator)
end

function main2()
  local client = require('external_connector/index').redis
  local keys = client:keys('*')
  print(table.tostring(keys))
  print(client:get('QUIK:Indicator:Request:Volumes'))
end

--if getScriptPath == nil then main1() end

--main()
local p = {}
print(p[''])
