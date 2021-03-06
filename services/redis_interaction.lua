local RedisInteraction = inheritsFrom(Class, {
  new = function(self)
    self.watches = {}
  end
})
local _keyDelimeter = ':'
local _redisPrefix = 'QUIK'.._keyDelimeter
local client = require('external_connector/index').redis

function RedisInteraction.Request(object)
  local k = _redisPrefix..object.Type()
  local options = { watch = k, cas = true, retry = 2 }
  local result = nil

  local responseKey = k..':Response:'..object:Name()
  local val = client:get(responseKey)
  if val ~= nil then
    result = object.Deserilaize(val)
    client:del(responseKey)
  else
    local requestKey = k..':Request:'..object:Name()
    local val = client:get(requestKey)
    if val == nil then
      client:set(requestKey, object:ToString())
    end
  end

  return result
end

function RedisInteraction:AddWatch(object, onRequest)
  local key = object.Type()
  if self.watches[key] == nil then self.watches[key] = {} end
  if self.watches[key][object.Type()] ~= nil then return nil end

  local setting = { ctor = object, onRequest = onRequest }
  self.watches[key][object:Name()] = setting
end

function RedisInteraction:Watch(object)
  for key, watches in pairs(self.watches) do
    local keys = client:keys(_redisPrefix..key..':Request:*')

    for i, v in ipairs(keys) do
      local splittedKey = split(v, _keyDelimeter)
      local name = splittedKey[#splittedKey]
      local processor = watches[name]

      if processor ~= nil then
        local val = client:get(v)
        local response = processor.onRequest(processor.ctor.FromString(val))
        client:set(_redisPrefix..object.Type()..':Response:'..name, response:ToString())
        client:del(v)
      end
    end
  end
end

return RedisInteraction
