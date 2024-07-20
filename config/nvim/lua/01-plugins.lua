local completion_item_resolve_capabilities = vim.lsp.protocol.make_client_capabilities()

-- Add auto import capabilities for rust-analyzer and typescript-language-server.
-- See also the register_completion_item_resolve_callback function below.
--
-- More info:
-- - https://rust-analyzer.github.io/manual.html#completion-with-autoimport
-- - https://www.reddit.com/r/neovim/comments/mn8ipa/lsp_add_missing_imports_on_complete_using_the/
-- - https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
completion_item_resolve_capabilities.textDocument.completion.completionItem = {
  resolveSupport = {
    properties = {"additionalTextEdits"}
  }
}

-- LSP progress loader
require("fidget").setup {}

require('fzf-lua').setup {
  lsp = {
    async_or_timeout = 120000,
    code_actions = {
      async_or_timeout = 120000,
    },
    symbols = {
      async_or_timeout = 120000,
    },
  }
}

local lspconfig = require('lspconfig')
lspconfig.gopls.setup {
  capabilities = completion_item_resolve_capabilities,
}

lspconfig.tsserver.setup {
  capabilities = completion_item_resolve_capabilities,
}

lspconfig.rust_analyzer.setup {
  cmd = { 'rust-analyzer' },
  capabilities = completion_item_resolve_capabilities,
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      check = {
        features = "all",
        -- allTargets = false,
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
        features = "all",
      },
      procMacro = {
        enable = true,
      },
      checkOnSave = {
        extraArgs = {
          "--target-dir",
          "target/rust-analyzer",
        },
      },
      -- cachePriming = {
      --   enable = false,
      -- },
    },
  },
}

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Ensure floating preview window has max width.
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  -- opts.border = opts.border or 'single'
  opts.max_width = opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', ',i', vim.diagnostic.open_float)
vim.keymap.set('n', ',j', vim.diagnostic.goto_next)
vim.keymap.set('n', ',k', vim.diagnostic.goto_prev)
vim.keymap.set('n', ',q', function()
  vim.diagnostic.setloclist{ title = 'Buffer diagnostics' }
end)
vim.keymap.set('n', ',Q', function()
  vim.diagnostic.setqflist{ title = 'Workspace diagnostics' }
end)

local au_group = 'UserLspConfig'

-- This function will register an autocmd for CompleteDone even and call
-- completionItem/resolve when the LSP server capabilities include
-- completionProvider.resolveProvider.
--
-- If the server supports it, make sure to register the client's
-- completion_item_resolve_capabilities.
local function register_completion_item_resolve_callback(buf, client)
  if vim.b[buf].lsp_resolve_callback_registered then
    return
  end

  vim.b[buf].lsp_resolve_callback_registered = true

  local resolve_provider = client.server_capabilities and
    client.server_capabilities.completionProvider and
    client.server_capabilities.completionProvider.resolveProvider

  local offset_encoding = client.offset_encoding

  vim.api.nvim_create_autocmd({"CompleteDone"}, {
    group = vim.api.nvim_create_augroup(au_group, {clear = false}),
    buffer = buf,
    callback = function(_)
      local completed_item = vim.v.completed_item
      if not (completed_item and completed_item.user_data and
          completed_item.user_data.nvim and completed_item.user_data.nvim.lsp and
          completed_item.user_data.nvim.lsp.completion_item) then
          return
      end

      local item = completed_item.user_data.nvim.lsp.completion_item
      local bufnr = vim.api.nvim_get_current_buf()

      -- Check if the item already has completions attached.
      -- https://github.com/neovim/neovim/issues/12310#issuecomment-628269290
      if item.additionalTextEdits and #item.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(item.additionalTextEdits, bufnr, offset_encoding)
        return
      end

      -- Check if the server supports resolving completions.
      if not resolve_provider then
        return
      end

      vim.lsp.buf_request(bufnr, "completionItem/resolve", item, function(err, result, _)
          if err ~= nil then
            return
          end

          if not result then
            return
          end

          if not result.additionalTextEdits then
            return
          end

          if #result.additionalTextEdits == 0 then
            return
          end

          vim.lsp.util.apply_text_edits(result.additionalTextEdits, bufnr, offset_encoding)
        end
      )
    end,
  })
end

vim.diagnostic.config({ virtual_text = false })

-- vim.lsp.set_log_level('trace')

local function find_references()
  vim.lsp.buf.references(nil, {
    on_list = function(opts)
      vim.fn.setloclist(0, {}, ' ', opts)
      vim.api.nvim_command('lopen')
    end,
  })
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup(au_group, {}),

  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', ',gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', ',gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', ',gt', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', ',gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', ',gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', ',wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', ',wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', ',wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', ',gT', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', ',r', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, ',lC', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', ',R', find_references, opts)
    vim.keymap.set('n', ',x', function()
      vim.lsp.buf.format { async = true }
    end, opts)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      print("LspAttach event: no LSP client", ev.data.client_id)
      return
    end

    -- disable syntax highlighting
    client.server_capabilities.semanticTokensProvider = nil

    register_completion_item_resolve_callback(ev.buf, client)
  end,
})

-- Update quickfix/loclist in real-time.
-- Inspiration from https://github.com/onsails/diaglist.nvim/issues/3#issuecomment-931792663
local function update_diagnostics(global_too)
    if vim.fn.getloclist(vim.fn.winnr(), { title = 0 }).title == 'Buffer diagnostics' then
        vim.diagnostic.setloclist{ open = false, title = 'Buffer diagnostics' }
    end

    if global_too and vim.fn.getqflist{ title = 0 }.title == 'Workspace diagnostics' then
        vim.diagnostic.setqflist{ open = false,  title = 'Workspace diagnostics' }
    end
end


vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  callback = function()
    update_diagnostics(false)
  end
})

vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
  callback = function()
    update_diagnostics(true)
  end
})

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  -- List of parsers to ignore installing (or "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {'rust'},
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    -- disable = function(lang, buf)
    --     local max_filesize = 100 * 1024 -- 100 KB
    --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    --     if ok and stats and stats.size > max_filesize then
    --         return true
    --     end
    -- end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
