local gears = require("gears");
local beautiful = require("beautiful");
local awful = require("awful");
local wibox = require("wibox");
local naughty = require("naughty");
local json = require("utils.json");
local math = require("math");
local rx = require("RxLua.rx");
require("utils.try");

local PlayerState = {
    Stop = 1,
    Play = 2,
    Pause = 3,
}
function PlayerState.from_string(str)
    local states = { playing = PlayerState.Play, pause = PlayerState.Pause, stop = PlayerState.Stop };

    return states[str];
end

function highlight(wdg)
    wdg:connect_signal(
        "mouse::enter",
        function (w)
            -- state.errors.onNext("focus");
            w.bg = beautiful.bg_focus;
            w.fg = beautiful.fg_focus;
        end
    );
    wdg:connect_signal(
        "mouse::leave",
        function (w)
            w.bg = beautiful.bg_normal;
            w.fg = beautiful.fg_normal;
        end
    );
end


local state = {
    state = rx.Subject.create(),
    playlist = rx.BehaviorSubject.create({}),
    current_song = {
        name = rx.Subject.create(),
        position = rx.Subject.create(),
        duration = rx.Subject.create()
    },
    menu = {
        visible = rx.BehaviorSubject.create(false),
        current_location = rx.BehaviorSubject.create(0)
    },
    errors = rx.Subject.create()
}

function handle_error(error)
    state.errors:onNext(error);
end

function state.update_playlist(stdout)
    local songs = {};
    local idx = 1;

    for song in stdout:gmatch("[^\r\n]+") do
        songs[idx] = song;
        idx = idx + 1;
    end

    local previous_songs = state.playlist:getValue();
    local has_difference = false;

    for i=1,#songs do
        if previous_songs[i] == nil or not(previous_songs[i] == songs[i]) then
            has_difference = true;
            break;
        end
    end

    if has_difference then
        state.playlist:onNext(songs);
    end
end

function state.update_state(newState)
    state.state:onNext(newState);
end

function state.update_current_song_name(artist)
    state.current_song.name:onNext(artist);
end

function state.update_current_song_position(value)
    state.current_song.position:onNext(value);
end

function state.update_current_song_duration(value)
    state.current_song.duration:onNext(value);
end

function state.menu.toggle_visible()
    try {
        function()
            state.menu.visible:onNext(not(state.menu.visible:getValue()));
        end,
        catch {
            handle_error
        }
    };
end

