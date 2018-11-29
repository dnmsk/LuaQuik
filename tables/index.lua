if getScriptPath == nil then return end

Tables = Disposable:new({
  new = function(self)
    self.tables = {}
  end,

  Find = function(self, name)
    local tbl = self.tables[name]
    if tbl == nil then
      tbl = { id = AllocTable(), rows = {} }
      self.tables[name] = tbl
    end
    return tbl
  end,

  Create = function(self, name, columns, conf)
    if conf == nil then conf = {} end
    local tbl = self:Find(name)
    tbl.columns = columns
    for i, v in ipairs(columns) do
      local colId = AddColumn(tbl.id, i, v.name, v.default, v.type, v.width)
    end
    tbl.window = CreateWindow(tbl.id)
    SetWindowCaption(tbl.id, name)
    SetWindowPos(tbl.id, 90, 60, conf.width or 600, conf.height or 400)
  end,

  Update = function(self)
    for ti, tv in pairs(self.tables) do
      local t_id = tv.id
      for ci, cv in ipairs(tv.columns) do
        for ri, rv in ipairs(cv.values()) do
          local row = tv.rows[ri]
          if row == nil then
            tv.rows[ri] = InsertRow(t_id, ri)
          end
          local val = rv.val
          SetCell(t_id, ri, ci, tostring(val), val)
          local color = rv.color
          if color ~= nil then
            SetColor(t_id, ri, ci, color, RGB(0,0,0), color, RGB(0,0,0))
          end
        end
      end
    end
  end,

  dispose = function(self)
    for i, v in pairs(self.tables) do DestroyTable(v.id) end
  end
})

for i, v in ipairs({
  'volumes'
}) do
  if getScriptPath == nil then
    dofile(_app_path..'./tables/'..v..'.lua')
  else
    dofile(_app_path..'tables\\'..v..'.lua')
  end
end
