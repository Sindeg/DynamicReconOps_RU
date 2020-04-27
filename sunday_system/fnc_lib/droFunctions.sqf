dro_checkAOIndexes = {
	params ["_indexes"];
	_availableIndexes = [];
	{
		if (count (((AOLocations select _AOIndex) select 2) select _x) > 0) then {_availableIndexes pushBack _x};
	} forEach _indexes;	
	_availableIndexes
};

dro_civDeathHandler = {
	params ["_unit"];
	_index = _unit addMPEventHandler ["mpkilled", {
		if (group (_this select 1) == (grpNetId call BIS_fnc_groupFromNetId)) then {
			if (isServer) then {
				if (isNil "civDeathCounter") then {
					civDeathCounter = 1;
					publicVariable "civDeathCounter";			
					_text = format["%1 ответственный за жертвы среди гражданского населения. Командование не расчитывает на подобное, недопустимо чтобы гражданские лица попадали на линию огня.", name ((_this select 0) select 1)];
					//["Command", _text] spawn BIS_fnc_showSubtitle;
					//[] spawn sun_playSubtitleRadio;				
					dro_messageStack pushBack [[["Командование", _text, 0]], true];
				} else {
					civDeathCounter = civDeathCounter + 1;
					publicVariable "civDeathCounter";			
					switch (civDeathCounter) do {
						case 0: {};
						case 1: {
							[_this] spawn {
								sleep 2;							
								_text = format["%1 ответственный за жертвы среди гражданского населения. Командование не расчитывает на подобное, недопустимо чтобы гражданские лица попадали на линию огня.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Командование", _text, 0]], true];
							};
						};
						case 2: {
							[_this] spawn {
								sleep 2;
								_text = format["%1 причастен к жертвам среди гражданского населения. Это ваше второе предупреждение! Если вы не можете выполнить свои цели, не избежав жертв среди гражданского населения, вас отзовут.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Командование", _text, 0]], true];
							};
						};
						case 3: {
							[_this] spawn {
								sleep 2;
								_text = format["Ваша команда несет ответственность за чрезмерные жертвы среди гражданского населения!", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Командование", _text, 0]], true];
								//if (player == leader group player) then {
									{
										[_x, 'FAILED', true] spawn BIS_fnc_taskSetState;
									} forEach taskIDs;
								//};
							};
						};
						case 4: {
							[_this] spawn {
								sleep 2;
								//[] execVM "sunday_system\endMission.sqf";
								
								[["", "BLACK OUT", 5]] remoteExec ["cutText", 0];
								[5, 0] remoteExec ["fadeSound", 0];
								[5, 0] remoteExec ["fadeSpeech", 0];
								sleep 5;
								if (isMultiplayer) then {
									'DROEnd_FailCiv2' call BIS_fnc_endMissionServer;
								} else {
									'DROEnd_FailCiv2' call BIS_fnc_endMission;
								};
								
							};
						};
						default {
							[_this] spawn {
								_text = format["%1 ответственный за жертвы среди гражданского населения. Командование не расчитывает на подобное, недопустимо чтобы гражданские лица попадали на линию огня.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Command", _text, 0]], true];
							};
						};
					};
				};
			};
		};
	}]; 
};

