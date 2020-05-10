params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

_vehicleList = eHeliClasses;
_vehicleType = selectRandom _vehicleList;

_helipadUsed = 0;
_thisPos = [];		
if (count (((AOLocations select _AOIndex) select 2) select 8) > 0) then {			
	_thisPos = getPos ([(((AOLocations select _AOIndex) select 2) select 8)] call sun_selectRemove);
	_helipadUsed = 1;
} else {
	_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;	
	_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
	_thisPos = _tempPos;			
};		
	
// Create Task		
_heliName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);
_taskTitle = "Уничтожить вертолёт";
_taskDesc = "";
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

_thisVeh = _vehicleType createVehicle _thisPos;
_thisVeh = [_thisVeh] call sun_checkVehicleSpawn;
if (isNull _thisVeh) exitWith {[(AOLocations call BIS_fnc_randomIndex), true] call fnc_selectObjective};			
_thisVeh setVariable ["thisTask", _taskName, true];			
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

[_thisVeh] call dro_addSabotageAction;

// Add destruction event handler
_thisVeh addEventHandler ["Killed", {
	[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];	
} ];

// Create helipad and emplacements
if (_helipadUsed == 0) then {
	_startDir = random 360;
	_helipad = createVehicle  ["Land_HelipadSquare_F", _thisPos, [], 0, "CAN_COLLIDE"];
	_helipad setDir (_startDir+45);	
	_dir = _startDir;
	_rotation = (_startDir - 45);
	for "_i" from 1 to 4 do {
		_cornerPos = [_thisPos, 16, _dir] call BIS_fnc_relPos;
		_corner = ["Land_HBarrierWall_corner_F", _cornerPos, _rotation] call dro_createSimpleObject;		
		_lightPos = [_thisPos, 10, _dir] call BIS_fnc_relPos;
		_light = ["PortableHelipadLight_01_red_F", _lightPos, _rotation] call dro_createSimpleObject;		
		_dir = _dir + 90;
		_rotation = _rotation + 90;
	};
	
	_towerPos = [_thisPos, 20, random 360] call BIS_fnc_relPos;
	["Land_HBarrierTower_F", _towerPos, (_startDir+45)] call dro_createSimpleObject;	
} else {
	_thisPad = nearestObject [_thisPos, "HeliH"];
	_dir = (getDir _thisPad);
	for "_i" from 1 to 4 do {				
		_lightPos = [_thisPos, 10, _dir] call BIS_fnc_relPos;
		_light = ["PortableHelipadLight_01_red_F", _lightPos, _dir] call dro_createSimpleObject;		
		_dir = _dir + 90;				
	};
};

_randItems = floor (random 4);
_itemsArray = ["Land_AirIntakePlug_05_F", "Land_DieselGroundPowerUnit_01_F", "Land_HelicopterWheels_01_assembled_F", "Land_HelicopterWheels_01_disassembled_F", "Land_RotorCoversBag_01_F", "Windsock_01_F"];
for "_i" from 1 to _randItems do {
	_itemPos = [_thisPos, 8, 20, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	_thisItem = selectRandom _itemsArray;
	[_thisItem, _itemPos, (random 360)] call dro_createSimpleObject;	
};

// Guards
_minAI = round (2 * aiMultiplier);
_maxAI = round (4 * aiMultiplier);
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;						
if (!isNil "_spawnedSquad") then {
	[_spawnedSquad, _thisPos] call bis_fnc_taskDefend;
};

// Get a selection of possible new travel locations if chance allows
_travelPositions = [];			
_possibleLocsMaxIndex = (count AOLocations)-1;
if (_possibleLocsMaxIndex > 0) then {
	for "_i" from 0 to ([0, _possibleLocsMaxIndex] call BIS_fnc_randomInt) step 1 do {
		if (_i != _AOIndex) then {
			_possibleLocTypes = [];
			if (count (((AOLocations select _i) select 2) select 4) > 0) then {_possibleLocTypes pushBack 4};
			if (count (((AOLocations select _i) select 2) select 5) > 0) then {_possibleLocTypes pushBack 5};
			if (count (((AOLocations select _i) select 2) select 8) > 0) then {_possibleLocTypes pushBack 8};
			diag_log format ["_possibleLocTypes = %1", _possibleLocTypes];		
			if (count _possibleLocTypes > 0) then {
				_selectedPosArray = if (8 in _possibleLocTypes) then {
					((((AOLocations select _i) select 2) select 8))
				} else {
					((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)))
				};				
				_selectedPos = [_selectedPosArray] call sun_selectRemove;					
				_travelPositions pushBack _selectedPos;
			};
		};		
	};
};

