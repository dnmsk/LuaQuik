(function()
  local client = require('external_connector\\index').http
  local json = require ('_packages\\dkjson')

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
  local width = 300
  local AppendTable = function(code)
    local resultGetter = function()
      local body, code, header = client.request('http://192.168.0.75:82/grouped_data/volumes?seccode='..code)
      local aggragates = json.decode(body, 1, nil)['Aggregate']
      local r = {}
      for k, v in pairs(aggragates) do
        r[tonumber(k)] = v
      end
      return r
    end
    local valGetter = function(field)
      return function(results)
        local r = {}
        for i, v in ipairs(table.sortKeys(results)) do
          if field == 'time' then
            r[#r+1] = { val = v, color = nil }
          else
            r[#r+1] = { val = math.floor(100 * results[v][field]) / 100, color = nil }
          end
        end
        return r
      end
    end
    local colums = {
      { name = 'Time', default = true, type = QTABLE_DATE_TYPE, width = 5.8, values = valGetter('time') },
      { name = 'Price', default = true, type = QTABLE_DOUBLE_TYPE, width = 8, values = valGetter('Price') },
      { name = 'AvgPrice', default = true, type = QTABLE_DOUBLE_TYPE, width = 8, values = valGetter('AvgPrice') },
      { name = 'Volume', default = true, type = QTABLE_INT_TYPE, width = 12, values = valGetter('Qty') },
      { name = 'Spent', default = true, type = QTABLE_DOUBLE_TYPE, width = 14, values = valGetter('Spent') },
    }
    Tables:Append(
      code,
      colums,
      resultGetter,
      { height = 850, width = width, posX = (positions[code] or 6) * width, posY = 0 }
    )
  end
--StockCodes
  for k, v in ipairs({ 'SBER', 'RTS', 'LKOH' }) do
    AppendTable(v)
  end
end)()

--[==[
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
      { name = 'Volume', default = true, type = QTABLE_INT_TYPE, width = 10, values = valGetter('volume') },
      { name = 'Delta', default = true, type = QTABLE_DOUBLE_TYPE, width = 12, values = valGetter('moneyDelta') },
      { name = 'AvgPrice', default = true, type = QTABLE_DOUBLE_TYPE, width = 6, values = valGetter('avgPrice') },
      { name = 'Spent', default = true, type = QTABLE_DOUBLE_TYPE, width = 13, values = valGetter('spent') },
      { name = 'Price', default = true, type = QTABLE_DOUBLE_TYPE, width = 8, values = valGetter('price') },
    }
    Tables:Append(
      code,
      colums,
      { height = 850, width = width, posX = (positions[code] or 6) * width, posY = 0 }
    )
  end
--StockCodes
  for k, v in ipairs({ 'SBER', 'RTS', 'LKOH' }) do
    AppendTable(v)
  end
end)()
--]==]