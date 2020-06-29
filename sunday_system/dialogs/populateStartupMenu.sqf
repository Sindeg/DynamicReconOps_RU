disableSerialization;
menuComplete = false;

menuSliderArray = [
	["Инфо", 1140],
	["Сценарий", 2000],
	["Окружение", 3000],	
	["Задания", 4000],
	["Доп. фракции", 5000]
];
menuSliderCurrent = 0;

ctrlSetFocus ((findDisplay 52525) displayCtrl 1150);

{	
	if ((ctrlIDC _x != 1098) && (ctrlIDC _x != 1052) && (ctrlIDC _x != 1053)) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlSetFade 0;
	};	
	if (ctrlIDC _x < 5000) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
	}; 		
} forEach (allControls findDisplay 52525);
[] spawn {
	//sleep 2;
	((findDisplay 52525) displayCtrl 1098) ctrlSetFade 0;
	((findDisplay 52525) displayCtrl 1098) ctrlCommit 1.5;
};
/*
_index = lbAdd [2103, "Random"];
_index = lbAdd [2103, "Dawn"];
_index = lbAdd [2103, "Day"];
_index = lbAdd [2103, "Dusk"];
_index = lbAdd [2103, "Night"];
*/
lbAdd [2104, "Случ"];
lbAdd [2104, "Январь"];
lbAdd [2104, "Февраль"];
lbAdd [2104, "Март"];
lbAdd [2104, "Апрель"];
lbAdd [2104, "Май"];
lbAdd [2104, "Июнь"];
lbAdd [2104, "Июль"];
lbAdd [2104, "Август"];
lbAdd [2104, "Сентябрь"];
lbAdd [2104, "Октябрь"];
lbAdd [2104, "Ноябрь"];
lbAdd [2104, "Декабрь"];
/*
lbAdd [2116, "Random"];
lbAdd [2116, "Custom"];
*/
_index = lbAdd [2106, "Случ"];
_index = lbAdd [2106, "1"];
_index = lbAdd [2106, "2"];
_index = lbAdd [2106, "3"];
_index = lbAdd [2106, "4"];
_index = lbAdd [2106, "5"];

["MAIN", 2020, false] call sun_switchButton;
["MAIN", 2030, false] call sun_switchButton;
["MAIN", 2050, false] call sun_switchButton;
["MAIN", 2060, false] call sun_switchButton;
["MAIN", 2070, false] call sun_switchButton;
["MAIN", 2080, false] call sun_switchButton;
["MAIN", 2090, false] call sun_switchButton;
["MAIN", 2400, false] call sun_switchButton;
["MAIN", 3010, false, "TIME"] call sun_switchButton;
['MAIN', 3020, false] call sun_switchButtonWeather;
["MAIN", 3030, false] call sun_switchButton;
["MAIN", 4010, false] call sun_switchButton;

// Отключение кнопок в меню (Дин. симуляция, мины, гражданские, мед. система)
ctrlEnable [2404, false]; // погода
ctrlEnable [2084, false];
ctrlEnable [2074, false];
ctrlEnable [2064, false]; // Гражданские
//ctrlEnable [2054, false]; // Минные поля
ctrlEnable [2024, false];
ctrlEnable [3034, false]; // Животные

/*
lbAdd [2117, "Enabled"];
lbAdd [2117, "Disabled"];
*/
//lbSetCurSel [2106, numObjectives];

lbSetCurSel [2104, month];
[2301] call dro_inputDaysData;
lbSetCurSel [2301, day];

// Slider items
sliderSetRange [2041, 5, 17];
sliderSetPosition [2041, aiMultiplier*10];
((findDisplay 52525) displayCtrl 2041) ctrlSetText format ["Количество противника: x%1", profileNamespace getVariable ['DRO_aiMultiplier', 1]];


sliderSetRange [2109, 0, 10];

