DateTime = inheritsFrom(Class, {
  new = function(self, stringDate, stringTime)
  --print('table..'..stringDate)
    self.stringDate  = stringDate or '00000000'
    self.stringTime = stringTime or '000000000'
  --[[
    self.year   = hash.year or 0
    self.month  = hash.month or 0
    self.day    = hash.day or 0
    self.hour   = hash.hour or 0
    self.min    = hash.min or 0
    self.sec    = hash.sec or 0
    self.ms     = hash.ms or 0
  --]]
  end
})

function DateTime.FromNumbers(numberDate, numberTime)
  numberDate = numberDate or '00000000'
  numberTime = numberTime or '000000000'
  return DateTime.new(numberDate..'', numberTime..'')
  --[[
  return DateTime.new({
    year   = math.floor(numberDate / 10000),
    month  = math.floor((numberDate % 10000) / 100),
    day    = math.floor(numberDate % 100),
    hour   = math.floor(numberTime / 10000000),
    min    = math.floor((numberTime % 10000000) / 100000),
    sec    = math.floor((numberTime % 100000) / 1000),
    ms     = math.floor(numberTime % 1000)
  })
  ]]
end

function DateTime.FromNumber(numberDateTime)
  return DateTime.FromNumbers(
    math.floor(numberDateTime / 1000000000),
    math.floor(numberDateTime % 1000000000)
  )
end

function DateTime.FromStrings(dateString, timeString)
  --return DateTime.FromNumbers(tonumber(dateString), tonumber(timeString))
  return DateTime.new(dateString, timeString)
end

function DateTime.FromQuik(quikDateTime)
  local month = quikDateTime.month
  local day = quikDateTime.day
  local hour = quikDateTime.hour
  local min = quikDateTime.min
  local sec = quikDateTime.sec or 0
  local ms = quikDateTime.ms or 0
  if month < 10 then month = '0'..month end
  if day < 10 then day = '0'..day end
  if hour < 10 then hour = '0'..hour end
  if min < 10 then min = '0'..min end
  if sec < 10 then sec = '0'..sec end
  if ms < 100 then
    if ms < 10 then ms = '00'..ms else ms = '0'..ms  end
  end
  return DateTime.new(
    quikDateTime.year..month..day,
    hour..min..sec..ms
  )
  --[[
  return DateTime.new({
    year = quikDateTime.year,
    month = quikDateTime.month,
    day = quikDateTime.day,
    hour = quikDateTime.hour,
    min = quikDateTime.min,
    sec = quikDateTime.sec,
    ms = quikDateTime.ms
  })
  ]]
end

function DateTime.Now()
  return DateTime.FromQuik(os.date('*t'))
end

function DateTime:DateNumber()
  return tonumber(self.stringDate)
--  if self._dateNumber == nil then
--    self._dateNumber = self.year * 10000 + self.month * 100 + self.day
--  end
--  return self._dateNumber
end

function DateTime:TimeNumber()
  return tonumber(self.stringTime)
--  if self._timeNumber == nil then
--    self._timeNumber = self.hour * 10000000 + self.min * 100000 + self.sec * 1000 + self.ms
--  end
--  return self._timeNumber
end

function DateTime:DateTimeNumber()
  return tonumber(self.stringDate..self.stringTime)
--  return self:DateNumber() * 1000000000 + self:TimeNumber()
end

function DateTime.Diff(dateTime1, dateTime2)
  return DateTime.new({
    year   = dateTime1.year - dateTime2.year,
    month  = dateTime1.month - dateTime2.month,
    day    = dateTime1.day - dateTime2.day,
    hour   = dateTime1.hour - dateTime2.hour,
    min    = dateTime1.min - dateTime2.min,
    sec    = dateTime1.sec - dateTime2.sec,
    ms     = dateTime1.ms - dateTime2.ms
  }):DateTimeNumber()
end

function DateTime:PeriodId(dateTimePeriod)
  return dateTimePeriod:DateTimeNumber() * math.floor(self:DateTimeNumber() / dateTimePeriod:DateTimeNumber())
--[[
  if dateTimePeriod.year > 0 then
    return dateTimePeriod.year * math.floor(self.year / dateTimePeriod.year) * 10000000000000
  end
  if dateTimePeriod.month > 0 then
    return self.year * 10000000000000
      + dateTimePeriod.month * math.floor(self.month / dateTimePeriod.month) * 100000000000
  end
  if dateTimePeriod.day > 0 then
    return self.year * 10000000000000 + self.month * 100000000000
      + dateTimePeriod.day * math.floor(self.day / dateTimePeriod.day) * 1000000000
  end
  if dateTimePeriod.hour > 0 then
    return self.year * 10000000000000 + self.month * 100000000000
      + self.day * 1000000000
      + dateTimePeriod.hour * math.floor(self.hour / dateTimePeriod.hour) * 10000000
  end
  if dateTimePeriod.min > 0 then
    return self.year * 10000000000000 + self.month * 100000000000
      + self.day * 1000000000 + self.hour * 10000000
      + dateTimePeriod.min * math.floor(self.min / dateTimePeriod.min) * 100000
  end
  if dateTimePeriod.sec > 0 then
    return self.year * 10000000000000 + self.month * 100000000000
      + self.day * 1000000000 + self.hour * 10000000 + self.min * 100000
      + dateTimePeriod.sec * math.floor(self.sec / dateTimePeriod.sec) * 1000
  end
  if dateTimePeriod.ms > 0 then
    return self.year * 10000000000000 + self.month * 100000000000
      + self.day * 1000000000 + self.hour * 10000000 + self.min * 100000
      + self.sec * 1000
      + dateTimePeriod.ms * math.floor(self.ms / dateTimePeriod.ms)
  end
]]
end