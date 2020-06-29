/*
	Инициализация техники COS.
	Скрипт для добавления инициализации гражданской технике после спавна COS.
*/
_veh = (_this select 0);
/////////////////////////////////////////////////

_randomFuel = true; // Случайное количество топлива в баке
_canBeLocked = true; // Вероятность что машина будет закрыта
_Bombs = true; // Транспорт может быть заминирован
_debug = false; // Дебаг режим с отметками на карте
////////////////////////////////////////////////

_markerstr = nil;
if (_debug) then {
	_randomnumber = floor random 1000000;
	_name = "Markername" + (str _randomnumber);
	_markerstr = createMarker [_name, getpos _veh];
	_markerstr setMarkerType "mil_box";
	_markerstr setmarkercolor "ColorBlack";
	_markerstr setMarkerText "Транспорт";
};

_locked = false;

// Задаем случайное количество топлива
if (_randomFuel) then {
	_fuel = random [0.2, 0.5, 0.8]; 
	_veh setFuel _fuel;
};

// 25% что техника будет закрыта
if (_canBeLocked) then {
	if (random 1 > 0.75) then {
		_veh setVehicleLock "LOCKED";
		_locked = true;
		
		if (_debug) then {
			_markerstr setmarkercolor "ColorYellow";
			_markerstr setMarkerText "Транспорт (закрыт)";
		};
	};
};

// 20% что техника будет заминирована
if (_Bombs) then {
	if (!_locked and random 1 > 0.8) then {
		_veh setvariable ["vehicle_is_planted", true, true]; // Чтобы не вызывать скрипт выброса из техники дважды
		
		if (random 1 > 0.7) then {
			// Минирование транспорта на движение рядом
			if (_debug) then {
				_markerstr setMarkerText "Транспорт (Заминирован на приближение)";
				_markerstr setmarkercolor "ColorCIV";
			};
		
			_veh spawn {
				waitUntil { { isPlayer _x && _x distance _this < 6 } count AllPlayers > 0 };
				_bomb = "Bo_GBU12_LGB" createVehicle getpos _this;
				_bomb setDamage 1;
			};
		}
		else {
			_veh addEventHandler [
				"Engine", 
				{ 
					params ["_vehicle", "_engineOn"];
					if(_engineOn ) then {
						myFnc = {
							_pos = getpos _this;
							_bomb = "Bo_GBU12_LGB" createVehicle getpos _this;
							_bomb setDamage 1;
							
							{ 
								_bodyParts = ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"];
								_num = [3,6] call BIS_fnc_randomInt;
								
								for "_i" from 1 to _num do {
									[_x, 0.4, selectRandom _bodyParts, "explosive"] call ace_medical_fnc_addDamageToUnit; 
								};
								
								[_x, true, (15), true] call ace_medical_fnc_setUnconscious;
							} forEach crew _this;
							
							sleep 5;

							{ 
								moveOut _x;
								_pos = [_this, 2, 5, 1, 0, 50, 0,[], getpos _x] call BIS_fnc_findSafePos;
								_x setpos _pos;
							} forEach crew _this;
						};
						[_vehicle, "myFnc"] call BIS_fnc_spawnOrdered;
					};
				}
			]; 
			
			if (_debug) then {
				_markerstr setMarkerText "Транспорт (Заминирован на двигатель)";
				_markerstr setmarkercolor "ColorRed";
			};
		};
	};
};