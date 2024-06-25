# Fivem Advanced Trash Collector Job (VRP2)

Using [VRP2 framework](https://github.com/vRP-framework/vRP)

[VRP2 Documentation](https://vrp-framework.github.io/vRP/dev/index.html)

## Features
* ✅ Work with Friends: It's possible for 4 players to work simultaneously on one truck, rewarding all players for dumping the garbage.
* ✅ Smooth Animations: This script uses a good set of animations with smooth transitions.
* ✅ Global Cooldown System: Each garbage can collected has a cooldown before another player can collect it. Due to GTA's rendering system in FiveM, object instances change based on distance, making it difficult to store cooldown times on objects. This script dynamically stores the cooldown time of each collected dump, affecting all players on the server.
* ✅ Dynamic Collection System: All dumps on the map are automatically identified and added to this script, without the need for any manual work.
* ✅ Uniform System: To start the job, the player needs to wear a predefined uniform set that currently includes the standard garbage collector's outfit, and it automatically adjusts for the character's sex.
* ✅ Garage system: This script has its own garage system without needing any additional dependencies for vehicles.
* ✅ Random Item Chance: It's possible to set a random chance of finding an item while collecting garbage.
* ✅ Safe Communication: Using VRP Tunnel for server communications in essential functions helps prevent hacker exploitation through triggers, which can, for example, mitigate money hacks.

## Dependencies

It's necessary to use the [Qtarget](https://github.com/overextended/qtarget) to interact with the objects
