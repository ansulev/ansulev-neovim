-- Treesitter: parsers from nvim-treesitter (main branch, needs `tree-sitter` CLI + a C compiler).
-- Highlight and folds are Neovim's own, switched on per buffer below.

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('ansulev-ts-update', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      vim.schedule(function() vim.cmd 'TSUpdate' end)
    end
  end,
})

vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }, { confirm = false })

local parsers = {
  'bash', 'c', 'diff', 'dockerfile', 'git_config', 'gitcommit', 'hcl', 'html', 'javascript', 'json',
  'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'regex', 'rust', 'sql',
  'terraform', 'toml', 'vim', 'vimdoc', 'yaml',
}
require('nvim-treesitter').install(parsers) -- async; already-installed parsers are skipped

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ansulev-ts-start', { clear = true }),
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then return end -- no parser for this filetype
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- nvim-treesitter indent is still experimental upstream: left off, ftplugin indent is used.
  end,
})
