// *****
// SETUP PLAYER START
// *****

newUnitsReady = false;
private _center = getPos trgAOC;
_playerGroup = (units(grpNetId call BIS_fnc_groupFromNetId));
_playersPos = [];
_groundStyleSelect = "";

// Has the player edited in Zeus?
_zeus = getAssignedCuratorLogic (leader(grpNetId call BIS_fnc_groupFromNetId));
diag_log format ["Zeus = %1",_zeus];

// Delete all tasks
/*
{
	diag_log format ["DRO: Deleting old task %1", _x];
	[_x] call BIS_fnc_deleteTask;
} forEach ([leader (grpNetId call BIS_fnc_groupFromNetId)] call BIS_fnc_tasksUnit);
*/

{	
	if (isObjectHidden _x) then {		
		deleteVehicle _x;
		diag_log format ["DRO: Deleting unit %1", _x];
	};
} forEach _playerGroup;
diag_log _playerGroup;

if (insertType == 0) then {
	insertType = [1,3] call BIS_fnc_randomInt;		
};

_customStart = false;
_randomStartingLocation = [];
_forceSeaStart = 0;
if (count customPos == 0) then {
	diag_log "DRO: No custom start position found, will generate random.";
	_randomStartingLocation = [];
} else {
	diag_log "DRO: Custom start position found.";
	_randomStartingLocation = customPos;
	if (surfaceIsWater _randomStartingLocation) then {
		_forceSeaStart = 1;
	};
	_customStart = true;
};

_seaSpawnReal = [];
_airStartPos = [];

// Random resupply
_resupplyValid = true;
if (count pHeliClasses > 0) then {
	if (random 1 > 0.5) then {
		customSupports pushBackUnique ["SUPPLY"];
		_resupplyValid = false;
	};
};
if (_resupplyValid) then {
	_validIndexes = [];
	{
		if (count ((_x select 2) select 6) > 0) then {
			_validIndexes pushBack _forEachIndex;
		};
	} forEach AOLocations;
	_resupplyPos = if (count _validIndexes > 0) then {
		[(((AOLocations select (selectRandom _validIndexes)) select 2) select 6)] call sun_selectRemove
	} else {
		[_center, 0, 500, 2, 0, 0.4, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos
	};
	if (!isNil "_resupplyPos") then {
		if (_resupplyPos isEqualTo [0,0,0]) then {
			_resupplyValid = false;
		};
	} else {
		_resupplyValid = false;
	};
	if (_resupplyValid) then {
		_resupply = "B_supplyCrate_F" createVehicle _resupplyPos;
		clearWeaponCargoGlobal _resupply;
		clearMagazineCargoGlobal _resupply;
		clearItemCargoGlobal _resupply;
		_resupply addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
		_resupply addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
		
		_resupply addItemCargoGlobal ["ACE_fieldDressing", 15];
		_resupply addItemCargoGlobal ["ACE_elasticBandage", 15];
		_resupply addItemCargoGlobal ["ACE_quikclot", 15];
		_resupply addItemCargoGlobal ["ACE_bloodIV", 2];
		_resupply addItemCargoGlobal ["ACE_bloodIV_500", 2];
		_resupply addItemCargoGlobal ["ACE_bloodIV_250", 3];
		_resupply addItemCargoGlobal ["ACE_morphine", 10];
		_resupply addItemCargoGlobal ["ACE_epinephrine", 10];
		_resupply addItemCargoGlobal ["ACE_tourniquet", 15];
		_resupply addItemCargoGlobal ["ACE_personalAidKit", 2];
		
		_resupply addItemCargoGlobal ["ACE_EntrenchingTool", 2];
		_resupply addItemCargoGlobal ["ACE_CableTie", 5];
		
		_resupply addItemCargoGlobal ["SmokeShell", 8];
		_resupply addItemCargoGlobal ["SmokeShellBlue", 2];
		_resupply addItemCargoGlobal ["SmokeShellOrange", 2];
		_resupply addItemCargoGlobal ["Item_MineDetector", 1];
		{    
		  _magazines = magazinesAmmoFull _x;      
		  {
			_resupply addMagazineCargoGlobal [(_x select 0), 2];
		  } forEach _magazines;  
		} forEach units (grpNetId call BIS_fnc_groupFromNetId);	
		[_resupply] spawn {
			waitUntil {sleep 5; (missionNameSpace getVariable ["playersReady", 0]) == 1};
			[(_this select 0)] call sun_supplyBox;
		};		
		markerResupply = createMarker ["resupplyMkr", _resupplyPos];
		markerResupply setMarkerShape "ICON";
		markerResupply setMarkerColor markerColorPlayers;
		markerResupply setMarkerType "mil_flag";
		markerResupply setMarkerText "Снаряжение";
		markerResupply setMarkerSize [0.6, 0.6];
	};
};
_carClasses = [];
_carWeights = [];
_slots = [];

if (count pCarNoTurretClasses > 0) then {
	{
		_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;		
		_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
		
		if (_vehicleClass != "Support") then {		
			_carClasses pushBack _x;						
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));						
			_slots pushBack _vehRoles;
			_weight = (1-((_vehRoles * 3)/100)) max 0;		
			_carWeights pushBack _weight;		
			
		};
	} forEach pCarNoTurretClasses;
};

{
	_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;
	_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
	
	if (_vehicleClass != "Support") then {		
		if (_x in _carClasses) then {} else {
			_carClasses pushBack _x;				
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
			_slots pushBack _vehRoles;		
			_weight = (1-((_vehRoles * 7)/100)) max 0;		
			_carWeights pushBack _weight;
		};		
	};		
} forEach pCarClasses;

_heliClasses = [];
_cargoRange = [100, 0];
{	
	_trueCargo = [_x] call sun_getTrueCargo;		
	if (_trueCargo >= count (units (grpNetId call BIS_fnc_groupFromNetId))) then {
		if (_forEachIndex == 0) then {
			_cargoRange set [0, _trueCargo];
			_cargoRange set [1, _trueCargo];
		};
		_heliClasses pushBack _x;
		if (_trueCargo < (_cargoRange select 0)) then {
			_cargoRange set [0, _trueCargo];
		};
		if (_trueCargo > (_cargoRange select 1)) then {
			_cargoRange set [1, _trueCargo];
		};
	};	
} forEach pHeliClasses;

_shipClasses = pShipClasses;
if (count _shipClasses == 0) then {
	_shipClasses pushBack "B_Boat_Transport_01_F";
};

if ((count _carClasses) == 0) then {
	_carClasses pushBack "B_G_Offroad_01_F";
	_carWeights pushBack 1;
};

if ((count _heliClasses) == 0) then {
	switch (playersSide) do {
		case west: {_heliClasses pushBack "B_Heli_Transport_01_F"};
		case east: {_heliClasses pushBack "O_Heli_Light_02_F"};
		case resistance: {_heliClasses pushBack "I_Heli_Transport_02_F"};
	};
};

diag_log format ["DRO: Insert will be %1", insertType];

