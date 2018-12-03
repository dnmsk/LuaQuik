StockProcessor = inheritsFrom(Class, {
  new = function(self)
    self.codeGroups = {}
    self.codeGroupsResults = {}
    self.processors = {}
  end
}).new()

function StockProcessor:Init(codeGroups)
  for i, v in pairs(codeGroups) do
    self.codeGroups[i] = {
      codes = v
    }
  end
end

function StockProcessor:SetProcessors(processors)
  for i, v in pairs(processors) do
    self.processors[i] = {
      groupFunc = v.groupFunc,
      resFunc = v.resFunc,
      period = v.period,
      groups = v.groups
    }
  end
end

function StockProcessor:Calculate(date)
  if date == nil then date = tonumber(os.date('%Y%m%d')) end
  for pi, pv in pairs(self.processors) do
    for ci, cv in pairs(self.codeGroups) do
      if pv.groups[ci] ~= nil then
        local data = cv[pi]
        if data == nil then
          data = { data = {}, lastChecked = 0 }
          cv[pi] = data
        end
        local minTime = math.floor(data.lastChecked - pv.period:DateTimeNumber() * 4)
        for k, v in pairs(data.data) do
          if k >= minTime then
            data.data[k] = {}
          end
        end
        for i, v in pairs(cv.codes) do
          local trades = AllTradesContainer:Trades(v, date)
          for ti, tv in pairs(trades) do
            local tradeTime = tv.datetime:DateTimeNumber()
            if tradeTime >= minTime or tradeTime > data.lastChecked then
              local periodId = tv.datetime:PeriodId(pv.period)
              local dataPeriod = data.data[periodId]
              if dataPeriod == nil then dataPeriod = {} end

              data.data[periodId] = pv.groupFunc(v, periodId, dataPeriod, tv)
            end
          end
        end
        if data.lastChecked < minTime then data.lastChecked = minTime end
      end
    end
  end
end

function StockProcessor:Results(codeGroup)
  local groupResult = self.codeGroups[codeGroup]
  local r = self.codeGroupsResults[codeGroup]
  if r == nil or os.difftime(os.time(), r.since) >= 1 then
    local result = {}
    for k, v in pairs(self.processors) do
      local data = groupResult[k]
      if data ~= nil then
        local r = {}
        local prevVal = {}
        for ri, rv in ipairs(table.sortKeys(data.data)) do
          local val = data.data[rv]
          r[rv] = v.resFunc(prevVal, val)
          prevVal = r[rv]
        end
        result[k] = r
      end
    end
    r = { since = os.time(), data = result }
    self.codeGroupsResults[codeGroup] = r
  end
  return r.data
end

return StockProcessor
