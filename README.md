Minetest 5.4 mod: Steampunk Blimp
========================================

This mod implements a fantasy steampunk blimp for minetest.
The mod was made for fun, but tries to provide an immersion on it's operation.
It can carry 5 people.
To fly it, it is necessary to provide some items, such as fuel to be burned and
water for the boiler. The fuel can be coal, coal block and wood. To supply it,
be on board and punch the necessary items on the airship. There is another way to
load water to the boiler: if it is landed on water, it can load it through the
menu. But the current pressure will be lost.
Activate the furnace in the first option of the menu. Take control by activating
the option "Take the Control".
The information panel will be on the left and bottom of the screen. Wait for the
boiler to reach the proper pressure for operation (green) before operating the power lever.
To go up, press Jump (space). Note that it takes some pressure from the boiler. To go down,
hold sneak (shift).
Forward increases the propeller power, Backward reduces. To go reverse, hold aux (E key)
and backward together. There is a power mode. When the lever reaches the up limit, hold E
and forward to increase the acceleration. But note that the boiler will lose pressure.
The blimp inventory can be accessed by Aux (E) + rightclick.

Shared owners:
This vehicle was made to be shared with a team. So the owner can set more users to
operate it. Inside the blimp, just use the command /blimp_share <name>
To remove someone from the sharing, /blimp_remove <name>
To list the owners, /blimp_list
Is possible to lock the blimp access, so only the owners can enter: /blimp_lock true
To let anyone enter, /blimp_lock false
All shared owners can access the blimp inventory

Painting:
As the planes, punch a dye against the hull, so the primary color will change
To change the secondary color, punch a dye, but holding Aux (E) key.
It is possible to set a logo on your blimp, so enter inside it and type the command /blimp_logo
Only the original owner can do the paintings

Shortcuts:
right click to enter and access menu
punch with dye to paint
forward and backward while in drive position: controls the power lever
left and right while in drive position: controls the direction
jump and sneak: controls the up and down movement
E + right click while inside: acess inventory
E + backward while in drive position: the machine does backward
E + foward while in drive position: extra power

Tip:
Drive it gently.
The captain can leave the drive position to walk too
If a player goes timeout or logoff in flight, the blimp will "rescue" him if no other player
enter the blimp, so is a good idea wait the friend at a secure place far from anyone who
wants to enter the blimp.

Know issues:
The walk movement inside the ship is affected by server lag, because the lack of
an interpolation method on attach function.
Rubber-band bug is from minetest nature, just close and reopen minetest to solve.
Or try to live the Michael Jackson's way of life and learn the Moonwalk properly XD
Some old versions of minetest can have an strange issue, the camera is set to
the map center. So if it happens, just type /blimp_eject to be free again.


License of source code:
MIT (see file LICENSE) 

License of media (textures and sounds):
---------------------------------------
collision.ogg by APercy, CC0

Blimp model and textures by APercy. CC BY-SA 3.0

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
Copyright (C) 2022 Alexsandro Percy (APercy) <alexsandro.percy@gmail.com>

You are free to:
Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.
The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and
indicate if changes were made. You may do so in any reasonable manner, but not in any way
that suggests the licensor endorses you or your use.

ShareAlike — If you remix, transform, or build upon the material, you must distribute
your contributions under the same license as the original.

No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.

Notices:

You do not have to comply with the license for elements of the material in the public
domain or where your use is permitted by an applicable exception or limitation.
No warranties are given. The license may not give you all of the permissions necessary
for your intended use. For example, other rights such as publicity, privacy, or moral
rights may limit how you use the material.

For more details:
http://creativecommons.org/licenses/by-sa/3.0/

