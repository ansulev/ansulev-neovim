# ansulev-neovim

A small Neovim 0.12 IDE config. Native first: `vim.pack` for plugins, `vim.lsp.config` for
language servers, built-in autocomplete for completion. Six plugin repos, no Mason, no distro.

Inspired by Chris Titus's [Neovim setup](https://github.com/ChrisTitusTech/neovim), cut down further:
mini.nvim replaces snacks, which-key, bufferline, oil, gitsigns and trouble; Neovim's own
autocomplete replaces blink.cmp; the system package manager replaces Mason.

## Requirements

- Neovim **0.12+**, git, ripgrep, fd, `tree-sitter` CLI (0.26.1+), a C compiler
- A clipboard tool: `xclip` (X11) or `wl-clipboard` (Wayland)
- Language servers you want (each one is enabled only when its binary is on PATH)

## Install (Arch Linux)

```bash
git clone https://github.com/ansulev/ansulev-neovim ~/Projects/ansulev-neovim
cd ~/Projects/ansulev-neovim
./install.sh all --dry-run   # see what it would do
./install.sh all --backup    # missing tools via yay/paru, then link ~/.config/nvim
nvim                         # plugins and parsers install on first launch
```

Only tools missing from PATH are installed, so `-git`/`-bin` variants you already have stay.
Without yay or paru, pacman installs the repo packages and the AUR ones are listed for you.
`link` refuses to touch an existing `~/.config/nvim`; `--backup` moves it aside first.
On other distros, install the tools below with your package manager and symlink the repo to
`~/.config/nvim`.

## What is in it

| File | Does |
|---|---|
| `init.lua` | Options, core keymaps, yank highlight, colorscheme |
| `plugin/10-treesitter.lua` | Parsers (nvim-treesitter `main`), native highlight and folds |
| `plugin/20-lsp.lua` | Servers, completion, format on save, `:Semgrep` |
| `plugin/30-mini.lua` | Picker, file explorer, key hints, statusline, tabline, git, diff, pairs, surround |
| `plugin/40-terminal.lua` | Floating terminal (toggleterm) |
| `plugin/50-ai.lua` | CodeCompanion: local model by default, Grok and Claude on demand |
| `nvim-pack-lock.json` | Plugin revisions. Commit it; `:lua vim.pack.update()` to update |

### Language servers

| Server | Package (Arch) | Covers |
|---|---|---|
| pyright | `pyright` | Python types |
| ruff | `ruff` | Python lint + format, bandit security rules (`S`) always on |
| bashls | `bash-language-server` + `shellcheck` + `shfmt` | Shell lint + format |
| lua_ls | `lua-language-server` | Lua, this config |
| taplo | `taplo-cli` | TOML |
| yamlls / jsonls | `yaml-language-server` / `vscode-json-languageserver` | YAML / JSON |
| marksman | `marksman` | Markdown links and headings |
| dockerls | `dockerfile-language-server` | Dockerfile |
| terraformls / tflint | `terraform-ls` (AUR) / `tflint` | Terraform |
| ltex_plus | `ltex-ls-plus-bin` (AUR) | Grammar and spelling via LanguageTool, local |

`ltex_plus` checks English by default. For a Spanish file, put `<!-- LTeX: language=es -->` on
the first line.

`:Semgrep [config]` scans the working directory into the quickfix list (default `p/default`,
metrics off). Semgrep has no language server, so it runs on demand.

## AI

`plugin/50-ai.lua` only offers the adapters it defines:

| Adapter | Runs on | Needs |
|---|---|---|
| `local_llm` (default) | llama.cpp at `http://127.0.0.1:8008` | a running `llama-server`; set `NVIM_AI_URL` / `NVIM_AI_MODEL` to change it |
| `grok` | Grok CLI over ACP | `grok login` once |
| `claude_code` | Claude subscription over ACP | `claude-agent-acp` (AUR) and a signed-in `claude`; it reuses that login, no token to export |

Chat, inline and command prompts all start on the local model. A cloud adapter runs only when
you pick it. Keep client or personal data on `local_llm`.

## Keys

Leader is <kbd>Space</kbd>. Press it and wait to see the list.

| Keys | Action |
|---|---|
| `<leader>ff` `fg` `fb` `fo` `fh` `fr` | Files, live grep, buffers, recent, help, resume |
| `<leader>fd` `fs` | Diagnostics, document symbols |
| `<leader>e` | File explorer at the current file |
| `<leader>gd` | Git diff overlay |
| `<leader>cf` | Format buffer |
| `<leader>q` | Diagnostics to location list |
| `<leader>u` | Undo tree (built in) |
| `<leader>bd` | Delete buffer |
| `<leader>ac` `ag` `al` | AI chat: local, Grok, Claude |
| `<leader>ai` `aa` | AI inline prompt, action menu |
| `<C-\>` | Floating terminal |
| `<C-s>` | Save |
| `<C-h/j/k/l>` | Move between windows |
| `jk` | Escape (insert mode) |
| `<Tab>` `<S-Tab>` `<CR>` | Move through and accept completion |
| `grn` `gra` `grr` `gri` `gO` `K` | LSP rename, action, references, implementation, symbols, hover (Neovim defaults) |

## Colors

`colorscheme current` is loaded when a `colors/current.vim` exists (written by a theme switcher,
gitignored); otherwise the built-in `habamax`.

## License

MIT. See `LICENSE`.
