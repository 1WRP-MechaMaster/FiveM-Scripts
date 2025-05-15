# Take Hostage by Robbster

Overview
This resource allows players to take other players as hostages at gunpoint in FiveM. The script features both traditional command-based hostage taking and modern ox_target integration for a more immersive roleplaying experience.
Originally created by Robbster, this enhanced version adds ox_target integration and a robust configuration system while maintaining all the original functionality.

Dependencies

ox_target (Only required if ox_target integration is enabled)

Installation

Download the latest release
Extract the files to your server's resources folder
Rename the folder to take_hostage (or any name you prefer)
Add ensure take_hostage to your server.cfg
If using ox_target, ensure it loads before this resource
Configure the script by editing config.lua
Restart your server or start the resource

Usage
Command Method
By default, the script provides two commands:

/takehostage - Take the nearest player as hostage
/th - Shorthand for the take hostage command

ox_target Method
When near another player, you can use ox_target's interaction menu to select "Take Hostage" option.
When Taking a Hostage

You must have a compatible pistol with ammunition
Press G to release the hostage unharmed
Press H to execute the hostage (if enabled in config)
You cannot sprint or use weapons while holding a hostage

When Being Taken Hostage

Most controls are disabled while being held hostage
You are automatically attached to the captor
If the captor is killed or disconnects, you will be released

Credits

Original script by Robbster
ox_target integration and config system by MechaMaster
Overextended Team for the ox_target library
