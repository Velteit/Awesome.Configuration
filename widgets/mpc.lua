local gears = require("gears");
local beautiful = require("beautiful");
local awful = require("awful");
local wibox = require("wibox");
local naughty = require("naughty");
local json = require("utils.json");
local math = require("math");

function catch(what)
    return what[1]
end

function try(what)
    status, result = pcall(what[1])
    if not status then
        what[2](result)
    end
    return result
end
local State = {
    Stop = 1,
    Play = 2,
    Pause = 3
}

local states = { playing = State.Play, pause = State.Pause, stop = State.Stop };
local widget = {
    state = State.Stop,
    current_song = nil,
    icons = {
        "/usr/share/icons/Adwaita/16x16/actions/media-playback-stop-symbolic.symbolic.png",
        "/usr/share/icons/Adwaita/16x16/actions/media-playback-start-symbolic.symbolic.png",
        "/usr/share/icons/Adwaita/16x16/actions/media-playback-pause-symbolic.symbolic.png",
    }
};

function widget.next()
    local command = "mpc next";
    awful.spawn.with_shell(command);
end

function widget.previous()
    local command = "mpc prev";
    awful.spawn.with_shell(command);
end

function widget.toggle()
    local command = "mpc toggle";
    awful.spawn.with_shell(command);
end

function btn(text, shape, func)
    local w = wibox.widget {
        {
            {
                text = text,
                align = "center",
                widget = wibox.widget.textbox 
            },
            widget = wibox.container.margin,
            top = 1,
            bottom = 1
        },
        shape = shape,
        shape_border_color = beautiful.border_normal,
        shape_border_width = 2,
        widget = wibox.container.background
    } 
    w:connect_signal(
        "mouse::enter",
        function (wdg)
            w.bg = beautiful.bg_focus;
            w.fg = beautiful.fg_focus;
        end
    );
    w:connect_signal(
        "mouse::leave",
        function (wdg)
            w.bg = beautiful.bg_normal;
            w.fg = beautiful.fg_normal;
        end
    );
    w:connect_signal("button::press", 
        function (wdg, _, _, button, _, geo)
            if button == 1 then
                func()
            end
        end
    );
    return wibox.widget {
        w,
        top = 3,
        bottom = 3,
        left = 3,
        right = 3,
        widget = wibox.container.margin
    };
end

local current_song = wibox.widget {
    widget      = wibox.widget.textbox,
    align = "center"
};
local imagebox = wibox.widget {
    image       = widget.icons[State.Stop],
    widget      = wibox.widget.imagebox
};
local progressbar = wibox.widget {
    max_value           = 1,
    value               = 0.0,
    forced_height       = 20,
    forced_width        = 100,
    paddings            = 1,
    background_color    = beautiful.bg_normal,
    color               = beautiful.bg_focus,
    border_color        = beautiful.border_normal,
    border_width        = beautiful.border_width,
    shape               = gears.shape.current_shape,
    widget              = wibox.widget.progressbar,
};
local inner_widget = wibox.widget {
    progressbar,
    { 
        {
            imagebox,
            {
                current_song,
                layout = wibox.layout.scroll.horizontal,
                max_size = 100,
                step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                speed = 50,
            },
            layout = wibox.layout.align.horizontal
        },
        left                = 10,
        widget              = wibox.container.margin
    },
    layout                  = wibox.layout.stack
};

local powerline_reverse = function(cr, width, height)
    gears.shape.transform(gears.shape.powerline):rotate_at(width/2, height/2, math.pi)(cr, width, height)
end 

local buttons = wibox.widget {
    {
        btn("Previous", powerline_reverse, widget.previous),
        btn("Toggle", gears.shape.hexagon, widget.toggle),
        btn("Next", gears.shape.powerline, widget.next),
        layout = wibox.layout.flex.horizontal
    },
    top = 4,
    bottom = 4,
    widget = wibox.container.margin
};
local menu = awful.popup {
    widget = { },
    minimum_width = 400,
    shape = gears.shape.round_rect,
    preferred_positions = "bottom",
    visible = false,
    ontop = true
}


