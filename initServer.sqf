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
missionNamespace setVariable ["airportDir", 0, true];

missionNamespace setVariable ["task_HVT", false, true];
missionNamespace setVariable ["task_destroy", false, true];
missionNamespace setVariable ["task_POW", false, true];
missionNamespace setVariable ["task_VEHICLE", false, true];
missionNamespace setVariable ["task_VEHICLESTEAL", false, true];
missionNamespace setVariable ["task_ARTY", false, true];
missionNamespace setVariable ["task_CACHEBUILDING", false, true];
missionNamespace setVariable ["task_HELI", false, true];
missionNamespace setVariable ["task_CLEARLZ", false, true];
missionNamespace setVariable ["task_CLEARBASE", false, true];
missionNamespace setVariable ["task_INTEL", false, true];
missionNamespace setVariable ["task_RECON", false, true];
missionNamespace setVariable ["task_FOOTPATROL", false, true];
missionNamespace setVariable ["task_DISARM", false, true];
missionNamespace setVariable ["task_FORTIFY", false, true];
missionNamespace setVariable ["task_PROTECTCIV", false, true];
missionNamespace setVariable ["task_SEARCHHOUSES", false, true];

[] execVM "start.sqf";

// Отключение тепловизоров в технике
/*
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
*/

waituntil {!( isNil "markerColorPlayers")};
waituntil {markerColorPlayers != "ColorBlack"};

// Скрипт отметок игроков на карте
_markers = "player_markers" call BIS_fnc_getParamValue;
if (_markers == 1) then {
	_nil = [] execVM "scripts\playerMarkers.sqf"
};

// Справка о сервере на карте
/*
private _worldName = worldName;

//if !(_worldName in ["Stratis","Altis","Malden","Tanoa","Enoch"]) then {_worldName = "Other"};

_pos1 = nil;
_pos2 = nil;
_pos3 = nil;
_pos4 = nil;
_pos5 = nil;
_pos6 = nil;

if (_worldName == "Altis") then {
	_pos1 = [-1.4549,32210.7];
	_pos2 = nil;
	_pos3 = nil;
	_pos4 = nil;
	_pos5 = nil;
	_pos6 = nil;
};
*/