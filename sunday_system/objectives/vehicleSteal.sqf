params ["_AOIndex"];

_break = false;
_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];
_locateSubTaskName = format ["subtask%1", floor(random 100000)];

// Get vehicles with a preference for those without turrets
_vehicleList = if (count eCarNoTurretClasses > 0) then {
	if (count eCarNoTurretClasses < 3) then {
		eCarClasses + eCarNoTurretClasses
	} else {
		eCarNoTurretClasses
	};	
} else {
	eCarClasses
};

// Get transport slot bounds
_cargoRange = [100, 0];
{
	_transportSlots = ([_x] call sun_getTrueCargo);
	if (_forEachIndex == 0) then {
		_cargoRange set [0, _transportSlots];
		_cargoRange set [1, _transportSlots];
	};	
	if (_transportSlots < (_cargoRange select 0)) then {
		_cargoRange set [0, _transportSlots];
	};
	if (_transportSlots > (_cargoRange select 1)) then {
		_cargoRange set [1, _transportSlots];
	};
} forEach _vehicleList;

// Get vehicle slot weights
_cargoWeights = [];
{
	_transportSlots = ([_x] call sun_getTrueCargo);
	_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, _transportSlots, 0, 1, true]; 
	_cargoWeights pushBack _thisWeight;
} forEach _vehicleList;

// If possible remove vehicles with too few slots
if (({_x < 0.2} count _cargoWeights) < (count _cargoWeights - 1)) then {
	_deletePositions = [];
	{
		if (_x < 0.2) then {
			_deletePositions pushBack _forEachIndex;
		};
	} forEach _cargoWeights;
	{
		_vehicleList deleteAt _x;
		_cargoWeights deleteAt _x;
	} forEach _deletePositions;	
};

diag_log _vehicleList;
diag_log _cargoWeights;

_vehicleType = [_vehicleList, _cargoWeights] call BIS_fnc_selectRandomWeighted;
//_vehicleType = selectRandom _vehicleList;		
_thisPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;

_thisVeh = _vehicleType createVehicle _thisPos;
_thisVeh = [_thisVeh] call sun_checkVehicleSpawn;
if (isNull _thisVeh) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

_roads = _thisVeh nearRoads 50;
_dir = 0;
if (count _roads > 0) then {
	_firstRoad = _roads select 0;
	if (count (roadsConnectedTo _firstRoad) > 0) then {			
		_connectedRoad = ((roadsConnectedTo _firstRoad) select 0);
		_dir = [_firstRoad, _connectedRoad] call BIS_fnc_dirTo;
		_thisVeh setDir _dir;
	} else {
		_thisVeh setDir (random 360);
	};
};

