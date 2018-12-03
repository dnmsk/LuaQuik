local Indicator = inheritsFrom(Class, {
  new = function(self, name, data)
    self.data = data
    self.name = name
  end
})

function Indicator.Type()
  return 'Indicator'
end

function Indicator:Name()
  return self.name
end

function Indicator.FromString(strData)
  local parts = split(strData, ';')
  return Indicator.new(parts[1], Indicator.Deserilaize(parts[2]))
end

function Indicator.Deserilaize(strData)
  local data = {}
  for i, v in ipairs(split(strData, '|')) do
    local parts = split(v, ':')
    data[parts[1]] = parts[2]
  end
  return data
end

function Indicator.Serialize(tbl)
  local _pairs = {}
  for k, v in pairs(tbl) do
    _pairs[#_pairs+1] = k..':'..v
  end
  return table.concat(_pairs, '|')
end

function Indicator:ToString()
  return table.concat({ self.name, Indicator.Serialize(self.data) }, ';')
end

return Indicator
