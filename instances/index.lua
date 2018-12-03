DoFiles({
  { 'common', 'all_trades_container.lua' },
  { 'processors', 'stock_processor.lua' },
  { 'tables', 'index.lua' },
})

local instances = {
  AllTradesContainer = AllTradesContainer,
  StockProcessor = StockProcessor,
  Processors = require('processors/index'),
  Tables = Tables,
  ProcessInteraction = require('instances/process_interaction')
}

return instances