_vehStyle = selectRandom ["LOADING", "WAITING"]; 
switch (_vehStyle) do {
	case "LOADING": {
		// Choose between repair situation or loading situation
		if (random 1> 0.5) then {
				// Find any doors to animate
			{ 
				if ( ((configFile >> "CfgVehicles" >> _vehicleType >> "AnimationSources" >> (configName _x) >> "source") call BIS_fnc_GetCfgData) == "door") then {
					_thisVeh animateDoor [(configName _x), 1, true];
				};
			} forEach ("true" configClasses (configFile >> "CfgVehicles" >> _vehicleType >> "AnimationSources"));

			// Create fluff objects			
			_itemsArray = [		
				"CargoNet_01_barrels_F",
				"CargoNet_01_box_F",			
				"Land_PaperBox_closed_F",
				"Land_PaperBox_open_empty_F",
				"Land_PaperBox_open_full_F",
				"Land_Pallet_MilBoxes_F",
				"Land_Pallets_F",
				"Land_Pallet_F"					
			];
			_item1Pos = [getPos _thisVeh, 5, (_dir - 155)] call dro_extendPos;
			_item2Pos = [_item1Pos, 1.5, (_dir - 180)] call dro_extendPos;
			_item1 = selectRandom _itemsArray;
			_item2 = selectRandom _itemsArray;
			[_item1, _item1Pos, _dir] call dro_createSimpleObject;
			[_item2, _item2Pos, _dir] call dro_createSimpleObject;	

			_guardPos = [getPos _thisVeh, 3, (_dir - 180)] call dro_extendPos;		
			_group = [_guardPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
		
		} else {
			_wheels = [];
			{ 
				if (["wheel", ((_x >> "name") call BIS_fnc_getCfgData), false] call BIS_fnc_inString) then {
					_wheels pushBack ((_x >> "name") call BIS_fnc_getCfgData);
				};
			} forEach ("true" configClasses (configFile >> "CfgVehicles" >> _vehicleType >> "HitPoints"));
			if (count _wheels > 0) then {
				_thisVeh sethit [(selectRandom _wheels), 1];				
			};
			
			// Create fluff objects			
			_itemsArray = [		
				"Land_Tyre_F",
				"Oil_Spill_F",
				"Land_CanisterFuel_F",
				"Land_Wrench_F"								
			];
			_item1Pos = [getPos _thisVeh, 2.5, (_dir - 85)] call dro_extendPos;
			_item2Pos = [_item1Pos, 1, _dir] call dro_extendPos;			
			_item1 = selectRandom _itemsArray;
			_item2 = selectRandom _itemsArray;
			[_item1, _item1Pos, (random 360)] call dro_createSimpleObject;
			[_item2, _item2Pos, (random 360)] call dro_createSimpleObject;
			_toolkit = "Item_ToolKit" createVehicle ([getPos _thisVeh, 2.5, (_dir - 140)] call dro_extendPos);
			
			_guardPos = [getPos _thisVeh, 3, (_dir - 90)] call dro_extendPos;		
			_group = [_guardPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
			_unit = ((units _group) select 0);
			_unit setUnitPos "MIDDLE";
			_unit setFormDir (_dir + 90);
			_unit setDir (_dir + 90);
		};		
		
		_spawnPos = [_thisPos, 6, (random 360)] call dro_extendPos;
		_minAI = round (3 * aiMultiplier);
		_maxAI = round (5 * aiMultiplier);
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;			
		if (!isNil "_spawnedSquad") then {
			[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
		};		
	};
	case "WAITING": {
		[_thisVeh] call sun_createVehicleCrew;
		//createVehicleCrew _thisVeh;
		_thisVeh engineOn true;
		
		_spawnPos = [_thisPos, 6, (random 360)] call dro_extendPos;
		_minAI = round (3 * aiMultiplier);
		_maxAI = round (5 * aiMultiplier);
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;			
		if (!isNil "_spawnedSquad") then {
			[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
		};		
	};	
};

// Create Task		
_vehicleName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);

_taskType = "truck";
_taskTitle = "Украсть технику";
_taskDesc = selectRandom [
	(format ["Важные транспортные средства в настоящее время перемещаются через регион %3, и наше командование стремится заполучить их для нашего собственного использования. Найдите %1, украдите его и доставьте в штаб.", _vehicleName, enemyFactionName, aoLocationName]),
	(format ["Сообщается, что %1 использовался противником в районе %3 поздно вечером. Разведка %4 полагает, что %1 содержит важную информацию о позициях %2 и хочет, чтобы вы нашли и украли эту технику. Доставьте в штаб транспорт, как только захватите его.", _vehicleName, enemyFactionName, aoLocationName, playersFactionName])
];

missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
_thisVeh setVariable ["thisTask", _taskName, true];

if (isMultiplayer) then {
	_thisVeh addMPEventHandler ["MPKilled", {
		[((_this select 0) getVariable ("thisTask")), "FAILED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
	}]; 
} else {
	_thisVeh addEventHandler ["Killed", {	
		[((_this select 0) getVariable ("thisTask")), "FAILED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
	}];
};	

// Create locate subtask
_subTaskDesc = format ["Провести разведку и определить местоположение %1.", _vehicleName];
_subTaskTitle = "Обнаружить";
_subTasks pushBack [_locateSubTaskName, _subTaskDesc, _subTaskTitle, "truck"];
missionNamespace setVariable [(format ["%1_taskType", _locateSubTaskName]), "truck", true];

[_thisVeh, _locateSubTaskName] spawn {
	waitUntil {
		sleep 3;
		({vehicle _x == (_this select 0)} count (units (grpNetId call BIS_fnc_groupFromNetId))) > 0								
	};
	[(_this select 1), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
	//'mkrAOC' setMarkerAlpha 1;			
};		

// Собственный триггер, срабатывающий когда игроки отвозят технику на базу
[_thisVeh, _taskName] spawn {
	waitUntil {sleep 5; _this select 0 distance (getMarkerPos "campMkr") < 100};
	[_this select 1, "SUCCEEDED", true] call BIS_fnc_taskSetState;
	
};

// Add steal trigger
// _trgSteal = [objNull, "mkrAOC"] call BIS_fnc_triggerToMarker;
// _trgSteal setTriggerActivation ["ANY", "PRESENT", false];
// _trgSteal setTriggerStatements [
	// "
		// (alive (thisTrigger getVariable 'thisVeh')) && 
		// !((thisTrigger getVariable 'thisVeh') in thisList)				
	// ",
	// "					
		// [(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		
	// ", 
	// ""];
// _trgSteal setVariable ["thisVeh", _thisVeh];				
// _trgSteal setVariable ["thisTask", _taskName];

// Marker
_markerName = format["vehMkr%1", floor(random 10000)];
[_thisVeh, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 400] execVM "sunday_system\objectives\followingMarker.sqf";

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