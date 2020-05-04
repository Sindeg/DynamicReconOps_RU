/*
Add Script to vehicles spawned by COS.
_veh = Vehicle. Refer to vehicle as _veh.
*/

_veh = (_this select 0);
_fuel = random [0.2, 0.5, 0.8]; 
_veh setFuel _fuel;