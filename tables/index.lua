Tables = inheritsFrom(Disposable, {
  new = function(self)
    self.tables = {}
    self.needCreate = {}
  end
}).new()

function Tables:Find(name)
  local tbl = self.tables[name]
  if tbl == nil then
    tbl = { id = AllocTable(), rows = {} }
    self.tables[name] = tbl
  end
  return tbl
end

function Tables:Append(name, columns, conf)
  if self.tables.name == nil then
    self.needCreate[name] = { columns = columns, conf = conf or {} }
  end
end

function Tables:Create()
  local tbls = self.needCreate
  self.needCreate = {}

  for k, v in pairs(tbls) do
    local tbl = self:Find(k)
    tbl.columns = v.columns
    for i, v in ipairs(v.columns) do
      local colId = AddColumn(tbl.id, i, v.name, v.default, v.type, v.width)
    end
    tbl.window = CreateWindow(tbl.id)
    SetWindowCaption(tbl.id, k)
    SetWindowPos(tbl.id, v.conf.posX or 90, v.conf.posY or 60, v.conf.width or 600, v.conf.height or 400)
  end
end

function Tables:Update(force)
  Logs:Write('Table', 'Tables:Update call')
  for ti, tv in pairs(self.tables) do
    local t_id = tv.id
    for ci, cv in ipairs(tv.columns) do
      local values = cv.values()
      for ri, rv in ipairs(values) do
        if true or ri > (#values - 5) then
          local cellVal = rv.val
          local row = tv.rows[ri]
          if row == nil then
            tv.rows[ri] = InsertRow(t_id, ri)
          end
          SetCell(t_id, ri, ci, tostring(cellVal), cellVal)
          local color = rv.color
          if color ~= nil then
            SetColor(t_id, ri, ci, color, RGB(0,0,0), color, RGB(0,0,0))
          end
        end
      end
    end
  end
end

function Tables:dispose()
  for i, v in pairs(self.tables) do DestroyTable(v.id) end
end

for i, v in ipairs({
  'volumes'
}) do
  DoFiles({{ 'tables', v..'.lua' }})
end
