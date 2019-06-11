local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "themes/zenburn/theme.lua")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local keys = require("keys.global")
local rules = require("rules")
local widgets = require("widgets");
local config = require("config");

local ctx = { client = client, awesome = awesome, root = root, screen = screen };

config.init(ctx);

-- TODO move to events. errors module
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- TODO move menu to widgets
editor_cmd = terminal .. " -e " .. config.global.editor

myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", config.global.terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

menubar.utils.terminal = config.global.terminal
-- TODO move to widgets
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()

-- TODO move to utils
local function set_wallpaper(s)
    path = beautiful.wallpapers_path
    wallpapers = {}
    awful.spawn.with_line_callback(
        "ls " .. path,
        {
            stdout = function(str)
                wallpapers[#wallpapers + 1] = path .. str
            end,
            output_done = function()

                local wallpaper = wallpapers[math.random(1, #wallpapers)]
                gears.wallpaper.maximized(wallpaper, s, true)

                gears.timer {
                    timeout = 30,
                    autostart = true,
                    callback =
                        function()
                            local wallpaper = wallpapers[math.random(1, #wallpapers)]
                            gears.wallpaper.maximized(wallpaper, s, true)
                        end
                }
            end
        }
    )
end
--TODO move to events
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    local sreen_config = config.screens.get_config(s);

    for _, tag in pairs(sreen_config) do
        awful.tag.add(tag.name, {
            layout = tag.layout,
            screen = s,
            gap = tag.gap or 2.0,
            gap_single_client = false,
            index = tag.index,
            selected = tag.index == 1
        });
    end

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mytaglist = widgets.taglist(s);
    s.mytasklist = widgets.tasklist(s);
    s.mywibox = awful.wibar({ position = "top", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mypromptbox,
            mykeyboardlayout,
            widgets.battery.widget,
            widgets.separator,
            widgets.brightness.widget,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)

-- TODO move to buttons.init
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- TODO move to keys.init
root.keys(gears.table.join(keys, widgets.brightness.keys))

-- TODO move to rules.init
awful.rules.rules = rules

events.init(ctx);

-- TODO move to autostart module
local xresources_name = "awesome.started"
local xresources = awful.util.pread("xrdb -query")
if not xresources:match(xresources_name) then
    awful.util.spawn_with_shell("xrdb -merge <<< " .. "'" .. xresources_name .. ":true'")
    os.execute("dex --environment Awesome --autostart --search-paths $XDG_CONFIG_HOME/autostart")
end
