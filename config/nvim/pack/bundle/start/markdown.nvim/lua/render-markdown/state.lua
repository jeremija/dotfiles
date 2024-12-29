local Config = require('render-markdown.config')
local log = require('render-markdown.core.log')
local presets = require('render-markdown.presets')
local treesitter = require('render-markdown.core.treesitter')
local util = require('render-markdown.core.util')

---@type table<integer, render.md.buffer.Config>
local configs = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field log_runtime boolean
---@field file_types string[]
---@field latex render.md.Latex
---@field on render.md.Callback
---@field custom_handlers table<string, render.md.Handler>
local M = {}

---@return boolean
function M.initialized()
    return M.config ~= nil
end

---@param default_config render.md.Config
---@param user_config render.md.UserConfig
function M.setup(default_config, user_config)
    local preset_config = presets.get(user_config)
    local config = vim.tbl_deep_extend('force', default_config, preset_config, user_config)
    -- Override settings that require neovim >= 0.10.0 and have compatible alternatives
    if not util.has_10 then
        config.code.position = 'right'
        config.checkbox.position = 'overlay'
    end
    -- Use lazy.nvim file type configuration if available and no user value is specified
    if user_config.file_types == nil then
        local lazy_file_types = util.lazy_file_types('render-markdown.nvim')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end

    M.config = config
    M.enabled = config.enabled
    M.log_runtime = config.log_runtime
    M.file_types = config.file_types
    M.latex = config.latex
    M.on = config.on
    M.custom_handlers = config.custom_handlers
    log.setup(config.log_level)
    for _, language in ipairs(M.file_types) do
        treesitter.inject(language, config.injections[language])
    end
end

function M.invalidate_cache()
    configs = {}
end

---@param default_config render.md.Config
---@return table
function M.difference(default_config)
    return require('render-markdown.debug.diff').get(default_config, M.config)
end

---@param amount integer
function M.modify_anti_conceal(amount)
    ---@param anti_conceal render.md.AntiConceal
    local function modify(anti_conceal)
        anti_conceal.above = math.max(anti_conceal.above + amount, 0)
        anti_conceal.below = math.max(anti_conceal.below + amount, 0)
    end
    modify(M.config.anti_conceal)
    for _, config in pairs(configs) do
        modify(config.anti_conceal)
    end
end

---@param buf integer
---@return render.md.buffer.Config
function M.get(buf)
    local config = configs[buf]
    if config == nil then
        local buf_config = M.default_buffer_config()
        for _, name in ipairs({ 'buftype', 'filetype' }) do
            local override = M.config.overrides[name][util.get('buf', buf, name)]
            if override ~= nil then
                buf_config = vim.tbl_deep_extend('force', buf_config, override)
            end
        end
        config = Config.new(buf_config)
        configs[buf] = config
    end
    return config
end

---@private
---@return render.md.BufferConfig
function M.default_buffer_config()
    local config = M.config
    ---@type render.md.BufferConfig
    local buffer_config = {
        enabled = true,
        max_file_size = config.max_file_size,
        debounce = config.debounce,
        render_modes = config.render_modes,
        anti_conceal = config.anti_conceal,
        padding = config.padding,
        heading = config.heading,
        paragraph = config.paragraph,
        code = config.code,
        dash = config.dash,
        bullet = config.bullet,
        checkbox = config.checkbox,
        quote = config.quote,
        pipe_table = config.pipe_table,
        callout = config.callout,
        link = config.link,
        sign = config.sign,
        inline_highlight = config.inline_highlight,
        indent = config.indent,
        html = config.html,
        win_options = config.win_options,
    }
    return vim.deepcopy(buffer_config)
end

