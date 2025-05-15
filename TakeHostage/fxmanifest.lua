fx_version 'cerulean'
game 'gta5'

author 'Original: Robbster'
description 'Take Hostage Script with ox_target integration'
version '2.0.0'

-- Define shared scripts
shared_scripts {
    'config.lua'
}

-- Define client scripts
client_scripts {
    'client/cl_takehostage.lua'
}

-- Define server scripts
server_scripts {
    'server/sv_takehostage.lua'
}

-- Define dependencies
dependencies {
    'ox_target'  -- Only required if Config.UseOxTarget is true
}