function state.menu.scroll(value)
    local index = math.min(math.max(0, value), #(state.playlist:getValue()))

    state.menu.current_location.onNext(index);
end;

local current_song = wibox.widget {
    widget  = wibox.widget.textbox,
    align   = "center"
};

local menu_slider = wibox.widget {
    handle_color        = beautiful.fg_normal,
    handle_shape        = gears.shape.rectangle,
    handle_border_color = beautiful.border_normal,
    bar_color           = beautiful.bg_normal,
    bar_shape           = gears.shape.rounded_rect,
    bar_height          = 3,
    maximum_width       = 10,
    -- handle_color        = "red",
    -- handle_shape        = gears.shape.rectangle,
    -- handle_border_color = "blue",
    handle_border_width = 1,
    value   = 10,
    widget  = wibox.widget.slider
};
-- menu_slider:connect_signal("property::value", function(a) handle_error(tostring(json.stringify(a))) end);

local count = 13;

local menu_items = {

};

function menu_items.redraw(index, songs)
    for i=1,count do
        menu_items[i]:set_text(songs[index*count + i]);
    end
end

local menu_visible_items = {
    layout = wibox.layout.fixed.vertical
};

for i=1,count do
    local text_wdg = wibox.widget {
        text    = "aaa",
        align   = "center",
        widget  = wibox.widget.textbox
    };

    menu_items[i] = text_wdg;
    local inner = wibox.widget {
        {
            {
                {
                    text_wdg,
                    max_size        = 200,
                    step_function   = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                    speed           = 50,
                    layout          = wibox.layout.scroll.horizontal,
                },
                widget              = wibox.container.background
            },
            left                    = 10,
            right                   = 10,
            top                     = 7,
            bottom                  = 7,
            widget                  = wibox.container.margin
        },
        widget                      = wibox.container.background,
        shape                       = gears.shape.rounded_rect,
        background_color            = beautiful.bg_normal,
        shape_border_color          = beautiful.border_normal,
        shape_border_width          = 2
    };
    local list_item = wibox.widget {
        inner,
        widget                          = wibox.container.margin,
        top                             = 2,
        bottom                          = 2
    };

    highlight(inner);
    inner:connect_signal(
        "button::press",
        function (wdg, _, _, button, _, geo)
            local index = i;

            if button == 1 then
                local command = string.format("mpc play %d", index + (state.menu.current_location:getValue()));

                awful.spawn(command);
            end
        end
    );

    table.insert(menu_visible_items, list_item);
end


local menu_list = {
    {
        {
            menu_visible_items,
            {
                menu_slider,
                direction   = "west",
                widget      = wibox.container.rotate
            },
            layout          = wibox.layout.flex.horizontal
        },
        left                = 5,
        right               = 5,
        top                 = 5,
        bottom              = 5,
        widget              = wibox.container.margin,
    },
    widget                  = wibox.container.background,
    shape                   = gears.shape.rounded_rect,
    background_color        = beautiful.bg_normal,
    shape_border_color      = beautiful.border_normal,
    shape_border_width      = 2
};

local widget = {
    menu = awful.popup {
        widget                  = menu_list,
        minimum_width           = 200,
        minimum_height          = 200,
        maximum_height          = 500,
        maximum_width           = 500,
        shape                   = gears.shape.rounded_rect,
        background_color        = beautiful.bg_normal,
        shape_border_color      = beautiful.border_normal,
        shape_border_width      = 2,
        preferred_positions     = "bottom",
        visible                 = false,
        ontop                   = true
    }
};

function duration_to_seconds(str)
    local minute = 0;
    local seconds = 0;

    for k,v in str:gmatch("([0-9]+):([0-9]+)") do
        minute = tonumber(k);
        seconds = tonumber(v);
    end

    return minute*60 + seconds;
end

local powerline_reverse = function(cr, width, height)
    gears.shape.transform(gears.shape.powerline):rotate_at(width/2, height/2, math.pi)(cr, width, height)
end

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

function widget.toggle_menu(wdg, _, _, button, geo)
    try {
        function()


            state.menu.toggle_visible();
            widget.menu:move_next_to(geo);
        end,
        catch {
            handle_error
        }
    }
end

function btn(text, shape, func)
    local widget = wibox.widget {
        text    = text,
        align   = "center",
        widget  = wibox.widget.textbox
    };

    return btn_base(widget, shape, func, func);
end

function btn_base(widget, shape, func, func2)
    local w = wibox.widget {
        {
            widget,
            widget          = wibox.container.margin,
        },
        shape = shape,
        shape_border_color  = beautiful.border_normal,
        shape_border_width  = 2,
        widget              = wibox.container.background
    }
    highlight(w);
    w:connect_signal("button::press",
        function (wdg, _, _, button, _, geo)
            if button == 1 then
                func(wdg, _, _, button, geo)
            end

            if button == 3 then
                func2(wdg, _, _, button, geo)
            end;
        end
    );
    return wibox.widget {
        w,
        widget = wibox.container.margin
    };
end

local imagebox = wibox.widget {
    -- image       = beautiful.widgets.mpc.icons[PlayerState.Stop],
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
    widget              = wibox.widget.progressbar,
    shape               = gears.shape.hexagon,
};

local play = wibox.widget {
    progressbar,
    {
        {
            imagebox,
            {
                current_song,
                layout          = wibox.layout.scroll.horizontal,
                max_size        = 100,
                step_function   = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                speed           = 50,
            },
            layout              = wibox.layout.align.horizontal
        },
        left                    = 10,
        widget                  = wibox.container.margin
    },
    forced_width                = 100,
    layout                      = wibox.layout.stack
};

local inner_widget = wibox.widget {
    btn("P", powerline_reverse, widget.previous),
    btn_base(play, gears.shape.hexagon, widget.toggle, widget.toggle_menu),
    btn("N", gears.shape.powerline, widget.next),
    layout = wibox.layout.ratio.horizontal,
    forced_width = 200
};
inner_widget:ajust_ratio(2, 0.25, 0.5, 0.25);

state.playlist:subscribe(function(songs)
    try {
        function ()
            local current_position = state.menu.current_location:getValue();

            menu_items.redraw(current_position, songs);

            widget.menu:setup(menu_list);
        end,
        catch {
            handle_error
        }
    }
end);

state.errors:subscribe(function(err)
    naughty.notify({
        title   = "Music",
        text    = err,
        preset  = naughty.config.presets.critical
    });
end);

state.current_song.name:subscribe(function(name)
    current_song:set_text(name);

    naughty.notify({
        title   = "Music",
        text    = name,
        preset  = naughty.config.presets.normal
    });
end);


state.state:subscribe(function(state)
    imagebox.image = beautiful.widgets.mpc.icons[state];
end);

state.current_song.position:combineLatest(state.current_song.duration):subscribe(function(position, duration)
    progressbar:set_value((position or 0)/(duration or 1));
end);

state.menu.visible:subscribe(function(value)
    widget.menu.visible = value;
    -- handle_error(tostring(widget.menu.visible));
end, handle_error);

local playlist_timer = gears.timer {
    timeout     = 1,
    call_now    = false,
    autostart   = true,
    callback    = function()
        awful.spawn.easy_async(
            { "mpc", "playlist" },
            function (stdout)
                state.update_playlist(stdout);
            end
        )
    end
}

local state_timer = gears.timer {
    timeout     = 0.5,
    call_now    = false,
    autostart   = true,
    callback    = function()
        awful.spawn.easy_async(
            { "sh", "-c", "mpc" },
            function(stdout)
                local sstate = (stdout:find("playing") and "playing") or (stdout:find("paused") and "pause") or  "stop";
                local current = duration_to_seconds(stdout:match("[0-9]+:[0-9]+") or "0:0");

                local pstate = PlayerState.from_string(sstate);

                state.update_current_song_position(current);
                state.update_state(pstate);

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

            state.update_current_song_name(song);
            state.update_current_song_duration(duration_to_seconds(value.time));
        end,
        stderr = handle_error
    }
);

widget.keys =  gears.table.join(
    awful.key(
        {},
        "XF86AudioPlay",
        widget.toggle,
        {description = "Toggle mpc play", group = "widgets:mpc"}
    )
);

widget.widget = inner_widget;

return w
