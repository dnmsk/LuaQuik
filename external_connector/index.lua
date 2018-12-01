local function isQuik()
  if getScriptPath then return true else return false end
end
if isQuik() then
  local script_path = "."
  script_path = getScriptPath()
  package.loadlib(getScriptPath()  .. "\\clibs\\lua51.dll", "main")
  package.path = package.path .. ";" .. script_path .. "\\?.lua;" .. script_path .. "\\?.luac"..";"..".\\?.lua;"..".\\?.luac"
  package.cpath = package.cpath .. ";" .. script_path .. '\\clibs\\?.dll'..";"..'.\\clibs\\?.dll'
end

local redis = require('external_connector/redis')

local externalConnector = {
  redis = redis.connect('127.0.0.1', 6379)
}

return externalConnector
