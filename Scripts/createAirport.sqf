/* _airport= [
	["Land_PortableLight_double_F",[-2.55103,-1.88086,0],212.879,1,0,[0,0],"", "",true,false], 
	["babe_helper",[2.77051,-2.0293,0],0,1,0,[0,0],"pilotPos_srv","",true,false], 
	["Land_Cargo_House_V3_F",[1.13184,-4.20654,0],184.185,1,0,[0,0],"", "",true,false], 
	["babe_helper",[2.39893,-4.55469,0.234555],0,1,0,[0,0],"airportPos_srv","",true,false], 
	["Land_HelipadEmpty_F",[5.10181,10.7139,0],358.225,1,0,[0,0],"airHelipad_srv","",true,false]
]; */

_airport = [
	["Land_Brick_01_F",[-0.587158,-4.03162,-4.76837e-007],324.945,1,0,[1.63082e-005,-2.06627e-005],"","",true,false], 
	["Land_HelicopterWheels_01_assembled_F",[2.1665,-4.62927,-0.00153017],122.971,1,0,[0.386673,-0.000133352],"","",true,false], 
	["CBA_BuildingPos",[3.12451,-4.1991,0],0,1,0,[0,0],"pilotPos_srv","",true,false], 
	["Land_RotorCoversBag_01_F",[1.66504,-5.08044,-0.0010004],359.99,1,0,[-0.001948,-0.000671232],"","",true,false], 
	["Land_Cargo_House_V3_F",[1.18311,-7.07739,0],180.955,1,0,[0,0],"","",true,false], 
	["Land_PortableLight_double_F",[-2.87671,-5.68884,0],200.304,1,0,[0,0],"","",true,false], 
	["Land_PitotTubeCover_01_F",[5.0354,-3.9541,-0.0134015],0.0298691,1,0,[-4.73088,-1.49597],"","",true,false], 
	["CBA_BuildingPos",[1.93994,-7.51685,0],0,1,0,[0,0],"airportPos_srv","",true,false], 
	["Land_DeckTractor_01_F",[5.43481,-5.68909,-0.000119686],342.392,1,0,[-0.00728419,-0.00655489],"","",true,false], 
	["Land_CratesWooden_F",[-3.24194,-7.32605,0],145.286,1,0,[0,-0],"","",true,false], 
	["SatelliteAntenna_01_Mounted_Sand_F",[4.87109,-6.12744,0.914172],91.2149,1,0,[0,-0],"","",true,false], 
	["Land_BarrelTrash_F",[-3.90967,-8.90808,2.38419e-006],0.00259147,1,0,[0.000416321,-0.000964753],"","",true,false], 
	["Land_Garbage_square3_F",[-3.49561,-9.16333,0],0,1,0,[0,0],"","",true,false], 
	["Land_WaterTank_F",[-2.65747,-9.7196,2.14577e-005],259.801,1,0,[-0.00105134,-0.000628746],"","",true,false], 
	["Land_HelipadEmpty_F",[1.646,10.9175,0],0,1,0,[0,0],"airHelipad_srv","",true,false], 
	["Land_AirConditioner_03_F",[2.41357,-11.9164,0],180.12,1,0,[0,0],"","",true,false]
];
// Добавление первой точки - расположения аэропорта
openMap [true, true]; // Opens map
_str = parsetext format ["<t size = '1.1'>Выберите один из <t color='#E39325'>аэропортов</t> на карте, в котором будет расположен арсенал самолётов для использования пилотами.<br/><br/> Желательно выбрать место в <t color='#E39325'>крайней южной</t> части аэропорта, так как созданная техника будет смотреть на север. <br/><br/>  Не выбирайте аэропорт вблизи противника</t>, чтобы избежать жертв."]; 
hint _str;
_mapEH = addMissionEventHandler ["MapSingleClick", 
	{
		// Следующий код выполняется при щелчке мыши на карте
		_pos1 = _this select 1; // Выбранное место
		_markerAirport = createMarker ["markerAirport", _pos1];
		"markerAirport" setMarkerColor markerColorPlayers;
		"markerAirport" setMarkerType "c_plane";
		"markerAirport" setMarkerText "Аэропорт";
		missionNameSpace setVariable ["airportChosen", true, true];
		//openMap [false, false];
	}
];
waitUntil {missionNamespace getVariable ["airportChosen", false]};

hintSilent "";
removeMissionEventHandler ["MapSingleClick",_mapEH];
sleep 1.5;

// Добавление второй точки - направления для аэропорта
_str = parsetext format ["Теперь выберите <t color='#E39325'>направление</t> аэропорта (укажите другой край аэропорта). В эту сторону будут направлен аэропорт и вся созданная техника."]; 
hint _str;

_mapDIR = addMissionEventHandler ["MapSingleClick", 
	{
		// Следующий код выполняется при щелчке мыши на карте
		_pos2 = _this select 1; // Выбранное место
		_markerAirport = createMarker ["markerDIR", _pos2];
		openMap [false, false];
	}
];

waitUntil {!visibleMap};
hintSilent "";
removeMissionEventHandler ["MapSingleClick",_mapDIR];
//deleteMarker "markerDIR";

arsenalBox removeAction choiceAirport;
{deleteVehicle _x} forEach nearestObjects [getMarkerPos "markerAirport", ["all"], 25];
sleep 2;

_dir = getMarkerPos "markerAirport" getDir getMarkerPos "markerDIR";
missionNamespace setVariable ["airportDir", _dir, true];

// Создание объектов в аэропорту
[getMarkerPos "markerAirport", _dir, _airport] remoteExec ["BIS_fnc_objectsMapper", 2, false];
sleep 3;

