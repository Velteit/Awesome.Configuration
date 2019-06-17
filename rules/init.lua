local awful = require("awful");
local beautiful = require("beautiful");
local global_rule = require("rules.global");
local floating_rule = require("rules.floating");
local dialog_rule = require("rules.dialog");
local chats = require("rules.chats");
local gears = require("gears");

local rules = {
    global_rule,
    -- Floating clients.
    floating_rule,
    -- Add titlebars to normal clients and dialogs
    dialog_rule,
    chats

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },) (
};

return rules;
