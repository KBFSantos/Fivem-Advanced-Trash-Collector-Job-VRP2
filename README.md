# Fivem Advanced Trash Collector Job (VRP2)

Fivem advanced garbage collector job script with several features, Currently using the [VRP2 framework](https://github.com/vRP-framework/vRP).

There's not much difficulty to convert to old vrp or "vrpex", You can read the [VRP2 Documentation](https://vrp-framework.github.io/vRP/dev/index.html) and convert on your own (I don't support converting this script).

## Features
* ✅ Work with Friends: This script allows 4 players to work simultaneously on only 1 truck by rewarding all players for dumping the garbage.
* ✅ Smooth Animations: This script uses a better set of animations than any other script, with smooth animations and transitions between them.
* ✅ Global Cooldown System: Each garbage can collected has a cooldown for another player to collect it. (Gta's rendering system included in fivem causes object instances to change depending on distance which makes it difficult to store cooldown times on objects. This script dynamically stores the cooldown time of each collected dump, affecting all players on the server.)
* ✅ Dynamic Collection System: All dumps on map are automatically identified and added to this script, without the need for any manual work.
* ✅ Uniform System: To start the job the player needs to wear the uniform with an already defined set that currently uses the standard clothes, and automatically recognizes the character's gender.
* ✅ Garage system: The script has its own garage system without needing any additional dependencies for vehicles.
* ✅ Random Item Chance: It's possible to set a random chance of finding some item while collecting garbage.
* ✅ Secure Communication: The script uses vrp tunnel for server communications in essential functions to prevent hacker exploitation using triggers, This can prevent money hacks for example.

## Dependencies

It's necessary to use the [Qtarget](https://github.com/overextended/qtarget) to interact with the objects