if (count _travelPositions > 0) then {
	[_thisVeh] call sun_createVehicleCrew;
	//createVehicleCrew _thisVeh;
	waitUntil {!isNull (driver _thisVeh)};
	_vehGroup = group (driver _thisVeh);
	// Initialise route waypoints
	_wpFirst = _vehGroup addWaypoint [_thisPos, 0];
	_wpFirst setWaypointType "MOVE";
	_wpFirst setWaypointBehaviour "AWARE";
	_wpFirst setWaypointSpeed "LIMITED";			
	{
		_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
		_wp = _vehGroup addWaypoint [_pos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointStatements ["TRUE", "vehicle this land 'LAND'"];
		_wp setWaypointTimeout [150, 300, 200];
		if (_reconChance < baseReconChance) then {
			taskIntel pushBack [_taskName, _pos, _intelSubTaskName, "WAYPOINT"];
		};
	} forEach _travelPositions;
	_wpLast = _vehGroup addWaypoint [_thisPos, 0];
	_wpLast setWaypointType "CYCLE";		
	_wpLast setWaypointStatements ["TRUE", "vehicle this land 'LAND'"];
	_wpLast setWaypointTimeout [150, 300, 200];
	if (_reconChance < baseReconChance) then {
		taskIntel pushBack [_taskName, _thisPos, _intelSubTaskName, "WAYPOINT"];
	};
	_taskDesc = selectRandom [
		(format ["Воздушные силы %2 размещены в регионе %3. У нас есть сведения, что %1 присутствует в этом районе, и его уничтожение значительно уменьшит атакующие способности %2.", _heliName, enemyFactionName, aoLocationName]),		
		(format ["%2 атаковали войска %4 из скрытых авиабаз в нескольких местах. Разведка определила одно из этих мест, где вашей команде поручено уничтожить %2.", _heliName, enemyFactionName, aoLocationName, playersFactionName]),
		(format ["Войска союзников попросили %4 помочь уничтожить %2 %1, который препятствует их прогрессу в регионе. Найдите и уничтожьте вертолет, чтобы обеспечить ополченцам дополнительную безопасность от воздушного нападения.", _heliName, enemyFactionName, aoLocationName, playersFactionName])	
	];
} else {
	_taskDesc = selectRandom [
		(format ["Разведка сообщает о возможной цели в регионе %3: возможно, %1 был вынужден отказаться от ремонта и до сих пор находится там. Обыщите область, найдите и уничтожьте %1.", _heliName, enemyFactionName, aoLocationName]),
		(format ["В %3 размещается %2 %1, который, по нашему мнению, будет доступен для уничтожения. Войдите в регион %3 и уничтожьте вертолет.", _heliName, enemyFactionName, aoLocationName])		
	];
};

// Marker
_markerName = format["heliMkr%1", floor(random 10000)];
[_thisVeh, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 800] execVM "sunday_system\objectives\followingMarker.sqf";

// Create intel subtasks	
_subTaskDesc = format ["Соберите всю информацию, что сможете. Разведданные могут помочь уменьшить область вашего поиска и определить всё местоположения, где располагается противник. Проверяйте тела убитых %1, ищите отмеченные места разведданных и выполняйте любые задания по их поиску.", enemyFactionName];
_subTaskTitle = "Найти разведданные";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	_reconChance,
	_subTasks,
	_thisVeh
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];