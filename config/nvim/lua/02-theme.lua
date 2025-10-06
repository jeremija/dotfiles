local theme_file_path = vim.fn.expand("$HOME/.theme")

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return "dark"
  end
  local content = file:read("*line")
  file:close()
  return content
end

local function set_dark_mode()
  vim.api.nvim_set_option_value("background", "dark", {})
  vim.cmd([[colorscheme jeremija]])
end

local function set_light_mode()
  vim.api.nvim_set_option_value("background", "light", {})
  vim.cmd([[colorscheme jeremija]])
end

local function switch_theme(theme)
  if theme == "light" then
    set_light_mode()
    print("Switching to light mode 🌖")
  else
    set_dark_mode()
    print("Switching to dark mode 🌘")
  end
end

local function watch_theme_change()
  local handle = vim.uv.new_fs_event()

  local unwatch_cb = function()
    if handle then
      vim.uv.fs_event_stop(handle)
    end
  end

  local event_cb = function(err)
    if err then
      error("Theme file watcher failed")
      unwatch_cb()
    else
      -- Important to wrap in schedule, otherwise error E5560
      vim.schedule(function()
        local theme = read_file(theme_file_path)
        switch_theme(theme)
        -- unwatch_cb()
        -- watch_theme_change()
      end)
    end
  end

  local flags = {
    watch_entry = false, -- true = when dir, watch dir inode, not dir content
    stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
    recursive = false, -- true = watch dirs inside dirs
  }

  -- attach handler
  if handle then
    vim.uv.fs_event_start(handle, theme_file_path, flags, event_cb)
  end

  return handle
end

local theme = read_file(theme_file_path)

-- switch theme in a schedule so that vim/_defaults.lua is loaded first.
vim.schedule(function()
  switch_theme(theme)
end)

watch_theme_change()
