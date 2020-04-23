private ["_opticsAllowed","_specialisedOptics","_optics","_basePos","_firstRun","_insideSafezone","_outsideSafezone"];
 
#define SZ_RADIUS 120

_basePos = getMarkerPos "campMkr";
_szmkr = getMarkerPos "campMkr";

//===== AT / MISSILE LAUNCHERS (excl RPG)
_missileSoldiers = ["B_soldier_AT_F"];
_missileSpecialisedAT = ["launch_NLAW_F","launch_RPG32_F","launch_RPG32_ghex_F","launch_RPG7_F","rhs_weap_fgm148","rhs_weap_maaws","rhs_weap_maaws_optic","launch_MRAWS_olive_F", "launch_MRAWS_olive_rail_F","launch_MRAWS_green_F","launch_MRAWS_green_rail_F","launch_MRAWS_sand_F","launch_MRAWS_sand_rail_F","rhs_weap_smaw","rhs_weap_smaw_gr_optic","rhs_weap_smaw_green","rhs_weap_smaw_optic","rhs_weap_rpg7","rhs_weap_rpg7_1pn93","rhs_weap_rpg7_pgo"];
_missileSpecialisedAA =["rhs_weap_igla","rhs_weap_fim92"];

//_blacklistAT = ["launch_B_Titan_F","launch_O_Titan_F","launch_I_Titan_F","launch_B_Titan_short_F","launch_O_Titan_short_F","launch_I_Titan_short_F","launch_O_Titan_F","launch_B_Titan_tna_F","launch_O_Titan_Short_F","launch_B_Titan_short_tna_F","launch_I_Titan_eaf_F","launch_B_Titan_olive_F","launch_O_Vorona_green_F","launch_O_Vorona_brown_F","launch_Titan_F","launch_Titan_short_F","launch_O_Titan_short_ghex_F","launch_O_Titan_ghex_F"];

_dropWeapon = 
{
	params ["_droppingWeapon"];
	_person = player;  	 
	_person removeWeapon (_droppingWeapon); 
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0]; 
	_weaponHolder addWeaponCargoGlobal [_droppingWeapon,1]; 
	_weaponHolder setPos (_person modelToWorld [0,.2,1.2]); 
	_weaponHolder disableCollisionWith _person; 
	_dir = getDir player + random [-25, 0, 25]; 
	_speed = 1.5; 
	_weaponHolder setVelocity [_speed * sin(_dir), _speed * cos(_dir),4];  
}; 
 
// _eventAdded = false;

// restrict_Thermal = false;
// restrict_LMG = false;
// restrict_sOptics = false;
// restrict_Marksman = false;
// restrict_mOptics = false;
 
while {true} do 
{
	_primaryWeapon = primaryWeapon player;
	_secondaryWeapon = secondaryWeapon player;
	_secondaryName = getText(configFile >> "CfgWeapons" >>_secondaryWeapon >> "displayName");
	_playerRole = roleDescription player;
	
	//------------------------------------- LaunchersAT
	if (({player hasWeapon _x} count _missileSpecialisedAT) > 0) then 
	{
		//if (({player isKindOf _x} count _missileSoldiers) < 1 && (_playerRole isEqualTo "ПТ специалист")) then 
		if (!(_playerRole isEqualTo "ПТ специалист")) then 
		{
			if (_insideSafezone) then {player removeWeapon _secondaryWeapon} else {[secondaryWeapon player] call _dropWeapon};
			hint parseText format ["<t size = '1.2' color='#FFBF00'>Внимание</t><br/><br />Только ПТ специалисты могут использовать %1. Вам доступны только базовые ПТ гранатомёты.<br/>",_secondaryName];
		};
	};
	
	sleep 1;
	
	//------------------------------------- LaunchersAA
	if (({player hasWeapon _x} count _missileSpecialisedAA) > 0) then 
	{
		if (!(_playerRole isEqualTo "ПВО специалист")) then 
		{
			if (_insideSafezone) then {player removeWeapon _secondaryWeapon} else {[secondaryWeapon player] call _dropWeapon};
			hint parseText format ["<t size = '1.2' color='#FFBF00'>Внимание</t><br/><br />Только ПВО специалисты могут использовать %1. Вам доступны только базовые ПТ гранатомёты.<br/>",_secondaryName];
			//titleText [AT_MSG,"PLAIN",3];
		};
	};

	sleep 1;
	 
	_szmkr = getMarkerPos "campMkr";
	
	 if ((player distance _szmkr) > SZ_RADIUS) then 
	{
		_insideSafezone = FALSE;
		_outsideSafezone = TRUE;
		// Скрытие всех меток кроме штаба
		"markermedic" setMarkerAlphaLocal 0;
		"VVS_all_1" setMarkerAlphaLocal 0;
		markerPlayerStart setMarkerAlphaLocal 1;
	}
	else
	{
		"markermedic" setMarkerAlphaLocal 1;
		"VVS_all_1" setMarkerAlphaLocal 1;
		markerPlayerStart setMarkerAlphaLocal 0;
		_outsideSafezone = FALSE;
		_insideSafezone = TRUE;
	};
 
	sleep 2;
	 
	// Проверка на занимаемый слот и добавление в команду определенного цвета
	_roleOn = "role_specialization" call BIS_fnc_getParamValue;
	if (_roleOn == 1) then
	{
		_playerRole = roleDescription player;
		switch (_playerRole) do
		{
			case "Медик": 
				{player assignTeam "RED";}; 
			case "Командир (медик)": 
				{player assignTeam "RED";}; 
			case "Инженер": 
				{player assignTeam "BLUE";}; 
			case "ПТ специалист": 
				{player assignTeam "GREEN";}; 
			case "ПВО специалист": 
				{player assignTeam "YELLOW";}; 
		};
	};
	
	//----- Sleep
	_basePos = getMarkerPos "campMkr";
	if ((player distance _basePos) <= 150) then 
	{
		sleep 10;
	} 
	else 
	{
		sleep 20;
	};
};