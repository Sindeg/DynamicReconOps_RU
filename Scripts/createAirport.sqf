_airport= [
	["Land_PortableLight_double_F",[-2.55103,-1.88086,0],212.879,1,0,[0,0],"","",true,false], 
	["babe_helper",[2.77051,-2.0293,0],0,1,0,[0,0],"pilotPos","",true,false], 
	["Land_Cargo_House_V3_F",[1.13184,-4.20654,0],184.185,1,0,[0,0],"","",true,false], 
	["babe_helper",[2.39893,-4.55469,0.234555],0,1,0,[0,0],"airportPos","",true,false], 
	["Land_HelipadEmpty_F",[5.10181,10.7139,0],358.225,1,0,[0,0],"airHelipad","",true,false]
];

openMap [true, true]; // Opens map
_str = parsetext format ["<t size = '1.1'>Выберите один из <t color='#E39325'>аэропортов</t> на карте, в котором будет расположен арсенал самолётов для использования пилотами.<br/><br/> Желательно выбрать место в <t color='#E39325'>крайней южной</t> части аэропорта, так как созданная техника будет смотреть на север. <br/><br/>  Не выбирайте аэропорт вблизи противника</t>, чтобы избежать жертв."]; 
hint _str;
_mapEH = addMissionEventHandler ["MapSingleClick", 
	{
		// Следующий код выполняется при щелчке мыши на карте
		_pos = _this select 1; // Выбранное место
		_markerAirport = createMarker ["markerAirport", _pos];
		"markerAirport" setMarkerColor markerColorPlayers;
		"markerAirport" setMarkerType "c_plane";
		"markerAirport" setMarkerText "Аэропорт";
		openMap [false, false];
	}
];
waitUntil {!visibleMap};
hintSilent "";
removeMissionEventHandler ["MapSingleClick",_mapEH];
arsenalBox removeAction choiceAirport;
{deleteVehicle _x} forEach nearestObjects [getMarkerPos "markerAirport", ["all"], 25];
sleep 2;

[getMarkerPos "markerAirport", 0, _airport] remoteExec ["BIS_fnc_objectsMapper", 2, false];
sleep 1;
airStand setpos getpos pilotPos;
airStand setdir 10;
{[_x,false] remoteExec ["allowDamage",_x];} forEach nearestObjects [getMarkerPos "markerAirport", [], 25];

_markerAirport = createMarker ["VVS_all_2", getpos airHelipad];
hint "Аэропорт установлен.";
"VVS_all_2" setMarkerAlpha 0;

[airStand, ["<t color='#11ff11'>Арсенал авиатранспорта</t>",{[["planes","helicopters"], ["B_T_VTOL_01_vehicle_F","B_T_VTOL_01_infantry_F","B_T_VTOL_01_armed_F","B_UAV_05_F","B_UAV_02_dynamicLoadout_F","O_UAV_02_dynamicLoadout_F","I_UAV_02_dynamicLoadout_F","RHS_A10","RHS_C130J","rhsusf_f22","rhsgref_cdf_b_su25","RHS_AN2_B","rhs_l159_cdf_b_CDF","rhs_l39_cdf_b_cdf","rhs_pchela1t_vvsc","rhs_pchela1t_vvs","rhs_mig29sm_vvsc","RHS_Su25SM_vvsc","rhs_mig29sm_vvs","rhs_mig29s_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_blueonblue","RHS_T50_vvs_generic_ext","rhssaf_airforce_o_l_18","rhssaf_airforce_o_l_18_101", "LOP_AA_Mi24V_UPK23","LOP_AA_Mi24V_FAB","LOP_AA_Mi24V_AT","LOP_AA_Mi8MTV3_UPK23","LOP_AA_Mi8MTV3_FAB","LOP_IA_Mi24V_UPK23","LOP_IA_Mi24V_FAB","LOP_IA_Mi24V_AT","LOP_IA_Mi8MTV3_UPK23","LOP_IA_Mi8MTV3_FAB","RHS_AH64D_wd","RHS_AH64DGrey","RHS_AH1Z_wd","RHS_UH1Y_FFAR","RHS_UH1Y","rhsgref_cdf_b_Mi24D","rhsgref_cdf_b_Mi24D_Early","rhsgref_cdf_b_reg_Mi17Sh","rhsgref_b_mi24g_CAS","rhsgref_cdf_b_Mi35","rhs_uh1h_hidf_gunship","B_T_UAV_03_dynamicLoadout_F","LOP_SLA_Mi8MTV3_UPK23","LOP_SLA_Mi8MTV3_FAB","rhs_mi28n_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8mtv3_Cargo_vvsc","RHS_Ka52_vvsc","RHS_Mi24P_vvsc","RHS_Mi24V_vvsc","RHS_Mi8MTV3_heavy_vvsc","rhs_mi28n_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8mtv3_Cargo_vvs","RHS_Ka52_vvs","RHS_Mi24P_vvs","RHS_Mi24V_vvs","RHS_Mi8MTV3_heavy_vvs","LOP_ChDKZ_Mi8MTV3_UPK23","LOP_ChDKZ_Mi8MTV3_FAB","O_Heli_Light_02_dynamicLoadout_F","I_E_Heli_light_03_dynamicLoadout_F","LOP_IRAN_Mi8MTV3_FAB","LOP_IRAN_Mi8MTV3_UPK23","LOP_IRAN_AH1Z_WD","LOP_IRAN_AH1Z_CS","LOP_IRAN_AH1Z_GS","LOP_UKR_Mi24V_UPK23","LOP_UKR_Mi24V_FAB","LOP_UKR_Mi24V_AT","LOP_UKR_Mi8MTV3_UPK23","LOP_UKR_Mi8MTV3_FAB","LOP_UN_Mi24V_UPK23","LOP_RACS_MH9_armed","LOP_UN_Mi24V_FAB","LOP_UN_Mi24V_AT","LOP_UN_Mi8MTV3_UPK23","LOP_UN_Mi8MTV3_FAB","LOP_UA_Mi8MTV3_UPK23","LOP_UA_Mi8MTV3_FAB","LOP_PMC_Mi24V_FAB","LOP_PMC_Mi24V_UPK23","LOP_PMC_Mi24V_AT","LOP_PMC_MH9_armed","I_Heli_light_03_dynamicLoadout_F","RHS_MELB_AH6M"], "VVS_all_2"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == 'Пилот'", 8]] remoteExec ["addAction",0,true];
[airStand, ["<t color='#11ff11'>Арсенал поддержки</t>",{[["cars"], ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_Repair_F","O_Truck_02_Ammo_F","O_Truck_02_fuel_F","O_Truck_02_box_F","I_Truck_02_ammo_F","I_Truck_02_fuel_F","I_Truck_02_box_F"], "VVS_all_2"] execvm "scripts\ASORVS\open.sqf";},[], 1.5, false, true, "", "roleDescription player == 'Пилот'", 8]] remoteExec ["addAction",0,true];
[airStand, ["<t size='1.2' color='#E39325'>Переместиться в штаб</t>",{3 fadeSound 0;cutText["Перемещение в штаб...","BLACK OUT",3];sleep 6;player setpos getmarkerpos "campmkr";cutText["","BLACK IN",5]; 2 fadeSound 1;},[], 1.5, false, true, "", "true", 8]] remoteExec ["addAction",0,true];