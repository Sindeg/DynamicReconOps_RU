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
// Цикл на всю технику на карте
// Выбрасывает всех после взрыва техники
while {true} do {
	{
		// В случае если на технике еще нет эвента на уничтожение и при этом эта техника не гражданская из города
		if ((isNil {_x getvariable "addedKillEvent"}) and (isNil {_x getvariable "vehicle_is_planted"})) then {
			_EHkilledIdx = _x addMPEventHandler ["MPkilled",  
			{ 
				params ["_unit", "_killer", "_instigator", "_useEffects"];

				myFnc = {		
					sleep 0.5;
					
					{ 
						_bodyParts = ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"];
						_num = [1,6] call BIS_fnc_randomInt;
						
						for "_i" from 1 to _num do {
							[_x, 0.4, selectRandom _bodyParts, "explosive"] call ace_medical_fnc_addDamageToUnit; 
						}; 
						[_x, true, (15), true] call ace_medical_fnc_setUnconscious;
					} forEach crew _this;
					
					waituntil {((getPosATL _this) select 2 < 10) and (speed _this < 10)}; 
					
					sleep 3;
					
					{ 
						if ((isPlayer _x) or (_this isKindOf "air")) then {
							moveOut _x;
							_pos = [_this, 2, 5, 1, 0, 50, 0,[], getpos _x] call BIS_fnc_findSafePos;
							_x setpos _pos;
							sleep 0.2;
						};
					} forEach crew _this;
				};
				[_unit, "myFnc"] call BIS_fnc_spawnOrdered;
			} 
			];
		};
	} foreach vehicles;
	sleep 10;
};

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