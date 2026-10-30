-- Find references that, when rust-analyzer's `references.excludeTests` is on,
-- also skips test-only code that rust-analyzer itself still reports.

local M = {}

local function rust_analyzer_client()
  return vim.lsp.get_clients({ name = 'rust_analyzer', bufnr = 0 })[1]
end

local function excluding_tests()
  local client = rust_analyzer_client()
  return client ~= nil and client.settings['rust-analyzer'].references.excludeTests
end

local function is_test_attr(text)
  text = text:gsub('%s', '')
  return text == '#[cfg(test)]' or text == '#![cfg(test)]' or text:match('test%]$') ~= nil
end

-- rust-analyzer's excludeTests only skips `#[test]` fns, not helpers inside
-- `#[cfg(test)]` items, so check the attributes on every enclosing node.
local function in_test_code(root, src, row, col)
  local function test_attr(node)
    return node:type():match('attribute_item$') and is_test_attr(vim.treesitter.get_node_text(node, src))
  end
  for child in root:iter_children() do
    if child:type() == 'inner_attribute_item' and test_attr(child) then
      return true
    end
  end
  local node = root:named_descendant_for_range(row, col, row, col)
  while node do
    local sib = node:prev_named_sibling()
    while sib and (sib:type():match('attribute_item$') or sib:type():match('comment$')) do
      if test_attr(sib) then
        return true
      end
      sib = sib:prev_named_sibling()
    end
    node = node:parent()
  end
  return false
end

local function drop_test_items(items)
  local client = rust_analyzer_client()
  local parsed = {}
  local test_files = {}

  local function parse(fname)
    if not parsed[fname] then
      local buf = vim.fn.bufnr(fname)
      local lines = buf ~= -1 and vim.api.nvim_buf_is_loaded(buf)
          and vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          or vim.fn.readfile(fname)
      local src = table.concat(lines, '\n')
      parsed[fname] = { root = vim.treesitter.get_string_parser(src, 'rust'):parse()[1]:root(), src = src }
    end
    return parsed[fname]
  end

  -- A file is test-only if any `mod foo;` on its chain of parent modules is.
  local function file_is_test(fname)
    if test_files[fname] ~= nil then
      return test_files[fname]
    end
    test_files[fname] = false
    local uri = vim.uri_from_fname(fname)
    local res = client and client:request_sync('experimental/parentModule', {
      textDocument = { uri = uri },
      position = { line = 0, character = 0 },
    }, 2000, 0)
    local is_test = false
    for _, loc in ipairs(res and res.result or {}) do
      local parent_uri = loc.targetUri or loc.uri
      local range = loc.targetSelectionRange or loc.range
      if parent_uri ~= uri then
        local parent = vim.uri_to_fname(parent_uri)
        local entry = parse(parent)
        if in_test_code(entry.root, entry.src, range.start.line, range.start.character)
            or file_is_test(parent) then
          is_test = true
          break
        end
      end
    end
    test_files[fname] = is_test
    return is_test
  end

  return vim.tbl_filter(function(item)
    if not item.filename:match('%.rs$') then
      return true
    end
    -- Integration tests are separate crates, so they have no parent module.
    if ('/' .. vim.fn.fnamemodify(item.filename, ':.')):match('/tests/') then
      return false
    end
    local entry = parse(item.filename)
    return not (in_test_code(entry.root, entry.src, item.lnum - 1, item.col - 1)
      or file_is_test(item.filename))
  end, items)
end

function M.find_references()
  vim.lsp.buf.references(nil, {
    on_list = function(opts)
      if excluding_tests() then
        opts.items = drop_test_items(opts.items)
      end
      vim.fn.setloclist(0, {}, ' ', opts)
      vim.api.nvim_command('lopen')
    end,
  })
end

function M.toggle_exclude_tests()
  for _, client in ipairs(vim.lsp.get_clients({ name = 'rust_analyzer' })) do
    local refs = client.settings['rust-analyzer'].references
    refs.excludeTests = not refs.excludeTests
    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
    vim.notify('rust-analyzer references.excludeTests = ' .. tostring(refs.excludeTests))
  end
end

return M
