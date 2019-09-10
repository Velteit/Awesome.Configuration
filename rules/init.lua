local awful = require("awful");
local beautiful = require("beautiful");
local global_rule = require("rules.global");
local floating_rule = require("rules.floating");
local dialog_rule = require("rules.dialog");
local chats = require("rules.chats");
local rider = require("rules.rider");
local web = require("rules.web");
local pip = require("rules.pip");
local gears = require("gears");

local rules = {
    global_rule,
    -- Floating clients.
    floating_rule,
    -- Add titlebars to normal clients and dialogs
    dialog_rule,
    web,
    pip,
    chats,
    rider

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },) (
};

return rules;
