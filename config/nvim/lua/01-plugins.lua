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

require("fidget").setup {}

local lspconfig = require('lspconfig')
lspconfig.gopls.setup {
  capabilities = completion_item_resolve_capabilities,
}

lspconfig.tsserver.setup {
  capabilities = completion_item_resolve_capabilities,
}

-- This function is used as a workaround when jumping to definitions. If we
-- jump to a rust library, the default implementation would add the whole
-- library to the workspace as a new project, but that would result in
-- rust-analyzer doing duplicate work and analyze the project all over again.
-- Instead, we just find the most recent root_dir from the same file type for
-- which we'd already figured out the root_dir. It's not 100% accurate since
-- the user could've navigated to another buffer by the time LSP returned a
-- response, but should otherwise work well.
local function most_recent_root_dir(cur_bufnr)
    local filetype = vim.bo[cur_bufnr].filetype
    local buffers = {}

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if not (bufnr == cur_bufnr) and
        vim.api.nvim_buf_is_loaded(bufnr) and
        vim.bo[bufnr].filetype == filetype
      then
        local root_dir = vim.b[bufnr].lsp_root_dir
        if root_dir then
          table.insert(buffers, {
            root_dir = root_dir,
            lastused = vim.fn.getbufinfo(bufnr)[1].lastused,
          })
        end
      end
    end

    table.sort(buffers, function(a, b)
      return a.lastused > b.lastused
    end)

    local item = buffers[1]

    return item and item.root_dir
end

local function is_in_workspace(path)
  local workspace_dir = vim.fn.getcwd()
  return vim.startswith(path, workspace_dir)
end

local root_dir = function(filename, bufnr)
  if not is_in_workspace(filename) then
    return most_recent_root_dir(bufnr)
  end

  local root_dir = lspconfig.util.root_pattern("Cargo.lock")(filename)

  vim.b[bufnr].lsp_root_dir = root_dir

  return root_dir
end

lspconfig.rust_analyzer.setup {
  root_dir = root_dir,
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
      checkOnSave = true,
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

    -- disable syntax highlighting
    client.server_capabilities.semanticTokensProvider = nil

    register_completion_item_resolve_callback(ev.buf, client)
  end,
})

-- Update quickfix/loclist in real-time.
-- Inspiration from https://github.com/onsails/diaglist.nvim/issues/3#issuecomment-931792663
local function update_diagnostics(global_too)
    if not vim.lsp.buf.server_ready() then
        return
    end

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
