Config = {}

--[[ Basic Configuration Options ]]--
Config.UseCommands = true        -- Enable command-based hostage taking
Config.UseOxTarget = true        -- Enable ox_target-based hostage taking
Config.EnableReleaseOption = true -- Allow releasing hostages
Config.EnableKillOption = true   -- Allow killing hostages

--[[ Interaction Settings ]]--
Config.InteractionDistance = 3.0 -- Maximum distance to interact with a player
Config.Cooldown = 5000           -- Cooldown between hostage attempts (in ms)

--[[ Commands ]]--
Config.Commands = {
    TakeHostage = "takehostage", -- Command to take a hostage
    TakeHostageShort = "th"      -- Short version of take hostage command
}

--[[ UI Settings ]]--
Config.NotificationType = "help" -- Notification type: "help", "notification", "chat" or "custom" (Add in client/cl_takehostage.lua)

--[[ Weapons Configuration ]]--
Config.AllowedWeapons = {
    `WEAPON_PISTOL`,
    `WEAPON_COMBATPISTOL`,
    `WEAPON_PISTOL50`,
    `WEAPON_SNSPISTOL`,
    `WEAPON_HEAVYPISTOL`,
    `WEAPON_VINTAGEPISTOL`,
    `WEAPON_REVOLVER`,
    `WEAPON_APPISTOL`
    -- Add any other weapons you want to allow
}

--[[ Key Bindings ]]--
Config.ReleaseKey = 47  -- G key
Config.KillKey = 74     -- H key

--[[ ox_target Configuration ]]--
Config.OxTarget = {
    Label = "Take Hostage",
    Icon = "fas fa-user-shield",
    Distance = 2.0  -- Maximum distance for ox_target interaction
}

return Config
