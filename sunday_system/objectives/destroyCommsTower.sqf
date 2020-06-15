_transmitter = nil;
_numMark = 0;
_centerPos = ((AOLocations select 0) select 0);
	
_towerTypes = [
	"rhs_prv13",
	"rhs_p37"
	//"Land_Communication_F",
	//"Land_TTowerSmall_2_F",
	//"Land_TTowerSmall_1_F"				
];			

_towerType = selectRandom _towerTypes;
_centerPos = ((AOLocations select 0) select 0);
_safePosRadar = [_centerPos, 300, 1000, 20, 0, 15, 0, []] call BIS_fnc_findSafePos;
{deleteVehicle _x} forEach nearestObjects [_safePosRadar, ["all"], 30];

_object = createVehicle [_towerType, _safePosRadar, [], 0, "NONE"];	
_object setDamage [0.7, false];		
sleep 0.5;			
_object setVectorUp [0,0,1];	
_transmitter = _object;

_transmitterPos = getPos _transmitter;
// Настоящая метка радара
createMarker ["Radar0", _transmitterPos];
"Radar0" setMarkerColor markerColorEnemy;
"Radar0" setMarkerType "mil_unknown";

// Метки возможных позиций радара
_numMark = [3, 4] call BIS_fnc_randomInt;
for "_i" from 1 to _numMark do { 
	_pos = selectRandom[_safePosRadar, _centerPos];
	_spawnMarkerPos = [_pos, 300 + 150 * _i, 1200, 30, 0, 25, 0, []] call BIS_fnc_findSafePos;
	
	_str = format ["radar%1",_i];
	createMarker [_str, _spawnMarkerPos];
	_str setMarkerColor markerColorEnemy;
	_str setMarkerType "mil_unknown";
};

if (!isNil "_transmitter") then {
	//enemyCommsActive = true;
	 
	// 2 отряда вокруг вышки связи
	for "_i" from 0 to 1 do { 
		_spawnPos = [(getPos _transmitter), 15, (random 360)] call BIS_fnc_relPos;
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [3,5]] call dro_spawnGroupWeighted;
		waitUntil {!isNil "_spawnedSquad"};
		[_spawnedSquad, (getPos _transmitter), 20] call BIS_fnc_taskPatrol;
	};
	
	if (count eStaticClasses > 0) then {
		if ((random 1) > 0.1) then {
			_turretClass = selectRandom eStaticClasses;
			_turretPos = [_safePosRadar, 9, 25, 3, 0, 0, 0] call BIS_fnc_findSafePos;
			if (count _turretPos > 0) then {
				_turret = _turretClass createVehicle _turretPos;
				[_turret] call sun_createVehicleCrew;
			};
		};
	};
	
	waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
	
	// Create Task
	_taskName = format ["task%1", floor(random 100000)];
	_taskTitle = "(Доп.) Уничтожить средства РЭБ";
	_taskDesc =	format ["%1 использует радиоэлектронное подавление в этом регионе. Найдите и уничтожьте источник РЭБ противника чтобы восстановить полную работу собственной связи (КВ и ДВ) в регионе.<br/><marker name='radar2'>Одно из возможных местоположений системы РЭБ</marker>.", enemyFactionName, aoName];
	_task = ["commsTask", true, [_taskDesc, _taskTitle, ""], [], "CREATED", 0, true, true, "danger", true] call BIS_fnc_setTask;		
	_transmitter setVariable ["thisTask", _taskName, true];
	missionNamespace setVariable [(format ["%1_taskType", _taskName]), "danger", true];
	
	// Destruction listener
	[_transmitter, _numMark] spawn {
		params ["_transmitter", "_numMark"];
		while {alive _transmitter} do {
			sleep 4;
			if (!alive _transmitter) then {				
				["commsTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
				//enemyCommsActive = false;
				
				// Удаляем все метки
				for "_i" from 0 to _numMark do { 
					_str = format ["radar%1",_i];
					_str setMarkerAlpha 0;
				};
			};
		};
	};
	
	_distanceJam = 3500; // Дальность работы помех
	[[_transmitter], _distanceJam, 9, false] remoteExec ["fnc_TFARjamRadios", 0, true]; 
	missionNameSpace setVariable ["JamTFARMessage", 1, true];
}
else 
{
	for "_i" from 0 to _numMark do 
	{ 
		_str = format ["radar%1",_i];
		deleteMarker _str;
	};
	deleteVehicle _transmitter;
};