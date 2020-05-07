/*
	Скрипт создания авиации врага
*/

_center = _this select 0; 
_HeliClasses = _this select 1;
_planeClasses = _this select 2;

//****************************** Настройки *******************************

_timeToSpawn = 18*60; // Время перед появлением новой авиации
_timeDifference = 3*60; // Изменение верхней и нижней границы времени появления авиации

_timeToPatrol = 7*60; // Время для авиации на прилёт в зону действий и патрулирования
_distanceRange = 7000; // Расстояние от центра операций до новой техники

_patrolRadiusMin = 450; // Минимальный радиус для патрулирования территории авиацией
_patrolRadiusMax = 900; // Максимальный радиус для патрулирования территории авиацией

_dropDistanceMin = 500; // Минимальный радиус до точки для высадки десанта с вертолёта
_dropDistanceMax = 900; // Максимальный радиус до точки для высадки десанта с вертолёта

_radiusCenterToStart = 1500; // Радиус внутри которого будет идти подсчет игроков
_numPlayersToStart = 3; // Количество игроков в этом радиусе для начала отправки авиации в зону

_debug = false; // Отладка
//************************************************************************

_transportHeliClasses = []; // Все грузовые вертолёты

// Находим все грузовые вертолёты
{
	if([_x, true] call BIS_fnc_crewCount > 12 && count (_x call BIS_fnc_allTurrets) < 2) then {_transportHeliClasses pushBack _x};
} forEach _HeliClasses;

if (count _transportHeliClasses == 0) then {
	{
		if([_x, true] call BIS_fnc_crewCount > 7 && count (_x call BIS_fnc_allTurrets) < 2) then {_transportHeliClasses pushBack _x};
	} forEach _HeliClasses;
};

_strikeAirClasses = _heliClasses + _planeClasses; // Вся авиация врага

// В боевой авиации не более 2 мест 
{ 
	if([_x, true] call BIS_fnc_crewCount > 2) then {_strikeAirClasses deleteAt (_strikeAirClasses find _x)};
} forEach _strikeAirClasses;

// Все возможные типы появления авиации
_typeSpawn = [
	"airStrike",
	"Heli_smoke" 
//	"Heli_ropes"
]; 

if (count _transportHeliClasses == 0) then {
	_typeSpawn deleteAt (_typeSpawn find "Heli_smoke")
	//_typeSpawn deleteAt (_typeSpawn find "Heli_ropes")
};

if (count _strikeAirClasses == 0) then {
	_typeSpawn deleteAt (_typeSpawn find "airStrike")
};

if (count _typeSpawn == 0) exitWith {}; // Если у противника нет авиации

// Создаём контрмеры для цикличного использования
private _flares = {
	_veh = _this select 0;
	_pos = _this select 1;
	while {alive _veh && alive driver _veh && {!(isTouchingGround _veh)} && (_veh distance2d _pos > 300)} do {    
		sleep 3.5;
		_veh action ["useWeapon", _veh, driver _veh, 0];
	};
};

// Создаём контрмеры для цикличного использования на отходе
private _flares2 = {
	while {alive _this && alive driver _this} do {    
		sleep 3.5;
		_this action ["useWeapon", _this, driver _this, 0];
	};
};

