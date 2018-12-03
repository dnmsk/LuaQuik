if getWorkingFolder ~= nil then
  _app_path = getWorkingFolder()..'\\lua\\my\\'
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

Settings={}
Settings.period = 666
Settings.Name = "Volumes"

function CreateIndicator()
  dofile(_app_path..'common\\index.lua')

  Indicator = inheritsFrom(Class, {
    new = function(self, dsInfo)
      self.dsInfo = dsInfo
    end,
  })

  function Indicator:Draw(index)
    Logs:Write('Volume Indicator', index..'_'..table.tostring(T(index)))

  end
end

function Init()
  CreateIndicator()

  _Indicator = Indicator.new(getDataSourceInfo())
  Settings.line = {}
  for i = 1, 100 do
    Settings.line[i] = {}
    Settings.line[i] = {Color = RGB(128, 128, 128), Type = TYPE_LINE, Width = 0,1}
  end

  Logs:Write('Volume Indicator', 'Init')
  Logs:Write('Volume Indicator', table.tostring(_Indicator.dsInfo))
  return 1
end

function OnCalculate(index)
  return _Indicator:Draw(index)
end