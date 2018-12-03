local Processors = inheritsFrom(Class, {
  new = function(self)
    self.container = {}
  end
}).new()

function Processors:Add(name, func)
  -- func = { groupFunc: ->(){}, resFunc: ->(){} }
  self.container[name] = func
end

function Processors:Get(name, conf)
  -- conf = { period: 'milliseconds', groups: { ['StockProcessorroups'] } }
  if conf == nil then conf = {} end
  local func = self.container[name]
  for k, v in pairs(conf) do
    func[k] = v
  end
  return func
end

for i, v in ipairs({
  'volumes'
}) do
  local processor = require('processors/'..v)
  Processors:Add(v, processor)
end

return Processors