while {true} do {
	if (_debug) then {systemChat "Новый цикл"};
	
    sleep ([_timeToSpawn - _timeDifference, _timeToSpawn + _timeDifference] call BIS_fnc_randomInt); // Периодичность цикла
	
	// _center = getpos player; 
	if ({_x distance _center < _radiusCenterToStart} count allPlayers > _numPlayersToStart) then {
		// Вычисляем общие координаты места появления будущей техники
		_centerTemp = [_center, 2000, 2500, 0, 1, 60, 0] call BIS_fnc_findSafePos;
		
		_startPosTemp = [_centerTemp, 100, 150, 0, 1, 60, 0] call BIS_fnc_findSafePos;
		_startDir = _centerTemp getDir _startPosTemp;
		_startPos = [_centerTemp, _distanceRange, _startDir] call BIS_fnc_relPos;

		_spawnDir = _startPos getdir _center;

		_currTypeSpawn = selectRandom _typeSpawn;
		
		switch (_currTypeSpawn) do {
			case "Heli_smoke": {
				if (_debug) then {systemChat "Heli_smoke"};
				_posDropPoint = [_center, _dropDistanceMin, _dropDistanceMax, 0, 0, 20, 0] call BIS_fnc_findSafePos;
				private _helipad = "Land_HelipadEmpty_F" createVehicle _posDropPoint; // Создаём невидимую вертолётную площадку, для точной посадки вертолёта

				_vehType = selectRandom _transportHeliClasses; // Случайный доступный вертолёт
				_spawnedHeli = [_startPos, _spawnDir, _vehType, enemySide] call BIS_fnc_spawnVehicle;
	   
				_spawnedHeli params ["_heli", "_crew", "_heliGroup"];
			   
				_vehSlotsMax = [_vehType, true] call BIS_fnc_crewCount;
				_vehSlotsMin = [_vehType, false] call BIS_fnc_crewCount;
				//_vehSlots = _vehSlotsMax - _vehSlotsMin;
				_vehSlots = _heli emptyPositions "cargo";
				// Создаём группу десанта
				private _supgroup = [_startPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_vehSlots, _vehSlots], false] call dro_spawnGroupWeighted;
				private _unitsCargo = units _supgroup; // Заводим их в группу для погрузки в вертолёт
			   
				// Задаём параметр храбрости для экпиажа вертолёта
				{_x setSkill ["courage", 1]} forEach units _heliGroup;
	 
				{_x moveInCargo _heli} forEach _unitsCargo;
				_heli domove _posDropPoint;
				_heli flyinheight 50;
			   
				waitUntil {
					sleep 1;
					(_heli distance2d _posDropPoint) < 1700 || (!alive _heli) || (!alive driver _heli)
				};
			   
				//[_heli, _posDropPoint] spawn _flares;
	 
				waitUntil {
					(_heli distance2d _posDropPoint) < 300 || (!alive _heli) || (!alive driver _heli)
				};
			   
				_heli land "get out";
				_heli flyInHeight 0;
				waitUntil {isTouchingGround _heli};
			   
				// Выкидываем дымы по кругу
				private _dir = 0;
				private _a = 0;
				while{alive _heli && _a < 16 && alive driver _heli} do {
					_sPos = [((getPos _heli) select 0) + (sin _dir) * 12, ((getPos _heli) select 1) + (cos _dir) * 12, ((getPos _heli) select 2)];
					_smoke1 = "SmokeShell" createVehicle _sPos;
					_a = _a + 1;
					_dir = _dir + (360 / 16);
				};
			   
				_supgroup leaveVehicle _heli;
				// Ждём пока все члены группы десанта покинут вертолёт
				waitUntil {
					sleep 5;
					(count (_unitsCargo select {alive _x && (!isNull objectParent _x)}) == 0) || (!alive _heli) || (!alive driver _heli)
				};
	 
				// Отлёт авиации с зоны операции и удаление
				_endDir = getDir _heli;
				_endPos = [_heli, _distanceRange, _endDir] call BIS_fnc_relPos;
				_heli flyinheight 50;
			   
				// Откидываем ловушки
				//_heli spawn _flares2;
			   
				_wp3 = _heliGroup addWaypoint [_endPos, 0];
				_wp3 setWaypointType "Move";
				_wp3 setWaypointCombatMode "BLUE";
				_wp3 setWaypointBehaviour "CARELESS";
			   
				_heliGroup setCurrentWaypoint _wp3;
			   
				_wp =_supgroup addWaypoint [_center, 0];
				_wp setWaypointType "SAD";
				_wp setWaypointCombatMode "RED";
				_wp setWaypointBehaviour "AWARE";
			   
				waitUntil {_heli distance _endPos < 500 || (!alive _heli)};
				if (alive _heli) then {
					{ _heli deleteVehicleCrew _x } forEach crew _heli; // Удаление всего экипажа
					deleteVehicle _heli;
				};
				deleteVehicle _helipad;
			};
	/* 		case "Heli_ropes": {
				if (_debug) then {systemChat "Heli_ropes"};
				_posDropPoint = [_center, _dropDistanceMin, _dropDistanceMax, 0, 0, 20, 0] call BIS_fnc_findSafePos;
				private _helipad = "Land_HelipadEmpty_F" createVehicle _posDropPoint; // Создаём невидимую вертолётную площадку, для точной посадки вертолёта
			   
				_vehType = selectRandom _transportHeliClasses; // Случайный доступный вертолёт
				_spawnedHeli = [_startPos, _spawnDir, _vehType, enemySide] call BIS_fnc_spawnVehicle;
	   
				_spawnedHeli params ["_heli", "_crew", "_heliGroup"];
				
				_vehSlotsMax = [_vehType, true] call BIS_fnc_crewCount;
				_vehSlotsMin = [_vehType, false] call BIS_fnc_crewCount;
				_vehSlots = _vehSlotsMax - _vehSlotsMin;
				
				// Создаём группу десанта
				private _supgroup = [_startPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_vehSlots, _vehSlots], false] call dro_spawnGroupWeighted;
				private _unitsCargo = units _supgroup; // Заводим их в группу для погрузки в вертолёт
	   
				// Задаём параметр храбрости для экпиажа вертолёта
				{_x setSkill ["courage", 1]} forEach units _heliGroup;
	 
				{_x moveInCargo _heli} forEach _unitsCargo;

				_heli flyinheight 50;
			   
			   [_heli, 20, getpos _helipad] call AR_Rappel_All_Cargo;
			   
				waitUntil {
					sleep 1;
					(_heli distance2d _posDropPoint) < 1700
				};
			   
				//[_heli, _posDropPoint] spawn _flares;

				 // Ждём пока все члены группы десанта покинут вертолёт
				waitUntil {
					sleep 1; 
					{isTouchingGround (vehicle _x) &&_x == (vehicle _x)} forEach (_unitsCargo)
				};
				
				// Доп. проверка, что вертолёт выгрузил весь десант и поднялся на исходные 50м.
				waitUntil {
					sleep 1; (getPosASL _heli) select 2 > 45
				}; 
				
				if (_debug) then {systemChat "Все боты на земле"};
				
				// Откидываем ловушки
				//_heli spawn _flares2;
				_endDir = getDir _heli;
				_endPos = [_heli, _distanceRange + 2000, _endDir] call BIS_fnc_relPos;
				
				 _wp3 = _heliGroup addWaypoint [_endPos, 0];
				_wp3 setWaypointType "Move";
				_wp3 setWaypointCombatMode "BLUE";
				_wp3 setWaypointBehaviour "CARELESS";
				_heliGroup setCurrentWaypoint _wp3;
				
				if (_debug) then {systemChat "Вертолёту новый ВП на отлёт"};
				
				{moveOut _x; unassignVehicle _x} forEach _unitsCargo;
				
				for "_i" from count waypoints _supgroup - 1 to 0 step -1 do {deleteWaypoint [_supgroup, _i]};
				
				if (_debug) then {systemChat "Пехота идёт на точку"};
				_wp =_supgroup addWaypoint [getpos player, 0];
				_wp setWaypointType "SAD";
				_wp setWaypointCombatMode "RED";
				_wp setWaypointBehaviour "AWARE";
				_supgroup setCurrentWaypoint _wp;
				
				sleep 1;
				
				waitUntil {_heli distance _endPos < 500 || (!alive _heli) || (!alive driver _heli)};
				if (alive _heli) then {
					{ _heli deleteVehicleCrew _x } forEach crew _heli; // Удаление всего экипажа
					deleteVehicle _heli;
				};
				deleteVehicle _helipad;
			}; */
			case "airStrike": { 
				if (_debug) then {systemChat "airStrike"};
				_vehType = selectRandom _strikeAirClasses; // Случайный доступный самолёт
				_spawnedHeli = [_startPos, _spawnDir, _vehType, enemySide] call BIS_fnc_spawnVehicle;	
				
				if ( isNil "_spawnedHeli" ) exitWith {};
						
				_spawnedHeli params ["_heli", "_crew", "_heliGroup"];
				
				sleep 1;
				_heli flyinheight 250;
				if (_debug) then {systemChat "Авиа летит в район операций";};
				
				_patrolRadius = [_patrolRadiusMin, _patrolRadiusMax] call BIS_fnc_randomInt;
				_startPosToPatrol = [_center, 400, 700, 0, 1, 60, 0] call BIS_fnc_findSafePos;
				
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
				
				_wpAircraft = _heliGroup addWaypoint [_endPos, 0];
				_wpAircraft setWaypointType "Move";
				_wpAircraft setWaypointCombatMode "BLUE";
				_wpAircraft setWaypointBehaviour "CARELESS";
				
				_heliGroup setCurrentWaypoint _wpAircraft;
				
				if (_debug) then {systemChat "Ждем удаления авиа";};
				
				waitUntil {_heli distance _endPos < 500 || (!alive _heli) || (!alive driver _heli)};
				if (alive _heli && alive driver _heli && _heli distance _endPos < 500) then {
					{ _heli deleteVehicleCrew _x } forEach crew _heli; // Удаление всего экипажа
					deleteVehicle _heli;
				};
				
				if (_debug) then {systemChat "Цикл завершен";};
			};
			default {};
		};
	};
};