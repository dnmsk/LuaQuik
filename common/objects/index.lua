Objects = {}

for i, v in ipairs({
  'indicator'
}) do
  DoFiles({{ 'common', 'objects', v..'.lua' }})
end
