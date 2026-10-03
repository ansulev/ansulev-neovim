-- Floating terminal on <C-\> (normal, insert and terminal mode).

vim.pack.add({ 'https://github.com/akinsho/toggleterm.nvim' }, { confirm = false })

require('toggleterm').setup({
  open_mapping = [[<C-\>]],
  direction = 'float',
})
