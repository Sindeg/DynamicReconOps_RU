/*
	Инициализация техники COS.
	Скрипт для добавления инициализации гражданской технике после спавна COS.
*/
_veh = (_this select 0);
_vehPos = (_this select 1);
/////////////////////////////////////////////////

_randomFuel = true; // Случайное количество топлива в баке
_canBeLocked = true; // Вероятность что машина будет закрыта

////////////////////////////////////////////////

sleep 4;

// Задаем случайное количество топлива
if (_randomFuel) then {
	_fuel = random [0.2, 0.5, 0.8]; 
	_veh setFuel _fuel;
};

if (_canBeLocked) then {
	if (random 1 > 0.8) then {
		_veh setVehicleLock "LOCKED";
	};
};