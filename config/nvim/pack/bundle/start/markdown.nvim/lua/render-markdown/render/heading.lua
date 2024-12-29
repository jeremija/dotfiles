local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Heading
---@field atx boolean
---@field marker render.md.Node
---@field level integer
---@field icon? string
---@field sign? string
---@field foreground? string
---@field background? string
---@field width render.md.heading.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border boolean

---@class render.md.width.Heading
---@field margin integer
---@field padding integer
---@field content integer

---@class render.md.render.Heading: render.md.Renderer
---@field private heading render.md.Heading
---@field private data render.md.data.Heading
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.heading = self.config.heading
    if not self.heading.enabled then
        return false
    end

    local atx = nil
    local marker = nil
    local level = nil
    if self.node.type == 'atx_heading' then
        atx = true
        marker = assert(self.node:child_at(0), 'atx heading expected child marker')
        level = Str.width(marker.text)
    elseif self.node.type == 'setext_heading' then
        atx = false
        marker = assert(self.node:child_at(1), 'ext heading expected child underline')
        level = marker.type == 'setext_h1_underline' and 1 or 2
    else
        return false
    end

    self.data = {
        atx = atx,
        marker = marker,
        level = level,
        icon = List.cycle(self.heading.icons, level),
        sign = List.cycle(self.heading.signs, level),
        foreground = List.clamp(self.heading.foregrounds, level),
        background = List.clamp(self.heading.backgrounds, level),
        width = List.clamp(self.heading.width, level) or 'full',
        left_margin = List.clamp(self.heading.left_margin, level) or 0,
        left_pad = List.clamp(self.heading.left_pad, level) or 0,
        right_pad = List.clamp(self.heading.right_pad, level) or 0,
        min_width = List.clamp(self.heading.min_width, level) or 0,
        border = List.clamp(self.heading.border, level) or false,
    }

    return true
end

function Render:render()
    if self.heading.sign then
        self:sign(self.data.sign, self.data.foreground)
    end
    local width = self:width(self:icon())
    self:background(width)
    self:left_pad(width)
    if self.data.atx then
        self:border(width)
    else
        self:conceal_underline()
    end
end

