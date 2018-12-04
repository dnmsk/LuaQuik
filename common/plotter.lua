local Plotter = inheritsFrom(Class, {
  new = function(self, name, dsInfo, linesCount)
    self.name = name
    self.pointsData = {}
    self.dsInfo = dsInfo -- {interval = 1, sec_code = 'SBER'}
    self.linesCount = linesCount
    self.dsPeriod = _dsIntervalToPeriod(self.dsInfo.period)
  end
})

local redisInteraction = require('services/redis_interaction').new()

local function _dsIntervalToPeriod(dsInterval)
  if interval == 1 then return DateTime.new({ min = 1 }) end
  if interval == 2 then return DateTime.new({ min = 2 }) end
  if interval == 3 then return DateTime.new({ min = 3 }) end
  if interval == 4 then return DateTime.new({ min = 4 }) end
  if interval == 5 then return DateTime.new({ min = 5 }) end
  if interval == 6 then return DateTime.new({ min = 6 }) end
  if interval == 10 then return DateTime.new({ min = 10 }) end
  if interval == 15 then return DateTime.new({ min = 15 }) end
  if interval == 20 then return DateTime.new({ min = 20 }) end
  if interval == 30 then return DateTime.new({ min = 30 }) end
  if interval == 60 then return DateTime.new({ hour = 1 }) end
  if interval == 120 then return DateTime.new({ hour = 2 }) end
  if interval == 240 then return DateTime.new({ hour = 4 }) end
  if interval == -1 then return DateTime.new({ day = 1 }) end
  if interval == -2 then return DateTime.new({ day = 7 }) end
  if interval == -3 then return DateTime.new({ month = 1 }) end
end

local function _waitForData(checkData)
  local loopIndex = 0
  local data = nil
  while loopIndex < 5000 or data == nil do
    loopIndex = loopIndex + 1
    data = checkData()
  end
  return data
end

function Plotter:PrepareForQuikDate(quikDate)
  local dateTime = DateTime.FromQuik(quikDate)
  if pointsData[dateTime.DateNumber()] == nil then
    local indicator = Indicator.new(self.name, {
      period = self.dsPeriod.DateTimeNumber(),
      date = dateTime.DateNumber()
    })
    local dataResponse = _waitForData(function() 
      redisInteraction.Request(indicator)
    end) or {}
    local pointsDataForDate = {}
    self.pointsData[dateTime.DateNumber()] = pointsDataForDate
    for k, v in pairs(dataResponse) do
      pointsDataForDate[DateTime.FromStrings('', k):TimeNumber()] = tonumber(v)
    end
  end
  local datePointsData = pointsData[dateTime.DateNumber()]
  if datePointsData[dateTime:TimeNumber()] == nil then
  end
end