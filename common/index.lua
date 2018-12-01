function inheritsFrom( baseClass, static )
  static = static or {}
  local new_class = {}
  local class_mt = { __index = new_class }

  function new_class.new(...)
    local newinst = {}
    if static.new ~= nil then
      static.new(newinst, ...)
    end
    setmetatable(newinst, class_mt)
    return newinst
  end
  if baseClass then
    setmetatable( new_class, { __index = baseClass } )
  end
  return new_class
end

Object = { _Type = 'object' }
Class = inheritsFrom(Object)
Disposable = inheritsFrom(Class)

function Disposable:dispose()
  self.dispose(self)
end

Logs = Disposable.new({
  new = function(self)
    self.logFiles = {}
  end,
  Write = function(self, logName, msg)
    local logFilePath = _app_path..'logs/'..logName..'_'..os.date('%x'):gsub('/', '-')..'.log'
    local logFile = self.logFiles[logFilePath]
    if logFile == nil then
      logFile = io.open(logFilePath, "a+")
      self.logFiles[logFilePath] = logFile
    end

    logFile:write(os.date('%X')..": ".. msg .. ";\n")
    logFile:flush()
  end,
  dispose = function(self)
    for i, v in ipairs(self.logFiles) do v:close() end
  end
})

--- Sleep that always works
function delay(msec)
    if sleep then
        pcall(sleep, msec)
    else
        pcall(socket.select, nil, nil, msec / 1000)
    end
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[#t+1] = str
  end
  return t
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{\n" .. table.concat( result, ",\n" ) .. "}"
end

function table.sortKeys(tbl)
  --if tbl == nil then tbl = {} end
  local tkeys = {}
  for k in pairs(tbl) do table.insert(tkeys, k) end

  table.sort(tkeys)
  return tkeys
end

function table.average(tbl)
  if #tbl == 0 then return 0 end
  local sum = 0
  for i in ipairs(tbl) do
    sum = sum + tbl[i]
  end
  return sum / #tbl
end

-- удаление точки и нулей после нее
function removeZero(str)
    while (string.sub(str,-1) == "0" and str ~= "0") do
    str = string.sub(str,1,-2)
    end
    if (string.sub(str,-1) == ".") then 
    str = string.sub(str,1,-2)
    end 
    return str
end

function DoFiles(files)
  local start = './'
  local delim = '/'
  if getScriptPath ~= nil then
    start = ''
    delim = '\\'
  end
  for i in ipairs(files) do
    local file = files[i]
    if #file == 1 then
      dofile(_app_path..file[#file])
    else
      dofile(_app_path..start..table.concat(files[i], delim))
    end
  end
end

DoFiles({
  { 'stock_settings.lua' },
  { 'external_connector', 'index.lua' },
})
