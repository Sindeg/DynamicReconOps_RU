_center = _this select 0;
_vehTypes = _this select 1;

_numFlyBys = [4,7] call BIS_fnc_randomInt; // Общее количество авиации

_timeToSpawn = 20*60; // Время перед появлением новой авиации
_timeToPatrol = 6*60; // Время для авиации на прилёт в зону действий и патрулирования
_distanceRange = 5000; // Расстояние от центра операций до новой техники

_debug = false; // Отладка

while {true} do {
	if (_debug) then {systemChat "Новый цикл";};
    sleep ([round(_timeToSpawn / 2), _timeToSpawn] call BIS_fnc_randomInt); // Каждые [_timeToSpawn / 2, _timeToSpawn] секунд отправляем новую авиацию
	if (_debug) then {systemChat "Авиа заспавнено";};
	
	_center = [_center, 200, 600, 0, 1, 60, 0] call BIS_fnc_findSafePos;
	_vehType = selectRandom _vehTypes;

 	_startPosTemp = [_center, 100, 150, 0, 1, 60, 0] call BIS_fnc_findSafePos;
	_startDir = [_center, _startPosTemp] call BIS_fnc_dirTo;
	_startDist = _distanceRange;
	_startPos = [_center, _startDist, _startDir] call BIS_fnc_relPos;

	_spawnDir = _startPos getdir _center;
	_spawnedHeli = [_startPos, _spawnDir, _vehType, enemySide] call BIS_fnc_spawnVehicle;	
	
	if ( isNil "_spawnedHeli" ) exitWith {};
			
	_spawnedHeli params [
		"_heli",
		"_crew",
		"_heliGroup"
	];
	
	sleep 3;
	_heli flyInHeightASL [400, 300, 350];
	if (_debug) then {systemChat "Авиа летит в район операций";};
	//Initial move to AO
 
	// _wp1 = _heliGroup addWaypoint [_center, 0];
	// _wp1 setWaypointType "SAD";
	// _wp1 setWaypointCombatMode "RED";
	// _wp1 setWaypointBehaviour "COMBAT";
	// sleep 40;
	
	// systemChat "Вейпоинт летать по радиусу. Будет летать 120 секунд";
	//Loiter at 400m
	// _wp2 = _heliGroup addWaypoint [_center, 0];
	// _wp2 setWaypointType "LOITER";
	// _wp2 setWaypointLoiterType "CIRCLE";
	// _wp2 setWaypointLoiterRadius 900;
	_patrolRadius = [550, 800] call BIS_fnc_randomInt;
	_wp2 = _heliGroup addWaypoint [_center, 0];
	_wp2 setWaypointCombatMode "RED";
	_wp2 setWaypointBehaviour "COMBAT";
	_wp2 setWaypointType "LOITER";
	_wp2 setWaypointLoiterType "CIRCLE";
	_wp2 setWaypointLoiterRadius _patrolRadius;
 
	sleep _timeToPatrol;
	
	if (_debug) then {systemChat "Теперь авиа улетает";};
	
	for "_i" from count waypoints _heliGroup - 1 to 0 step -1 do
	{
		deleteWaypoint [_heliGroup, _i];
	};
	
	sleep 2;
	
	// Отлёт авиации с зоны операции и удаление
	_endDir = getDir _heli;
	_endPos = [_heli, _distanceRange, _endDir] call BIS_fnc_relPos;
	
	_wp3 = _heliGroup addWaypoint [_endPos, 0];
	_wp3 setWaypointType "Move";
	_wp3 setWaypointCombatMode "BLUE";
	_wp3 setWaypointBehaviour "CARELESS";
	
	_heliGroup setCurrentWaypoint _wp3;
	
	if (_debug) then {systemChat "Ждем удаления авиа";};
	
	waitUntil {_heli distance _endPos < 500 || (!alive _heli)};
	if (alive _heli) then {
		{ _heli deleteVehicleCrew _x } forEach crew _heli; // Удаление всего экипажа
		deleteVehicle _heli;
	};
	
	if (_debug) then {systemChat "Цикл завершен";};
};