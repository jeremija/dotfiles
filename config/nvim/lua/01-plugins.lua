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

local lspconfig = require('lspconfig')
lspconfig.gopls.setup {
  capabilities = completion_item_resolve_capabilities,
}

lspconfig.tsserver.setup {
  capabilities = completion_item_resolve_capabilities,
}

lspconfig.rust_analyzer.setup {
  capabilities = completion_item_resolve_capabilities,
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
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
vim.keymap.set('n', ',q', vim.diagnostic.setloclist)

local au_group = 'UserLspConfig'

-- This function will register an autocmd for CompleteDone even and call
-- completionItem/resolve when the LSP server capabilities include
-- completionProvider.resolveProvider.
--
-- If the server supports it, make sure to register the client's
-- completion_item_resolve_capabilities.
local function register_completion_item_resolve_callback(client)
  local resolve_provider = client.server_capabilities and
    client.server_capabilities.completionProvider and
    client.server_capabilities.completionProvider.resolveProvider

  vim.api.nvim_create_autocmd({"CompleteDone"}, {
    group = vim.api.nvim_create_augroup(au_group, {clear = false}),
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
        vim.lsp.util.apply_text_edits(item.additionalTextEdits, bufnr, client.offset_encoding)
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

          vim.lsp.util.apply_text_edits(result.additionalTextEdits, bufnr, client.offset_encoding)
        end
      )
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
    vim.keymap.set('n', ',d', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', ',wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', ',wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', ',wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', ',gT', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', ',r', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, ',C', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', ',R', vim.lsp.buf.references, opts)
    vim.keymap.set('n', ',x', function()
      vim.lsp.buf.format { async = true }
    end, opts)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      print("LspAttach event: no LSP client", ev.data.client_id)
      return
    end

    register_completion_item_resolve_callback(client)
  end,
})
