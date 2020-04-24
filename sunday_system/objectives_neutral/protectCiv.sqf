params ["_AOIndex"];

_reconChance = 0;
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_subTaskName = format ["subtask%1", floor(random 100000)];
_subTaskName2 = format ["subtask%1", floor(random 100000)];
_thisPos = [];
_thisHouse = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;	
_buildingPositions = [_thisHouse] call BIS_fnc_buildingPositions;
_thisCiv = objNull;
if (count _buildingPositions > 0) then {
	_thisPos = selectRandom _buildingPositions;
	_civType = selectRandom civClasses;
	_group = createGroup playersSide;
	_thisCiv = _group createUnit [_civType, _thisPos, [], 0, "NONE"];	
	[_thisCiv] call dro_civDeathHandler;
	_thisCiv setVariable ["NOHOSTILE", true, true];
	_thisCiv setCaptive true;
	_thisCiv disableAI "PATH";
};

if (isNull _thisCiv) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

// Marker
_markerName = format["protectMkr%1", floor(random 10000)];
_markerProtect = createMarker [_markerName, _thisPos];			
_markerProtect setMarkerShape "ICON";
_markerProtect setMarkerType "mil_end";
_markerProtect setMarkerColor "ColorCivilian";		
_markerProtect setMarkerAlpha 0;

// Create task
_taskTitle = "Спасти гражданского";
_taskDesc = selectRandom [
	(format ["%3 - журналист в регионе %2, который был под арестом в течение последнего года. Основываясь на сведениях, собранных в предыдущей операции, мы считаем, что в настоящее время его жизни угрожает реальная угроза со стороны %1. Переместитесь в область %3 и защитите его.", enemyFactionName, aoLocationName, name _thisCiv]),
	(format ["Мы получили сообщение о том, что местное гражданское население готово предоставить нам подробную информацию о передвижениях войск %1, но в настоящее время одному из информаторов угрожает опасность. Найдите его и защитите.", enemyFactionName, aoLocationName, name _thisCiv]),
	(format ["%1 начал расправляться с протестующими в регионе %2. Активный участник операции по имени %3 обратился за помощью после получения серьезных угроз его жизни. Доберись до него и защитите его от вреда.", enemyFactionName, aoLocationName, name _thisCiv])
];

_taskType = "defend";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Create subtasks	
_subTaskDesc = format ["Найдите %1.", name _thisCiv];
_subTaskTitle = "Найти";
_subTasks pushBack [_subTaskName, _subTaskDesc, _subTaskTitle, "help"];
missionNamespace setVariable [(format ["%1_taskType", _subTaskName]), "help", true];

_subTaskDesc2 = format ["Защитите %1 от противника, эвакуируйте его за пределы зоны операции и доставьте в штаб.", name _thisCiv];
_subTaskTitle2 = "Защитить";
_subTasks pushBack [_subTaskName2, _subTaskDesc2, _subTaskTitle2, "defend"];
missionNamespace setVariable [(format ["%1_taskType", _subTaskName2]), "defend", true];

_thisCiv setVariable ["taskName", _taskName, true];
_thisCiv setVariable ["subTasks", _subTasks, true];

// Completion trigger
[_thisCiv, _taskName, _subTasks] spawn {
	_thisCiv = (_this select 0);
	_taskName = (_this select 1);
	_subTasks = (_this select 2);
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	
	waitUntil {
		sleep 3;
		if (_taskName call BIS_fnc_taskCompleted) exitWith {true};		
		(((leader (grpNetId call BIS_fnc_groupFromNetId)) distance _thisCiv) < 6)
	};
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	["PROTECT_CIV_MEET", (name (leader (grpNetId call BIS_fnc_groupFromNetId))), [name _thisCiv], false] spawn dro_sendProgressMessage;
	
	_thisCiv setUnitPos "DOWN";	
	_thisCiv setCaptive false;
	
	[((_subTasks select 0) select 0), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', ((_subTasks select 0) select 0)], 1, true];
	[((_subTasks select 0) select 1), "ASSIGNED", true] call BIS_fnc_taskSetState;
	_allGroups = [];
	_messageSent = false;
	for "_i" from 0 to ([1, 3] call BIS_fnc_randomInt) step 1 do {		
		_spawnGroup = [(getPos _thisCiv)] call dro_triggerAmbushSpawn;		
		if (!isNull _spawnGroup) then {
			_allGroups pushBack _spawnGroup;
			//_spawnGroup deleteGroupWhenEmpty false;
		};		
		if (!_messageSent && !isNull _spawnGroup) then {
			_messageSent = true;
			if (_taskName call BIS_fnc_taskCompleted) exitWith {};
			["AMBUSHCIV", "Command", [name _thisCiv]] spawn dro_sendProgressMessage;			
		};
		sleep 40;		
	};
	
	if (count _allGroups > 0) then {
		waitUntil {
			sleep 5;
			if (_taskName call BIS_fnc_taskCompleted) exitWith {true};
			[_allGroups] call sun_checkAllDeadFleeing
		};
	};
	
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	["PROTECT_CIV_CLEAR", (name (leader (grpNetId call BIS_fnc_groupFromNetId))), [name _thisCiv], false] spawn dro_sendProgressMessage;
	[((_subTasks select 0) select 1), "SUCCEEDED", true] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', ((_subTasks select 0) select 1)], 1, true];
	[_taskName, "SUCCEEDED", true] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', _taskName], 1, true];
	
	sleep 30;
	_thisCiv enableAI "PATH";
	_thisCiv setUnitPos "UP";
};

// Create triggers
_thisCiv addEventHandler ["Killed", {
	_unit = (_this select 0);
	[(_unit getVariable "taskName"), 'FAILED', true] spawn BIS_fnc_taskSetState;
}]; 

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	0,
	_subTasks,
	_thisCiv,
	0	
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];