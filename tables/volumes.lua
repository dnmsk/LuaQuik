(function()
  local valGetter = function(field)
    return function()
      local results = StockProcessor:Results('SberBank').Volumes
      local r = {}
      for i, v in ipairs(table.sortKeys(results)) do
        r[#r+1] = { val = results[v][field], color = nil }
      end
      return r
    end
  end
  local colums = {
    { name = 'Time', default = true, type = QTABLE_DATE_TYPE, width = 28, values = valGetter('time') },
    { name = 'Volume', default = true, type = QTABLE_INT_TYPE, width = 28, values = valGetter('volume') },
    { name = 'Money', default = true, type = QTABLE_DOUBLE_TYPE, width = 28, values = valGetter('money') },
--    { name = '', default = true, type = '', width = '' },
  }
  Tables:Create(
    'SBER',
    colums
  )
end)()