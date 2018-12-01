(function()
  local positions = {
    SBER = 0,
    SBERP = 1,
    VTBR = 2,
    RTS = 3,
    GAZP = 4,
    LKOH = 5,
    AFLT = 6,
    MGNT = 7
  }
  local width = 272
  local AppendTable = function(code)
    local valGetter = function(field)
      return function()
        local results = StockProcessor:Results(code).Volumes
        local r = {}
        for i, v in ipairs(table.sortKeys(results)) do
          r[#r+1] = { val = results[v][field], color = nil }
        end
        return r
      end
    end
    local colums = {
      { name = 'Time', default = true, type = QTABLE_DATE_TYPE, width = 5.8, values = valGetter('time') },
      { name = 'Volume', default = true, type = QTABLE_INT_TYPE, width = 9, values = valGetter('volume') },
      { name = 'Spent', default = true, type = QTABLE_DOUBLE_TYPE, width = 12, values = valGetter('spent') },
      { name = 'Delta', default = true, type = QTABLE_DOUBLE_TYPE, width = 11, values = valGetter('moneyDelta') },
      { name = 'Price', default = true, type = QTABLE_DOUBLE_TYPE, width = 7, values = valGetter('price') },
    }
    Tables:Append(
      code,
      colums,
      { height = 850, width = width, posX = (positions[code] or 6) * width, posY = 0 }
    )
  end

  for k, v in pairs(StockCodes) do
    AppendTable(k)
  end
end)()