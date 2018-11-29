(function()
  local CreateTable = function(resultsName)
    local valGetter = function(field)
      return function()
        local results = StockProcessor:Results(resultsName).Volumes
        local r = {}
        for i, v in ipairs(table.sortKeys(results)) do
          r[#r+1] = { val = results[v][field], color = nil }
        end
        return r
      end
    end
    local colums = {
      { name = 'Time', default = true, type = QTABLE_DATE_TYPE, width = 10, values = valGetter('time') },
      { name = 'Volume', default = true, type = QTABLE_INT_TYPE, width = 12, values = valGetter('volume') },
      { name = 'Spent', default = true, type = QTABLE_DOUBLE_TYPE, width = 14, values = valGetter('spent') },
      { name = 'Delta', default = true, type = QTABLE_DOUBLE_TYPE, width = 10, values = valGetter('moneyDelta') },
      { name = 'Price', default = true, type = QTABLE_DOUBLE_TYPE, width = 5, values = valGetter('price') },
  --    { name = '', default = true, type = '', width = '' },
    }
    Tables:Create(
      resultsName,
      colums,
      { height = 850, width = 260 }
    )
  end

  for i, v in ipairs({
      'Mgnt',
      'Aflt',
      'Vtbr',
      'Gazp',
      'Lkoh',
      'SberBankPrev',
      'SberBank'
  }) do
    CreateTable(v)
  end
end)()