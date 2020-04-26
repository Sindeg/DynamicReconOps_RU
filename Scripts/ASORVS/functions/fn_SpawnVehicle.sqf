objNull spawn {
	hint "Ожидайте создания техники.";
	_time = random [35, 45, 50];
	_left = _time;
	_tick = 0.2;
	while {_left > 0} do
	{
		_left = _left - _tick;
		_done = (1 - _left / _time) * 100;
		hintsilent parsetext format ["<t size = '1.2'>Готовность транспорта<br/><t color = '#E39325'>%1 %2<t/><t/>",_done tofixed 0, "%"];
		sleep _tick;
	};
	//sleep _time; //wait for client to be able to check vehicles positions properly again.
	_somedeleted = false;
	{
		deleteVehicle _x;
		_somedeleted =true;
	}
	forEach (ASORVS_VehicleSpawnPos nearEntities ASORVS_VehicleSpawnRadius);
	if(_somedeleted) then {
		sleep 0.1;
	};
	_veh = createVehicle [ASORVS_CurrentVehicle, ASORVS_VehicleSpawnPos, [], 0, "CAN_COLLIDE"];
	hint parsetext "<t size='1.2' color = '#E39325'>Транспорт доставлен.<t/>";
	_veh setVehicleLock "UNLOCKED";

	_veh setDir 20;
	
	// Разоружение, если игрок создаёт самолёт
	if (ASORVS_VehicleTypes select 0 == "planes"  || ASORVS_VehicleTypes select 1 == "helicopters") then {
		[_veh, 0] remoteExec ["setVehicleAmmo", 0, true];
		[_veh, 0.05] remoteExec ["setFuel", 0, true];
	};
	
	Stz_Atv = _veh;
	[
		Stz_Atv,
		"<t color='#11ff11'>Удалить технику",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa",
		"(((Stz_Atv distance baseWorker) < 80) && ((_this distance _target) < 6) && ({alive _x} count crew cursorTarget == 0) && (!(vehicle player isKindOf ""LandVehicle"")))",
		"true",
		{},
		{},
		{[Stz_Atv,player] spawn fnc_deleteVehicle;deleteVehicle cursorTarget;[Stz_Atv,player] remoteExec ["fnc_deleteVehicle",0];},
		{},
		[],
		8,
		0,
		false,
		false
	] remoteExec ["BIS_fnc_holdActionAdd",0,true]; // было Stz_Atv вместо true
};