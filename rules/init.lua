local awful = require("awful");
local beautiful = require("beautiful");
local global_rule = require("rules.global");
local floating_rule = require("rules.floating");
local dialog_rule = require("rules.dialog");
local chats = require("rules.chats");
local rider = require("rules.rider");
local web = require("rules.web");
local pip = require("rules.pip");
local term = require("rules.term");
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
    rider,
    term,
};

return rules;
