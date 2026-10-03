-- mini.nvim: one dependency-free repo for picker, file explorer, key hints, statusline,
-- tabline, git, diff, pairs, surround and text objects.

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' }, { confirm = false })

require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.tabline').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.ai').setup()
require('mini.git').setup()
require('mini.diff').setup()
require('mini.files').setup({ options = { use_as_default_explorer = true } })
require('mini.pick').setup()
require('mini.extra').setup()

local map = vim.keymap.set

-- Enter: accept a selected completion, close an unselected menu, else mini.pairs' smart newline.
local key = function(k) return vim.api.nvim_replace_termcodes(k, true, true, true) end
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 0 then return require('mini.pairs').cr() end
  return vim.fn.complete_info({ 'selected' }).selected ~= -1 and key('<C-y>') or key('<C-e><CR>')
end, { expr = true, replace_keycodes = false, desc = 'Accept completion or newline' })

local pick, extra = require('mini.pick').builtin, require('mini.extra').pickers
map('n', '<leader>ff', pick.files, { desc = 'Find files' })
map('n', '<leader>fg', pick.grep_live, { desc = 'Grep (live)' })
map('n', '<leader>fb', pick.buffers, { desc = 'Buffers' })
map('n', '<leader>fh', pick.help, { desc = 'Help' })
map('n', '<leader>fr', pick.resume, { desc = 'Resume last picker' })
map('n', '<leader>fd', extra.diagnostic, { desc = 'Diagnostics' })
map('n', '<leader>fs', function() extra.lsp({ scope = 'document_symbol' }) end, { desc = 'Symbols' })
map('n', '<leader>fo', extra.oldfiles, { desc = 'Recent files' })
map('n', '<leader>e', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end,
  { desc = 'File explorer' })
map('n', '<leader>gd', function() require('mini.diff').toggle_overlay(0) end, { desc = 'Git diff overlay' })

local clue = require('mini.clue')
clue.setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' }, { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' }, { mode = 'x', keys = 'g' },
    { mode = 'n', keys = '[' }, { mode = 'n', keys = ']' },
    { mode = 'n', keys = '<C-w>' }, { mode = 'n', keys = 'z' },
    { mode = 'n', keys = "'" }, { mode = 'n', keys = '`' }, { mode = 'n', keys = '"' },
    { mode = 'i', keys = '<C-r>' }, { mode = 'i', keys = '<C-x>' },
  },
  clues = {
    { mode = 'n', keys = '<Leader>a', desc = '+AI' },
    { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
    { mode = 'n', keys = '<Leader>c', desc = '+Code' },
    { mode = 'n', keys = '<Leader>f', desc = '+Find' },
    { mode = 'n', keys = '<Leader>g', desc = '+Git' },
    clue.gen_clues.builtin_completion(), clue.gen_clues.g(), clue.gen_clues.marks(),
    clue.gen_clues.registers(), clue.gen_clues.windows(), clue.gen_clues.z(),
  },
  window = { delay = 300 },
})
