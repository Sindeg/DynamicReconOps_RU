params ["_AOIndex"];

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

diag_log format["DRO: Task seeking a position in: %1", str (((AOLocations select _AOIndex) select 2) select 0)];

_styles = [];
if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
	_styles pushBack "ROAD";
};
if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {
	_styles pushBack "GROUND";
};
_style = selectRandom _styles;

_thisPos = if (_style == "ROAD") then {
	[(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
} else {
	[(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;	
};

// Create disarm targets
_IEDPool = ["IEDLandBig_F", "IEDUrbanBig_F", "IEDLandSmall_F", "IEDUrbanSmall_F"];
_UXOPool = ["BombCluster_03_UXO1_F", "BombCluster_02_UXO1_F", "BombCluster_01_UXO1_F", "BombCluster_03_UXO4_F", "BombCluster_02_UXO4_F", "BombCluster_01_UXO4_F", "BombCluster_03_UXO2_F", "BombCluster_02_UXO2_F", "BombCluster_01_UXO2_F", "BombCluster_03_UXO3_F", "BombCluster_02_UXO3_F", "BombCluster_01_UXO3_F"];
_disarmTargetsIED = [];
_disarmTargetsUXO = [];

// Create roadside IED
if (_style == "ROAD") then {
	_road = ((_thisPos nearRoads 10) select 0);
	_roadDir = ([_road] call sun_getRoadDir);
	_IED = createMine [(selectRandom _IEDPool), (_thisPos getPos [4, _roadDir + (selectRandom [-90, 90])]), [], 0];
	_disarmTargetsIED pushBack _IED;
};

if ((random 1) > 0 && !UXOUsed) then {
	// Create spread of ordnance
	for "_i" from 0 to (floor (random [3, 6, 7])) do {
		_pos = [_thisPos, 10, 75, 0.5, 0, 1, 0] call BIS_fnc_findSafePos;
		if (count _pos > 0) then {
			_UXO = createMine [(selectRandom _UXOPool), _pos, [], 0];
			_disarmTargetsUXO pushBack _UXO;
			UXOUsed = true;
		};
	};
};

_taskDesc = selectRandom [
	(format ["Гражданское население %2 живет в опасности из - за невзорвавшихся боеприпасов %1. Если мы собираемся заручиться поддержкой местного населения и самостоятельно взять район, нам нужно сделать его безопасным. Найдите и обезопасьте любые боеприпасы, которые вы можете найти в отмеченной области.", enemyFactionName, aoLocationName]),
	(format ["Нам пришли сообщения о том, что в регионе %2 есть неразорвавшиеся боеприпасы. Если мы собираемся заручиться поддержкой местного населения и самостоятельно взять район, нам нужно сделать его безопасным. Найдите и обезопасьте любые боеприпасы, которые вы можете найти в отмеченной области.", enemyFactionName, aoLocationName])	
];

// Marker
_markerName = format["disarmMkr%1", floor(random 10000)];
if (count _disarmTargetsUXO > 0) then {
	_avgPos = [(_disarmTargetsUXO + _disarmTargetsIED)] call sun_avgPos;
	_thisPos = _avgPos;

	// Get marker size
	_minX = 9999999;
	_maxX = 0;
	_minY = 9999999;
	_maxY = 0;
	{
		_pos = getPos _x;
		_minX = (_pos select 0) min _minX;
		_maxX = (_pos select 0) max _maxX;
		_minY = (_pos select 1) min _minY;
		_maxY = (_pos select 1) max _maxY;
	} forEach (_disarmTargetsUXO + _disarmTargetsIED);

	_boundX = _maxX - _minX;
	_boundY = _maxY - _minY;

	_markerDisarm = createMarker [_markerName, _thisPos];			
	_markerDisarm setMarkerShape "ELLIPSE";
	_markerDisarm setMarkerBrush "Cross";
	_markerDisarm setMarkerSize [_boundX, _boundY];
	_markerDisarm setMarkerColor "ColorRed";		
	_markerDisarm setMarkerAlpha 0.5;
	
} else {
	
	[(_disarmTargetsIED select 0), _taskName, _markerName, _intelSubTaskName, "ColorRed", 150, "Cross"] execVM "sunday_system\objectives\staticMarker.sqf";
	
	_taskDesc = selectRandom [
		(format ["Недавно захваченный террорист, который являлся изготовителем СВУ рассказал, что эти бомбы используются в регионе %2. Мы знаем, что по крайней мере одно из таких СВУ присутствует в этом районе, и мы должны обезвредить его, чтобы уменьшить вероятность жертв и потерь среди гражданского населения.", enemyFactionName, aoLocationName]),
		(format ["%1 уже продолжительное время использует СВУ в регионе %2, и нам нужно, чтобы этот район был безопасным, чтобы уменьшить вероятность гражданских жертв.", enemyFactionName, aoLocationName])	
	];		
};
// Create task
_taskTitle = "Locate and Disarm";
_taskType = "mine";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

// Completion trigger
[_disarmTargetsIED, _disarmTargetsUXO, _taskName, _markerName] spawn {
	_allOrd = (_this select 0) + (_this select 1);
	while {count _allOrd > 0} do {
		sleep 5;
		_removeList = [];
		{
			if (!mineActive _x) then {
				_removeList pushBack _x;
			};
		} forEach _allOrd;
		_allOrd = _allOrd - _removeList;
	};	
	[(_this select 2), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', (_this select 2)], 1, true];
	(_this select 3) setMarkerAlpha 0;
};

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
	0
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];