---@private
---@return integer
function Render:icon()
    local icon, highlight = self.data.icon, {}
    if self.data.foreground ~= nil then
        table.insert(highlight, self.data.foreground)
    end
    if self.data.background ~= nil then
        table.insert(highlight, self.data.background)
    end
    if self.data.atx then
        local marker = self.data.marker
        -- Add 1 to account for space after last `#`
        local width = self.context:width(marker) + 1
        if icon == nil or #highlight == 0 then
            return width
        end
        if self.heading.position == 'right' then
            self.marks:add_over(true, marker, {
                conceal = '',
            }, { 0, 0, 0, 1 })
            self.marks:add_over('head_icon', marker, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local padding = width - Str.width(icon)
            if self.heading.position == 'inline' or padding < 0 then
                local added = self.marks:add_over('head_icon', marker, {
                    virt_text = { { icon, highlight } },
                    virt_text_pos = 'inline',
                    conceal = '',
                }, { 0, 0, 0, 1 })
                return added and Str.width(icon) or width
            else
                self.marks:add_over('head_icon', marker, {
                    virt_text = { { Str.pad(padding) .. icon, highlight } },
                    virt_text_pos = 'overlay',
                })
                return width
            end
        end
    else
        local node = self.node
        if icon == nil or #highlight == 0 then
            return 0
        end
        if self.heading.position == 'right' then
            self.marks:add_over('head_icon', node, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local added = true
            for row = node.start_row, node.end_row - 1 do
                local added_row = self.marks:add('head_icon', row, node.start_col, {
                    end_row = row,
                    end_col = node.end_col,
                    virt_text = { { row == node.start_row and icon or Str.pad(Str.width(icon)), highlight } },
                    virt_text_pos = 'inline',
                })
                added = added and added_row
            end
            return added and Str.width(icon) or 0
        end
    end
end

---@private
---@param icon_width integer
---@return render.md.width.Heading
function Render:width(icon_width)
    local width = icon_width
    if self.data.atx then
        width = width + self.context:width(self.node:child('inline'))
    else
        width = width + vim.fn.max(Iter.list.map(self.node:lines(), Str.width))
    end
    local left_padding = self.context:resolve_offset(self.data.left_pad, width)
    local right_padding = self.context:resolve_offset(self.data.right_pad, width)
    width = math.max(left_padding + width + right_padding, self.data.min_width)
    ---@type render.md.width.Heading
    return {
        margin = self.context:resolve_offset(self.data.left_margin, width),
        padding = left_padding,
        content = width,
    }
end

---@private
---@param width render.md.width.Heading
function Render:background(width)
    local highlight = self.data.background
    if highlight == nil then
        return
    end
    local win_col, padding = 0, {}
    if self.data.width == 'block' then
        win_col = width.margin + width.content + self:indent(self.data.level)
        table.insert(padding, self:padding_text(vim.o.columns * 2))
    end
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add('head_background', row, 0, {
            end_row = row + 1,
            hl_group = highlight,
            hl_eol = true,
        })
        if win_col > 0 and #padding > 0 then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add('head_background', row, 0, {
                priority = 0,
                virt_text = padding,
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param width render.md.width.Heading
function Render:border(width)
    if not self.data.border then
        return
    end

    local foreground = self.data.foreground
    local background = self.data.background and colors.bg_to_fg(self.data.background)
    local prefix = self.heading.border_prefix and self.data.level or 0
    local virtual = self.heading.border_virtual

    ---@param icon string
    ---@return { [1]: string, [2]: string }[]
    local function line(icon)
        ---@param size integer
        ---@param highlight? string
        ---@return { [1]: string, [2]: string }
        local function section(size, highlight)
            if highlight ~= nil then
                return { icon:rep(size), highlight }
            else
                return self:padding_text(size)
            end
        end
        local content_width = self.data.width == 'block' and width.content or vim.o.columns
        return {
            section(width.margin, nil),
            section(width.padding, background),
            section(prefix, foreground),
            section(content_width - width.padding - prefix, background),
        }
    end

    local line_above = line(self.heading.above)
    if not virtual and self:empty_line('above') and self.node.start_row - 1 ~= self.context.last_heading then
        self.marks:add('head_border', self.node.start_row - 1, 0, {
            virt_text = line_above,
            virt_text_pos = 'overlay',
        })
    else
        self.marks:add(false, self.node.start_row, 0, {
            virt_lines = { self:indent_virt_line(line_above, self.data.level) },
            virt_lines_above = true,
        })
    end

    local line_below = line(self.heading.below)
    if not virtual and self:empty_line('below') then
        self.marks:add('head_border', self.node.end_row, 0, {
            virt_text = line_below,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = self.node.end_row
    else
        self.marks:add(false, self.node.start_row, 0, {
            virt_lines = { self:indent_virt_line(line_below, self.data.level) },
        })
    end
end

---@private
---@param position 'above'|'below'
---@return boolean
function Render:empty_line(position)
    local line = self.node:line(position, 1)
    return line ~= nil and Str.width(line) == 0
end

---@private
---@param width render.md.width.Heading
function Render:left_pad(width)
    local virt_text = {}
    if width.margin > 0 then
        table.insert(virt_text, self:padding_text(width.margin))
    end
    if width.padding > 0 then
        table.insert(virt_text, self:padding_text(width.padding, self.data.background))
    end
    if #virt_text == 0 then
        return
    end
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = virt_text,
            virt_text_pos = 'inline',
        })
    end
end

---@private
function Render:conceal_underline()
    self.marks:add_over(true, self.data.marker, {
        conceal = '',
    })
end

return Render