dro_addConstructPoint = {
	params ["_pos", "_objType", "_dir", ["_posDistShift", 0]];		
	
	_useLib = if (_posDistShift == 0) then {false} else {true};
	_pos = _pos getPos [_posDistShift, _dir];
	_box = createVehicle [(selectRandom ["Land_WoodenCrate_01_F", "Land_WoodenCrate_01_stack_x3_F"]), _pos, [], 0, "CAN_COLLIDE"];
	_box setDir (random 360);
	[
		_box,
		"Построить баррикаду",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"((_this distance _target) < 4)",
		"true",
		{},
		{
			// Progress
			/*
			if ((_this select 4) % 3 == 0) then {			
				_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
				playSound3D [_sound, (_this select 1)];				
			};
			*/
		},
		{
			// Completed
			// Remove helper
			deleteVehicle (_this select 0);			
			// Create object
			if ((_this select 3) select 3) then {				
				_objList = (selectRandom compositionsBunkerCorners);				
				_removeElements = [];
				{
					if ((_x select 0) == "Sign_Arrow_Blue_F") then {
						_removeElements pushBack _x;
					};
				} forEach (_objList);
				_objList = _objList - _removeElements;
				_spawnedObjects = [((_this select 3) select 1), ((_this select 3) select 2), _objList] call BIS_fnc_ObjectsMapper;
			} else {
				_objList = ((_this select 3) select 0);
				_pos = ((_this select 3) select 1);
				_dir = ((_this select 3) select 2);
				if (_objList isEqualType []) then {
					
					_distShift = -2;
					{					
						_spawnPos = _pos getPos [_distShift, _dir - 90];
						_spawnPos set [2, 0];			
						_obj = createVehicle [_x, _spawnPos, [], 0, "CAN_COLLIDE"];					
						_obj setDir _dir;					
						_distShift = _distShift + 2;
					} forEach _objList;				
				} else {				
					_pos set [2, 0];			
					_obj = createVehicle [_objList, _pos, [], 0, "CAN_COLLIDE"];
					_obj setDir _dir;
				};
			};
		},
		{
			// Interrupted			
		},
		[_objType, _pos, _dir, _useLib],
		5,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	_box
};

dro_addConstructAction = {
	params ["_obj", "_objsToDelete", "_createPos", "_createDir", "_taskName"];		
	[
		_obj,
		"Построить баррикаду",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"((_this distance _target) < 4)",
		"true",
		{},
		{
			// Progress
			if ((_this select 4) % 4 == 0) then {			
				_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
				playSound3D [_sound, (_this select 1)];
				if (count (((_this select 3) select 0) select {!isObjectHidden _x}) > 0) then {
					(selectRandom (((_this select 3) select 0) select {!isObjectHidden _x})) hideObjectGlobal true;
				};
			};
		},
		{
			// Completed
			// Remove barricade components			
			{deleteVehicle _x} forEach (((_this select 3) select 0) + [_this select 0]);
			
			// Create barricade
			_objects = selectRandom compositionsConstructs;
			_spawnedObjects = [((_this select 3) select 1), ((_this select 3) select 2), _objects] call BIS_fnc_ObjectsMapper;
			
			// Complete the task
			if ([((_this select 3) select 3)] call BIS_fnc_taskExists) then {
				_taskState = [((_this select 3) select 3)] call BIS_fnc_taskState;				
				if !(_taskState isEqualTo "SUCCEEDED") then {
					[((_this select 3) select 3), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;					
				};
			};
			missionNamespace setVariable [format ['%1Completed', ((_this select 3) select 0)], 1, true];
		},
		{
			// Interrupted
			{
				_x hideObjectGlobal false;
			} forEach ((_this select 3) select 0);
		},
		[_objsToDelete, _createPos, _createDir, _taskName],
		20,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];	
};


dro_sendProgressMessage = {
	params ["_message", ["_sender", "Command"], ["_data", []], ["_playAudio", true]];	
	//sleep (random [1, 2, 1.5]);
	/*
	if (!isNil "bis_fnc_showsubtitle_subtitle") then {
		waitUntil {sleep (random [2, 3, 2.5]); isNull bis_fnc_showsubtitle_subtitle};
	};
	*/
	if (typeName _sender == "OBJECT") then {
		_sender = name _sender;
	};
	switch (_message) do {
		case "HOSTILECIVS": {
			dro_messageStack pushBack [
				[
					[_sender, "Напоминаем вам, что часть гражданского населения может враждебно отреагировать на ваше присутствие. Двигайтесь осторожно и оцените любой контакт как потенциальную угрозу.", 0],
					[_sender, "Даже если вы попадаете в ситуацию с неопределенными целями, не стреляйте, пока не увидите явных признаков враждебного намерения. Жертвы среди гражданского населения по-прежнему считаются неприемлемыми.", 10]
				],
				_playAudio
			];			
		};
		case "AMBUSH": {
			dro_messageStack pushBack [
				[
					[_sender, "Это командование, похоже, что ваши действия были замечены, мы обнаружили новых врагов, двигающихся прямо к вам.", 0],
					[_sender, "Найдите укрытие, удерживайте и защищайте свою позицию", 7]
				],
				_playAudio
			];				
		};
		case "AMBUSHOP": {
			dro_messageStack pushBack [
				[
					[_sender, "Это командование, мы наблюдаем приближающихся врагов на вашу позицию.", 0],
					[_sender, "Займите позиции и удерживайте точку.", 7]
				],
				_playAudio
			];			
		};
		case "AMBUSHCIV": {	
			dro_messageStack pushBack [
				[
					[_sender, (format ["Как мы и ожидали, силы противника сейчас движутся к вашей позиции.", (_data select 0)]), 0],
					[_sender, (format ["Укрепитесь и защищайте %1!", (_data select 0)]), 7]
				],
				_playAudio
			];			
		};
		case "PROTECT_CIV_MEET": {
			dro_messageStack pushBack [
				[
					[_sender, (format ["Вы %1? Мы знаем об угрозе вашей жизни, и мы здесь, чтобы защитить вас.", (_data select 0)]), 0],
					[_sender, (format ["Следуйте за нами, а мы сделаем всё остальное.", (_data select 0)]), 7]
				],
				_playAudio
			];				
		};
		case "PROTECT_CIV_CLEAR": {	
			dro_messageStack pushBack [
				[
					[_sender, (format ["Это должно быть последний из них, я предлагаю покинуть район как можно скорее.", (_data select 0)]), 0],
					[(_data select 0), (format ["Слава Богу, что вы приехали. Не волнуйтесь, я не собираюсь торчать здесь.", (_data select 0)]), 7]				
				],
				_playAudio
			];					
		};
		case "BRIEFING": {	
			_greeting = (format ["Добрый день %1, это Главное управление.", playerCallsign]);
			_hour = (date select 3);
			if (_hour >= 0 && _hour < 8) then {
				_greeting = (format ["Утро доброе %1, это Главное управление.", playerCallsign]);
			} else {
				if (_hour >= 8 && _hour < 18) then {
					_greeting = (format ["Добрый день %1, это Главное управление.", playerCallsign]);
				} else {
					if (_hour >= 18) then {
						_greeting = (format ["Добрый вечер %1, это Главное управление.", playerCallsign]);
					};
				};
			};
			_sendOff = selectRandom [
				format ["Удачи, будьте бдительны, и давайте обеспечим успешное выполнение %1.", (missionNameSpace getVariable ["mName", "the operation"])],
				format ["%1 будет важной миссией для нас, мы надеемся на успешное выполнение. Удачи.", (missionNameSpace getVariable ["mName", "the operation"])],
				format ["Будьте наготове. Мы не хотим допустить ошибок сегодня.", (missionNameSpace getVariable ["mName", "the operation"])]
			];
			dro_messageStack pushBack [
				[
					[_sender, _greeting, 0],
					[_sender, "Мы подготовили полный инструктаж, который доступен в ваших заметках.", 6],
					[_sender, _sendOff, 14]
				],
				_playAudio
			];
		};
		case "TASK_SUCCEED": {
			diag_log "DRO: TASK_SUCCEED called";
			if (({_x call BIS_fnc_taskCompleted} count taskIDs) < (count taskIDs)) then {				
				_phrases = if (isNil "oneTaskCompleted") then {
					oneTaskCompleted = true;
					[(format ["Хорошая работа %1, двигайтесь в том же темпе.", playerCallsign]), "Хорошая работа. Продолжайте в том же духе.", (format ["Хорошая работа %1, сохраняйте темп и давайте закончим это.", playerCallsign])];				
				} else {
					if (oneTaskCompleted) then {
						[(format ["Еще одна цель, %1. Вы хорошо справляетесь.", playerCallsign]), (format ["Отличная работа, %1. Вы хорошо справляетесь.", playerCallsign]), (format ["Отлично %1.", playerCallsign]), (format ["Хорошая работа %1, сохраняйте темп и давайте закончим работу", playerCallsign])];
					};
				};
				dro_messageStack pushBack [
					[
						[_sender, (selectRandom _phrases), 0]			
					],
					_playAudio
				];
			};		
		};
		case "REACTIVE_TASK": {	
			dro_messageStack pushBack [
				[
					[_sender, (_data select 0), 0]			
				],
				_playAudio
			];			
		};
		case "FRIENDLY_START": {
			_phrase = selectRandom [
				(format ["%1, это %2. Мы начинаем движение.", playerCallsign, _sender]),
				(format ["%1, %2 здесь. Мы готовимся начать наш штурм.", playerCallsign, _sender]),
				(format ["%1, мы начинаем движение к нашей цели. Увидимся на месте.", playerCallsign])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]			
				],
				_playAudio
			];
		};
		case "REVEAL_INTEL": {			
			if (count (_data select 1) > 0) then {
				dro_messageStack pushBack [
					[
						[_sender, (_data select 0), 0],
						[_sender, (_data select 1), 6]		
					],
					_playAudio
				];				
			} else {
				dro_messageStack pushBack [
					[
						[_sender, (_data select 0), 0]		
					],
					_playAudio
				];				
			};			
		};		
		case "END_LEAVE": {			
			_phrase = selectRandom [
				(format ["Хорошо %1, время выбираться.", playerCallsign]),
				(format ["Это всё, %1. Пора уходить.", playerCallsign])				
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RTB": {			
			_phrase = selectRandom [
				(format ["Хорошо %1, вернитесь к %2.", playerCallsign, markerText "campMkr"]),
				(format ["Это всё, %1, возвращайтесь к %2 прямо сейчас.", playerCallsign, markerText "campMkr"])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RENDEZVOUS": {			
			_phrase = selectRandom [
				(format ["Хорошо %1, вам необходимо встретиться с %2, а затем покинуть зону операции.", playerCallsign, groupId friendlySquad]),
				(format ["На этом всё, %1, вам необходимо встретиться с %2 до того, как вы покинете зону операции.", playerCallsign, groupId friendlySquad])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RENDEZVOUS_FAIL": {			
			_phrase = selectRandom [
				(format ["Мы потеряли контакт с %1! Вам необходимо покинуть зону операции, а затем мы оправим спецгруппу для их поиска.", groupId friendlySquad])				
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];			
		};
		case "END_HOLD": {			
			_phrase = selectRandom [
				(format ["%1, нам нужно, чтобы вы захватили и удерживали %2. Все отряды уже начали выдвигаться туда.", playerCallsign, (text (holdAO select 5))]),
				(format ["Задача выполнена %1. Теперь ваша задача помочь в штурме и удержании %2. Все отряды уже в пути, чтобы зачистить территорию.", playerCallsign, (text (holdAO select 5))])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0],		
					[_sender, "Однако, если вы не способны поддержать штурм, отступайте и покиньте зону спецоперации.", 8]	
				],
				_playAudio
			];			
		};
		case "OBSERVE_SUCCEED": {			
			_phrase = selectRandom [
				(format ["Хорошая работа %1, %2", playerCallsign, (_data select 0)]),
				(format ["Отличная разведка %1, %2", playerCallsign, (_data select 0)]),
				(format ["Отличная работа %1, %2", playerCallsign, (_data select 0)])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];			
		};
	};	
};

dro_addSabotageAction = {
	params ["_objects", ["_taskName", ""]];
	if (typeName _objects == "OBJECT") then {		
		_objects = [_objects];		
	};
	{
		_x setVariable ['sabotaged', false, true];
	} forEach _objects;
	if (count _taskName == 0) then {
		_taskName = (_objects select 0) getVariable "thisTask";
	};
	{
		[
			_x,
			"Саботаж",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"(alive _target) && !(_target getVariable ['sabotaged', false]) && ((_this distance _target) < 4) && ('ToolKit' in (items _this + assignedItems _this))",
			"true",
			{},
			{
				if ((_this select 4) % 3 == 0) then {			
					_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
					playSound3D [_sound, (_this select 1)];
					//(selectRandom ["FD_Skeet_Launch1_F", "FD_Skeet_Launch2_F"]) remoteExec ["playSound", (_this select 1)];
				};
			},
			{
				// Sabotage this object
				((_this select 0) setVariable ['sabotaged', true, true]);				
				(_this select 0) removeAllEventHandlers "Explosion";
				(_this select 0) removeAllEventHandlers "Killed";
				[(_this select 0), "ALL"] remoteExec ["disableAI", (_this select 0), true];
				[(_this select 0), "LOCKED"] remoteExec ["setVehicleLock", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllItems", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllWeapons", (_this select 0), true];
				{[(_this select 0), _x] remoteExec ["removeMagazine", (_this select 0), true]} forEach magazines (_this select 0);
				// Check for any other objects that might need sabotaging for task completion
				_complete = true;
				{	
					
					if !(_x getVariable ['sabotaged', false]) then {
						_complete = false;
					};
				} forEach ((_this select 3) select 0);
				// If all are sabotaged then complete the task				
				if (_complete) then {					
					if ([((_this select 3) select 1)] call BIS_fnc_taskExists) then {
						_taskState = [((_this select 3) select 1)] call BIS_fnc_taskState;				
						if !(_taskState isEqualTo "SUCCEEDED") then {
							[((_this select 3) select 1), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;							
						};
					};
					missionNamespace setVariable [format ['%1Completed', ((_this select 3) select 0)], 1, true];					
				};				
			},
			{},
			[_objects, _taskName],
			10,
			10,
			true,
			false
		] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	} forEach _objects;
};


dro_missionName = {
	_missionNameType = selectRandom ["OneWord", "DoubleWord", "TwoWords"];
	_taskBasedList = [];
	{
		_title = (((_x call BIS_fnc_taskDescription) select 1) select 0);
		if ((["hvt", _title, false] call BIS_fnc_inString)) then {
			_taskBasedList = ["Priest", "Ghost", "King", "Duke", "Baron", "Viper", "Snake", "Lion", "Tiger", "Bishop", "Apollo", "Jupiter", "Poseidon", "Odin", "Valhalla", "Anubis", "Osiris", "Reaper", "Ahriman", "Malsumis"];
		} else {
			if ((["cache", _title, false] call BIS_fnc_inString)) then {
				_taskBasedList = ["Pillar", "Hoard", "Nest", "Trove", "Gold", "Fortune", "Emerald", "Opal", "Iron", "Steel", "Pearl", "Oyster", "Fountain", "Egg"];
			} else {
				if ((["intel", _title, false] call BIS_fnc_inString)) then {
					_taskBasedList = ["Scribe", "Papyrus", "Tome", "Mind", "Book", "Codex", "Atlas", "Scroll", "Source", "Abacus", "Mentor", "Oracle", "Sphinx"];
				} else {
					if ((["helicopter", _title, false] call BIS_fnc_inString)) then {
						_taskBasedList = ["Falcon", "Pheasant", "Goose", "Grouse", "Buzzard", "Albatross", "Condor", "Turkey", "Pelican", "Gnat", "Moth"];
					} else {
						if ((["artillery", _title, false] call BIS_fnc_inString) || (["destroy aa", _title, false] call BIS_fnc_inString)) then {
							_taskBasedList = ["Hammer", "Maul", "Lance", "Grip", "Drill"];
						} else {
							if ((["captive", _title, false] call BIS_fnc_inString)) then {
								_taskBasedList = ["Lamb", "Artemis", "Hermes", "Exodus", "Cage", "Bond", "Lock", "Leash", "Shackle", "Tether", "Snare", "Diplomat"];
							} else {
								if ((["observe", _title, false] call BIS_fnc_inString)) then {
									_taskBasedList = ["Vigil", "Lens", "Tower", "Hunter", "Night", "Archer", "Track", "Seer", "Eye", "Spy"];
								};
							};
						};
					};
				};
			};			
		};		
	} forEach taskIDs;
	
	_missionName = switch (_missionNameType) do {
		case "OneWord": {
			_nameArray = if (count _taskBasedList > 0) then {
				_taskBasedList				
			} else {
				["Garrotte", "Castle", "Tower", "Sword", "Moat", "Traveller", "Headwind", "Fountain", "Taskmaster", "Tulip", "Carnation", "Gaunt", "Goshawk", "Jasper", "Flashbulb", "Banker", "Piano", "Rook", "Knight", "Bishop", "Pyrite", "Granite", "Hearth", "Staircase"];
			};			
			format ["Операция %1", selectRandom _nameArray];
		};
		case "DoubleWord": {
			_name1Array = ["Dust", "Swamp", "Red", "Green", "Black", "Gold", "Silver", "Lion", "Bear", "Dog", "Tiger", "Eagle", "Fox", "North", "Moon", "Watch", "Under", "Key", "Court", "Palm", "Fire", "Fast", "Light", "Blind", "Spite", "Smoke", "Castle"];
			_name2Array = ["bowl", "catcher", "fisher", "claw", "house", "master", "man", "fly", "market", "cap", "wind", "break", "cut", "tree", "woods", "fall", "force", "storm", "blade", "knife", "cut", "cutter", "taker", "torch"];
			format ["Операция %1%2", selectRandom _name1Array, selectRandom _name2Array];
		};
		case "TwoWords": {		
			_name1Array = ["Awoken", "Warning", "Wakeful", "Bonded", "Sweeping", "Watching", "Bladed", "Crushing", "Arcane", "Midnight", "Fallen", "Turbulent", "Nesting", "Daunting", "Dogged", "Darkened", "Shallow", "Blank", "Absent", "Parallel", "Restless"];					
			_name2Array = if (count _taskBasedList > 0) then {
				_taskBasedList
			} else {
				["Sky", "Moon", "Sun", "Hand", "Monk", "Priest", "Viper", "Snake", "Boon", "Cannon", "Market", "Rook", "Knight", "Bishop", "Command", "Mirror", "Spider", "Charter", "Court", "Hearth"]
			};		
			format ["Операция %1 %2", selectRandom _name1Array, selectRandom _name2Array];
		};
	};
	_missionName
};

sun_addIntel = {
	 _intelObject = _this select 0;
	 _taskName = _this select 1;
	 _intelObject setVariable ["task", _taskName];	
	
	[_intelObject,
		["Подобрать разведданные",
		{
			[_this select 3, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", (_this select 3)], 1, true];
			deleteVehicle (_this select 0);
			[5, false, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";			
		},
		_taskName,
		6,
		true,
		true,
		"",
		"true",
		5
	]] remoteExec ['addAction', 0, true];
	// _intelObject = _this select 0;
	// _taskName = _this select 1;
	// _intelObject setVariable ["task", _taskName];	
	// _intelObject addAction [
		// "Collect Intel",
		// {
			// [_this select 3, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			// missionNamespace setVariable [format ["%1Completed", (_this select 3)], 1, true];
			// deleteVehicle (_this select 0);
			// [5, false, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";			
		// },
		// _taskName,
		// 6,
		// true,
		// true,
		// "",
		// "true",
		// 5
	// ];	
};

dro_initLobbyCam = {
	private ["_playerPos", "_camLobbyStartPos", "_camLobbyEndPos"];
	_playerPos = [((getPos player) select 0), ((getPos player) select 1), (((getPos player) select 2)+1.2)];
	_camLobbyStartPos = [(getPos player), 5, (getDir player)-35] call dro_extendPos;
	_camLobbyStartPos = [(_camLobbyStartPos select 0), (_camLobbyStartPos select 1), (_camLobbyStartPos select 2)+1];
	camLobby = "camera" camCreate _camLobbyStartPos;
	camLobby cameraEffect ["internal", "BACK"];
	camLobby camSetPos _camLobbyStartPos;
	camLobby camSetTarget _playerPos;
	camLobby camCommit 0;
	cameraEffectEnableHUD false;
	_camLobbyEndPos = [(getPos player), 5, (getDir player)+35] call dro_extendPos;
	_camLobbyEndPos = [(_camLobbyEndPos select 0), (_camLobbyEndPos select 1), (_camLobbyEndPos select 2)+1];
	camLobby camPreparePos _camLobbyEndPos;
	camLobby camPrepareTarget _playerPos;
	camLobby camCommitPrepared 120;
};

dro_hvtCapture = {
	params ["_hostage", "_player"];		
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'captureTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 1;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'captureTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
};

dro_hostageRelease = {
	params ["_hostage", "_player"];	
	_hostage setVariable ["hostageBound", false, true];
	[_hostage, "Acts_AidlPsitMstpSsurWnonDnon_out"] remoteExec ["playMoveNow", 0]; 
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'joinTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 1;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'joinTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
	//missionNamespace setVariable [format ['%1Completed', ((_this select 0) getVariable 'taskName')], 1, true];	
};

dro_detectPosMP = {
	private ["_taskName", "_taskPosFake"];
	_taskName = _this select 0;
	_taskPosFake = _this select 1;		
	if (alive player) then {
		if ((((vehicle player) distance _taskPosFake) < 1000) || (((getConnectedUAV player) distance _taskPosFake) < 1000)) then {			
			_aimedPos = screenToWorld [0.5, 0.5];
			if ((_aimedPos distance _taskPosFake) < 100) then {				
				_inspTime = (missionNamespace getVariable _taskName);
				_inspTime = _inspTime + 1;
				["DRO: Received an observe hit on %1(%3) by player %2, setting to %4", _taskName, player, (missionNamespace getVariable _taskName), _inspTime] call bis_fnc_logFormatServer;
				missionNamespace setVariable [_taskName, _inspTime, true];
			};
		};
	};
};

fnc_deleteVehicle = 
{
    private _vehicle = (_this select 0);
    private _uidPlay = (_this select 1);
	
	deleteVehicle _vehicle;
};

fnc_TFARjamRadios = 
{
	/* 
	Параметры
	0 - Массив объектов, подавляющих радиосообщения вокруг.
	1 - (Необязательный, 1000) - радиус действия объектов, подавляющих радиосообщения.
	2 - (Необязательный, 50) - сила объектов, подавляющих радиосообщения вокруг.
	4 - Отладка

	radioJammer = [[radio1], 1000, 50, TRUE] execVM "scripts\TFARjamRadios.sqf"; 
	*/
	if (!hasInterface) exitwith {};
	waituntil {!isnull player};
	
	_jammers = param [0, [objNull], [[objNull]]];
	_rad = param [1, 1000, [0]];
	_strength = param [2, 50, [0]] - 1;
	_debug = param [3, false, [true]];

	_radB = 300; // Радиус полной блокировки радисообщений

	//Ближайший объект
	_jammerDist = {
		_jammer = objNull;
		_closestDist = 1000000;
		{
			if (_x distance player < _closestdist) then {
				_jammer = _x;
				_closestDist = _x distance player;
			};
		} foreach _jammers;
		_jammer;
	};
	_jammer = call _jammerDist;

	while {alive _jammer} do
	{
		// Set variables
		_dist = player distance _jammer;
		
		 _distPercent = _dist / _rad;
		_interference = 1;
		_sendInterference = 1;

		if (_dist < _rad) then {
			_interference = _strength - (_distPercent * _strength) + 1;
			_sendInterference = 1/_interference; 
		};
		
		if (_dist < 150) then {
			player setVariable ["tf_receivingDistanceMultiplicator", 1000];
			player setVariable ["tf_sendingDistanceMultiplicator", 1/1000];
		}
		else
		{
			player setVariable ["tf_receivingDistanceMultiplicator", _interference];
			player setVariable ["tf_sendingDistanceMultiplicator", _sendInterference];
		};
		
		
		if (_debug) then {
			deletemarkerLocal "CIS_DebugMarker";
			//deletemarkerLocal "CIS_DebugMarker2";
			
			_debugMarker = createmarkerLocal ["CIS_DebugMarker", position _jammer];
			_debugMarker setMarkerShapeLocal "ELLIPSE";
			_debugMarker setMarkerSizeLocal [_rad, _rad];
			
			//_debugMarker2 = createmarkerLocal ["CIS_DebugMarker2", position _jammer];
			//_debugMarker2 setMarkerShapeLocal "ICON";
			//_debugMarker2 setMarkerTypeLocal "mil_dot";
			//_debugMarker2 setMarkerTextLocal format ["%1", _jammer];
				
			systemChat format ["Ближайшая вышка. Расстояние: %1, Процент дистанции %2, Помехи: %3, Помехи отправления: %4", _dist,  100 * _distPercent, _interference, _sendInterference];
			systemChat format ["Активные: %1, Список всех: %2",_jammer, _jammers];
		};
		sleep 7.0;
		
		if (count _jammers > 1) then {
			{
				if (!alive _x AND count _jammers > 1) then {_jammers = _jammers - [_x]};
			} foreach _jammers;
			
			_jammer = call _jammerDist;
		};
	};

	// Установка значений в изначальное положение
	player setVariable ["tf_receivingDistanceMultiplicator", 1];
	player setVariable ["tf_sendingDistanceMultiplicator", 1];
};