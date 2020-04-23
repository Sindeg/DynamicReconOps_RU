// Защищает определенных юнитов от возможности "взятия в плен"

_captive = _this select 0;
_state = _this select 1;				// True or False 
_cuffed = _this select 2;				// “SetHandcuffed” or “SetSurrendered”

_valid = [baseMedic, baseWorker, airStand]; // Массив юнитов, которых нельзя связать

if (_captive in _valid && _state isEqualto True && _cuffed isEqualto "SetHandcuffed") then		
{ 
	["ace_captives_setHandcuffed", [_captive, false], _captive] call CBA_fnc_targetEvent;
};