params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

// Destroy Artillery emplacement
_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;

_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
_thisPos = _tempPos;

_artyTypes = [];
if (count eArtyClasses > 0) then {
	_artyTypes pushBack "ARTY";
};
if (count eAAClasses > 0) then {
	_artyTypes pushBack "AA";
};
_artyType = selectRandom _artyTypes;

_vehicleType = switch (_artyType) do {
	case "ARTY": {
		selectRandom eArtyClasses
	};
	case "AA": {
		selectRandom eAAClasses
	};
};
	
// Create Task		
_artyName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);
_taskTitle = switch (_artyType) do {
	case "ARTY": {
		"Уничтожить артиллерию"
	};
	case "AA": {
		"Уничтожить ПВО"
	};
};
_taskDesc = selectRandom [
	(format ["Артиллерия %2 %1 мешает проводить операции %3 в регионе %4. Крайне важно, чтобы эта цель была уничтожена до того, как основные силы %3 смогут безопасно атаковать противника и полномасштабную атаку. Уничтожить %1.", _artyName, enemyFactionName, playersFactionName, aoLocationName]),
	(format ["%2 переместили %1 на территорию %4, после чего силы %3 приостановили все операции в этой области, до тех пор, пока цель не будет уничтожена. Мы считаем, вашему отряду под силу проникнуть на территорию и уничтожить %1.", _artyName, enemyFactionName, playersFactionName, aoLocationName]),
	(format ["За несколько часов до наступления %3 необходимо, чтобы %2 %1, расположенный рядом с %4, был уничтожен. Командование попросило ваш отряд проникнуть и уничтожить %1 до прибытия основных сил.", _artyName, enemyFactionName, playersFactionName, aoLocationName])
];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

_thisVeh = _vehicleType createVehicle _thisPos;
_thisVeh = [_thisVeh] call sun_checkVehicleSpawn;
if (isNull _thisVeh) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};		
_thisVeh setVariable ["thisTask", _taskName, true];
_thisVeh setVehicleLock "LOCKED";

// Have artillery fire periodically
if (random 1 > 0.35) then {
	[_thisVeh] call sun_createVehicleCrew;
	//createVehicleCrew _thisVeh;
	[_artyType, _thisVeh] spawn {
		if ((_this select 0) == "ARTY") then {
			_ranges = [(_this select 1)] call dro_getArtilleryRanges;
			_targetPos = [(getPos (_this select 1)), (_ranges select 0), (_ranges select 1), 0, 1, 0, 0, [trgAOC]] call BIS_fnc_findSafePos;
			while {alive (_this select 1)} do {																
				sleep 60;
				(_this select 1) commandArtilleryFire [_targetPos, (selectRandom (getArtilleryAmmo [(_this select 1)])), ([3,5] call BIS_fnc_randomInt)];				
			};
			
		};
	};	
};

[_thisVeh] call dro_addSabotageAction;

// Add destruction event handler
_thisVeh addEventHandler ["Killed", {
	[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];	
} ];

// Create fortifications
_dir = direction _thisVeh;
_rotation = (_dir - 45);
for "_i" from 1 to 4 do {
	_cornerPos = [getPos _thisVeh, 16, _dir] call dro_extendPos;
	_corner = ["Land_HBarrierWall_corner_F", _cornerPos, _rotation] call dro_createSimpleObject;
	_dir = _dir + 90;
	_rotation = _rotation + 90;
};

_randItems = [4,10] call BIS_fnc_randomInt;
_itemsArray = [
	"Land_CargoBox_V1_F",
	"Land_Cargo10_grey_F",
	"Land_Cargo10_military_green_F",
	"CargoNet_01_barrels_F",
	"CargoNet_01_box_F",
	"Land_MetalBarrel_F",
	"Land_PaperBox_closed_F",
	"Land_PaperBox_open_empty_F",
	"Land_PaperBox_open_full_F",
	"Land_Pallet_MilBoxes_F",
	"Land_Pallets_F",
	"Land_Pallet_F"			
];
for "_i" from 1 to _randItems do {
	_itemPos = [_thisPos, 8, 20, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	_thisItem = selectRandom _itemsArray;
	[_thisItem, _itemPos, (random 360)] call dro_createSimpleObject;
};
_boxPos = [getPos _thisVeh, 4, (random 360)] call BIS_fnc_relPos;
"Box_NATO_AmmoVeh_F" createVehicle _boxPos;

// Create a bunker object and spawn enemies to guard it
_netPos = [_thisPos, 10, 40, 5, 0, 10, 0] call BIS_fnc_findSafePos;
	
_net = "CamoNet_INDP_big_F" createVehicle _netPos;
_net setDir (random 360);
_minAI = round (3 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad = [_netPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;		
if (!isNil "_spawnedSquad") then {
	[_spawnedSquad, _netPos] call bis_fnc_taskDefend;
};

// Marker
_markerName = format["artyMkr%1", floor(random 10000)];
[_thisVeh, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 600] execVM "sunday_system\objectives\followingMarker.sqf";	

// Create intel subtasks	
_subTaskDesc = format ["Соберите всю информацию, что сможете. Разведданные могут помочь уменьшить область вашего поиска и определить всё местоположения, где располагается противник. Проверяйте тела убитых %1, ищите отмеченные места разведданных и выполняйте любые задания по их поиску.", enemyFactionName];
_subTaskTitle = "Найти разведданные";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];
missionNamespace setVariable [(format ["%1_taskType", _intelSubTaskName]), "documents", true];

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	random 1
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];