---@return string[]
function M.validate()
    ---@param buffer render.md.debug.ValidatorSpec
    ---@return render.md.debug.ValidatorSpec
    local function add_buffer_rules(buffer)
        return buffer
            :type('enabled', 'boolean')
            :type({ 'max_file_size', 'debounce' }, 'number')
            :list('render_modes', 'string', 'boolean')
            :nested('anti_conceal', function(anti_conceal)
                anti_conceal
                    :type('enabled', 'boolean')
                    :type({ 'above', 'below' }, 'number')
                    :nested('ignore', function(ignore)
                        ignore
                            :list({ 'head_icon', 'head_background', 'head_border' }, 'string', { 'boolean', 'nil' })
                            :list({ 'code_language', 'code_background', 'code_border' }, 'string', { 'boolean', 'nil' })
                            :list({ 'dash', 'bullet', 'check_icon', 'check_scope' }, 'string', { 'boolean', 'nil' })
                            :list({ 'quote', 'table_border', 'callout' }, 'string', { 'boolean', 'nil' })
                            :list({ 'link', 'sign' }, 'string', { 'boolean', 'nil' })
                            :check()
                    end)
                    :check()
            end)
            :nested('padding', function(padding)
                padding:type('highlight', 'string'):check()
            end)
            :nested('heading', function(heading)
                heading
                    :type({ 'enabled', 'sign', 'border_virtual', 'border_prefix' }, 'boolean')
                    :type({ 'above', 'below' }, 'string')
                    :list('border', 'boolean', 'boolean')
                    :list({ 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number', 'number')
                    :list({ 'icons', 'signs', 'backgrounds', 'foregrounds' }, 'string')
                    :one_of('position', { 'overlay', 'inline', 'right' })
                    :one_or_list_of('width', { 'full', 'block' })
                    :check()
            end)
            :nested('paragraph', function(paragraph)
                paragraph:type('enabled', 'boolean'):type({ 'left_margin', 'min_width' }, 'number'):check()
            end)
            :nested('code', function(code)
                code:type({ 'enabled', 'sign', 'language_name' }, 'boolean')
                    :type({ 'language_pad', 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number')
                    :type({ 'above', 'below', 'highlight', 'highlight_inline' }, 'string')
                    :type('highlight_language', { 'string', 'nil' })
                    :list('disable_background', 'string', 'boolean')
                    :one_of('style', { 'full', 'normal', 'language', 'none' })
                    :one_of('position', { 'left', 'right' })
                    :one_of('width', { 'full', 'block' })
                    :one_of('border', { 'thin', 'thick', 'none' })
                    :check()
            end)
            :nested('dash', function(dash)
                dash:type('enabled', 'boolean')
                    :type('left_margin', 'number')
                    :type({ 'icon', 'highlight' }, 'string')
                    :one_of('width', { 'full' }, 'number')
                    :check()
            end)
            :nested('bullet', function(bullet)
                bullet
                    :type('enabled', 'boolean')
                    :type({ 'left_pad', 'right_pad' }, 'number')
                    :type('highlight', 'string')
                    :list_or_list_of_list({ 'icons', 'ordered_icons' }, 'string', 'function')
                    :check()
            end)
            :nested('checkbox', function(checkbox)
                checkbox
                    :type('enabled', 'boolean')
                    :one_of('position', { 'overlay', 'inline' })
                    :nested({ 'unchecked', 'checked' }, function(box)
                        box:type({ 'icon', 'highlight' }, 'string'):type('scope_highlight', { 'string', 'nil' }):check()
                    end)
                    :nested('custom', function(boxes)
                        boxes:nested('ALL', function(box)
                            box:type({ 'raw', 'rendered', 'highlight' }, 'string')
                                :type('scope_highlight', { 'string', 'nil' })
                                :check()
                        end)
                    end)
                    :check()
            end)
            :nested('quote', function(quote)
                quote:type({ 'enabled', 'repeat_linebreak' }, 'boolean'):type({ 'icon', 'highlight' }, 'string'):check()
            end)
            :nested('pipe_table', function(pipe_table)
                pipe_table
                    :type('enabled', 'boolean')
                    :type({ 'padding', 'min_width' }, 'number')
                    :type({ 'alignment_indicator', 'head', 'row', 'filler' }, 'string')
                    :list('border', 'string')
                    :one_of('preset', { 'none', 'round', 'double', 'heavy' })
                    :one_of('style', { 'full', 'normal', 'none' })
                    :one_of('cell', { 'trimmed', 'padded', 'raw', 'overlay' })
                    :check()
            end)
            :nested('callout', function(callouts)
                callouts
                    :nested('ALL', function(callout)
                        callout
                            :type({ 'raw', 'rendered', 'highlight' }, 'string')
                            :type('quote_icon', { 'string', 'nil' })
                            :check()
                    end, false)
                    :check()
            end)
            :nested('link', function(link)
                link:type('enabled', 'boolean')
                    :type({ 'image', 'email', 'hyperlink', 'highlight' }, 'string')
                    :nested('footnote', function(footnote)
                        footnote:type('superscript', 'boolean'):type({ 'prefix', 'suffix' }, 'string'):check()
                    end)
                    :nested('wiki', function(wiki)
                        wiki:type({ 'icon', 'highlight' }, 'string'):check()
                    end)
                    :nested('custom', function(patterns)
                        patterns
                            :nested('ALL', function(pattern)
                                pattern
                                    :type({ 'pattern', 'icon' }, 'string')
                                    :type('highlight', { 'string', 'nil' })
                                    :check()
                            end, false)
                            :check()
                    end)
                    :check()
            end)
            :nested('sign', function(sign)
                sign:type('enabled', 'boolean'):type('highlight', 'string'):check()
            end)
            :nested('inline_highlight', function(sign)
                sign:type('enabled', 'boolean'):type('highlight', 'string'):check()
            end)
            :nested('indent', function(indent)
                indent
                    :type({ 'enabled', 'skip_heading' }, 'boolean')
                    :type({ 'per_level', 'skip_level' }, 'number')
                    :check()
            end)
            :nested('html', function(html)
                html:type('enabled', 'boolean')
                    :nested('comment', function(comment)
                        comment
                            :type('conceal', 'boolean')
                            :type('highlight', 'string')
                            :type('text', { 'string', 'nil' })
                            :check()
                    end)
                    :check()
            end)
            :nested('win_options', function(win_options)
                win_options
                    :nested('ALL', function(win_option)
                        win_option:type({ 'default', 'rendered' }, { 'number', 'string', 'boolean' }):check()
                    end, false)
                    :check()
            end)
    end

    local validator = require('render-markdown.debug.validator').new()

    add_buffer_rules(validator:spec(M.config, false))
        :type('log_runtime', 'boolean')
        :list('file_types', 'string')
        :one_of('preset', { 'none', 'lazy', 'obsidian' })
        :one_of('log_level', { 'off', 'debug', 'info', 'error' })
        :nested('injections', function(injections)
            injections
                :nested('ALL', function(injection)
                    injection:type('enabled', 'boolean'):type('query', 'string'):check()
                end)
                :check()
        end)
        :nested('latex', function(latex)
            latex
                :type('enabled', 'boolean')
                :type({ 'top_pad', 'bottom_pad' }, 'number')
                :type({ 'converter', 'highlight' }, 'string')
                :check()
        end)
        :nested('on', function(on)
            on:type({ 'attach', 'render' }, 'function'):check()
        end)
        :nested('overrides', function(overrides)
            overrides
                :nested({ 'buftype', 'filetype' }, function(override)
                    override
                        :nested('ALL', function(buffer)
                            add_buffer_rules(buffer):check()
                        end, true)
                        :check()
                end)
                :check()
        end)
        :nested('custom_handlers', function(custom_handlers)
            custom_handlers
                :nested('ALL', function(spec)
                    spec:type('extends', 'boolean'):type('parse', 'function'):check()
                end)
                :check()
        end)
        :check()

    return validator:get_errors()
end

return M