if (weatherOvercast isEqualType "") then {	
	sliderSetPosition [2109, 3];
	lbSetCurSel [2116, 0];
} else {	
	sliderSetPosition [2109, (weatherOvercast*10)];
	lbSetCurSel [2116, 1];
};

if (!isNil "aoName") then {
	ctrlSetText [2202, format ["Зона операции: %1", aoName]];
};

// Objective preferences
if (count preferredObjectives > 0) then {
	{
		switch (_x) do {
			case "HVT": {((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "POW": {((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "INTEL": {((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "CACHE": {((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "MORTAR": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "WRECK": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};			
			case "VEHICLE": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "VEHICLESTEAL": {((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "ARTY": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "HELI": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "CLEARLZ": {((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "FORTIFY": {((findDisplay 52525) displayCtrl 2211) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "DISARM": {((findDisplay 52525) displayCtrl 2212) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "PROTECTCIV": {((findDisplay 52525) displayCtrl 2213) ctrlSetTextColor [0.05, 1, 0.5, 1]};
		}; 
		
	} forEach preferredObjectives;
};

{
	_indexP = lbAdd [_x, "NONE"];					
	lbSetData [_x, _indexP, ""];
	lbSetColor [_x, _indexP, [1, 1, 1, 1]];	
} forEach [3800, 3801, 3802, 3803, 3804, 3805];	

{
	_index = lbAdd [_x, "RANDOM"];					
	lbSetData [_x, _index, "RANDOM"];
} forEach [1301, 1311];	

_pFactionSel = pFactionIndex;
_eFactionSel = eFactionIndex;

{	
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	diag_log _thisFactionFlag;
	_thisSideNum = (_x select 3);
	// Add factions to combo boxes
	_color = "";
	switch (_thisSideNum) do {
		case 1: {
			_color = [0, 0.3, 0.6, 1];
		};
		case 0: {
			_color = [0.5, 0, 0, 1];
		};
		case 2: {
			_color = [0, 0.5, 0, 1];
		};
		case 3: {
			_color = [1, 1, 1, 1];
		};						
	};				
	if (_thisSideNum == 3) then {
		_indexC = lbAdd [1321, _thisFactionName];					
		lbSetData [1321, _indexC, _thisFaction];
		lbSetColor [1321, _indexC, _color];		
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1321, _indexC, _thisFactionFlag];
				lbSetPictureColor [1321, _indexC, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1321, _indexC, [1, 1, 1, 1]];
			};
		};
	} else {		
		_indexP = lbAdd [1301, _thisFactionName];					
		lbSetData [1301, _indexP, _thisFaction];
		lbSetColor [1301, _indexP, _color];
		
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1301, _indexP, _thisFactionFlag];
				lbSetPictureColor [1301, _indexP, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1301, _indexP, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DRO_playersFaction", ""]) == _thisFaction) then {
			_pFactionSel = _indexP;
		};
		_indexE = lbAdd [1311, _thisFactionName];					
		lbSetData [1311, _indexE, _thisFaction];
		lbSetColor [1311, _indexE, _color];
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1311, _indexE, _thisFactionFlag];
				lbSetPictureColor [1311, _indexE, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1311, _indexE, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DRO_enemyFaction", ""]) == _thisFaction) then {
			_eFactionSel = _indexE;
		};
	};				
} forEach availableFactionsData;


{
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	_thisSideNum = (_x select 3);
	// Add factions to combo boxes
	_color = "";
	switch (_thisSideNum) do {
		case 1: {
			_color = [0, 0.3, 0.6, 1];
		};
		case 0: {
			_color = [0.5, 0, 0, 1];
		};
		case 2: {
			_color = [0, 0.5, 0, 1];
		};
		case 3: {
			_color = [1, 1, 1, 1];
		};						
	};				
	if (_thisSideNum != 3) then {	
		{
			_indexP = lbAdd [_x, _thisFactionName];					
			lbSetData [_x, _indexP, _thisFaction];
			lbSetColor [_x, _indexP, _color];
			if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
				if (count _thisFactionFlag > 0) then {
					lbSetPicture [_x, _indexP, _thisFactionFlag];
					lbSetPictureColor [_x, _indexP, [1, 1, 1, 1]];
					lbSetPictureColorSelected [_x, _indexP, [1, 1, 1, 1]];
				};
			};
		} forEach [3800, 3801, 3802];	
		
		{
			_indexE = lbAdd [_x, _thisFactionName];					
			lbSetData [_x, _indexE, _thisFaction];
			lbSetColor [_x, _indexE, _color];
			if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
				if (count _thisFactionFlag > 0) then {
					lbSetPicture [_x, _indexE, _thisFactionFlag];
					lbSetPictureColor [_x, _indexE, [1, 1, 1, 1]];
					lbSetPictureColorSelected [_x, _indexE, [1, 1, 1, 1]];
				};
			};
		} forEach [3803, 3804, 3805];		
		
	};				
} forEach (availableFactionsData + availableFactionsDataNoInf);

lbSetCurSel [1301, _pFactionSel];
lbSetCurSel [1311, _eFactionSel];
lbSetCurSel [1321, cFactionIndex];

lbSetCurSel [3800, (playersFactionAdv select 0)];
lbSetCurSel [3801, (playersFactionAdv select 1)];
lbSetCurSel [3802, (playersFactionAdv select 2)];
lbSetCurSel [3803, (enemyFactionAdv select 0)];
lbSetCurSel [3804, (enemyFactionAdv select 1)];
lbSetCurSel [3805, (enemyFactionAdv select 2)];

//_return pushBack ["Текущие настройки", "Стандарт", "Снайперы", "Много техники"]
// Add multiline tooltips
_tooltip = str composeText [
	"Предустановки",
	toString [13, 10],
	"Стандарт: Классический режим. Выполняйте задания своим отрядом в зоне операции.",
	toString [13, 10],
	"Снайперы: Устраните определенную цель в малонаселенном регионе, оставаясь незамеченым.",
	toString [13, 10],
	"Много техники: в отличии от 'стандарта', в этом режиме у противника будет большое количество техники.",
	toString [13, 10]
];
((findDisplay 52525) displayCtrl 2094) ctrlSetTooltip _tooltip;
_tooltip = str composeText [	 
	"AI Skill",
	toString [13, 10],
	"Normal: Reduces the AI's aiming ability dramatically while leaving their strategic skills almost unchanged. This is the default setting for DRO, balanced for the number of enemy units you're likely to encounter.",
	toString [13, 10],
	"Hard: Reduces the AI's aiming ability less dramatically while leaving their strategic skills almost unchanged.",
	toString [13, 10],
	"Realism: Makes no changes to any AI skills and leaves them as set in your Arma options menu.",
	toString [13, 10]
];
((findDisplay 52525) displayCtrl 2034) ctrlSetTooltip _tooltip;



// Search for incompatible mods
_modList = "";
/*
if ((configfile >> "CfgPatches" >> "ace_main") call BIS_fnc_getCfgIsClass) then {		
	_modList = composeText [_modList, lineBreak, "ACE3"];
};
*/
_warningList = "";
if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {	
	if (!isNil "ace_medical_enableRevive") then {
		if (ace_medical_enableRevive > 0) then {
			_warningList = composeText [lineBreak, "ACE медицина включена, DRO система оживления будет автоматически отключена."];
		};
	};
};

if ((configfile >> "CfgPatches" >> "C2_CORE") call BIS_fnc_getCfgIsClass) then {		
	_modList = composeText [_modList, lineBreak, "C2 - Command And Control"];
};
if (!(_modList isEqualType "") || !(_warningList isEqualType "")) then {
	_text = composeText ["Warning!", lineBreak, "Данные моды могут привести к ошибкам в миссии:", lineBreak, _modList, _warningList];
	((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
	[] spawn {
		disableSerialization;
		{
			_x ctrlSetFade 0;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
		{
			_x ctrlCommit 0.2;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
	};
};

menuComplete = true;