local logs = inheritsFrom(Disposable, {
  new = function(self)
    self.logFiles = {}
  end
}).new()

function logs:Write(logName, msg)
  local logFilePath = _app_path..'logs/'..logName..'_'..os.date('%x'):gsub('/', '-')..'.log'
  local logFile = self.logFiles[logFilePath]
  if logFile == nil then
    logFile = io.open(logFilePath, "a+")
    self.logFiles[logFilePath] = logFile
  end

  logFile:write(os.date('%X')..": ".. msg .. "\n")
  logFile:flush()
end

function logs:dispose()
  for i, v in ipairs(self.logFiles) do v:close() end
end

return logs
