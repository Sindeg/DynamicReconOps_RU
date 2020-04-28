#include "sunday_system\fnc_lib\sundayFunctions.sqf"

missionNameSpace setVariable ["factionDataReady", 0, true];
missionNameSpace setVariable ["weatherChanged", 0, true];
missionNameSpace setVariable ["factionsChosen", 0, true];
missionNameSpace setVariable ["arsenalComplete", 0, true];
missionNameSpace setVariable ["aoCamPos", [], true];
missionNameSpace setVariable ["dro_introCamReady", 0, true];
missionNameSpace setVariable ["dro_introCamComplete", 0, true];
missionNameSpace setVariable ["briefingReady", 0, true];
missionNameSpace setVariable ["playersReady", 0, true];
missionNameSpace setVariable ["publicCampName", "", true];
missionNameSpace setVariable ["startPos", [], true];
missionNameSpace setVariable ["initArsenal", 0, true];
missionNameSpace setVariable ["allArsenalComplete", 0, true];
missionNameSpace setVariable ["aoComplete", 0, true];
missionNameSpace setVariable ["objectivesSpawned", 0, true];
missionNameSpace setVariable ["aoLocationName", "", true];
missionNameSpace setVariable ["aoLocation", "", true];
missionNameSpace setVariable ["lobbyComplete", 0, true];
missionNameSpace setVariable ["JamTFARMessage", 0, true];
missionNameSpace setVariable ["airportChosen", false, true];

[] execVM "start.sqf";

// Отключение тепловизоров в технике
[] spawn 
{
	while {TRUE} do
	{
		sleep 70;
		{
			_x disableTIEquipment true;
		} foreach vehicles;
	};
};

waituntil {!( isNil "markerColorPlayers")};
waituntil {markerColorPlayers != "ColorBlack"};

// Отметки игроков на карте
_markers = "player_markers" call BIS_fnc_getParamValue;
if (_markers == 1) then {
	_nil = [] execVM "scripts\playerMarkers.sqf"
};
	