local menu_visible = false;
inner_widget:connect_signal(
    "button::press",
    function (wdg, _, _, button, _, geo)
        awful.spawn.easy_async(
            { "mpc", "playlist" },
            function (stdout)
                menu_visible = not(menu_visible);

                try {
                    function()
                        if menu_visible then
                            local songs = {};
                            for song in stdout:gmatch("[^\r\n]+") do songs[#songs + 1] = song; end
                            local songs_container = wibox.widget {
                                layout = wibox.layout.grid.vertical,
                                forced_num_cols = #songs//20,
                                forced_num_rows = 20,
                                homogenous = true
                            };
                            local menu_container = {
                                {

                                    {
                                        current_song,
                                        layout = wibox.layout.align.horizontal,
                                    },
                                    buttons,
                                    {
                                        songs_container,
                                        widget = wibox.container.margin,
                                        top = 5,
                                        left = 5,
                                        right = 5,
                                        bottom = 5
                                    },
                                    layout = wibox.layout.align.vertical
                                },
                                widget = wibox.container.background,
                                shape              = gears.shape.rounded_rect,
                                background_color    = beautiful.bg_normal,
                                shape_border_color        = beautiful.border_normal,
                                shape_border_width = 2
                            };

                            local i = 1;
                            local j = 1;

                            for _,song in pairs(songs) do
                                local current = current_song.text == song;
                                local inner_part = wibox.widget {
                                    {
                                        {
                                            text = song,
                                            widget = wibox.widget.textbox
                                        },
                                        widget = wibox.container.margin,
                                        left = 6,
                                        right = 6,
                                        top = 2,
                                        bottom = 2
                                    },
                                    widget = wibox.container.background
                                };

                                inner_part.id = i + (j-1)*20;

                                if current then 
                                    inner_part.bg = beautiful.bg_urgent;
                                    inner_part.fg = beautiful.fg_urgent;

                                    menu.current_song_wdg = inner_part;
                                end

                                local widget = wibox.widget {
                                    {
                                        inner_part,
                                        shape              = gears.shape.rectangle,
                                        bg                 = beautiful.bg_normal,
                                        shape_border_color = beautiful.border_focus,
                                        shape_border_width = beautiful.border_width,
                                        widget = wibox.container.background
                                    },
                                    widget = wibox.container.margin,
                                    top = 2,
                                    bottom = 2,
                                    left = 10,
                                    right = 10
                                };

                                inner_part:connect_signal(
                                    "mouse::enter",
                                    function (wdg)
                                        wdg.pbg = wdg.bg;
                                        wdg.bg = beautiful.bg_focus;

                                        wdg.pfg = wdg.fg;
                                        wdg.fg = beautiful.fg_focus;
                                    end
                                );
                                inner_part:connect_signal(
                                    "mouse::leave",
                                    function (wdg)
                                        wdg.bg = wdg.pbg;
                                        wdg.fg = wdg.pfg;
                                    end
                                );
                                inner_part:connect_signal(
                                    "button::press", 
                                    function (wdg, _, _, button, _, geo)
                                        if button == 1 then
                                            -- local command = string.format("mpc play %d", (i - 1) + (j-1)*20);
                                            local command = string.format("mpc play %d", wdg.id);

                                            awful.spawn(command);

                                            menu.current_song_wdg.bg = beautiful.bg_normal;
                                            menu.current_song_wdg.pbg = beautiful.bg_normal;
                                            menu.current_song_wdg.fg = beautiful.fg_normal;
                                            menu.current_song_wdg.pfg = beautiful.fg_normal;

                                            wdg.pbg = beautiful.bg_urgent;
                                            wdg.pfg = beautiful.fg_urgent;

                                            menu.current_song_wdg = wdg;
                                        end
                                    end
                                );

                                -- table.insert(songs_container, widget);
                                songs_container:add_widget_at(widget, i, j);

                                if i%20 == 0 then
                                    i = 1;
                                    j = j + 1;
                                else
                                    i = i + 1;
                                end
                            end


                            menu:setup(menu_container);
                        end
                    end,
                    catch {
                        function(error) naughty.notify({text = error}); end
                    }
                }

                menu:move_next_to(geo);
                menu.visible = menu_visible;
            end
        );
    end
);

local state_timer = gears.timer {
    timeout = 0.5,
    call_now = false,
    autostart = true,
    callback = function()
        awful.spawn.easy_async(
            { "sh", "-c", "mpc" },
            function(stdout)
                local state = (stdout:find("playing") and "playing") or (stdout:find("paused") and "pause") or  "stop";
                local current = duration_to_seconds(stdout:match("[0-9]+:[0-9]+") or "0:0");
                local all = duration_to_seconds((widget.current_song or {time = "0:0"}).time or "0:0");
                local pstate = states[state];

                if not(pstate == widget.state) then
                    widget.state = pstate;
                    imagebox.image = widget.icons[widget.state];
                end


                if widget.state == State.Play then
                    progressbar:set_value(current/all);
                elseif widget.state == State.Stop then
                    progressbar:set_value(current/all);
                end
            end
        );
    end
};

awful.spawn.with_line_callback(
    string.format("bash -c \"%s\"", "mpc idleloop player | while read event; do echo $(mpc -f '{ \\\"artist\\\": \\\"%artist%\\\", \\\"title\\\": \\\"%title%\\\", \\\"time\\\": \\\"%time%\\\" }' current); done"),
    {
        stdout = function (stdout)
            local value = json.parse(stdout);
            local song = string.format("%s - %s", value.artist, value.title);

            naughty.notify({
                title = "Music",
                text = song,
                preset = naughty.config.presets.normal
            });

            widget.current_song = {
                artist = value.artist,
                title = value.title,
                time = value.time
            };

            current_song:set_text(song);
        end,
        stderr = function (stderr)
            naughty.notify({
                title = "Music",
                text = stderr,
                preset = naughty.config.presets.critical
            });
        end
    }
);

function duration_to_seconds(str)
    local minute = 0;
    local seconds = 0;

    for k,v in str:gmatch("([0-9]+):([0-9]+)") do
        minute = tonumber(k);
        seconds = tonumber(v);
    end

    return minute*60 + seconds;
end
widget.keys =  gears.table.join(
    awful.key(
        {},
        "XF86AudioPlay",
        widget.toggle,
        {description = "Toggle mpc play", group = "widgets:mpc"}
    )
);

widget.widget = inner_widget;

return widget;
