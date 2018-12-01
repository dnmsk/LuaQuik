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
  local data = {}
  for i, v in ipairs(split(parts[2], '|')) do
    local parts = split(v, ':')
    data[parts[1]] = parts[2]
  end
  return Indicator.new(parts[1], data)
end

function Indicator:ToString()
  local _pairs = {};
  for k, v in pairs(self.data) do
    _pairs[#_pairs+1] = k..':'..v
  end
  return table.concat({ self.name, table.concat(_pairs, '|') }, ';')
end

return Indicator
