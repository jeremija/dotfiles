local cmp = require('cmp')
local completion_item_resolve_capabilities = require('cmp_nvim_lsp').default_capabilities()

cmp.setup({
  completion = {
    autocomplete = false,
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  })
})

-- LSP progress loader
require("fidget").setup {
  notification = {
    window = {
      winblend = 0,
    }
  }
}

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

vim.lsp.config('gopls', {
  capabilities = completion_item_resolve_capabilities,
})
vim.lsp.enable('gopls')

vim.lsp.config('ts_ls', {
  capabilities = completion_item_resolve_capabilities,
})
vim.lsp.enable('ts_ls')

vim.lsp.config('rust_analyzer', {
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
      procMacro = {
        enable = true,
      },
      check = {
        features = "all",
        allTargets = true,
      },
      checkOnSave = true,
      cargo = {
        extraArgs = {
          "--target-dir",
          "target/rust-analyzer",
        },
        buildScripts = {
          enable = true,
        },
        features = "all",
        allTargets = true,
      },
      inalyHints = {
        typeHints = {
          enable = true,
        },
        parameterHints = {
          enable = true,
        },
        chainingHints = {
          enable = true,
        },
      },
      -- cachePriming = {
      --   enable = false,
      -- },
    },
  },
})
vim.lsp.enable('rust_analyzer')

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
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
})
vim.lsp.enable('lua_ls')

-- Ensure floating preview window has max width.
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
--- @diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  -- opts.border = opts.border or 'single'
  opts.max_width = opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', ',i', vim.diagnostic.open_float)
vim.keymap.set('n', ',j', function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set('n', ',k', function()
  vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set('n', ',q', function()
  vim.diagnostic.setloclist { title = 'Buffer diagnostics' }
end)
vim.keymap.set('n', ',Q', function()
  vim.diagnostic.setqflist { title = 'Workspace diagnostics' }
end)
vim.keymap.set('n', ',j', function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
   if vim.snippet.active({ direction = 1 }) then
     return '<Cmd>lua vim.snippet.jump(1)<CR>'
   else
     return '<Tab>'
   end
 end, { expr = true, silent = true })
vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
   if vim.snippet.active({ direction = -1 }) then
     return '<Cmd>lua vim.snippet.jump(-1)<CR>'
   else
     return '<Tab>'
   end
 end, { expr = true, silent = true })


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
  end,
})

-- Update quickfix/loclist in real-time.
-- Inspiration from https://github.com/onsails/diaglist.nvim/issues/3#issuecomment-931792663
local function update_diagnostics(global_too)
  if vim.fn.getloclist(vim.fn.winnr(), { title = 0 }).title == 'Buffer diagnostics' then
    vim.diagnostic.setloclist { open = false, title = 'Buffer diagnostics' }
  end

  if global_too and vim.fn.getqflist { title = 0 }.title == 'Workspace diagnostics' then
    vim.diagnostic.setqflist { open = false, title = 'Workspace diagnostics' }
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

require('nvim-treesitter').setup()
-- require('nvim-treesitter').install({ 'lua', 'vim', 'bash', 'rust' })

-- vim.api.nvim_create_autocmd('FileType', {
--   callback = function(ev)
--     if vim.bo[ev.buf].filetype == 'rust' then
--       vim.treesitter.stop(ev.buf)
--     else
--       pcall(vim.treesitter.start, ev.buf)
--     end
--   end,
-- })

require('render-markdown').setup {
  heading = {
    enabled = false,
  },
  sign = {
    enabled = false,
  },
  code = {
    style = 'normal',
    -- below = ' ',
  },
  anti_conceal = {
    -- This enables hiding any added text on the line the cursor is on
    -- This does have a performance penalty as we must listen to the 'CursorMoved' event
    enabled = false,
  },
}
