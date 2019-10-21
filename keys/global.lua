local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local config = require("config.global");
local debug = require("utils.debug");
require("awful.hotkeys_popup.keys")
function new_tag()
    awful.spawn.easy_async("rofi -dmenu -markup -p 'Workspace' -lines 0 -location 2 | echo",
        function(tag_name, err, reason, exit_code)
            if exit_code == 0 then 
                workdir_choose("~/", tag_name);
            end;
    end);
end

function workdir_choose(path, tag_name)
    local command = "(ls -d . .. $(realpath "..path..")/*/ 2>/dev/null || echo '.\n..') | rofi -dmenu -markup -p $(realpath "..path..") -lines 5 -location 2"
    awful.spawn.easy_async_with_shell(command,
        function(str, err, reason, exit_code)
            -- debug.print("err", err)
            -- debug.print("str", str)
            if exit_code == 0 then 
                str = str:gsub("\n", "")
                if str == ".." then
                    str = path .. str .. "/"
                end

                if str ~= "." then
                    workdir_choose(str, tag_name)
                    return;
                end

                local command = "tmux new-session -d -c " .. path:gsub("\n", "") .. " -s '" .. tag_name:gsub("\n", "") .. "'";

                awful.spawn.with_shell(command);

                local tag = awful.tag.add(
                   tag_name:gsub("\n", ""),
                   {
                       screen = awful.screen.focused(),
                       layout = awful.layout.layouts[2]
                   }
                );
                tag.workdir = path:gsub("\n", "");
                tag:view_only();
            end
    end);
end

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
            local tag = awful.screen.focused().selected_tag
            if not tag then return end;
            -- TODO Screen as group?
            local command = config.terminal .. " --command tmux new-session -A -c '" .. (tag.workdir or "")  .. "' -s '" .. (tag.name or "") .. "'"

            awful.spawn(command)
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    awful.key(
        { config.modkey, },
        "a",
        new_tag,
        {description = "new tag", group = "tags"}
    ),
    awful.key(
        { config.modkey, "Shift" },
        "a",
        function()
            awful.spawn.easy_async("rofi -dmenu -markup -p 'Workspace' -lines 0 -location 2 | echo",
                function(tag_name, err, reason, exit_code)
                    if exit_code == 0 then 
                        if not client.focus then return end;

                        local command = "tmux new-session -d -c " .. path:gsub("\n", "") .. " -s '" .. tag_name:gsub("\n", "") .. "'";

                        awful.spawn.with_shell(command);

                        local tag = awful.tag.add(
                           tag_name:gsub("\n", ""),
                           {
                               screen = awful.screen.focused(),
                               layout = awful.layout.layouts[2],
                               volatile = true
                           }
                        );
                        tag.workdir = path:gsub("\n", "");
                        client.focus:tags({tag});
                        tag:view_only();
                    end;
            end);
        end,
        {description = "new tag", group = "tags"}
    ),
    awful.key(
        { config.modkey, "Shift" },
        "d", 
        function () 
            local tag = awful.screen.focused().selected_tag
            if not tag then return end;
            tag:delete();
        end,
        {description = "delete tag", group = "tags"}
    ),
    awful.key(
        { config.modkey, "Shift" },
        "r", 
        function () 
            awful.spawn.easy_async("rofi -dmenu -markup -p 'Rename' -lines 0 -location 2",
                function(tag_name, err, reason, exit_code)
                    if exit_code == 0 then 
                        local tag = awful.screen.focused().selected_tag
                        if not tag then return end;
                        tag.name = tag_name:gsub("\n", "");
                    end
            end);
        end,
        {description = "rename tag", group = "tags"}
    ),
    awful.key(
        { config.modkey, },
        "t", 
        function () 
            local tags = awful.screen.focused().tags;
            local tags_str = "";
            for i=1, #tags do
                local tag = tags[i];
                if #tags_str > 0 then
                    tags_str = tags_str .. ";";
                end
                tags_str = tags_str .. tag.name;
                tags[tag.name] = tag;
            end

            awful.spawn.easy_async_with_shell("echo -e '" .. tags_str .. "' | rofi -dmenu -markup -p 'Tags' -lines " .. #tags .. " -location 2 -sep ';'" ,
                function(tag_name, err, reason, exit_code)
                    if exit_code == 0 then 
                        local tag = tags[tag_name:gsub("\n", "")];

                        if not tag then return end

                        tag:view_only();
                    end
                end
            );
        end,
        {description = "rename tag", group = "tags"}
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
for i = 1, 7 do
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
