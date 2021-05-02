local awful = require("awful");
local beautiful = require("beautiful");
local global_rule = require("rules.global");
local floating_rule = require("rules.floating");
local dialog_rule = require("rules.dialog");
local telegram = require("rules.telegram");
local teams = require("rules.teams");
local rider = require("rules.rider");
local freerdp = require("rules.freerdp");
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
    telegram,
    rider,
    term,
    teams,
    freerdp,
};

return rules;
