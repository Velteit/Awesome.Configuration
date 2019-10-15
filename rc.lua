local beautiful = require("beautiful")
local awful = require("awful")
beautiful.init(awful.util.getdir("config") .. "themes/default/theme.lua")

local gears = require("gears")
require("awful.autofocus")
local wibox = require("wibox")
naughty = require("naughty")
local menubar = require("menubar")
local keys = require("keys.global")
local rules = require("rules")
local widgets = require("widgets");
local config = require("config");
local events = require("events");
local autorun = require("autorun");


local ctx = { client = client, awesome = awesome, root = root, screen = screen };

config.init(ctx);
widgets.init(ctx);


-- TODO move menu to widgets
editor_cmd = config.global.terminal .. " -e " .. config.global.editor

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
        local command = "tmux new-session -d -c ~/ -s '" .. tag.name .. "'";

        awful.spawn.with_shell(command);

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
    s.mywibox = awful.wibar({ position = "top", height = 20, screen = s })

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
            widgets.kbd.widget,
            widgets.battery.widget,
            widgets.separator,
            widgets.brightness.widget,
            widgets.volume.widget,
            wibox.widget.systray(),
            widgets.clock.widget,
            s.mylayoutbox,
        },
    }
end)

-- TODO move to buttons.init
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- TODO move to keys.init
root.keys(gears.table.join(keys, widgets.brightness.keys, widgets.volume.keys))

-- TODO move to rules.init
awful.rules.rules = rules

events.init(ctx);
autorun.init(ctx);