switch (insertType) do {

	case 1: {
		// GROUND INSERTION		
		_groundStylesAvailable = [];		
		_seaSpawn = nil;
		
		if (_forceSeaStart == 1) then {
			_groundStylesAvailable = ["SEA"];
		} else {
		
			// Check for sea start possibility
			_seaPositions = [];	
			if (!_customStart) then {
				_seaPlaces = selectBestPlaces [_center, aoSize, "(1 + sea)", 50, 5];							
				{
					_thisPos = (_x select 0);
					_zValue = getTerrainHeightASL _thisPos;					
					if (_zValue < -10) then {
						_seaPositions pushBack [((_x select 0)select 0), ((_x select 0)select 1), _zValue];	
					};					
				} forEach _seaPlaces;				
				_seaPositions = [_seaPositions, [_center], {_input0 distance _x}, "DESCEND"] call BIS_fnc_sortBy;
				diag_log format ["DRO: Potential sea positions: %1", _seaPositions];
			};

			// Generate random ground start position for player group
			if (count _randomStartingLocation == 0) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+1500), 8, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			};
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+3000), 2, 0, 0.6, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
			};		
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+4500), 2, 0, 0.6, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
			};	
			if (_forceSeaStart == 1) then {
				_groundStylesAvailable = ["SEA"];
			} else {
				if (!(_randomStartingLocation isEqualTo [0,0,0])) then {								
					_groundStylesAvailable pushBack "FOB";					
				};
			};					
			
			if (count _groundStylesAvailable == 0) then {			
				if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
					_seaSpawn = _seaPositions select 0;
					_groundStylesAvailable pushBackUnique "SEA";
				};		
			} else {
				_seaRand = (random 100);
				if (_seaRand > 85) then {
					if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
						_seaSpawn = _seaPositions select 0;
						_groundStylesAvailable pushBackUnique "SEA";
					};
				};
			};		
		};
		_groundStyleSelect = selectRandom _groundStylesAvailable;
		diag_log format ["DRO: Ground insert style will be %1", _groundStyleSelect];
				
		switch (_groundStyleSelect) do {
			case "FOB": {					
				// Spawn FOB				
				insertType = "GROUND";
				// Get smallest distance to an AO
				_closestDistance = 1000000;
				{
					_dist = (_x select 0) distance _randomStartingLocation;
					if (_dist < _closestDistance) then {
						_closestDistance = _dist;
					};
				} forEach AOLocations;
				
				_boundaries = [0, 1000, 2000, 1000000];
				_chosenBoundary = 0;
				{
					if (_closestDistance > _x) then {
						if (_forEachIndex + 1 < count _boundaries) then {
							if (_closestDistance <= (_boundaries select (_forEachIndex + 1))) then {
								_chosenBoundary = _forEachIndex;
							};
						};
					};
				} forEach _boundaries;
				
				switch (_chosenBoundary) do {
					case 0: {
						// Camp
						[_randomStartingLocation] call fnc_generateCampsite;
					};
					case 1: {
						// Small FOB
						_objects = selectRandom compositionsFOBs;
						_ambGrp = createGroup playersSide;		
						_spawnDir = (random 360);
						{
							_x hideObjectGlobal true;
						} forEach (nearestTerrainObjects [_randomStartingLocation, [], 40]);
						_spawnedObjects = [_randomStartingLocation, _spawnDir, _objects] call BIS_fnc_ObjectsMapper;
						{
							if (typeOf _x == "Sign_Arrow_Blue_F") then {
								_guardGroup = [getPos _x, playersSide, pInfClassesForWeights, pInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
								_guardUnit = ((units _guardGroup) select 0);
								[_guardUnit, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), "ASIS"] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_guardUnit setFormDir (getDir _x);
								_guardUnit setDir (getDir _x);
								//_guardUnit disableAI "TARGET";
								//_guardUnit disableAI "MOVE";
								deleteVehicle _x;
							};
						} forEach _spawnedObjects;
						
						_addonPlaces = [_randomStartingLocation, 3, 3, 14] call sun_defineGrid;						
						_addonPlaces deleteAt 4;
							
						for "_i" from 3 to ([4, 7] call BIS_fnc_randomInt) step 1 do {
							_thisPos = [_addonPlaces] call sun_selectRemove;
							_objects = selectRandom compositionsFOBAddons;
							_spawnedObjects = [_thisPos, (selectRandom [_spawnDir, _spawnDir + 90]), _objects] call BIS_fnc_ObjectsMapper;
							if (random 1 > 0.6) then {
								_ambGuard = (units (([_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
								[_ambGuard, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_dir = (selectRandom [(_ambGuard getDir _thisPos), (_thisPos getDir _ambGuard)]);																
								_ambGuard setDir _dir;
								if (random 1 > 0.3) then {
									_safePos = (getPos _ambGuard) findEmptyPosition [1.5, 2.5];
									if (count _safePos > 0) then {
										_ambGuard2 = (units (([_safePos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
										//_ambGuard2 setPos (_thisPos getPos [(random [1.5, 2.5, 2]), _dir - 25]);
										[_ambGuard2, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
										_ambGuard2 setDir ((_ambGuard2 getDir _ambGuard) - 20);
									};
								};
							};
						};
						
						// Случайный отряд патрулирования
						/*
						_spawnPos1 = _randomStartingLocation findEmptyPosition [10, 30];
						_spawnedSquad1 = [_spawnPos1, playersSide, pInfClassesForWeights, pInfClassWeights, [2, 4]] call dro_spawnGroupWeighted;						
						waitUntil {!isNil "_spawnedSquad1"};
						{							
							_x disableAI "TARGET";
							_x disableAI "AUTOTARGET";
							_x disableAI "FSM";
							_x disableAI "WEAPONAIM";
							_x disableAI "AUTOCOMBAT";
						} forEach (units _spawnedSquad1);						
						[_spawnedSquad1, _randomStartingLocation, 30] call BIS_fnc_taskPatrol;						
						*/
					};
					case 2: {
						// Big FOB
						_ambGrp = createGroup playersSide;
						_objects = selectRandom compositionsFOBLarge;								
						//_spawnDir = (random 360);
						{
							_x hideObjectGlobal true;
						} forEach (nearestTerrainObjects [_randomStartingLocation, [], 80]);
						_spawnedObjects = [_randomStartingLocation, 0, _objects] call BIS_fnc_ObjectsMapper;
						{
							if (["patrol", (typeOf _x)] call BIS_fnc_inString) then {
								if (random 1 > 0.25) then {
									_ambGuard = (units (([_randomStartingLocation, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
									[_ambGuard, (selectRandom ["WATCH", "WATCH2"]), "ASIS"] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
									_dirOut = ((getDir _x) + 180);
									_ambGuard setDir _dirOut;
									[_x, _ambGuard, [(selectRandom [-1.5, 1.5]),-1.5,4.3], _dirOut] call BIS_fnc_relPosObject;
								};					
							};
							
							if (typeOf _x == "Sign_Arrow_Direction_Green_F") then {
								_objVehWork = createVehicle [(selectRandom pCarClasses), (getPos _x), [], 0, "CAN_COLLIDE"];
								_objVehWork setDir (getDir _x);
								deleteVehicle _x;
								_objVehWork setVehicleLock "LOCKED";
								_objVehWork setDamage 0.8;
								_class = (selectRandom pInfClasses);
								{
									if (["engineer", _x, false] call BIS_fnc_inString) then {
										_class = _x;
									};
								} forEach pInfClasses;							
								_ambWorker = _ambGrp createUnit [_class, _randomStartingLocation, [], 0, "NONE"];
								
								[_ambWorker, (selectRandom ["REPAIR_VEH_KNEEL", "REPAIR_VEH_STAND"]), (selectRandom ["LIGHT", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
								[_objVehWork, _ambWorker, [-2,(selectRandom [-1.5, 1.5]), 0], (getDir _objVehWork)] call BIS_fnc_relPosObject;
								_dirTo = ((getDir _objVehWork) + 90);
								_ambWorker setDir _dirTo;
								//[_ambWorker, "InBaseMoves_repairVehicleKnl"] remoteExec ["switchMove", 0, true];
								
							};					
						} forEach _spawnedObjects;
						
						_base = createVehicle ["Land_CanvasCover_01_F", _randomStartingLocation, [], 0, "CAN_COLLIDE"];					
						_obj1 = objNull;
						_obj3 = createVehicle ["Land_CampingTable_white_F", [0,0,100], [], 0, "CAN_COLLIDE"];
						[_base, _obj3, [1.1,0.7,0], 90] call BIS_fnc_relPosObject;		
						if (playersFaction in ["BLU_CTRG_F", "BLU_F", "BLU_GEN_F", "BLU_T_F", "IND_F", "OPF_F", "OPF_T_F", "OPF_V_F"]) then {
							_obj1 = createVehicle ["Land_TripodScreen_01_large_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _obj1, [0.3,3.1,0], 230] call BIS_fnc_relPosObject;
												
							_obj4 = createVehicle ["Land_Laptop_unfolded_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj4, [-0.35,0.15,0.82], 160] call BIS_fnc_relPosObject;
							_obj5 = createVehicle ["Land_SatellitePhone_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj5, [0.5,0,0.82], 20] call BIS_fnc_relPosObject;
							_box1 = createVehicle ["Land_PaperBox_open_full_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box1, [2.3,0.4,0], 5] call BIS_fnc_relPosObject;
							_box2 = createVehicle ["Land_Pallet_MilBoxes_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box2, [2.5,1.7,0], 350] call BIS_fnc_relPosObject;
						} else {
							_obj1 = createVehicle ["Land_MapBoard_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							
							[_base, _obj1, [0.3,3.1,0], 50] call BIS_fnc_relPosObject;
							
							_map = switch (worldName) do {
								case "Altis": {"Land_Map_altis_F"};
								case "Stratis": {"Land_Map_stratis_F"};
								case "Tanoa": {"Land_Map_Tanoa_F"};
								case "Malden": {"Land_Map_Malden_F"};
								case "Enoch": {"Land_Map_Enoch_F"};
								default {"Land_Map_blank_F"};
							};	
							_intelClasses = ["Land_File1_F", "Land_FilePhotos_F", "Land_File2_F", "Land_File_research_F", "Land_MobilePhone_old_F", "Land_PortableLongRangeRadio_F", "Land_Laptop_02_unfolded_F"];
							
							_obj4 = createVehicle [_map, [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj4, [-0.35,0.12,0.82], 70] call BIS_fnc_relPosObject;
							if (_map == "Land_Map_blank_F") then {
								_mapPic = ((configFile >> "CfgWorlds" >> worldName >> "pictureMap") call BIS_fnc_GetCfgData);
								if (!isNil "_mapPic") then {
									_obj4 setObjectTextureGlobal [0, _mapPic];
								};
							};
							_obj5 = createVehicle [(selectRandom _intelClasses), [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj5, [0.5,0,0.82], 20] call BIS_fnc_relPosObject;
							
							_box1 = createVehicle ["Land_Pallet_MilBoxes_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box1, [2.3,0.4,0], 5] call BIS_fnc_relPosObject;
							_box2 = createVehicle ["Land_PaperBox_open_full_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box2, [2.5,2,0], 350] call BIS_fnc_relPosObject;
						};
						_mapBoard = switch (worldName) do {
							case "Altis": {"MapBoard_altis_F"};
							case "Stratis": {"MapBoard_stratis_F"};
							case "Tanoa": {"MapBoard_Tanoa_F"};
							case "Malden": {"MapBoard_Malden_F"};
							case "Enoch": {"MapBoard_Enoch_F"};
							default {"Land_MapBoard_F"};
						};	
						_obj2 = createVehicle [_mapBoard, [0,0,100], [], 0, "CAN_COLLIDE"];
						[_base, _obj2, [-3.6,3.4,0], 320] call BIS_fnc_relPosObject;
						
						if (typeOf _obj2 == "Land_MapBoard_F") then {
							_mapPic = ((configFile >> "CfgWorlds" >> worldName >> "pictureMap") call BIS_fnc_GetCfgData);
							if (!isNil "_mapPic") then {
								_obj2 setObjectTextureGlobal [0, _mapPic];
							};
						};
						
						// Create officers
						if (count pOfficerClasses > 0) then {
							if (random 1 > 0.3) then {
								_dir = if (typeOf _obj1 == "Land_MapBoard_F") then {((getDir _obj1) + 220)} else {((getDir _obj1) + 40)};
								_officer = _ambGrp createUnit [(selectRandom pOfficerClasses), (_obj1 getPos [2, _dir]), [], 0, "CAN_COLLIDE"];
								_officer setDir (_officer getDir _obj1);
								[_officer, "BRIEFING", (selectRandom ["LIGHT", "ASIS", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
							};
							if (random 1 > 0.3) then {
								_officer2 = _ambGrp createUnit [(selectRandom pOfficerClasses), (_obj3 getPos [0.7, ((getDir _obj3) - 150)]), [], 0, "CAN_COLLIDE"];
								[_officer2, "LEAN_ON_TABLE", (selectRandom ["LIGHT", "ASIS", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
								_officer2 setDir (getDir _obj3);
								_officer2 setPos [((getPos _officer2) select 0), ((getPos _officer2) select 1), 0.8];
							};
						};
						
						for "_i" from 0 to ([2, 4] call BIS_fnc_randomInt) do {
							_thisPos = [_randomStartingLocation, 10, 18, 1, 0, 1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
							if !(_thisPos isEqualTo [0,0,0]) then {
								//_ambGuard = _ambGrp createUnit [(selectRandom pInfClasses), _thisPos, [], 0, "NONE"];
								_ambGuard = (units (([_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
								[_ambGuard, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_dir = (selectRandom [(_ambGuard getDir _thisPos), (_thisPos getDir _ambGuard)]);								
								_ambGuard setDir _dir;
								if (random 1 > 0.3) then {
									_safePos = (getPos _ambGuard) findEmptyPosition [1.5, 2.5];
									if (count _safePos > 0) then {
										_ambGuard2 = (units (([_safePos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
										//_ambGuard2 setPos (_thisPos getPos [(random [1.5, 2.5, 2]), _dir - 25]);
										[_ambGuard2, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
										_ambGuard2 setDir ((_ambGuard2 getDir _ambGuard) - 20);
									};
								};
							};
						};					
					};					
				};
								
				// Create 'real' player units at the spawn position and switch players
				_playersPos = [_randomStartingLocation, 20, (random 360)] call dro_extendPos;				
				//[_playersPos] remoteExec ["sun_newUnits", s1];
				[_playersPos] call sun_setPlayerGroup;
				waitUntil {newUnitsReady};				
				_rolesFilled = 0;
				_whileAttempts = 0;
				_select = 0;
				_vehLocation = [];
				startVehicles = ["", ""]; // Отключение спавна дружественной техники
				
				// Ящик с арсеналом
				_boxLocation = _randomStartingLocation findEmptyPosition [0, 20, "B_supplyCrate_F"];
				if (count _boxLocation > 0) then {				
					_box = arsenalBox;
					//clearWeaponCargoGlobal _box;
					//clearMagazineCargoGlobal _box;
					//clearItemCargoGlobal _box;

					_box setPos _boxLocation;
					sleep 2;
					_box setVectorUp [0,0,1];
				};
				
				_posArsenalSpawn = [getpos arsenalBox, 3, 15, 3, 0, 30, 0, [], getpos arsenalBox] call BIS_fnc_findSafePos;
				markerRespawnTeam = createMarker ["respawnBase", _posArsenalSpawn];
				markerRespawnTeam setMarkerShape "ICON";
				markerRespawnTeam setMarkerColor "ColorGreen";
				markerRespawnTeam setMarkerType "mil_flag";
				markerRespawnTeam setMarkerAlpha 0;
				
				// FOB marker
				deleteMarker "campMkr";				
				//_campName = format ["ШТАБ", ([FOBNames] call sun_selectRemove)];
				_campName = format ["ШТАБ"];
				missionNameSpace setVariable ["publicCampName", _campName];
				publicVariable "publicCampName";
				markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
				markerPlayerStart setMarkerShape "ICON";
				markerPlayerStart setMarkerColor markerColorPlayers;
				markerPlayerStart setMarkerType "loc_Bunker";
				markerPlayerStart setMarkerSize [3, 3];
				markerPlayerStart setMarkerText _campName;
				if ((paramsArray select 0) < 3 && (paramsArray select 1) < 2) then {	
					respawnFOB = [missionNamespace, "campMkr", _campName] call BIS_fnc_addRespawnPosition;
				};
				
				// Установка места спавна техники
				_spawnerPos = [_boxLocation, 45, 60, 11, 0, 10, 0] call BIS_fnc_findSafePos;
				_heliPodPos = "Land_HelipadSquare_F" createVehicle _spawnerPos;
				_markerSpawner = createMarker ["VVS_all_1", _spawnerPos];
				"VVS_all_1" setmarkerpos _spawnerPos;
				"VVS_all_1" setMarkerColor "ColorBrown";
				"VVS_all_1" setMarkerType "mil_box";
				"VVS_all_1" setMarkerText "Техника";
				
				// Установка арсенала техники
				_workerPos = [_spawnerPos, 10, 10, 2, 0, 10, 0] call BIS_fnc_findSafePos;
				baseWorker setpos _workerPos;
				baseWorker setdir getDir arsenalBox;
				
				// Добавление пунктов меню действий для арсенала техники
				if (minesEnabled == 1) then {
					[baseWorker, ["<t color='#ABAC9F'>Арсенал автомобилей</t>",{[["cars"], ["rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_3camo_msv","O_gorles_GAZ_Tigr_01","rhs_tigr_msv","rhs_tigr_m_msv", "BWA3_Eagle_Tropen","BWA3_Eagle_FLW100_Tropen","BWA3_Eagle_Fleck","BWA3_Eagle_FLW100_Fleck", "LOP_AA_Offroad_M2_Police","LOP_AA_M1025_W_M2","LOP_AA_M1025_W_Mk19","LOP_AA_M1025_D","LOP_AA_M998_D_4DR","LOP_IA_M1025_W_Mk19","LOP_IA_M1025_D","LOP_IA_M1025_W_M2","LOP_IA_M998_D_4DR","B_MRAP_01_gmg_F","B_MRAP_01_F","B_MRAP_01_hmg_F","B_LSV_01_unarmed_F","B_LSV_01_AT_F","B_LSV_01_armed_F","B_T_MRAP_01_F","B_T_MRAP_01_gmg_F","B_T_MRAP_01_hmg_F","B_T_LSV_01_unarmed_F","B_T_LSV_01_AT_F","B_T_LSV_01_armed_F","LOP_PESH_M1025_W_M2","LOP_PESH_M1025_W_Mk19","LOP_PESH_M1025_D","LOP_PESH_M998_D_4DR","LOP_PESH_Nissan_PKM","LOP_PESH_Offroad_M2","LOP_PESH_Offroad_AT","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m1025_w","rhsusf_m1043_w_m2","rhsusf_m1043_w_mk19","rhsusf_m1043_w","rhsusf_m1045_w","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr","rhsusf_m998_w_4dr_fulltop","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr","rhsusf_m966_w","rhsusf_m1043_d_m2","rhsusf_m1043_d_mk19","rhsusf_m1043_d","rhsusf_m1045_d","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr","rhsusf_m998_d_4dr_fulltop","rhsusf_m998_d_4dr_halftop","rhsusf_m966_d","rhsusf_mrzr4_d","rhsgref_cdf_b_reg_uaz","rhsgref_cdf_b_reg_uaz_open","rhsgref_cdf_b_reg_uaz_dshkm","rhsgref_cdf_b_reg_uaz_ags","rhsgref_cdf_b_reg_uaz_spg9","LOP_CDF_Offroad_M2","B_CTRG_LSV_01_light_F","B_G_Offroad_01_AT_F","B_G_Offroad_01_armed_F","rhsgref_hidf_m1025_m2","rhsgref_hidf_m1025","rhsgref_hidf_m1025_mk19","rhsgref_hidf_M998_2dr_fulltop","rhsgref_hidf_M998_2dr_halftop","rhsgref_hidf_M998_2dr","rhsgref_hidf_M998_4dr_fulltop","rhsgref_hidf_M998_4dr_halftop","rhsgref_hidf_m998_4dr"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#ABAC9F'>Арсенал грузовых авто</t>",{[["cars","tanks"], ["LOP_AA_Ural","LOP_AA_Ural_open","LOP_IA_Ural_open","LOP_IA_Ural","B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_Repair_F","B_Truck_01_covered_F","B_Truck_01_medical_F","rhsusf_M1078A1P2_WD_fmtv_usarmy","B_Truck_01_transport_F","rhsusf_M1078A1P2_B_WD_fmtv_usarmy","rhsusf_M1078A1P2_B_WD_CP_fmtv_usarmy","rhsusf_M1083A1P2_WD_fmtv_usarmy","rhsusf_M1083A1P2_B_M2_WD_fmtv_usarmy","rhsusf_M977A4_AMMO_usarmy_wd","rhsusf_M977A4_REPAIR_usarmy_wd","rhsusf_M977A4_AMMO_BKIT_usarmy_wd","rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_wd","rhsusf_M977A4_REPAIR_BKIT_usarmy_wd","rhsusf_M1078A1P2_D_fmtv_usarmy","rhsusf_M1078A1P2_B_D_fmtv_usarmy","rhsusf_M1078A1P2_B_M2_D_fmtv_usarmy","rhsusf_M1078A1P2_B_D_CP_fmtv_usarmy","rhsusf_M1083A1P2_D_fmtv_usarmy","rhsusf_M1083A1P2_B_WD_fmtv_usarmy","rhsusf_M1085A1P2_B_WD_Medical_fmtv_usarmy","rhsusf_M1083A1P2_B_D_fmtv_usarmy","rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy","rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy","rhsusf_M977A4_AMMO_usarmy_d","rhsusf_M977A4_REPAIR_usarmy_d","rhsusf_M977A4_AMMO_BKIT_M2_usarmy_d","rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_d","rhsusf_M977A4_REPAIR_BKIT_usarmy_d","rhsusf_M977A4_AMMO_BKIT_M2_usarmy_wd","rhsusf_M1078A1R_SOV_M2_D_fmtv_socom","rhsusf_M1084A1R_SOV_M2_D_fmtv_socom","rhsgref_cdf_b_gaz66","rhsgref_cdf_b_gaz66_zu23","rhsgref_cdf_b_gaz66_r142","rhsgref_cdf_b_gaz66_ammo","rhsgref_cdf_b_gaz66o","rhsgref_cdf_b_ural","rhsgref_cdf_b_ural_fuel","rhsgref_cdf_b_ural_Zu23","rhsgref_cdf_b_ural_open","rhsgref_cdf_b_ural_repair","rhsgref_cdf_b_zil131","rhsgref_cdf_b_zil131_open","LOP_CDF_KAMAZ_Covered","LOP_CDF_KAMAZ_Ammo","LOP_CDF_KAMAZ_Medical","LOP_CDF_KAMAZ_Transport","LOP_CDF_KAMAZ_Repair","rhsusf_M977A4_AMMO_BKIT_usarmy_d""LOP_CDF_KAMAZ_Fuel"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал БТР</t>",{[["cars","tanks"], ["rhs_btr80_vmf","O_gorles_BTR_80_01", "LOP_AA_M113_C","LOP_AA_M113_D","LOP_AA_M113_W","LOP_AA_M1117_D","LOP_IA_BTR80","LOP_IA_M113_W","B_APC_Wheeled_01_cannon_F","B_T_APC_Wheeled_01_cannon_F","rhsusf_m113_usarmy_MK19","rhsusf_m113_usarmy_supply","rhsusf_m113_usarmy_M240","rhsusf_m113_usarmy_medical","rhsusf_m113_usarmy_unarmed","rhsusf_stryker_m1126_m2_wd","rhsusf_stryker_m1126_mk19_wd","rhsusf_stryker_m1127_m2_wd","rhsusf_stryker_m1132_m2_wd","rhsusf_stryker_m1134_wd","rhsusf_m113_usarmy_M2_90","rhsusf_M1117_W","rhsusf_M1220_usarmy_wd","rhsusf_M1220_M153_M2_usarmy_wd","rhsusf_M1220_M2_usarmy_wd","rhsusf_M1220_MK19_usarmy_wd","rhsusf_M1230_M2_usarmy_wd","rhsusf_M1230_MK19_usarmy_wd","rhsusf_M1230a1_usarmy_wd","rhsusf_M1232_usarmy_wd","rhsusf_M1232_M2_usarmy_wd","rhsusf_M1232_MK19_usarmy_wd","rhsusf_M1237_M2_usarmy_wd","rhsusf_M1237_MK19_usarmy_wd","rhsusf_m1240a1_usarmy_wd","rhsusf_m1240a1_m2crows_usarmy_wd","rhsusf_m1240a1_m2_usarmy_wd","rhsusf_m1240a1_m240_usarmy_wd","rhsusf_m1240a1_mk19crows_usarmy_wd","rhsusf_m1240a1_mk19_usarmy_wd","rhsusf_m113d_usarmy_MK19","rhsusf_m113d_usarmy_M240","rhsusf_m113d_usarmy_supply","rhsusf_m113d_usarmy_medical","rhsusf_m113d_usarmy_unarmed","rhsusf_M1117_O","rhsusf_M1220_usarmy_d","rhsusf_M1220_M153_M2_usarmy_d","rhsusf_M1220_M2_usarmy_d","rhsusf_M1220_MK19_usarmy_d","rhsusf_M1220_M153_MK19_usarmy_d","rhsusf_M1230_M2_usarmy_d","rhsusf_M1230_MK19_usarmy_d","rhsusf_M1230a1_usarmy_d","rhsusf_M1232_usarmy_d","rhsusf_M1232_M2_usarmy_d","rhsusf_M1232_MK19_usarmy_d","rhsusf_M1237_MK19_usarmy_d","rhsusf_M1237_M2_usarmy_d","rhsusf_m1240a1_usarmy_d","rhsusf_m1240a1_m2crows_usarmy_d","rhsusf_m1240a1_m2_usarmy_d","rhsusf_m1240a1_m240_usarmy_d","rhsusf_m1240a1_mk19crows_usarmy_d","rhsusf_m1240a1_mk19_usarmy_d","rhsusf_M1238A1_M2_socom_d","rhsusf_M1238A1_socom_d","rhsusf_M1238A1_Mk19_socom_d","rhsusf_M1239_socom_d","rhsusf_M1239_M2_socom_d","rhsusf_M1239_MK19_socom_d","rhsusf_M1239_M2_Deploy_socom_d","rhsusf_M1239_MK19_Deploy_socom_d","rhsusf_m1245_m2crows_socom_d","rhsusf_m1245_mk19crows_socom_d","rhsusf_m1245_m2crows_socom_deploy","rhsusf_m1245_mk19crows_socom_deploy","rhsgref_cdf_b_btr60","rhsgref_cdf_b_btr70","rhsgref_BRDM2_b","rhsgref_BRDM2_ATGM_b","rhsgref_BRDM2UM_b","rhsgref_BRDM2_HQ_b","LOP_CDF_BTR60","LOP_CDF_BTR70","rhsgref_hidf_m113a3_unarmed","rhsgref_hidf_m113a3_mk19","rhsgref_BRDM2_HQ_vdv","O_gorles_BRDM_2UM_Armed_01","rhsgref_BRDM2UM_ins_g","rhsgref_BRDM2UM_vmf","O_gorles_BRDM_2UM_01","rhsgref_BRDM2_ATGM_vdv","rhsgref_BRDM2_HQ_ins","rhsgref_BRDM2_ATGM_ins","O_gorles_BRDM_29P148_01","rhsgref_BRDM2_vdv","rhsgref_BRDM2_ins","LOP_TKA_BTR60","rhs_btr60_vmf","rhsgref_ins_btr60","rhsgref_tla_btr60"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал БМП</t>",{[["cars","tanks"], ["BWA3_Puma_Tropen","BWA3_Puma_Fleck", "LOP_AA_BMP2_C","B_APC_Tracked_01_rcws_F","B_APC_Tracked_01_CRV_F","B_T_APC_Tracked_01_rcws_F","B_T_APC_Tracked_01_CRV_F","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_wd","RHS_M2A3_BUSKI_wd","RHS_M6_wd","RHS_M2A3_BUSKIII_wd","RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII","RHS_M6","rhsgref_cdf_b_bmp2d","rhsgref_cdf_b_bmp2k","I_LT_01_AT_F","I_LT_01_cannon_F","I_LT_01_scout_F","LOP_AA_BMP2","LOP_IA_BMP2","rhsgref_cdf_b_bmp2e","rhsgref_cdf_b_bmp2","LOP_TKA_BMP2","LOP_US_BMP2","LOP_ChDKZ_BMP2","rhs_bmp2_vdv","rhsgref_ins_bmp2","LOP_IRAN_BMP2","LOP_UN_BMP2","rhsgref_cdf_bmp2","LOP_IRAN_BMP1","LOP_ISTS_BMP1","LOP_UN_BMP1","rhsgref_ins_g_bmp1","rhsgref_cdf_bmp1","LOP_SLA_BMP1","LOP_TKA_BMP1","LOP_TKA_BMP1D","LOP_AA_BMP1","rhsgref_cdf_b_bmp1d","LOP_AA_BMP1_C","rhsgref_ins_g_bmp1d","rhsgref_ins_g_bmp1k","rhsgref_cdf_bmp1k","rhs_bmp1k_vv","rhs_bmp1p_vv","rhsgref_ins_bmp1p","rhsgref_cdf_b_bmp1p","LOP_AA_BMP1_C","O_gorles_BMP_1_01","O_gorles_BMP_1D_01","O_gorles_BMP_1P_01","O_gorles_BMP_1K_01","O_gorles_BMP_21980_01","O_gorles_BMP_21986_01","O_gorles_BMP_2D_01","rhsgref_ins_bmp2d","rhsgref_ins_g_bmp2k","LOP_SLA_BMP1D","O_gorles_BMP_2D_01","rhs_bmp2k_vv","rhsgref_ins_bmd1","rhs_bmd1","rhs_bmd1k","rhs_bmd1pk","rhs_bmd1p","rhs_bmd1r","rhs_bmd2m","rhs_bmd2","rhs_bmd2k","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv","rhsgref_ins_g_bmd1p","rhsgref_cdf_bmd1p","rhsgref_cdf_bmd1k","rhs_prp3_vmf","rhs_brm1k_msv","rhs_Ob_681_2","rhs_bmp3_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","O_gorles_BMP_3early_01","O_gorles_BMP_3late_01","O_gorles_BMP_3Vesna_K_01","O_gorles_BMP_3Vesna_KA_01","rhs_bmp3_late_msv","O_APC_Tracked_02_cannon_F","I_APC_tracked_03_cannon_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал танков</t>",{[["cars","tanks"], ["BWA3_Leopard2_Fleck", "LOP_AA_T72BA","LOP_AA_T34","LOP_AA_T55","LOP_AA_T72BB","LOP_IA_M1A1_AIM_D","B_AFV_Wheeled_01_cannon_F","B_AFV_Wheeled_01_up_cannon_F","B_MBT_01_TUSK_F","B_MBT_01_cannon_F","B_T_AFV_Wheeled_01_up_cannon_F","B_T_AFV_Wheeled_01_cannon_F","B_T_MBT_01_cannon_F","B_T_MBT_01_TUSK_F","rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy","rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy","rhsgref_cdf_b_t72ba_tv","rhsgref_cdf_b_t72bb_tv","LOP_CDF_T72BA","LOP_CDF_T72BC","rhsusf_m1a1hc_wd","rhsusf_m1a1fep_od","rhsusf_m1a1fep_wd","rhsusf_m1a1fep_d","LOP_SLA_T72BB","LOP_US_T72BC","LOP_UKR_T72BB","LOP_UKR_T72BC","rhssaf_army_t72s","rhs_t80","rhs_t80a","rhs_t80b","rhs_t80bv","rhs_t80bk","rhs_t80bvk","rhs_t80ue1","rhs_t80um","rhs_t80u45m","rhs_t80u","rhs_t80uk","rhs_t90am_tv","rhs_t90a_tv","rhs_t90saa_tv","rhs_t90sab_tv","rhs_t90sm_tv","rhs_t90_tv","rhs_t14_tv","O_MBT_04_command_F","O_MBT_02_cannon_F","O_MBT_04_cannon_F","O_T_MBT_04_command_F","O_T_MBT_04_cannon_F","O_T_MBT_02_cannon_ghex_F","O_gorles_T90SA_2004_01","O_gorles_T90SA_2016_01","O_gorles_T80UE_1_01","O_gorles_T90AM_01","O_gorles_T90SM_01","O_gorles_T80U_45M_01","O_gorles_T90_1992_01","O_gorles_T90A_2006_01","O_gorles_T80UK_01","O_gorles_T80U_01","O_gorles_T80UM_01","O_gorles_T80BVK_01","O_gorles_T80BK_01","O_gorles_T80BV_01","O_gorles_T80B_01","rhs_sprut_vdv","LOP_AFR_OPF_T34","LOP_AFR_OPF_T55","LOP_TKA_T55","LOP_TKA_T34","I_MBT_03_cannon_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал ЗСУ</t>",{[["cars","tanks"], ["LOP_AA_ZSU234","B_APC_Tracked_01_AA_F","B_T_APC_Tracked_01_AA_F","rhsgref_cdf_b_zsu234","rhs_zsu234_aa","rhsgref_ins_zsu234","O_gorles_ZSU_23_4V_01","LOP_UN_ZSU234","LOP_IRAN_ZSU234","LOP_TKA_ZSU234","I_LT_01_AA_F","O_T_APC_Tracked_02_AA_ghex_F","O_APC_Tracked_02_AA_F","RHS_M6"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#09C1A8'>Арсенал артиллерии</t>",{[["cars","tanks"], ["LOP_AA_BM21","LOP_IA_BM21_C","LOP_IA_2S1","LOP_IA_BM21","B_MBT_01_arty_F","B_MBT_01_mlrs_F","B_T_MBT_01_mlrs_F","B_T_MBT_01_arty_F","rhsusf_m109_usarmy","rhsusf_m109d_usarmy","rhsusf_M142_usarmy_WD","rhsusf_M142_usarmy_D","rhsgref_cdf_b_reg_BM21","rhsgref_cdf_b_2s1","LOP_AM_OPF_BM21","LOP_ChDKZ_BM21","O_gorles_BM_21_01","LOP_UN_BM21","I_E_Truck_02_MRL_F","I_Truck_02_MRL_F","LOP_IRAN_2S1","rhssaf_army_2s1","rhsgref_ins_g_2s1","I_ISF_2S3M1_01","rhssaf_army_o_2s1","O_MBT_02_arty_F","O_T_MBT_02_arty_ghex_F","O_gorles_2S3M1_01"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#09C1A8'>Арсенал вертолётов</t>",{[["helicopters"], ["LOP_AA_Mi8MT_Cargo","LOP_IA_UH1Y_UN","LOP_IA_Mi8MT_Cargo","B_Heli_Transport_03_F","B_Heli_Transport_03_unarmed_F","B_Heli_Transport_01_F","RHS_CH_47F","RHS_CH_47F_cargo","RHS_UH60M","RHS_UH60M_ESSS2","RHS_UH60M_ESSS","RHS_UH60M2","RHS_UH60M_MEV2","RHS_CH_47F_light","LOP_CDF_Mi8MT_Cargo","B_CTRG_Heli_Transport_01_sand_F","B_CTRG_Heli_Transport_01_tropic_F","rhs_uh1h_hidf","rhs_uh1h_hidf_unarmed","RHS_Mi8AMT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8T_vvsc","rhs_ka60_c","RHS_Mi8AMT_vvs","rhssaf_airforce_o_ht40","rhssaf_airforce_o_ht48","LOP_ChDKZ_Mi8MT_Cargo","rhsgref_ins_Mi8amt","RHS_Mi8mt_Cargo_vvs","RHS_Mi8t_vv","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","LOP_ChDKZ_Mi8MT_Cargo","O_gorles_Mi_8MT_01","B_Heli_Light_01_F","RHS_MELB_MH6M","RHS_MELB_H6M","LOP_RACS_MH9","LOP_PMC_MH9","I_C_Heli_Light_01_civil_F","RHS_UH60M_MEV","RHS_UH1Y_UNARMED","rhsusf_CH53E_USMC","rhsusf_CH53E_USMC_GAU21","rhsusf_CH53e_USMC_cargo","O_Heli_Light_02_dynamicLoadout_F","O_Heli_Transport_04_F","O_Heli_Transport_04_ammo_F","O_Heli_Transport_04_box_F","O_Heli_Transport_04_medevac_F","O_Heli_Transport_04_repair_F","O_Heli_Transport_04_fuel_F","O_Heli_Transport_04_bench_F","O_Heli_Transport_04_covered_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#E2AE0B'>Арсенал БПА</t>",{[["cars","tanks"], ["B_UGV_01_rcws_F","B_UGV_01_F","B_T_UGV_01_rcws_olive_F","B_T_UGV_01_olive_F","O_T_UGV_01_rcws_ghex_F","O_T_UGV_01_ghex_F","O_UGV_01_rcws_F","O_UGV_01_F","I_E_UGV_01_rcws_F","I_UGV_01_F","I_E_UGV_01_F","I_UGV_01_rcws_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == '[Штаб] Командир взвода' || roleDescription player == '[Штаб] Офицер'", 5]] remoteExec ["addAction",0,true];
				}
				else {
					[baseWorker, ["<t color='#ABAC9F'>Арсенал автомобилей</t>",{[["cars"], ["rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_3camo_msv","O_gorles_GAZ_Tigr_01","rhs_tigr_msv","rhs_tigr_m_msv", "BWA3_Eagle_Tropen","BWA3_Eagle_FLW100_Tropen","BWA3_Eagle_Fleck","BWA3_Eagle_FLW100_Fleck", "LOP_AA_Offroad_M2_Police","LOP_AA_M1025_W_M2","LOP_AA_M1025_W_Mk19","LOP_AA_M1025_D","LOP_AA_M998_D_4DR","LOP_IA_M1025_W_Mk19","LOP_IA_M1025_D","LOP_IA_M1025_W_M2","LOP_IA_M998_D_4DR","B_MRAP_01_gmg_F","B_MRAP_01_F","B_MRAP_01_hmg_F","B_LSV_01_unarmed_F","B_LSV_01_AT_F","B_LSV_01_armed_F","B_T_MRAP_01_F","B_T_MRAP_01_gmg_F","B_T_MRAP_01_hmg_F","B_T_LSV_01_unarmed_F","B_T_LSV_01_AT_F","B_T_LSV_01_armed_F","LOP_PESH_M1025_W_M2","LOP_PESH_M1025_W_Mk19","LOP_PESH_M1025_D","LOP_PESH_M998_D_4DR","LOP_PESH_Nissan_PKM","LOP_PESH_Offroad_M2","LOP_PESH_Offroad_AT","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m1025_w","rhsusf_m1043_w_m2","rhsusf_m1043_w_mk19","rhsusf_m1043_w","rhsusf_m1045_w","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr","rhsusf_m998_w_4dr_fulltop","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr","rhsusf_m966_w","rhsusf_m1043_d_m2","rhsusf_m1043_d_mk19","rhsusf_m1043_d","rhsusf_m1045_d","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr","rhsusf_m998_d_4dr_fulltop","rhsusf_m998_d_4dr_halftop","rhsusf_m966_d","rhsusf_mrzr4_d","rhsgref_cdf_b_reg_uaz","rhsgref_cdf_b_reg_uaz_open","rhsgref_cdf_b_reg_uaz_dshkm","rhsgref_cdf_b_reg_uaz_ags","rhsgref_cdf_b_reg_uaz_spg9","LOP_CDF_Offroad_M2","B_CTRG_LSV_01_light_F","B_G_Offroad_01_AT_F","B_G_Offroad_01_armed_F","rhsgref_hidf_m1025_m2","rhsgref_hidf_m1025","rhsgref_hidf_m1025_mk19","rhsgref_hidf_M998_2dr_fulltop","rhsgref_hidf_M998_2dr_halftop","rhsgref_hidf_M998_2dr","rhsgref_hidf_M998_4dr_fulltop","rhsgref_hidf_M998_4dr_halftop","rhsgref_hidf_m998_4dr"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#ABAC9F'>Арсенал грузовых авто</t>",{[["cars","tanks"], ["LOP_AA_Ural","LOP_AA_Ural_open","LOP_IA_Ural_open","LOP_IA_Ural","B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_Repair_F","B_Truck_01_covered_F","B_Truck_01_medical_F","rhsusf_M1078A1P2_WD_fmtv_usarmy","B_Truck_01_transport_F","rhsusf_M1078A1P2_B_WD_fmtv_usarmy","rhsusf_M1078A1P2_B_WD_CP_fmtv_usarmy","rhsusf_M1083A1P2_WD_fmtv_usarmy","rhsusf_M1083A1P2_B_M2_WD_fmtv_usarmy","rhsusf_M977A4_AMMO_usarmy_wd","rhsusf_M977A4_REPAIR_usarmy_wd","rhsusf_M977A4_AMMO_BKIT_usarmy_wd","rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_wd","rhsusf_M977A4_REPAIR_BKIT_usarmy_wd","rhsusf_M1078A1P2_D_fmtv_usarmy","rhsusf_M1078A1P2_B_D_fmtv_usarmy","rhsusf_M1078A1P2_B_M2_D_fmtv_usarmy","rhsusf_M1078A1P2_B_D_CP_fmtv_usarmy","rhsusf_M1083A1P2_D_fmtv_usarmy","rhsusf_M1083A1P2_B_WD_fmtv_usarmy","rhsusf_M1085A1P2_B_WD_Medical_fmtv_usarmy","rhsusf_M1083A1P2_B_D_fmtv_usarmy","rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy","rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy","rhsusf_M977A4_AMMO_usarmy_d","rhsusf_M977A4_REPAIR_usarmy_d","rhsusf_M977A4_AMMO_BKIT_M2_usarmy_d","rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_d","rhsusf_M977A4_REPAIR_BKIT_usarmy_d","rhsusf_M977A4_AMMO_BKIT_M2_usarmy_wd","rhsusf_M1078A1R_SOV_M2_D_fmtv_socom","rhsusf_M1084A1R_SOV_M2_D_fmtv_socom","rhsgref_cdf_b_gaz66","rhsgref_cdf_b_gaz66_zu23","rhsgref_cdf_b_gaz66_r142","rhsgref_cdf_b_gaz66_ammo","rhsgref_cdf_b_gaz66o","rhsgref_cdf_b_ural","rhsgref_cdf_b_ural_fuel","rhsgref_cdf_b_ural_Zu23","rhsgref_cdf_b_ural_open","rhsgref_cdf_b_ural_repair","rhsgref_cdf_b_zil131","rhsgref_cdf_b_zil131_open","LOP_CDF_KAMAZ_Covered","LOP_CDF_KAMAZ_Ammo","LOP_CDF_KAMAZ_Medical","LOP_CDF_KAMAZ_Transport","LOP_CDF_KAMAZ_Repair","rhsusf_M977A4_AMMO_BKIT_usarmy_d""LOP_CDF_KAMAZ_Fuel"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал БТР</t>",{[["cars","tanks"], ["rhs_btr80_vmf","O_gorles_BTR_80_01", "LOP_AA_M113_C","LOP_AA_M113_D","LOP_AA_M113_W","LOP_AA_M1117_D","LOP_IA_BTR80","LOP_IA_M113_W","B_APC_Wheeled_01_cannon_F","B_T_APC_Wheeled_01_cannon_F","rhsusf_m113_usarmy_MK19","rhsusf_m113_usarmy_supply","rhsusf_m113_usarmy_M240","rhsusf_m113_usarmy_medical","rhsusf_m113_usarmy_unarmed","rhsusf_stryker_m1126_m2_wd","rhsusf_stryker_m1126_mk19_wd","rhsusf_stryker_m1127_m2_wd","rhsusf_stryker_m1132_m2_wd","rhsusf_stryker_m1134_wd","rhsusf_m113_usarmy_M2_90","rhsusf_M1117_W","rhsusf_M1220_usarmy_wd","rhsusf_M1220_M153_M2_usarmy_wd","rhsusf_M1220_M2_usarmy_wd","rhsusf_M1220_MK19_usarmy_wd","rhsusf_M1230_M2_usarmy_wd","rhsusf_M1230_MK19_usarmy_wd","rhsusf_M1230a1_usarmy_wd","rhsusf_M1232_usarmy_wd","rhsusf_M1232_M2_usarmy_wd","rhsusf_M1232_MK19_usarmy_wd","rhsusf_M1237_M2_usarmy_wd","rhsusf_M1237_MK19_usarmy_wd","rhsusf_m1240a1_usarmy_wd","rhsusf_m1240a1_m2crows_usarmy_wd","rhsusf_m1240a1_m2_usarmy_wd","rhsusf_m1240a1_m240_usarmy_wd","rhsusf_m1240a1_mk19crows_usarmy_wd","rhsusf_m1240a1_mk19_usarmy_wd","rhsusf_m113d_usarmy_MK19","rhsusf_m113d_usarmy_M240","rhsusf_m113d_usarmy_supply","rhsusf_m113d_usarmy_medical","rhsusf_m113d_usarmy_unarmed","rhsusf_M1117_O","rhsusf_M1220_usarmy_d","rhsusf_M1220_M153_M2_usarmy_d","rhsusf_M1220_M2_usarmy_d","rhsusf_M1220_MK19_usarmy_d","rhsusf_M1220_M153_MK19_usarmy_d","rhsusf_M1230_M2_usarmy_d","rhsusf_M1230_MK19_usarmy_d","rhsusf_M1230a1_usarmy_d","rhsusf_M1232_usarmy_d","rhsusf_M1232_M2_usarmy_d","rhsusf_M1232_MK19_usarmy_d","rhsusf_M1237_MK19_usarmy_d","rhsusf_M1237_M2_usarmy_d","rhsusf_m1240a1_usarmy_d","rhsusf_m1240a1_m2crows_usarmy_d","rhsusf_m1240a1_m2_usarmy_d","rhsusf_m1240a1_m240_usarmy_d","rhsusf_m1240a1_mk19crows_usarmy_d","rhsusf_m1240a1_mk19_usarmy_d","rhsusf_M1238A1_M2_socom_d","rhsusf_M1238A1_socom_d","rhsusf_M1238A1_Mk19_socom_d","rhsusf_M1239_socom_d","rhsusf_M1239_M2_socom_d","rhsusf_M1239_MK19_socom_d","rhsusf_M1239_M2_Deploy_socom_d","rhsusf_M1239_MK19_Deploy_socom_d","rhsusf_m1245_m2crows_socom_d","rhsusf_m1245_mk19crows_socom_d","rhsusf_m1245_m2crows_socom_deploy","rhsusf_m1245_mk19crows_socom_deploy","rhsgref_cdf_b_btr60","rhsgref_cdf_b_btr70","rhsgref_BRDM2_b","rhsgref_BRDM2_ATGM_b","rhsgref_BRDM2UM_b","rhsgref_BRDM2_HQ_b","LOP_CDF_BTR60","LOP_CDF_BTR70","rhsgref_hidf_m113a3_unarmed","rhsgref_hidf_m113a3_mk19","rhsgref_BRDM2_HQ_vdv","O_gorles_BRDM_2UM_Armed_01","rhsgref_BRDM2UM_ins_g","rhsgref_BRDM2UM_vmf","O_gorles_BRDM_2UM_01","rhsgref_BRDM2_ATGM_vdv","rhsgref_BRDM2_HQ_ins","rhsgref_BRDM2_ATGM_ins","O_gorles_BRDM_29P148_01","rhsgref_BRDM2_vdv","rhsgref_BRDM2_ins","LOP_TKA_BTR60","rhs_btr60_vmf","rhsgref_ins_btr60","rhsgref_tla_btr60"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал БМП</t>",{[["cars","tanks"], ["BWA3_Puma_Tropen","BWA3_Puma_Fleck", "LOP_AA_BMP2_C","B_APC_Tracked_01_rcws_F","B_APC_Tracked_01_CRV_F","B_T_APC_Tracked_01_rcws_F","B_T_APC_Tracked_01_CRV_F","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_wd","RHS_M2A3_BUSKI_wd","RHS_M6_wd","RHS_M2A3_BUSKIII_wd","RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII","RHS_M6","rhsgref_cdf_b_bmp2d","rhsgref_cdf_b_bmp2k","I_LT_01_AT_F","I_LT_01_cannon_F","I_LT_01_scout_F","LOP_AA_BMP2","LOP_IA_BMP2","rhsgref_cdf_b_bmp2e","rhsgref_cdf_b_bmp2","LOP_TKA_BMP2","LOP_US_BMP2","LOP_ChDKZ_BMP2","rhs_bmp2_vdv","rhsgref_ins_bmp2","LOP_IRAN_BMP2","LOP_UN_BMP2","rhsgref_cdf_bmp2","LOP_IRAN_BMP1","LOP_ISTS_BMP1","LOP_UN_BMP1","rhsgref_ins_g_bmp1","rhsgref_cdf_bmp1","LOP_SLA_BMP1","LOP_TKA_BMP1","LOP_TKA_BMP1D","LOP_AA_BMP1","rhsgref_cdf_b_bmp1d","LOP_AA_BMP1_C","rhsgref_ins_g_bmp1d","rhsgref_ins_g_bmp1k","rhsgref_cdf_bmp1k","rhs_bmp1k_vv","rhs_bmp1p_vv","rhsgref_ins_bmp1p","rhsgref_cdf_b_bmp1p","LOP_AA_BMP1_C","O_gorles_BMP_1_01","O_gorles_BMP_1D_01","O_gorles_BMP_1P_01","O_gorles_BMP_1K_01","O_gorles_BMP_21980_01","O_gorles_BMP_21986_01","O_gorles_BMP_2D_01","rhsgref_ins_bmp2d","rhsgref_ins_g_bmp2k","LOP_SLA_BMP1D","O_gorles_BMP_2D_01","rhs_bmp2k_vv","rhsgref_ins_bmd1","rhs_bmd1","rhs_bmd1k","rhs_bmd1pk","rhs_bmd1p","rhs_bmd1r","rhs_bmd2m","rhs_bmd2","rhs_bmd2k","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv","rhsgref_ins_g_bmd1p","rhsgref_cdf_bmd1p","rhsgref_cdf_bmd1k","rhs_prp3_vmf","rhs_brm1k_msv","rhs_Ob_681_2","rhs_bmp3_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","O_gorles_BMP_3early_01","O_gorles_BMP_3late_01","O_gorles_BMP_3Vesna_K_01","O_gorles_BMP_3Vesna_KA_01","rhs_bmp3_late_msv","O_APC_Tracked_02_cannon_F","I_APC_tracked_03_cannon_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал танков</t>",{[["cars","tanks"], ["BWA3_Leopard2_Fleck", "LOP_AA_T72BA","LOP_AA_T34","LOP_AA_T55","LOP_AA_T72BB","LOP_IA_M1A1_AIM_D","B_AFV_Wheeled_01_cannon_F","B_AFV_Wheeled_01_up_cannon_F","B_MBT_01_TUSK_F","B_MBT_01_cannon_F","B_T_AFV_Wheeled_01_up_cannon_F","B_T_AFV_Wheeled_01_cannon_F","B_T_MBT_01_cannon_F","B_T_MBT_01_TUSK_F","rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy","rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy","rhsgref_cdf_b_t72ba_tv","rhsgref_cdf_b_t72bb_tv","LOP_CDF_T72BA","LOP_CDF_T72BC","rhsusf_m1a1hc_wd","rhsusf_m1a1fep_od","rhsusf_m1a1fep_wd","rhsusf_m1a1fep_d","LOP_SLA_T72BB","LOP_US_T72BC","LOP_UKR_T72BB","LOP_UKR_T72BC","rhssaf_army_t72s","rhs_t80","rhs_t80a","rhs_t80b","rhs_t80bv","rhs_t80bk","rhs_t80bvk","rhs_t80ue1","rhs_t80um","rhs_t80u45m","rhs_t80u","rhs_t80uk","rhs_t90am_tv","rhs_t90a_tv","rhs_t90saa_tv","rhs_t90sab_tv","rhs_t90sm_tv","rhs_t90_tv","rhs_t14_tv","O_MBT_04_command_F","O_MBT_02_cannon_F","O_MBT_04_cannon_F","O_T_MBT_04_command_F","O_T_MBT_04_cannon_F","O_T_MBT_02_cannon_ghex_F","O_gorles_T90SA_2004_01","O_gorles_T90SA_2016_01","O_gorles_T80UE_1_01","O_gorles_T90AM_01","O_gorles_T90SM_01","O_gorles_T80U_45M_01","O_gorles_T90_1992_01","O_gorles_T90A_2006_01","O_gorles_T80UK_01","O_gorles_T80U_01","O_gorles_T80UM_01","O_gorles_T80BVK_01","O_gorles_T80BK_01","O_gorles_T80BV_01","O_gorles_T80B_01","rhs_sprut_vdv","LOP_AFR_OPF_T34","LOP_AFR_OPF_T55","LOP_TKA_T55","LOP_TKA_T34","I_MBT_03_cannon_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#11ff11'>Арсенал ЗСУ</t>",{[["cars","tanks"], ["LOP_AA_ZSU234","B_APC_Tracked_01_AA_F","B_T_APC_Tracked_01_AA_F","rhsgref_cdf_b_zsu234","rhs_zsu234_aa","rhsgref_ins_zsu234","O_gorles_ZSU_23_4V_01","LOP_UN_ZSU234","LOP_IRAN_ZSU234","LOP_TKA_ZSU234","I_LT_01_AA_F","O_T_APC_Tracked_02_AA_ghex_F","O_APC_Tracked_02_AA_F","RHS_M6"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#09C1A8'>Арсенал артиллерии</t>",{[["cars","tanks"], ["LOP_AA_BM21","LOP_IA_BM21_C","LOP_IA_2S1","LOP_IA_BM21","B_MBT_01_arty_F","B_MBT_01_mlrs_F","B_T_MBT_01_mlrs_F","B_T_MBT_01_arty_F","rhsusf_m109_usarmy","rhsusf_m109d_usarmy","rhsusf_M142_usarmy_WD","rhsusf_M142_usarmy_D","rhsgref_cdf_b_reg_BM21","rhsgref_cdf_b_2s1","LOP_AM_OPF_BM21","LOP_ChDKZ_BM21","O_gorles_BM_21_01","LOP_UN_BM21","I_E_Truck_02_MRL_F","I_Truck_02_MRL_F","LOP_IRAN_2S1","rhssaf_army_2s1","rhsgref_ins_g_2s1","I_ISF_2S3M1_01","rhssaf_army_o_2s1","O_MBT_02_arty_F","O_T_MBT_02_arty_ghex_F","O_gorles_2S3M1_01"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#09C1A8'>Арсенал вертолётов</t>",{[["helicopters"], ["LOP_AA_Mi8MT_Cargo","LOP_IA_UH1Y_UN","LOP_IA_Mi8MT_Cargo","B_Heli_Transport_03_F","B_Heli_Transport_03_unarmed_F","B_Heli_Transport_01_F","RHS_CH_47F","RHS_CH_47F_cargo","RHS_UH60M","RHS_UH60M_ESSS2","RHS_UH60M_ESSS","RHS_UH60M2","RHS_UH60M_MEV2","RHS_CH_47F_light","LOP_CDF_Mi8MT_Cargo","B_CTRG_Heli_Transport_01_sand_F","B_CTRG_Heli_Transport_01_tropic_F","rhs_uh1h_hidf","rhs_uh1h_hidf_unarmed","RHS_Mi8AMT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8T_vvsc","rhs_ka60_c","RHS_Mi8AMT_vvs","rhssaf_airforce_o_ht40","rhssaf_airforce_o_ht48","LOP_ChDKZ_Mi8MT_Cargo","rhsgref_ins_Mi8amt","RHS_Mi8mt_Cargo_vvs","RHS_Mi8t_vv","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","LOP_ChDKZ_Mi8MT_Cargo","O_gorles_Mi_8MT_01","B_Heli_Light_01_F","RHS_MELB_MH6M","RHS_MELB_H6M","LOP_RACS_MH9","LOP_PMC_MH9","I_C_Heli_Light_01_civil_F","RHS_UH60M_MEV","RHS_UH1Y_UNARMED","rhsusf_CH53E_USMC","rhsusf_CH53E_USMC_GAU21","rhsusf_CH53e_USMC_cargo","O_Heli_Light_02_dynamicLoadout_F","O_Heli_Transport_04_F","O_Heli_Transport_04_ammo_F","O_Heli_Transport_04_box_F","O_Heli_Transport_04_medevac_F","O_Heli_Transport_04_repair_F","O_Heli_Transport_04_fuel_F","O_Heli_Transport_04_bench_F","O_Heli_Transport_04_covered_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
					[baseWorker, ["<t color='#E2AE0B'>Арсенал БПА</t>",{[["cars","tanks"], ["B_UGV_01_rcws_F","B_UGV_01_F","B_T_UGV_01_rcws_olive_F","B_T_UGV_01_olive_F","O_T_UGV_01_rcws_ghex_F","O_T_UGV_01_ghex_F","O_UGV_01_rcws_F","O_UGV_01_F","I_E_UGV_01_rcws_F","I_UGV_01_F","I_E_UGV_01_F","I_UGV_01_rcws_F"], "VVS_all_1"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "", 5]] remoteExec ["addAction",0,true];
				};
		
				// Установка ящиков с колесами и гуслями
				_repairPos = [_workerPos, 3, 3, 2, 0, 10, 0] call BIS_fnc_findSafePos;
				_repairBox = "Land_WoodenCrate_01_stack_x3_F" createVehicle _repairPos;
				_cargo = "Supply500" createVehicle [0,0,0];
				_cargo attachTo [_repairBox, [0,0,0.85]];
				
				[_cargo, "repairBox"] call fnc_setVehicleName;
				
				repairBox enableSimulation false;
				repairBox allowdamage false;
				[repairBox, 250] call ace_cargo_fnc_setSpace;
				[repairBox, 60, "ACE_Track", true] call ace_repair_fnc_addSpareParts; 
				[repairBox, 120, "ACE_Wheel", true] call ace_repair_fnc_addSpareParts;
				
				// Установка медика на базе
				_medicPos = [_boxLocation, 6, 20, 3, 0, 20, 0] call BIS_fnc_findSafePos;
				baseMedic setpos _medicPos;
				baseMedic setdir getDir arsenalBox;
				[baseMedic,"Получить <t color='#11ff11'>Медицинскую помощь","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa","(player distance baseMedic) < 4","true",{},{},{[_this select 1,_this select 1] call ace_medical_treatment_fnc_fullHeal;[parseText format ["<t align='center' font='PuristaBold' size='1.6'>'Медицинская помощь завершена'</t>"],true,nil,2,0.7,0] spawn BIS_fnc_textTiles;},{},[],8,0,false,false] remoteExec ["BIS_fnc_holdActionAdd",0,true];
				_markerMedic = createMarker ["markerMedic", _medicPos];
				"markerMedic" setMarkerColor "ColorRed";
				"markerMedic" setMarkerType "loc_Hospital";
				"markerMedic" setMarkerText "Врач";
				
				for "_i" from 1 to 5 do {
					_boxSupplyPos = [_boxLocation, 4, 13, 1, 0, 10, 0] call BIS_fnc_findSafePos;
					_boxSupply = "TFAR_NATO_Radio_Crate" createVehicle _boxSupplyPos;
					
					clearItemCargoGlobal _boxSupply;
					clearMagazineCargoGlobal _boxSupply;
					clearWeaponCargoGlobal _boxSupply;
					clearBackpackCargoGlobal _boxSupply;
				};
			};		
			
			case "SEA": {				
				insertType = "SEA";
				_shipClass = selectRandom _shipClasses;
				
				if (getMarkerColor "campMkr" == "") then {
					_randomStartingLocation = [(_seaSpawn select 0), (_seaSpawn select 1), 0];
				} else {
					_randomStartingLocation = getMarkerPos "campMkr";					
				};
				[_randomStartingLocation] call sun_setPlayerGroup;
				//[_randomStartingLocation] remoteExec ["sun_newUnits", s1];
				waitUntil {newUnitsReady};				
				sleep 2;
				// Spawn vehicles until there are enough slots for players
				_vehiclePool = [];
				_rolesFilled = 0;
				while {(_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId))))} do {
				
					_shipClass = selectRandom _shipClasses;
					_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
					
					_boatLoc = _randomStartingLocation findEmptyPosition [0, 10, _shipClass];
					
					_boat = createVehicle [_shipClass, _boatLoc, [], 0, "NONE"];
					
					[
						_boat,
						[
							"Толкнуть",  
							{  
								_dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
								_nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
								(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
							},  
							nil,  
							6,  
							false,  
							false,  
							"",  
							"(_this distance _target < 8) && (vehicle _this == _this)"
						]
					] remoteExec ["addAction", 0, true];
					
					_rolesFilled = _rolesFilled + _vehRoles;
					
					_vehiclePool pushBack _boat;
					
				};	
				
				if (count _vehiclePool > 0) then {
					
					_playersLeft = (units(grpNetId call BIS_fnc_groupFromNetId));
					diag_log format ["_playersLeft = %1", _playersLeft];
					{
						if ((count _playersLeft) > 0) then {
							_thisBoat = _x;
							diag_log format ["_thisBoat = %1", _thisBoat];
							_vehRoles = (count([_thisBoat] call BIS_fnc_vehicleRoles));
							diag_log format ["_vehRoles = %1", _vehRoles];
							_playersToAssign = [];
							if (_vehRoles > (count _playersLeft)) then {_vehRoles = (count _playersLeft)};
							for "_i" from 0 to (_vehRoles - 1) do {	
								diag_log format ["_i = %1", _i];
								diag_log format ["(_playersLeft select _i) = %1", (_playersLeft select _i)];
								_thisUnit = (_playersLeft select _i);
								_playersToAssign pushBack _thisUnit;							
							};
							_playersLeft = _playersLeft - _playersToAssign;
							diag_log format ["_playersLeft = %1", _playersLeft];
							diag_log format ["_playersToAssign = %1", _playersToAssign];
							if ((count _playersToAssign) > 0) then {
								[_playersToAssign, _thisBoat] spawn sun_groupToVehicle;
							};
						};						
					} forEach _vehiclePool;
					diag_log format ["(units(group s1)) = %1", (units(grpNetId call BIS_fnc_groupFromNetId))];					
					deleteMarker "campMkr";
					missionNameSpace setVariable ["publicCampName", "Altis Ocean Territory"];
					publicVariable "publicCampName";
					markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
					markerPlayerStart setMarkerShape "ICON";
					markerPlayerStart setMarkerColor markerColorPlayers;
					markerPlayerStart setMarkerType "mil_start";
					markerPlayerStart setMarkerText "Точка начала операции";
					
					{
						_x addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
						_x addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
						_x addItemCargoGlobal ["Medikit", 1];
						_x addItemCargoGlobal ["FirstAidKit", 10];
					} forEach _vehiclePool;
										
					
				};				
			};
		};		
				
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];
			
	};
	case 2: {
		// HALO INSERTION		
		// Generate drop position
		insertType = "HALO";
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,1,1,0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};
				
		_randomStartingLocation set [2, 0];
		_startHeight = (getTerrainHeightASL _randomStartingLocation) + 2000;
		_planeStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2100];
		_airStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2000];
		
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Точка сброса";		
						
		//[_airStartPos] remoteExec ["sun_newUnits", s1];
		[_airStartPos] call sun_setPlayerGroup;
		waitUntil {newUnitsReady};
		sleep 2;
		
		_lastPos = _airStartPos;
		{
			_thisPos = [_lastPos, 20, ([_airStartPos, _center] call BIS_fnc_dirTo)] call dro_extendPos;
			_x setPos [(_thisPos select 0) + (random 10), (_thisPos select 1) + (random 10), (3000 + (random 20))];			
			_lastPos = _thisPos;
		} forEach units (grpNetId call BIS_fnc_groupFromNetId);
				
		[units (grpNetId call BIS_fnc_groupFromNetId)] execVM 'sunday_system\player_setup\callParadrop.sqf';
		
		// Set wind
		0 setGusts 0;
		setWind [0, 0, true];		
		diag_log "DRO: Air insert called";
		sleep 2;		
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];			
		missionNameSpace setVariable ["publicCampName", format ["%1 Airspace", ((configfile >> "CfgWorlds" >> worldName >> "description") call BIS_fnc_getCfgData)]];
		publicVariable "publicCampName";
	};
	
	case 3: {
		// HELI INSERTION		
		insertType = "HELI";
		// Generate drop position				
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize-150),(aoSize+500),0,0,0.25,0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,aoSize,(aoSize+1500),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};				
		_randomStartingLocation set [2, 0];
		
		_dir = [_center, _randomStartingLocation] call BIS_fnc_dirTo;
		_heliPos = [_randomStartingLocation, 2000, _dir] call BIS_fnc_relPos;
		_heliPos set [2,100];
		_cargoWeights = [];
		{
			_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, [_x] call sun_getTrueCargo, 1, 0, true] max 0; 
			_cargoWeights pushBack _thisWeight;
		} forEach _heliClasses;		
		diag_log format ["DRO: _heliClasses = %1", _heliClasses];
		diag_log format ["DRO: _cargoWeights = %1", _cargoWeights];
		_heliClass = _heliClasses selectRandomWeighted _cargoWeights;
		
		_insertHeli = createVehicle [_heliClass, _heliPos, [], 0, "FLY"];
		_insertHeli allowDamage false;
		[_insertHeli, playersSide, false] call sun_createVehicleCrew;		
		_insertHeli setPos _heliPos;
		_insertHeli setDir (_dir + 180);		
		waitUntil {!isNull (driver _insertHeli)};		
		_insertHeli flyInHeight 40;
		_insertHeli setBehaviour "CARELESS";
		_insertHeli setCaptive true;
		(driver _insertHeli) disableAI "TARGET";		
		(driver _insertHeli) disableAI "AUTOTARGET";		
		
		_heliGroup = group (driver _insertHeli);
		while {(count (waypoints (_insertHeli) )) > 0} do {
		   deleteWaypoint ((waypoints (_insertHeli) ) select 0);
		};
		[_heliGroup, _randomStartingLocation, _insertHeli, _heliPos] spawn {
			_heliGroup = (_this select 0);
			_randomStartingLocation = (_this select 1);
			_insertHeli = (_this select 2);
			_heliPos = (_this select 3);
			
			private _wp0 = _heliGroup addWaypoint [(getPos _insertHeli), 0];	
			_wp0 setWaypointBehaviour "CARELESS";			
			_wp0 setWaypointSpeed "NORMAL";
			_wp0 setWaypointType "MOVE";	
			
			private _wpLand = _heliGroup addWaypoint [_randomStartingLocation, 0];
			_wpLand setWaypointType "MOVE";
			_wpLand setWaypointStatements ["TRUE", "vehicle this land 'GET OUT'"];
			diag_log format ["DRO: Insert heli waypoints: %1, %2", waypointPosition _wp0, waypointPosition _wpLand];
			waitUntil {
				sleep 2;
				((getPos _insertHeli) select 2) <= 3
			};			
			_insertHeli disableAI "MOVE";
			diag_log "DRO: Insert heli AI disabled";
			waitUntil {
				sleep 1;
				_insertHeli setVelocity [0, 0, 0];
				({_x in _insertHeli} count (units (grpNetId call BIS_fnc_groupFromNetId))) == 0;				
			};
			_insertHeli enableAI "MOVE";
			diag_log "DRO: Insert heli AI enabled";
			private _wpEnd = _heliGroup addWaypoint [_heliPos, 0];
			_wpEnd setWaypointType "MOVE";
			_wpEnd setWaypointStatements ["TRUE", "_heli = vehicle this; {_heli deleteVehicleCrew _x} forEach crew _heli; deleteVehicle _heli;"];			
		};
				
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Точка сброса";
		
		//[getPos logicStartPos] remoteExec ["sun_newUnits", s1];
		[getPos logicStartPos] call sun_setPlayerGroup;
		waitUntil {newUnitsReady};
		sleep 3;
		[(units(grpNetId call BIS_fnc_groupFromNetId)), _insertHeli] spawn sun_groupToVehicle;
	};	
};

// Set leader to higher rank to avoid demotion
(leader (grpNetId call BIS_fnc_groupFromNetId)) setRank "COLONEL";

// Check for UAV terminals and spawn random UAV if possible
_uavSpawned = 0;
_spawnUAVPatrol = false;
if (count pUAVClasses > 0) then {
	{
		_itemsPresent = assignedItems _x;
		{
			if ((["UavTerminal", _x] call BIS_fnc_inString) && (_uavSpawned == 0)) then {
				_availableUAVs = [];
				{
					if (_x isKindOf "Car" || _x isKindOf "Helicopter") then {
						_availableUAVs pushBack _x;
					};
					
				} forEach pUAVClasses;
				if (count _availableUAVs > 0) then {					
					if (insertType == "GROUND") then {
						_uavClass = selectRandom _availableUAVs;
						_uavLocation = _randomStartingLocation findEmptyPosition [10, 30, _uavClass];
						if (count _uavLocation > 0) then {
							_uav = createVehicle [_uavClass, _uavLocation, [], 0, "NONE"];
							_uavSpawned = 1;
						};
					};					
				};								
			};
		} forEach _itemsPresent;
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
};

// Create transport boat if any routes are blocked by water
diag_log "DRO: Searching for water";
_waterReturn = [_randomStartingLocation, _center, true] call sun_checkRouteWater;
_waterPositions = [];
if (typeName _waterReturn == "ARRAY") then {
	_waterPositions pushBack _waterReturn;
} else {
	{
		if (typeName (_x select 3) == "ARRAY") then {
			_waterPositions pushBack (_x select 3);
		};
	} forEach AOLocations;
};
if (count _waterPositions > 0) then {
	diag_log "DRO: Found water for extra boat spawn";
	_closestWaterPositions = [_waterPositions, [_randomStartingLocation], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
	_checkPos = (_closestWaterPositions select 0);					
	_waterPlaces = selectBestPlaces [_checkPos, 200, "sea - waterDepth + (waterDepth factor [0.25, 0.5])", 20, 5];					
	diag_log format ["DRO: _waterPlaces = %1", _waterPlaces];
	_deepestPos = ((_waterPlaces select 0) select 0);
	_deepestHeight = getTerrainHeightASL ((_waterPlaces select 0) select 0);					
	{
		_height = getTerrainHeightASL (_x select 0);
		if (_height < _deepestHeight) then {
			_deepestHeight = _height;
			_deepestPos = (_x select 0);
		};
	} forEach _waterPlaces;					
	
	_boatPos = [(_deepestPos select 0), (_deepestPos select 1), 0];
	diag_log format ["DRO: _boatPos = %1", _boatPos];
	// Spawn boats until there are enough slots for players
	_rolesFilled = 0;
	while {_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId)))} do {
	
		_shipClass = selectRandom _shipClasses;
		_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
		_dir = [_checkPos, _boatPos] call BIS_fnc_dirTo;
		_boat = createVehicle [_shipClass, _boatPos, [], 0, "NONE"];
		_boat setDir _dir;
		
		[
			_boat,
			[
				"Толкнуть",  
				{  
				   _dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
				   _nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
					(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
				},  
				nil,  
				6,  
				false,  
				false,  
				"",  
				"(_this distance _target < 8) && (vehicle _this == _this)"
			]
		] remoteExec ["addAction", 0, true];						
		_rolesFilled = _rolesFilled + _vehRoles;						
	};						
	_markerName = format["boatMkr%1", floor(random 10000)];
	_markerBoat = createMarker [_markerName, _boatPos];			
	_markerBoat setMarkerShape "ICON";
	_markerBoat setMarkerType "mil_pickup";							
	_markerBoat setMarkerColor markerColorPlayers;						
	_markerBoat setMarkerText "Лодка";	
};		


missionNameSpace setVariable ["startPos", _randomStartingLocation, true];

[[musicMain, 0 ,1],"bis_fnc_playmusic", true] call BIS_fnc_MP;

sleep 1;

// Add supports
[_randomStartingLocation] execVM "sunday_system\player_setup\addSupports.sqf";

playerGroup = _playerGroup;

if (isMultiplayer) then {
	// If respawn is enabled add the dynamic team respawn position
	if ((paramsArray select 0) < 3) then {
		if ((paramsArray select 1) == 0 OR (paramsArray select 1) == 2) then {
			[] execVM 'sunday_system\player_setup\teamRespawnPos.sqf';			
		};		
		diag_log format ["DRO: Respawn time = %1", respawnTime];
		{		
			respawnTime remoteExec ["setPlayerRespawnTime", _x];				
		} forEach allPlayers;
	};		
	{
		if (!isPlayer _x) then {		
			// Add eventhandlers to govern respawning in MP games				
			if ((paramsArray select 0) == 3) then {
				// Respawn disabled
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];
			} else {
				// Respawn enabled
				[_x, ["killed", {[(_this select 0)] execVM "sunday_system\player_setup\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _x];
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x];				
			};			
		};		
		// Add player's side to spectator whitelist
		_x setVariable ["WhitelistedSides", [playersSideCfgGroups], true];		
		_x setVariable ["AllowFreeCamera", true, true];
		_x setVariable ["AllowAi", true, true];
		_x setVariable ["Allow3PPCamera", true, true];
		_x setVariable ["ShowFocusInfo", true, true];
		_x setVariable ["ShowCameraButtons", true, true];
		// Add respawn weapon loss failsafes		
		_x setVariable ["respawnLoadout", (getUnitLoadout _x), true];
		_x setVariable ["respawnPWeapon", [(primaryWeapon  _x), primaryWeaponItems _x], true];
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
};

// Lights, backpacks, reset action, unit traits, force allowDamage to account for any setup issues
{
	_thisUnit = _x;
	diag_log format ["DRO: Setting allowDamage for %1 to true", _thisUnit];
	[_thisUnit, true] remoteExec ["allowDamage", _thisUnit];	
	
	_thisUnit enableGunLights "forceon";
	
	if (!isPlayer _thisUnit) then {
		[_thisUnit] call sun_addResetAction;
	};	
	
	[] remoteExec ["sun_backpackFix", _thisUnit];
	
	[_thisUnit, ["Medic", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["engineer", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["explosiveSpecialist", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["UAVHacker", true]] remoteExec ["setUnitTrait", _thisUnit];	
	
	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

// Add friendly unit trigger to leader
if (missionPreset == 3) then {
	[(leader (grpNetId call BIS_fnc_groupFromNetId)), "DRO_Friendly_Engage"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId))];
};

// Set player callsign and icon
_iconSide = switch (playersSide) do {
	case west: {"b_inf"};
	case east: {"o_inf"};
	case resistance: {"n_inf"};
	default {"b_inf"};
};	
(grpNetId call BIS_fnc_groupFromNetId) addGroupIcon [_iconSide, [0, 0]];
(grpNetId call BIS_fnc_groupFromNetId) setGroupIconParams [colorPlayers, playerCallsign, 1, true, true, colorPlayers];
(grpNetId call BIS_fnc_groupFromNetId) setGroupIdGlobal [playerCallsign];

// Remove arsenal backdrop objects
sleep 2;
_backdropList = (getPos logicStartPos) nearObjects 20;
_backdropList = _backdropList - (units(grpNetId call BIS_fnc_groupFromNetId));
{
	if !(_x isKindOf "Module_F") then {
		deleteVehicle _x;
	};		
} forEach _backdropList;

if (reviveDisabled < 3) then {
	diag_log "DRO: Revive enabled";
	_reviveHandle = [(grpNetId call BIS_fnc_groupFromNetId)] execVM "sunday_revive\initRevive.sqf";
	waitUntil {scriptDone _reviveHandle};
};

if (stealthEnabled == 1) then {
	[] execVM "sunday_system\stealth.sqf";	
}; 
/*
// If MCC4 is present re-initialise it for new players
if (isClass (configFile >> "CfgPatches" >> "mcc_sandbox")) then {
	[] execVM "\mcc_sandbox_mod\init.sqf";
};

// If Zeus is present re-initialise it for new players
if (!isNull _zeus) then {
	(leader(grpNetId call BIS_fnc_groupFromNetId)) assignCurator _zeus;
};
*/
// Chance to reveal some intel at start
if (random 1 > 0.35) then {
	[([1,3] call BIS_fnc_randomInt), false] execVM "sunday_system\intel\revealIntel.sqf";	
};

["ace_captiveStatusChanged",{_this execVM "scripts\protectFromCaptive.sqf"}] call CBA_fnc_addEventHandler;
missionNameSpace setVariable ["playersReady", 1, true];