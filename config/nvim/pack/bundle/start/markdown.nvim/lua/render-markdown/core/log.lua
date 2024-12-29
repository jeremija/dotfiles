local util = require('render-markdown.core.util')

---@class render.md.log.Entry
---@field date string
---@field level string
---@field name string
---@field message string

---@class render.md.Log
---@field private level render.md.config.LogLevel
---@field private entries render.md.log.Entry[]
---@field private file string
local M = {}

---@param level render.md.config.LogLevel
function M.setup(level)
    -- Write out any logs before closing
    vim.api.nvim_create_autocmd('VimLeave', {
        group = vim.api.nvim_create_augroup('RenderMarkdownLog', { clear = true }),
        callback = M.flush,
    })
    M.level = level
    M.entries = {}
    -- Typically resolves to ~/.local/state/nvim/render-markdown.log
    M.file = vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Clear the file contents if it is too big
    if util.file_size_mb(M.file) > 5 then
        assert(io.open(M.file, 'w')):close()
    end
end

function M.open()
    M.flush()
    vim.cmd.tabnew(M.file)
end

---@param capture string
---@param node render.md.Node
function M.node(capture, node)
    M.add('debug', 'node', {
        capture = capture,
        text = node.text,
        rows = { node.start_row, node.end_row },
        cols = { node.start_col, node.end_col },
    })
end

---Encountered if new type is seen for a particular group
---@param language string
---@param group string
---@param value string
function M.unhandled_type(language, group, value)
    M.add('error', 'unhandled type', string.format('%s -> %s -> %s', language, group, value))
end

---@param level render.md.config.LogLevel
---@param name string
---@param buf integer
---@param ... any
function M.buf(level, name, buf, ...)
    M.add(level, string.format('%s|%s|%d', name, util.file_name(buf), buf), ...)
end

---@param level render.md.config.LogLevel
---@param name string
---@param ... any
function M.add(level, name, ...)
    if M.level_value(level) < M.level_value(M.level) then
        return
    end
    local messages = {}
    local args = vim.F.pack_len(...)
    for i = 1, args.n do
        local message = type(args[i]) == 'string' and args[i] or vim.inspect(args[i])
        table.insert(messages, message)
    end
    ---@type render.md.log.Entry
    local entry = {
        date = vim.fn.strftime('%Y-%m-%d %H:%M:%S'),
        level = string.upper(level),
        name = name,
        message = table.concat(messages, ' | '),
    }
    table.insert(M.entries, entry)
    -- Periodically flush logs to disk
    if #M.entries > 1000 then
        M.flush()
    end
end

---@private
---@param level render.md.config.LogLevel
---@return integer
function M.level_value(level)
    if level == 'debug' then
        return 1
    elseif level == 'info' then
        return 2
    elseif level == 'error' then
        return 3
    elseif level == 'off' then
        return 4
    else
        return 0
    end
end

---@private
function M.flush()
    if #M.entries == 0 then
        return
    end
    local file = assert(io.open(M.file, 'a'))
    for _, entry in ipairs(M.entries) do
        local line = string.format('%s %s [%s] - %s', entry.date, entry.level, entry.name, entry.message)
        file:write(line .. '\n')
    end
    file:close()
    M.entries = {}
end

return M