// Назначение глоабльных имен
[pilotPos_srv, "pilotPos"] call fnc_setVehicleName;
[airportPos_srv, "airportPos"] call fnc_setVehicleName;
[airHelipad_srv, "airHelipad"] call fnc_setVehicleName;

// Перенос рабочего на его место
airStand setpos getpos pilotPos;
airStand setdir _dir;

// Делаем все объекты неуязвимыми
{[_x,false] remoteExec ["allowDamage",_x];} forEach nearestObjects [getMarkerPos "markerAirport", [], 25];

// Создаем маркер на месте вертолётной площадки, на нем будет появляться заспавненая техника
_markerAirport = createMarker ["VVS_all_2", getpos airHelipad];
"VVS_all_2" setMarkerAlpha 0;
hint "Аэропорт установлен.";

[airStand, ["<t color='#11ff11'>Арсенал самолётов</t>",{[["planes","helicopters"], ["B_UAV_05_F","B_UAV_02_dynamicLoadout_F","O_UAV_02_dynamicLoadout_F","I_UAV_02_dynamicLoadout_F","RHS_A10","rhsusf_f22","rhsgref_cdf_b_su25","RHS_AN2_B","rhs_l159_cdf_b_CDF","rhs_l39_cdf_b_cdf","rhs_pchela1t_vvsc","rhs_pchela1t_vvs","rhs_mig29sm_vvsc","RHS_Su25SM_vvsc","rhs_mig29sm_vvs","rhs_mig29s_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_blueonblue","RHS_T50_vvs_generic_ext","rhssaf_airforce_o_l_18","rhssaf_airforce_o_l_18_101"], "VVS_all_2"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == 'Пилот'", 8]] remoteExec ["addAction",0,true];
[airStand, ["<t color='#11ff11'>Арсенал вертолётов</t>",{[["planes","helicopters"], ["LOP_AA_Mi24V_UPK23","LOP_AA_Mi24V_FAB","LOP_AA_Mi24V_AT","LOP_AA_Mi8MTV3_UPK23","LOP_AA_Mi8MTV3_FAB","LOP_IA_Mi24V_UPK23","LOP_IA_Mi24V_FAB","LOP_IA_Mi24V_AT","LOP_IA_Mi8MTV3_UPK23","LOP_IA_Mi8MTV3_FAB","RHS_AH64D_wd","RHS_AH64DGrey","RHS_AH1Z_wd","RHS_UH1Y_FFAR","RHS_UH1Y","rhsgref_cdf_b_Mi24D","rhsgref_cdf_b_Mi24D_Early","rhsgref_cdf_b_reg_Mi17Sh","rhsgref_b_mi24g_CAS","rhsgref_cdf_b_Mi35","rhs_uh1h_hidf_gunship","B_T_UAV_03_dynamicLoadout_F","LOP_SLA_Mi8MTV3_UPK23","LOP_SLA_Mi8MTV3_FAB","rhs_mi28n_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8mtv3_Cargo_vvsc","RHS_Ka52_vvsc","RHS_Mi24P_vvsc","RHS_Mi24V_vvsc","RHS_Mi8MTV3_heavy_vvsc","rhs_mi28n_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8mtv3_Cargo_vvs","RHS_Ka52_vvs","RHS_Mi24P_vvs","RHS_Mi24V_vvs","RHS_Mi8MTV3_heavy_vvs","LOP_ChDKZ_Mi8MTV3_UPK23","LOP_ChDKZ_Mi8MTV3_FAB","O_Heli_Light_02_dynamicLoadout_F","I_E_Heli_light_03_dynamicLoadout_F","LOP_IRAN_Mi8MTV3_FAB","LOP_IRAN_Mi8MTV3_UPK23","LOP_IRAN_AH1Z_WD","LOP_IRAN_AH1Z_CS","LOP_IRAN_AH1Z_GS","LOP_UKR_Mi24V_UPK23","LOP_UKR_Mi24V_FAB","LOP_UKR_Mi24V_AT","LOP_UKR_Mi8MTV3_UPK23","LOP_UKR_Mi8MTV3_FAB","LOP_UN_Mi24V_UPK23","LOP_RACS_MH9_armed","LOP_UN_Mi24V_FAB","LOP_UN_Mi24V_AT","LOP_UN_Mi8MTV3_UPK23","LOP_UN_Mi8MTV3_FAB","LOP_UA_Mi8MTV3_UPK23","LOP_UA_Mi8MTV3_FAB","LOP_PMC_Mi24V_FAB","LOP_PMC_Mi24V_UPK23","LOP_PMC_Mi24V_AT","LOP_PMC_MH9_armed","I_Heli_light_03_dynamicLoadout_F","RHS_MELB_AH6M"], "VVS_all_2"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == 'Пилот'", 8]] remoteExec ["addAction",0,true];
[airStand, ["<t color='#11ff11'>Арсенал поддержки</t>",{[["cars"], ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_Repair_F","O_Truck_02_Ammo_F","O_Truck_02_fuel_F","O_Truck_02_box_F","I_Truck_02_ammo_F","I_Truck_02_fuel_F","I_Truck_02_box_F"], "VVS_all_2"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == 'Пилот'", 8]] remoteExec ["addAction",0,true];
[airStand, ["<t size='1.2' color='#E39325'>Переместиться в штаб</t>",{3 fadeSound 0;cutText["Перемещение в штаб...","BLACK OUT",3];sleep 6;player setpos getmarkerpos "campmkr";cutText["","BLACK IN",5]; 2 fadeSound 1;},[], 1.5, false, true, "", "true", 8]] remoteExec ["addAction",0,true];