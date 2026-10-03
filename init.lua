-- ansulev-neovim — Neovim 0.12+ IDE config. Core here; plugins live in plugin/*.lua
-- (sourced automatically, in name order, after this file).

vim.loader.enable()
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Providers off: nothing here needs them, and :checkhealth stays clean.
for _, p in ipairs { 'node', 'perl', 'python3', 'ruby' } do
  vim.g['loaded_' .. p .. '_provider'] = 0
end

-- [[ Options ]]
local o = vim.o
o.number, o.relativenumber = true, true
o.mouse = 'a'
o.undofile = true
o.ignorecase, o.smartcase = true, true
o.signcolumn = 'yes'
o.updatetime = 200
o.timeoutlen = 400
o.splitright, o.splitbelow = true, true
o.scrolloff = 8
o.cursorline = true
o.confirm = true
o.inccommand = 'split'
o.breakindent = true
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.expandtab, o.shiftwidth, o.tabstop = true, 2, 2
o.winborder = 'rounded'
o.foldenable = false -- folds exist (treesitter), start open
o.showmode = false -- the statusline shows it
vim.schedule(function() o.clipboard = 'unnamedplus' end) -- deferred: clipboard probe is slow

-- Native completion (0.12): popup as you type. LSP feeds it through 'omnifunc' ("o").
o.autocomplete = true
o.complete = 'o^10,.^5,w^5,b^5,u^5'
o.completeopt = 'menuone,noselect,popup,fuzzy'

-- [[ Keymaps ]]
local map = vim.keymap.set
map('i', 'jk', '<Esc>', { desc = 'Escape' })
map({ 'n', 'i', 'x', 's' }, '<C-s>', '<Cmd>write<CR><Esc>', { desc = 'Save file' })
map('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('x', '<', '<gv', { desc = 'Indent left, keep selection' })
map('x', '>', '>gv', { desc = 'Indent right, keep selection' })
map('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Buffer delete' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })
map('n', '<leader>u', '<Cmd>packadd nvim.undotree | Undotree<CR>', { desc = 'Undo tree' })
for _, k in ipairs { 'h', 'j', 'k', 'l' } do
  map('n', '<C-' .. k .. '>', '<C-w>' .. k, { desc = 'Window ' .. k })
end

-- Completion menu: Tab/S-Tab move (Enter is mapped with mini.pairs, plugin/30-mini.lua).
local pum = function(yes, no)
  return function() return vim.fn.pumvisible() == 1 and yes or no end
end
map('i', '<Tab>', pum('<C-n>', '<Tab>'), { expr = true, desc = 'Next completion' })
map('i', '<S-Tab>', pum('<C-p>', '<S-Tab>'), { expr = true, desc = 'Previous completion' })

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('ansulev-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- [[ Colorscheme ]]
-- `theme-switch` writes colors/current.vim (gitignored). Fall back to a built-in scheme.
if not pcall(vim.cmd.colorscheme, 'current') then vim.cmd.colorscheme 'habamax' end
