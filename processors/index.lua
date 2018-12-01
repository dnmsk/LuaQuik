DoFiles({{ 'common', 'stock_processor.lua' }})

Processors = Class:new({
  new = function(self)
    self.container = {}
  end,
  Add = function(self, name, func)
    -- func = { groupFunc: ->(){}, resFunc: ->(){} }
    self.container[name] = func
  end,
  Get = function(self, name, conf)
    -- conf = { period: 'milliseconds', groups: { ['StockProcessorroups'] } }
    if conf == nil then conf = {} end
    local func = self.container[name]
    for k, v in pairs(conf) do
      func[k] = v
    end
    return func
  end
})

for i, v in ipairs({
  'volumes'
}) do
  DoFiles({{ 'processors', v..'.lua' }})
end
