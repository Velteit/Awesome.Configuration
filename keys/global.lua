local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local config = require("config.global");
require("awful.hotkeys_popup.keys")

local keys = gears.table.join(
    awful.key(
        { config.modkey, }, 
        "s",
        hotkeys_popup.show_help,
        {description="show help", group="awesome"}
    ),
    awful.key(
        { config.modkey, },
        "Left",
        awful.tag.viewprev,
        {description = "view previous", group = "tag"}
    ),
    awful.key(
        { config.modkey, },
        "Right",
        awful.tag.viewnext,
        {description = "view next", group = "tag"}
    ),
    awful.key(
        { config.modkey, },
        "Escape", 
        awful.tag.history.restore,
        {description = "go back", group = "tag"}
    ),
    awful.key(
        { config.modkey, },
        "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key(
        { config.modkey, },
        "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key(
        { config.modkey, },
        "w",
        function ()
            mymainmenu:show()
        end,
        {description = "show main menu", group = "awesome"}
    ),
    -- Layout manipulation
    awful.key(
        { config.modkey, "Shift" },
        "j",
        function ()
            awful.client.swap.byidx(1)
        end,
        {description = "swap with next client by index", group = "client"}
    ),
    awful.key(
        { config.modkey, "Shift" },
        "k",
        function () 
            awful.client.swap.byidx(-1)
        end,
        {description = "swap with previous client by index", group = "client"}
    ),
    awful.key(
        { config.modkey, "Control" }, 
        "j", 
        function ()
            awful.screen.focus_relative( 1) 
        end,
        {description = "focus the next screen", group = "screen"}
    ),
    awful.key(
        { config.modkey, "Control" }, 
        "k", 
        function ()
            awful.screen.focus_relative(-1) 
        end,
        {description = "focus the previous screen", group = "screen"}
    ),
    awful.key(
        { config.modkey, }, 
        "u", 
        awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}
    ),
    awful.key(
        { config.modkey, }, 
        "Tab",
        function ()
            awful.menu.clients();
        end,
        {description = "List Of Clients", group = "client"}
    ),
    -- Standard program
    awful.key(
        { config.modkey, },
        "Return", 
        function () 
            awful.spawn(config.terminal) 
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    awful.key(
        { config.modkey, "Control" },
        "r", 
        awesome.restart,
        {description = "reload awesome", group = "awesome"}
    ),
    awful.key(
        { config.modkey, "Shift"   },
        "q",
        awesome.quit,
        {description = "quit awesome", group = "awesome"}
    ),

    awful.key(
        { config.modkey, },
        "l",
        function ()
            awful.tag.incmwfact(0.05)
        end,
        {description = "increase master width factor", group = "layout"}
    ),
    awful.key(
        { config.modkey, },
        "h",
        function ()
            awful.tag.incmwfact(-0.05)
        end,
        {description = "decrease master width factor", group = "layout"}
    ),
    awful.key(
        { config.modkey, "Shift"   },
        "h",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end,
        {description = "increase the number of master clients", group = "layout"}
    ),
    awful.key(
        { config.modkey, "Shift"   },
        "l",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "decrease the number of master clients", group = "layout"}
    ),
    awful.key(
        { config.modkey, "Control" },
        "h",
        function ()
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}
    ),
    awful.key(
        { config.modkey, "Control" },
        "l",
        function ()
            awful.tag.incncol(-1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}
    ),
    awful.key(
        { config.modkey, },
        "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}
    ),
    awful.key(
        { config.modkey, "Shift"   },
        "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}
    ),

    awful.key(
        { config.modkey, "Control" },
        "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}
    ),

    -- Prompt
    awful.key(
        { config.modkey },
        "r",
        function () 
            awful.spawn("rofi -show drun", { screen = awful.screen.focused().index });
            -- awful.screen.focused().mypromptbox:run() 
        end,
        {description = "run prompt", group = "launcher"}
    )
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 6 do
    keys = gears.table.join(
        keys,
        -- View tag only.
        awful.key(
            { config.modkey },
            "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}
        ),
        -- Toggle tag display.
        awful.key(
            { config.modkey, "Control" },
            "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}
        ),
        -- Move client to tag.
        awful.key(
            { config.modkey, "Shift" },
            "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}
        ),
        -- Toggle tag on focused client.
        awful.key(
            { config.modkey, "Control", "Shift" },
            "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

return keys;
