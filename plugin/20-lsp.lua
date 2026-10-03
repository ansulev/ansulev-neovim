-- LSP: configs from nvim-lspconfig, binaries from the system package manager (no Mason).
-- A server is enabled only when its binary is on PATH, so a missing tool is silent, not an error.
-- Linting is LSP too: ruff (Python, incl. bandit "S" rules), bashls (runs shellcheck), tflint.
-- Prose: ltex_plus (LanguageTool, local) for English and Spanish. Semgrep has no language
-- server, so it is the on-demand :Semgrep command at the end of this file.

vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' }, { confirm = false })

local servers = { -- lspconfig name = binary
  bashls = 'bash-language-server',
  dockerls = 'docker-langserver',
  jsonls = 'vscode-json-language-server',
  ltex_plus = 'ltex-ls-plus',
  lua_ls = 'lua-language-server',
  marksman = 'marksman',
  pyright = 'pyright-langserver',
  ruff = 'ruff',
  taplo = 'taplo',
  terraformls = 'terraform-ls',
  tflint = 'tflint',
  yamlls = 'yaml-language-server',
}

vim.lsp.config('lua_ls', {
  settings = { Lua = { runtime = { version = 'LuaJIT' }, workspace = {
    checkThirdParty = false, library = { vim.env.VIMRUNTIME } } } },
})
-- Default English. A Spanish file opts in with a first-line comment: <!-- LTeX: language=es -->
vim.lsp.config('ltex_plus', { settings = { ltex = { language = 'en-US' } } })
-- ruff owns Python lint + imports, with the bandit security rules ("S") added to any project
-- config; pyright keeps types only.
vim.lsp.config('ruff', { init_options = { settings = { lint = { extendSelect = { 'S' } } } } })
vim.lsp.config('pyright', { settings = { pyright = { disableOrganizeImports = true },
  python = { analysis = { ignore = { '*' } } } } })

for name, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then vim.lsp.enable(name) end
end

vim.g.format_on_save = true -- :let g:format_on_save = v:false to stop it for the session

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('ansulev-lsp', { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf) -- snippets, auto-imports on <C-y>
    end
    if client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('ansulev-fmt-' .. ev.buf, { clear = true }),
        buffer = ev.buf,
        callback = function()
          if vim.g.format_on_save then vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 1000 }) end
        end,
      })
    end
  end,
})

vim.keymap.set({ 'n', 'x' }, '<leader>cf', function() vim.lsp.buf.format({ async = true }) end,
  { desc = 'Format buffer' })

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { source = 'if_many', spacing = 2 },
  float = { source = 'if_many' },
})

-- :Semgrep [config] — scan the cwd into the quickfix list. Default ruleset p/default, metrics off.
vim.api.nvim_create_user_command('Semgrep', function(args)
  local config = args.args ~= '' and args.args or 'p/default'
  vim.notify('semgrep: scanning with ' .. config)
  local cmd = { 'semgrep', 'scan', '--emacs', '--metrics=off', '--config', config, '.' }
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      local lines = vim.split(res.stdout or '', '\n', { trimempty = true })
      vim.fn.setqflist({}, ' ', { title = 'semgrep ' .. config, lines = lines, efm = '%f:%l:%c:%m' })
      vim.notify(('semgrep: %d finding(s), exit %d'):format(#lines, res.code))
      if #lines > 0 then vim.cmd 'copen' end
    end)
  end)
end, { nargs = '?', desc = 'Semgrep scan of the cwd into quickfix' })
