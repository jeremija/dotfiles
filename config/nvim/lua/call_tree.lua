-- LSP call hierarchy rendered as a lazily expanded tree in a split.
local M = {}

local MAX_DEEP_DEPTH = 3
local MAX_DEEP_REQUESTS = 200
local WIDTH = 70
local HEADER_LINES = 1

local ns = vim.api.nvim_create_namespace('call_tree')
local trees = {}
local show_detail = false

local function item_key(item)
  local s = item.selectionRange.start
  return item.uri .. ':' .. s.line .. ':' .. s.character
end

local function new_node(item, from_ranges, parent)
  local node = {
    item = item,
    from_ranges = from_ranges or {},
    parent = parent,
    depth = parent and parent.depth + 1 or 0,
    expanded = false,
    loading = false,
    children = nil,
    recursive = false,
  }
  local key = item_key(item)
  local p = parent
  while p do
    if item_key(p.item) == key then
      node.recursive = true
      break
    end
    p = p.parent
  end
  return node
end

local function marker(node)
  if node.recursive then
    return '↻'
  elseif node.loading then
    return '…'
  elseif node.children and #node.children == 0 then
    return '·'
  elseif node.expanded then
    return '▾'
  end
  return '▸'
end

local function render(tree)
  if not vim.api.nvim_buf_is_valid(tree.buf) then
    return
  end

  local title = tree.direction == 'incoming' and 'Incoming calls' or 'Outgoing calls'
  local lines = { title .. '  (<CR> jump, p preview, <Space> toggle, l/h expand/collapse, L deep, d signature, s switch, R reroot, q close)' }
  local hls = { { 0, 0, #title, 'Title' }, { 0, #title, #lines[1], 'Comment' } }
  local line_nodes = {}

  local function walk(node)
    local indent = string.rep('  ', node.depth)
    local prefix = indent .. marker(node) .. ' '
    local text = prefix .. (node.label or node.item.name)
    local row = #lines
    table.insert(hls, { row, #prefix, #text, 'Function' })

    local rest_start = #text
    local fname = vim.fn.fnamemodify(vim.uri_to_fname(node.item.uri), ':~:.')
    text = text .. '  ' .. fname .. ':' .. (node.item.selectionRange.start.line + 1)
    local detail = node.item.detail
    if show_detail and detail and detail ~= '' then
      text = text .. '  ' .. (detail:gsub('%s+', ' '))
    end
    if #node.from_ranges > 1 then
      text = text .. '  (' .. #node.from_ranges .. ' calls)'
    end
    if node.recursive then
      text = text .. '  (recursive)'
    end
    table.insert(hls, { row, rest_start, #text, 'Comment' })

    table.insert(lines, text)
    line_nodes[#lines] = node

    if node.expanded and node.children then
      for _, child in ipairs(node.children) do
        walk(child)
      end
    end
  end
  walk(tree.root)

  vim.bo[tree.buf].modifiable = true
  vim.api.nvim_buf_set_lines(tree.buf, 0, -1, false, lines)
  vim.bo[tree.buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(tree.buf, ns, 0, -1)
  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(tree.buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = hl[4] })
  end

  tree.line_nodes = line_nodes
end

local function sort_children(children)
  table.sort(children, function(a, b)
    if a.item.uri ~= b.item.uri then
      return a.item.uri < b.item.uri
    end
    return a.item.selectionRange.start.line < b.item.selectionRange.start.line
  end)
end

-- SymbolKind: Class, Enum, Interface, Object (rust-analyzer impl blocks), Struct.
local CONTAINER_KINDS = { [5] = true, [10] = true, [11] = true, [19] = true, [23] = true }

local function pos_le(a, b)
  return a.line < b.line or (a.line == b.line and a.character <= b.character)
end

local function range_contains(range, pos)
  return pos_le(range.start, pos) and pos_le(pos, range['end'])
end

local function strip_generics(s)
  local out, depth = {}, 0
  for i = 1, #s do
    local c = s:sub(i, i)
    if c == '<' then
      depth = depth + 1
    elseif c == '>' and s:sub(i - 1, i - 1) ~= '-' then
      depth = math.max(depth - 1, 0)
    elseif depth == 0 then
      table.insert(out, c)
    end
  end
  return vim.trim(table.concat(out))
end

local function container_label(name, is_rust)
  if not is_rust then
    return name
  end
  local impl = name:match('^impl%s+(.+)$')
  if not impl then
    return strip_generics(name)
  end
  local trait, ty = impl:match('^(.-)%s+for%s+(.+)$')
  if trait then
    return '<' .. strip_generics(ty) .. ' as ' .. strip_generics(trait) .. '>'
  end
  return strip_generics(impl)
end

local function find_container(symbols, pos, container)
  for _, sym in ipairs(symbols or {}) do
    if sym.range and range_contains(sym.range, pos) then
      if CONTAINER_KINDS[sym.kind] then
        container = sym
      end
      return find_container(sym.children, pos, container)
    end
  end
  return container
end

local function qualified_name(item, symbols)
  local name = item.name
  if not symbols or #symbols == 0 then
    return name
  end
  local pos = item.selectionRange.start
  local is_rust = item.uri:match('%.rs$') ~= nil
  local sep = is_rust and '::' or '.'

  if symbols[1].location then
    -- Flat SymbolInformation[] from servers without hierarchical symbols.
    for _, sym in ipairs(symbols) do
      if sym.name == name and sym.containerName and sym.containerName ~= ''
          and range_contains(sym.location.range, pos) then
        return sym.containerName .. sep .. name
      end
    end
    return name
  end

  local container = find_container(symbols, pos)
  if container then
    return container_label(container.name, is_rust) .. sep .. name
  end
  return name
end

local function load_symbols(tree, uri, cb)
  local cached = tree.symbols[uri]
  if cached ~= nil then
    return cb(cached)
  end
  local waiters = tree.symbol_waiters[uri]
  if waiters then
    table.insert(waiters, cb)
    return
  end
  waiters = { cb }
  tree.symbol_waiters[uri] = waiters

  local function done(result)
    tree.symbols[uri] = result
    tree.symbol_waiters[uri] = nil
    for _, waiter in ipairs(waiters) do
      waiter(result)
    end
  end

  local client = vim.lsp.get_client_by_id(tree.client_id)
  if not client or not client:supports_method('textDocument/documentSymbol') then
    return done(false)
  end
  local bufnr = vim.api.nvim_buf_is_valid(tree.src_buf) and tree.src_buf or nil
  client:request('textDocument/documentSymbol', { textDocument = { uri = uri } }, function(err, result)
    vim.schedule(function()
      done(not err and result or false)
    end)
  end, bufnr)
end

local function qualify(tree, nodes, cb)
  local pending = #nodes
  if pending == 0 then
    return cb()
  end
  for _, node in ipairs(nodes) do
    load_symbols(tree, node.item.uri, function(symbols)
      node.label = qualified_name(node.item, symbols or nil)
      pending = pending - 1
      if pending == 0 then
        cb()
      end
    end)
  end
end

local function fetch_children(tree, node, cb)
  if node.children or node.recursive then
    return cb()
  end
  if node.loading then
    return
  end
  local client = vim.lsp.get_client_by_id(tree.client_id)
  if not client then
    vim.notify('call_tree: LSP client is gone', vim.log.levels.WARN)
    return
  end

  node.loading = true
  render(tree)

  local method = 'callHierarchy/' .. tree.direction .. 'Calls'
  local bufnr = vim.api.nvim_buf_is_valid(tree.src_buf) and tree.src_buf or nil
  client:request(method, { item = node.item }, function(err, result)
    vim.schedule(function()
      local children = {}
      if err then
        vim.notify('call_tree: ' .. method .. ' failed: ' .. err.message, vim.log.levels.ERROR)
      else
        for _, call in ipairs(result or {}) do
          local item = tree.direction == 'incoming' and call.from or call.to
          table.insert(children, new_node(item, call.fromRanges, node))
        end
        sort_children(children)
      end
      qualify(tree, children, function()
        node.loading = false
        node.children = children
        cb()
      end)
    end)
  end, bufnr)
end

local function expand(tree, node, cb)
  if node.recursive then
    return cb and cb()
  end
  fetch_children(tree, node, function()
    node.expanded = true
    render(tree)
    if cb then
      cb()
    end
  end)
end

local function expand_deep(tree, node, remaining, budget)
  if remaining <= 0 or node.recursive then
    return
  end
  if not node.children then
    if budget.left <= 0 then
      return
    end
    budget.left = budget.left - 1
  end
  expand(tree, node, function()
    for _, child in ipairs(node.children or {}) do
      expand_deep(tree, child, remaining - 1, budget)
    end
  end)
end

local function set_root(tree, item, direction)
  tree.direction = direction
  tree.root = new_node(item)
  render(tree)
  local root = tree.root
  qualify(tree, { root }, function()
    if tree.root == root then
      render(tree)
    end
  end)
  expand_deep(tree, tree.root, MAX_DEEP_DEPTH, { left = MAX_DEEP_REQUESTS })
end

local function current_tree()
  return trees[vim.api.nvim_get_current_buf()]
end

local function node_at_cursor(tree)
  return tree.line_nodes[vim.api.nvim_win_get_cursor(0)[1]]
end

local function line_of(tree, target)
  for lnum, node in pairs(tree.line_nodes) do
    if node == target then
      return lnum
    end
  end
end

local function location_of(tree, node)
  local range = node.from_ranges[1]
  if not range or not node.parent then
    return { uri = node.item.uri, range = node.item.selectionRange }
  end
  -- Outgoing fromRanges are in the caller, i.e. the parent's file.
  local uri = tree.direction == 'incoming' and node.item.uri or node.parent.item.uri
  return { uri = uri, range = range }
end

local function target_window(tree)
  if vim.api.nvim_win_is_valid(tree.src_win) and tree.src_win ~= vim.api.nvim_get_current_win() then
    return tree.src_win
  end
  local tree_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= tree_win and vim.api.nvim_win_get_config(win).relative == '' then
      return win
    end
  end
  vim.cmd('leftabove vnew')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(tree_win)
  return win
end

local function jump(tree, node, keep_focus)
  local tree_win = vim.api.nvim_get_current_win()
  local win = target_window(tree)
  tree.src_win = win
  vim.api.nvim_set_current_win(win)
  vim.cmd("normal! m'")
  vim.lsp.util.show_document(location_of(tree, node), tree.offset_encoding, { focus = true })
  vim.cmd('normal! zz')
  if keep_focus then
    vim.api.nvim_set_current_win(tree_win)
  end
end

local function set_keymaps(buf)
  local function map(lhs, fn)
    vim.keymap.set('n', lhs, function()
      local tree = current_tree()
      local node = tree and node_at_cursor(tree)
      if node then
        fn(tree, node)
      end
    end, { buffer = buf, nowait = true, silent = true })
  end

  map('<CR>', function(tree, node) jump(tree, node, false) end)
  map('o', function(tree, node) jump(tree, node, false) end)
  map('p', function(tree, node) jump(tree, node, true) end)
  map('l', function(tree, node) expand(tree, node) end)
  local function toggle(tree, node)
    if node.expanded then
      node.expanded = false
      render(tree)
    else
      expand(tree, node)
    end
  end
  map('<Tab>', toggle)
  map('<Space>', toggle)
  map('h', function(tree, node)
    if node.expanded and node.children and #node.children > 0 then
      node.expanded = false
      render(tree)
    elseif node.parent then
      local lnum = line_of(tree, node.parent)
      if lnum then
        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      end
    end
  end)
  map('L', function(tree, node)
    expand_deep(tree, node, MAX_DEEP_DEPTH, { left = MAX_DEEP_REQUESTS })
  end)
  map('s', function(tree, node)
    set_root(tree, node.item, tree.direction == 'incoming' and 'outgoing' or 'incoming')
  end)
  map('R', function(tree, node) set_root(tree, node.item, tree.direction) end)
  map('d', function(tree)
    show_detail = not show_detail
    render(tree)
  end)

  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
end

local function find_tree_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if trees[vim.api.nvim_win_get_buf(win)] then
      return win
    end
  end
end

local function create_tree(client, src_win, src_buf, direction, item)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'calltree'
  vim.bo[buf].modifiable = false

  local win = find_tree_win()
  if win then
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd('botright vsplit')
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_win_set_width(win, WIDTH)
  end
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].winfixwidth = true

  local tree = {
    buf = buf,
    client_id = client.id,
    offset_encoding = client.offset_encoding,
    src_win = src_win,
    src_buf = src_buf,
    line_nodes = {},
    symbols = {},
    symbol_waiters = {},
  }
  trees[buf] = tree
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = buf,
    once = true,
    callback = function()
      trees[buf] = nil
    end,
  })

  set_keymaps(buf)
  set_root(tree, item, direction)
  vim.api.nvim_win_set_cursor(win, { HEADER_LINES + 1, 0 })
end

--- Open a call tree for the symbol under the cursor.
--- @param direction 'incoming'|'outgoing'
function M.open(direction)
  local src_buf = vim.api.nvim_get_current_buf()
  local src_win = vim.api.nvim_get_current_win()
  local clients = vim.lsp.get_clients({ bufnr = src_buf, method = 'textDocument/prepareCallHierarchy' })
  local client = clients[1]
  if not client then
    vim.notify('call_tree: no attached LSP server supports call hierarchy', vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params(src_win, client.offset_encoding)
  client:request('textDocument/prepareCallHierarchy', params, function(err, result)
    vim.schedule(function()
      if err then
        vim.notify('call_tree: prepareCallHierarchy failed: ' .. err.message, vim.log.levels.ERROR)
        return
      end
      if not result or #result == 0 then
        vim.notify('call_tree: no call hierarchy item under cursor', vim.log.levels.INFO)
        return
      end
      local function start(item)
        create_tree(client, src_win, src_buf, direction, item)
      end
      if #result == 1 then
        start(result[1])
      else
        vim.ui.select(result, {
          prompt = 'Call hierarchy item',
          format_item = function(item)
            return item.name .. (item.detail and ('  ' .. item.detail) or '')
          end,
        }, function(choice)
          if choice then
            start(choice)
          end
        end)
      end
    end)
  end, src_buf)
end

return M
