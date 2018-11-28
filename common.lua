
-- Create a new class that inherits from a base class
--
function inheritsFrom( baseClass )

    -- The following lines are equivalent to the SimpleClass example:

    -- Create the table and metatable representing the class.
    local new_class = {}
    local class_mt = { __index = new_class }

    -- Note that this function uses class_mt as an upvalue, so every instance
    -- of the class will share the same metatable.
    --
    function new_class:new(hash)
        local newinst = hash or {}
        setmetatable(newinst, class_mt)
        if newinst.new then
          newinst.new(newinst)
        end
        return newinst
    end

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    return new_class
end

Object = {}
Class = inheritsFrom(Object)
Disposable = inheritsFrom(Class)

function Disposable:dispose()
  self.dispose(self)
end

Logs = Disposable:new({
  new = function(self)
    self.logFiles = {}
  end,
  Write = function(self, logName, msg)
    local logFilePath = _app_path..'logs/'..logName..'_'..os.date('%x'):gsub('/', '-')..'.txt'
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

Tables = Disposable:new({
  new = function(self)
    self.tables = {}
  end,

  Find = function(self, name)
    local table = self.tables[name]
    if table == nil then
      table = { id = AllocTable() }
      self.tables[name] = table
      table['window'] = CreateWindow(table['id'])
      SetWindowCaption(table['id'], name)
      SetWindowPos(table['id'], 90, 60, 600, 400)
    end
    return table
  end,

  CreateTable = function(self, name, columns)
    local table = self:Find(self, name)
    table['columns'] = columns
    local id = table['id']
    for i, v in ipairs(columns) do
      AddColumn(id, i, v['name'], v['default'], v['type'], v['width'])
    end
  end,

  update = function(self)
    for ti, tv in ipairs(self.tables) do
      local t_id = tv['id']
      for ci, cv in ipairs(tv['columns']) do
        for ri, rv in ipairs(cv['values']()) do
          local val = rv['val']
          SetCell(t_id, ri, ci, tostring(val), val)
          local color = rv['color']
          if color ~= nil then
            SetColor(t_id, ri, ci, color, RGB(0,0,0), color, RGB(0,0,0))
          end
        end
      end
    end
  end,

  dispose = function(self)
    for i, v in ipairs(self.tables) do DestroyTable(v) end
  end
})

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
  return "{" .. table.concat( result, "," ) .. "}"
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