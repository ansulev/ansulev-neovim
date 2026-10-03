-- AI: CodeCompanion. Presets are hidden, so the adapter list is exactly what is defined here:
--   local_llm  (default) llama.cpp, nothing leaves the machine. $NVIM_AI_URL / $NVIM_AI_MODEL
--   grok       Grok CLI over ACP, your SuperGrok login (`grok agent stdio`, cached OAuth token)
--   claude_code Claude subscription over ACP (`claude-agent-acp`, uses your `claude` login)
-- Cloud adapters run only when picked (`ga` in a chat, or <leader>ag / <leader>al).
-- Client/PII work stays on local_llm.

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/olimorris/codecompanion.nvim',
}, { confirm = false })

local url = vim.env.NVIM_AI_URL or 'http://127.0.0.1:8008'
local model = vim.env.NVIM_AI_MODEL or 'defiant-9b'

local function local_llm()
  local openai = require('codecompanion.adapters.http.openai')
  local utils = require('codecompanion.adapters.utils')
  return require('codecompanion.adapters').extend('openai_compatible', {
    name = 'local_llm',
    formatted_name = 'Local (' .. model .. ')',
    env = { url = url, api_key = 'TERM', chat_url = '/v1/chat/completions' }, -- no key; TERM is always set
    schema = { model = { default = model } },
    handlers = {
      -- Qwen-family chat templates reject a system message after the first user turn.
      form_messages = function(self, messages)
        return openai.handlers.form_messages(self, utils.merge_system_messages(messages))
      end,
    },
  })
end

local function grok()
  return require('codecompanion.adapters.acp').extend('opencode', { -- same ACP shape, other binary
    name = 'grok',
    formatted_name = 'Grok',
    commands = { default = { 'grok', 'agent', 'stdio' } },
  })
end

-- claude-agent-acp signs in with Claude Code's own login (~/.claude). The preset's auth handler
-- insists on $CLAUDE_CODE_OAUTH_TOKEN; skip it so no token is copied anywhere.
local function claude_code()
  return require('codecompanion.adapters.acp').extend('claude_code', {
    handlers = { auth = function() return true end },
  })
end

require('codecompanion').setup({
  adapters = {
    http = { local_llm = local_llm, opts = { show_presets = false } },
    acp = { grok = grok, claude_code = claude_code, opts = { show_presets = false } },
  },
  interactions = {
    chat = { adapter = 'local_llm' },
    inline = { adapter = 'local_llm' },
    cmd = { adapter = 'local_llm' },
    background = { adapter = 'local_llm' },
  },
})

local map = vim.keymap.set
map({ 'n', 'x' }, '<leader>ac', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'AI chat (local)' })
map({ 'n', 'x' }, '<leader>ag', '<Cmd>CodeCompanionChat adapter=grok<CR>', { desc = 'AI chat (Grok)' })
map({ 'n', 'x' }, '<leader>al', '<Cmd>CodeCompanionChat adapter=claude_code<CR>', { desc = 'AI chat (Claude)' })
map({ 'n', 'x' }, '<leader>ai', ':CodeCompanion ', { desc = 'AI inline prompt (local)' })
map({ 'n', 'x' }, '<leader>aa', '<Cmd>CodeCompanionActions<CR>', { desc = 'AI actions' })
map('x', '<leader>ap', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'AI add selection to chat' })
