if getScriptPath then
  _app_path = getScriptPath()..'\\'
  dofile(_app_path..'common\\index.lua')
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

function main()
  local client = require('external_connector/index').redis

  local t = os.time()

  local nrk = '--'
  local nobody = '--'
  local loops = 10000
  for i=1, loops do
    client:set('usr:nrk', 10)
    client:set('usr:nobody', 5)
    nrk = client:get('usr:nrk') 
    nobody = client:get('usr:nobody') 
  end

  Logs:Write('Sandbox', nrk)
  Logs:Write('Sandbox', nobody)
  local diff = os.difftime(os.time(), t)
  Logs:Write('Sandbox', diff)
  Logs:Write('Sandbox', diff/loops)
end

if getScriptPath == nil then main() end
