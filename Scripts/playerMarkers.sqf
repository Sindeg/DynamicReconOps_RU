_countPlayers = 0; // Число отмеченных игроков

_Color = markerColorPlayers;

_createMarker = {
	params ["_x", "_xSize", "_ySize","_markerText"];	

	_markerName = str(format ["player_mrk_%1", _countPlayers]);
	_countPlayers = _countPlayers + 1;
	
	_mName = _markerName;
	_mName = createMarker [_markerName, position _x]; 
	
	_mName setMarkerSize [_xSize, _ySize];
	_mName setMarkerShape "ICON";
	_mName setMarkerType "mil_triangle";
	_mName setMarkerColor _Color;
	_mName setMarkerText _markerText;
	_mName setMarkerDir (direction _x);
};

while {true} do
{
	_countPlayers = 0;
	{
		if (_x getVariable "needMark" == 1) then
		{
			_needMark = false;
			_vehPlayer = objectParent _x;
			_player = name _x;
			
			if (isNull _vehPlayer) then 
			{
				// Игрок вне транспорта
				[_x, 0.6, 0.9, name _x] call _createMarker;
			}
			else
			{
				_countCrew = {alive _x} count (crew _vehPlayer);
				if (driver _vehPlayer == _x) then
				{
					// Игрок на водителе
					_vehName = getText (configFile >> "CfgVehicles" >> (typeof _vehPlayer) >> "displayName");
					_nameMarker = [format["%1 [%2]", _vehName, _player], format["%1 [%2]", _vehName, _countCrew]] select (_countCrew > 1);
					[_x, 1, 1.3, _nameMarker] call _createMarker;
				}
				else
				{	
					if (_countCrew == 1) then 
					{
						// Игрок один в транспорте
						_vehName = getText (configFile >> "CfgVehicles" >> (typeof _vehPlayer) >> "displayName");
						_nameMarker = format["%1 [%2]", _vehName, _player];
						
						[_x, 1, 1.3, _nameMarker] call _createMarker;
					};
				};
			};
		};
		_x setVariable ["respawnLoadout", (getUnitLoadout _x), true];
	} forEach allPlayers;
	
	sleep 2;
	
	for "_i" from 0 to _countPlayers do {
		_name = str(format ["player_mrk_%1", _i]);
		deleteMarker _name;
	};
	
};