params ["_AOIndex"];

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

diag_log format["DRO: Task seeking a position in: %1", str (((AOLocations select _AOIndex) select 2) select 0)];

_thisPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;

// Create objects
_offsetPos = _thisPos getPos [2.5, random 360];
_pool = ["Land_WoodenCrate_01_F", "Land_FoodSacks_01_cargo_brown_F", "Land_Shovel_F", "Land_JunkPile_F", "Land_Pallets_F"];
_mainObj = "Land_WoodenCrate_01_stack_x3_F" createVehicle _offsetPos;
_otherObjs = [];
for "_i" from 0 to 3 do {
	_offsetPos = _thisPos getPos [3, random 360];
	_obj = (selectRandom _pool) createVehicle _offsetPos;
	_otherObjs pushBack _obj;
};

// Marker
_markerName = format["barricadeMkr%1", floor(random 10000)];
_markerBuilding = createMarker [_markerName, _thisPos];			
_markerBuilding setMarkerShape "ICON";
_markerBuilding setMarkerType "mil_end";
_markerBuilding setMarkerColor "ColorCivilian";		
_markerBuilding setMarkerAlpha 0;

// Create task
_taskTitle = "Построить баррикаду";
_taskDesc = selectRandom [
	(format ["Войска %1 перебрасывают войска и припасы через %2, и штаб поставил перед вами задачу помешать их продвижению путем строительства блокады на одной из дорог.", enemyFactionName, aoLocationName]),
	(format ["У нас есть сведения, что %1 может перебросить свои войска в %2 в ближайшее время. Имея это в виду, нам нужны дорожные баррикады, чтобы лучше защитить территорию. Используйте всё, что вы найдете, чтобы построить блокаду.", enemyFactionName, aoLocationName])	
];

_taskType = "use";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

[_mainObj, _otherObjs, _thisPos, ([_thisPos] call sun_getRoadDir), _taskName] call dro_addConstructAction;

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	0,
	nil,
	nil,
	2
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];