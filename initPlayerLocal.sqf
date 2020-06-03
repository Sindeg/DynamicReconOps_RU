_rscLayer = ["RscLogo"] call BIS_fnc_rscLayer;
_rscLayer cutRsc ["DRO_Splash", "PLAIN", 0, true];

diag_log format ["DRO: Player %1 waiting for player init", player];
waitUntil {!isNull player};

#include "sunday_system\fnc_lib\sundayFunctions.sqf";
#include "sunday_system\fnc_lib\droFunctions.sqf";
#include "sunday_revive\reviveFunctions.sqf";
#include "sunday_system\fnc_lib\menuFunctions.sqf";

addWeaponItemEverywhere = compileFinal " _this select 0 addPrimaryWeaponItem (_this select 1); ";
addHandgunItemEverywhere = compileFinal " _this select 0 addHandgunItem (_this select 1); ";
//removeWeaponItemEverywhere = compileFinal "_this select 0 removePrimaryWeaponItem (_this select 1)";

if (!hasInterface || isDedicated) exitWith {};

player setVariable ['startReady', false, true];
playerCameraView = cameraView;
loadoutSavingStarted = false;

fnc_missionText = {
	// Mission info readout
	_campName = (missionNameSpace getVariable "publicCampName");
	diag_log format ["DRO: Player %1 establishing shot initialised", player];
	sleep 3;
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", toUpper _campName], true, nil, 5, 0.7, 0] spawn BIS_fnc_textTiles;
	sleep 6;
	_hours = "";
	if ((date select 3) < 10) then {
		_hours = format ["0%1", (date select 3)];
	} else {
		_hours = str (date select 3);
	};
	_minutes = "";
	if ((date select 4) < 10) then {
		_minutes = format ["0%1", (date select 4)];
	} else {
		_minutes = str (date select 4);
	};
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1  %2</t>", str(date select 1) + "." + str(date select 2) + "." + str(date select 0), _hours + _minutes + " HOURS"], true, nil, 5, 0.7, 0] spawn BIS_fnc_textTiles;
	sleep 6;
	// Operation title text
	_missionName = missionNameSpace getVariable ["mName", ""];
	_string = format ["<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", _missionName];
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", toUpper _missionName], true, nil, 7, 0.7, 0] spawn BIS_fnc_textTiles;
};

fnc_addAction_AirportTp = {
	arsenalbox addAction ["<t size='1.2' color='#E39325'>Переместиться в аэропорт</t>", {
	if (isNil "airHelipad" || {isNull airHelipad }) then 
	{
		hint "Командир не назначил расположение аэропорта."
	}
	else {
		3 fadeSound 0;
		cutText["Перемещение в аэропорт...","BLACK OUT",3];
		sleep 6;
		player setpos getpos airportPos;
		player setdir 280;
		cutText["","BLACK IN",5]; 
		2 fadeSound 1;
	};
	},[],1.5, true, true, "","player distance arsenalBox < 6", 0,false,"",""];
};

fnc_playerSetup = 
{
	// Удаление мертвых тех
	_respawnType = "RespawnPositions" call BIS_fnc_getParamValue;
	// if (_respawnType == 2) then {
		// player addMPEventHandler ['MPKilled', {
			// params ["_unit", "_killer", "_instigator", "_useEffects"]; 
			// _unit spawn { 
				// sleep 3;
				// if (!isNull _unit) then {
					// deleteVehicle _unit;
					// systemchat "body deleted";
				// };
				
				// systemchat "end";
			// } 
		// }
		// ];
	// };
	sleep 1;
	// Отключение каналов в игре
	1 enableChannel false;
	2 enableChannel false;
	4 enableChannel false;
	
	enableTeamSwitch false;
	0 fadeRadio 0;
	enableRadio false;
	enableSentences false;
	
	_playerRole = roleDescription player;
	
	// Специализация по ролям
	_roleOn = "role_specialization" call BIS_fnc_getParamValue;
	if (_roleOn == 1) then
	{
		// Изначально у всех нет специальностей
		player setVariable ["ACE_IsEngineer", 0, true];
		player setVariable ["ace_medical_medicclass", 0, true];
		
		_playerRole = roleDescription player;
		
		switch (_playerRole) do
		{
			case "Медик": 
			{
				player setVariable ["ace_medical_medicclass", 2, true];
				hint parsetext format ["<t size='1.2'>Ваша специальность - <t color='#FA4F00'>медик.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно переливание крови другим бойцам, использование хирургического набора, аптечек и дефибриллятора.<br/><br/>Аптечки находятся в <t color='#EEB70D'>снаряжении арсенала.</t></t>"];
			}; 
			case "Инженер": 
			{
				player setVariable ["ACE_IsEngineer", 2, true];
				hint parsetext format ["<t size='1.2'>Ваша специальность - <t color='#3855d6'>инженер.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно использование набора для инструментов.</t>"];
			}; 
			case "ПТ специалист": 
			{
				hint parsetext format ["<t size='1.1'>Ваша специальность - <t color='#08ff77'>ПТ специалист.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно использование любых ПТ гранатомётов.</t>"];
			}; 
			case "ПВО специалист": 
			{
				hint parsetext format ["<t size='1'>Ваша специальность - <t color='#fff705'>ПВО специалист.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно использование ПЗРК.</t>"];
			}; 
			case "[Штаб] Офицер": 
			{
				hint parsetext format ["<t size='1.2'>Ваша специальность - <t color='#FA4F00'>медик.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно переливание крови другим бойцам, использование хирургического набора, аптечек и дефибриллятора.<br/><br/>Аптечки находятся в <t color='#EEB70D'>снаряжении арсенала.</t></t>"];
				player setVariable ["ace_medical_medicclass", 2, true];
				[] call fnc_addAction_AirportTp;
			}; 
			case "[Штаб] Командир взвода": 
			{
				player setVariable ["ace_medical_medicclass", 2, true];
				//hint parsetext format ["<t size='1.2'>Ваша специальность - <t color='#FA4F00'>медик.</t></t><br/><br/><t align='center' t size='1.1'>Вам доступно переливание крови другим бойцам, использование хирургического набора, аптечек и дефибриллятора.<br/><br/>Аптечки находятся в <t color='#EEB70D'>снаряжении арсенала.</t></t>"];
				choiceAirport = arsenalBox addAction 
				[
					"<t size='1.2' color='#E39325'>Выбрать место аэропорта</t>", 
					"scripts\createAirport.sqf", 
					[],
					1.5, 
					true, 
					true, 
					"",
					"player distance arsenalBox < 8", // _target, _this, _originalTarget
					7,
					false,
					"",
					""
				];
				
				[] call fnc_addAction_AirportTp;
			};
			case "Пилот":
			{
				hint parsetext format ["<t size='1'>Ваша специальность - <t color='#0E86F7'>Пилот.</t></t><br/><br/><t align='center' t size='1.1'>Для перехода в аэропорт (если он установлен командиром) в меню действий, стоя рядом с арсеналом, выберите <t color = '#e6b53d'>Переместиться в аэропорт.</t></t>"];
				[] call fnc_addAction_AirportTp;
				player setVariable ["ACE_IsEngineer", 2, true];
			}
		};
		
		_nil = [] execVM "scripts\role_specialization.sqf";
		
	}
	else
	{
		player setVariable ["ACE_IsEngineer", 2, true];
		player setVariable ["ace_medical_medicclass", 2, true];
	};
	
	// Установка точек респавна для каждой роли
	_respawnType = "RespawnPositions" call BIS_fnc_getParamValue;
	if (_respawnType == 2) then {
		_playerRole = roleDescription player;
		switch (_playerRole) do
		{
			case "[Штаб] Офицер": 
			{
				[player, "respawnBase", "Штаб"] call BIS_fnc_addRespawnPosition;
			}; 
			case "Пилот":
			{
				[player, "respawnBase", "Штаб"] call BIS_fnc_addRespawnPosition;
			};
			default 
			{
				[player, "respawn", "Отряд"] call BIS_fnc_addRespawnPosition;
			};
		};
	};
	// 3д иконка арсенала
	addMissionEventHandler
	[
		"Draw3D",
		{
			if (player distance arsenalbox < 40) then {
				alphaText = linearConversion[5, 40, player distance arsenalbox, 1, 0, true];
				_pos = getPosWorld arsenalbox;
				drawIcon3D ['\A3\ui_f\data\IGUI\Cfg\Actions\takeFlag_ca.paa', [1, 0.615, 0.121, alphaText], [(_pos select 0),(_pos select 1), 2.5], 1, 1, 0, "Арсенал (зажать WIN)", 1, 0.0315, "PuristaSemibold"];
			};
		}	
	];
	
	// 3д икона стационарных орудий
	addMissionEventHandler
	[
		"Draw3D",
		{
			if (player distance repairBox < 40) then {
				alphaText = linearConversion[5, 40, player distance repairBox, 1, 0, true];
				_pos = getPosWorld repairBox;
				drawIcon3D ['\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\mortar_ca.paa', [0.05, 0.63, 0.99, alphaText], [(_pos select 0),(_pos select 1), 2.5], 1, 1, 0, "Станковое оружие", 1, 0.04, "PuristaSemibold"];
			};
		}	
	];
	
	// Отрисовка врача
	addMissionEventHandler
	[
		"Draw3D",
		{
			if (player distance baseMedic < 40) then {
				alphaText = linearConversion[5, 40, player distance baseMedic, 1, 0, true];
				_pos = getPosWorld baseMedic;
				drawIcon3D ['\A3\ui_f\data\igui\cfg\actions\heal_ca.paa', [0.89, 0.25, 0.25, alphaText], [(_pos select 0),(_pos select 1), 2.5], 1, 1, 0, "Врач", 1, 0.04, "PuristaSemibold"];
			};
		}	
	];
	
	// Арсенал техники
	addMissionEventHandler
	[
		"Draw3D",
		{
			if (player distance baseWorker < 80) then {
				alphaText = linearConversion[5, 80, player distance baseWorker, 1, 0, true];
				_pos = getPosWorld baseWorker;
				drawIcon3D ['\A3\ui_f\data\igui\cfg\mptable\soft_ca.paa', [0.80, 0.59, 0, alphaText], [(_pos select 0),(_pos select 1), 2.5], 1, 1, 0, "Арсенал техники", 1, 0.04, "PuristaSemibold"];
			};
		}	
	];
	
	player createDiarySubject ["Правила СЕРВЕРА", "Правила СЕРВЕРА"];
	player createDiaryRecord ["Правила СЕРВЕРА", ["Правила СЕРВЕРА", "
	При входе на сервер каждый игрок соглашается с данными правилами и обязуется им следовать.
	<br/><br/>
	Администрация оставляет за собой право после блокировки, не предоставлять игроку информации из серверных log файлов, доказательств нарушения в виде игровых скриншотов или видеозаписей.
	<br/><br/>
	ЗАПРЕЩЕНО:
	<br/><br/>
	1. ОБЩЕЕ
	<br/><br/>
	1.1 Оскорбление других игроков
	<br/><br/>
	1.2 Оскорбление администрации, поведение оскорбляющее администрацию или весь проект в целом,
	сознательное лже-обвинение администрации в нарушениях правил сервера, как в прямой, так и в завуалированной форме.
	<br/><br/>
	1.3 Игровые ники, шевроны содержащие не нормативную лексику или оскорбительные изображения.
	<br/><br/>
	1.4 Использование читерских программ, аддонов, скриптов и тд.
	<br/><br/>
	1.5 Реклама серверов, игр, режимов и тд.
	<br/><br/>
	1.6 Намеренная стрельба по союзникам
	<br/><br/>
	1.7 Стрельба, установка мин и др. вредительство на базе
	<br/><br/>
	1.8 Флудить, шутки шутить, обсуждать не игровую обстановку, сообщать бесполезную информацию, засорять эфир КВ 150 и ДВ 50 раций(в игре на сервере).
	<br/><br/>
	<br/>
	2. ВО ВРЕМЯ ОРГАНИЗОВАННОЙ ИГРЫ
	<br/><br/>
	2.1 Изменять своё местоположения без приказа командира.
	<br/><br/>
	2.2 Экипировать обмундирование не соответствующее цвету указанному командиром.
	<br/><br/>
	2.3 Занимать/вызывать технику без приказа командира.
	<br/><br/>
	2.4 Занимать слот пилота без приказа командира.
	<br/><br/>
	2.5 Использовать игровой чат для переговоров, координации, передачи боевой информации и тд.
	<br/><br/>
	2.6 Невыполнение приказов поставленных командиром.
	<br/><br/>
	2.7 Пререкаться и обсуждать приказы поставленные командиром.
	<br/><br/>
	2.8 Возрождаться без приказа командира.
	<br/><br/>
	<br/>
	Разъяснения:
	<br/><br/>
	3.1 Вся коммуникация осуществляются ТОЛЬКО по средствам КВ/ДВ раций, если ваш собеседник не может слышать вас из-за расстояния или рельефа это НЕ повод использовать чат.
	<br/><br/>
	3.2 ВСЕ игроки, не зависимо от типа игры должны находиться на обще-серверных частотах КВ 150, ДВ 50.
	<br/><br/>
	3.3 Игроки могут настроить себе ДОПОЛНИТЕЛЬНУЮ частоту и флудить там сколько им угодно.
	<br/><br/>
	3.4 Игроки более высокого звания имеют приоритет в занятии слотов.
	<br/><br/>
	3.5 Во время КОМАНДНОЙ игры игроки могут занимать любые слоты, следовать своей стратегии, вызывать любую технику.
	<br/><br/>
	3.6 Любой из игроков может осуществлять командование операцией с одобрения офицеров на сервере.
	<br/><br/>
	3.7 Офицеры не могут изменять режим уже идущей игры. Если миссия началась как командная - она должна закончиться командной, и наоборот. Офицеры могут сменить режим, уведомив всех игроков об этом до начала миссии.
	<br/><br/>
	Правила могут быть дополнены.
	"]];
	
	player createDiarySubject ["О миссии", "О миссии"];
	
	player createDiaryRecord ["О миссии", ["Советы",
	" - Если вы остались без техники, доберитесь до ближайшего города. Во всех населенных пунктах вы найдете гражданский транспорт.<br/>
	 - На метке <font color='#DEC034' size='14'>Снаряжение</font> можно найти медицину и другую амуницию.<br/>
	 - Разведданные, которые можно подобрать с убитых бойцов, служат для того, чтобы раскрывать на карте местоположения врага, а так же уменьшать область поиска объектов заданий. Отмеченная область для поиска объекта будет сужаться, а затем вовсе станет конкретной меткой (например, местоположение ПВО которое необходимо уничтожить).
	"]];
	
	player createDiaryRecord ["О миссии", ["Связь",
	"Связь в игре осуществляется только через TFAR рацию, поэтому всем игрокам, во время игры на сервере, необходимо зайти в TeamSpeak нашего сервера.<br/><br/>
	Используемая рация: <font color='#DEC034' size='14'>FADAK</font><br/><br/>
	Используемые частоты: КВ <font color='#DEC034' size='14'>150</font>, ДВ <font color='#DEC034' size='14'>50</font>.<br/><br/>
	Управление: <br/><br/>
	<font color='#67ED24'>Caps Lock</font>	-	Разговор по рации.<br/>
	<font color='#67ED24'>CTRL + Caps Lock</font>	-	Разговор по рации дальней связи.<br/>
	<font color='#67ED24'>CTRL + P</font>	-	Открыть интерфейс личной рации (рация должна быть в слоте инвентаря). В том случае, если у вас имеются несколько раций - вы сможете выбрать требуемую. Также есть возможность установить рацию как активную (ту, которая будет использоваться для передачи.<br/>
	<font color='#67ED24'>NUM[1-8]</font>	-	Быстрое переключение каналов коротковолновой рации.<br/>
	<font color='#67ED24'>ALT + P</font>	-	Открыть интерфейс рации дальней связи (рация дальней связи должна быть одета на спину, либо вы должны быть в технике за водителя, стрелка, командира или помощника пилота). Если доступно несколько рации - вам будет предложено выбрать. Также одну из них можно установить как активную.<br/>
	<font color='#67ED24'>CTRL + NUM[1-9]</font>	-	Быстрое переключение каналов рации дальней связи.<br/>
	<font color='#67ED24'>CTRL + TAB</font>	-	Изменить громкость прямой речи. Можно говорить шепотом , нормально и кричать. Не влияет на кромкость сигнала в радио передаче.<br/>
	<font color='#67ED24'>ESC</font>	-	Выход из интерфейса рации.<br/>
	"]];

	player createDiaryRecord ["О миссии", ["Штаб",
	"Находясь на базе, все действия, кроме открытия арсенала, осуществляются с помощью меню действий (колесо мыши).<br/><br/>
	В штабе находятся:<br/><br/>
	<font color='#DEC034' size='15'>Арсенал</font> - чтобы открыть арсенал подойдите к ящику в центре штаба, и смотря на него, зажмите клавишу <font color='#D8D4C1' size='14'>WIN</font> для открытия ACE меню<br/><br/>
	<font color='#DEC034' size='15'>Врач</font> - полностью восстанавливает ваше здоровье.<br/><br/>
	<font color='#DEC034' size='15'>Арсенал техники</font> - создание транспорта, включая вертолеты. Рядом с ним находится ящик, в котором вы можете взять запасные колеса / гусеницы (ACE меню).<br/><br/>
	В пределах штаба находится безопасная зона, внутри которой отключен урон.
	"]];

	player createDiaryRecord ["О миссии", ["Роли", 
	"В зависимости от выбранного слота (специализации) вам могут быть доступны следущее снаряжение и доступные действия:<br/><br/>
	<font color='#DA3B16' size='15'>[Штаб] Командир взвода</font> - обязятельный слот при старте игры. Выбирает местоположение операций, штаба и настраивает задания. Так же может указать расположение аэропорта, куда могут перемещаться пилоты (Для выбора используйте соответствующее действие стоя на базе у арсенала). Специальность - медик.<br/><br/>
	<font color='#DA3B16' size='15'>[Штаб] Офицер</font> - Инструктирует новоприбывших, находится в штабе для оказания помощи отряду. Может перемещаться в аэропорт для создания и управления БПЛА. Специальность - медик.<br/><br/>
	<font color='#2D88EF' size='15'>Инженер</font> - возможность ремонтировать технику с помощью набора инструментов.<br/><br/>
	<font color='#7FFF00' size='15'>ПТ специалист</font> - использование ПТ установок.<br/><br/>
	<font color='#FCFC0F' size='15'>ПВО специалист</font> - использование ПВО установок.<br/><br/>
	<font color='#DA3B16' size='15'>Медик</font> - использование аптечек, дефибрилляторов, пакетов крови и хирургических наборов. Аптечки находятся в снаряжении ящика с арсеналом.<br/><br/>
	<font color='#D8D4C1' size='15'>Пилот</font> - использование боевых вертолётов и самолётов (в случае, если командир выбрал местоположение аэропорта). Для перемещения в аэропорт выберите соответствующее действие стоя на базе у арсенала.<br/><br/>
	Если вы не находитесь на слоте ПТ специалиста, вам доступны только одноразовые пусковые установки (отстрелы).<br/><br/>
	Для простого опознавания специальности игрока на поле боя его ник выделяется цветом, соответствущим цвету, которым выделена специальность.
	"]];
	
	//Если создано задание с взрывом вышки связи, оповестить игроков о механике глушения рации
	if ((missionNameSpace getVariable ["JamTFARMessage", 0]) == 1) then
	{
		[] spawn 
		{
			waitUntil {player distance getpos arsenalbox > 150};
			_time = [6,15] call BIS_fnc_randomInt;
			sleep _time;
			hint parsetext format ["<t size = '1.5' color = '#EE3D0D'>Внимание<br/><t/><t color = 'FFFFFF'size = '1.2'>Противник применяет РЭБ, возможны проблемы в работе связи.<t/><t/>"];
		};
	};
	
	[player,["needMark",1,true]] remoteExec ['setVariable', player, TRUE]; // Отмечать игрока на карте
	
	arsenalbox addAction 
	[
		"<t size='1.2' color='#2099E7'>[Вкл/Выкл] свою метку на карте</t>", 
		{
			if (player getVariable "needMark" == 1) then 
			{
				[player,["needMark", 0, true]] remoteExec ['setVariable', player, TRUE]; 
				"Ваша метка на карте выключена." remoteExec ["hint", player];
			}
			else 
			{
				[player,["needMark", 1 ,true]] remoteExec ['setVariable', player, TRUE]; 
				"Ваша метка на карте включена." remoteExec ["hint", player];
			};
		},
		[],
		1.5, 
		true, 
		true, 
		"",
		"player distance arsenalBox < 6 && (getPlayerUID player == '76561198034679611' || getPlayerUID player == '76561198087792460')"
	];
	
	// Россия
	repairBox addAction
	[
		"<t color='#d96811'>Добавить 2В14-1 Поднос</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_Podnos_Bipod_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_Podnos_Gun_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить 9к115-2 Метис-М</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_Metis_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_Metis_Tripod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить 9к113 Корнет</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_Kornet_Tripod_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_Kornet_Gun_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить АГС-30</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_AGS30_Tripod_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_AGS30_Gun_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить ДШКМ</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_DShkM_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_DShkM_TripodHigh_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить КОРД</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_Kord_Tripod_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_Kord_Gun_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#d96811'>Добавить СПГ-9</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_SPG9_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_SPG9_Tripod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	// США #38a1f5
	repairBox addAction
	[
		"<t color='#38a1f5'>Добавить М2</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_M2_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_M2_Tripod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#38a1f5'>Добавить Мк19</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["RHS_Mk19_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["RHS_Mk19_Tripod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#38a1f5'>Добавить миномет М252</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["rhs_M252_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["rhs_M252_Bipod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#38a1f5'>Добавить TOW</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["rhs_Tow_Gun_Bag", 1]; repairBox addBackpackCargoGlobal ["rhs_TOW_Tripod_Bag", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	// Нейтральные #ccc58b
	repairBox addAction
	[
		"<t color='#ccc58b'>Добавить тяжелый пулемет М2 .50</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["I_E_HMG_02_support_high_F", 1]; repairBox addBackpackCargoGlobal ["I_E_HMG_02_high_weapon_F", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	repairBox addAction
	[
		"<t color='#ccc58b'>Добавить миномет mk6</t>",
		{hint "В снаряжение ящика была добавлена выбранная вами установка";clearItemCargoGlobal repairBox; clearMagazineCargoGlobal repairBox; clearWeaponCargoGlobal repairBox; clearBackpackCargoGlobal repairBox; repairBox addBackpackCargoGlobal ["I_Mortar_01_support_F", 1]; repairBox addBackpackCargoGlobal ["I_Mortar_01_weapon_F", 1];},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		5
	];
	
	systemchat("Загрузка завершена."); 
	systemchat("Совет: откройте карту и выберете раздел 'О миссии', чтобы получить справочную информацию.");
};

// Turn on menu music
0 fadeMusic 0;
playMusic "LeadTrack01_F_Jets";
5 fadeMusic 1;

player setVariable ["respawnLoadout", (getUnitLoadout player), true];
VAR_CAMERA_VIEW = playerCameraView;

diag_log format ["clientOwner = %1", clientOwner];
playerReady = 0;
enableTeamSwitch false;
enableSentences false;

// Move to mission area if JIP and do not process intro script
_doJIP = if (didJIP) then {
	if ((missionNameSpace getVariable ["lobbyComplete", 0]) == 0) then {
		false
	} else {
		true
	};	
} else {
	false
};

if (_doJIP) exitWith {
	["DRO: JIP detected for player %1", player] call bis_fnc_logFormat;
	//Position
	_pos = if (getMarkerColor "respawn" == "") then {
		getMarkerPos "campMkr"
	} else {
		getMarkerPos "respawn"
	};
	_pos set [2,0];
	// Loadout	
	_chosenSlotUnit = objNull;
	{
		if (!isPlayer _x) exitWith {
			_chosenSlotUnit = _x;
		};
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);	
	if (!isNull _chosenSlotUnit) then {
		["DRO: JIP player %1 will be selectPlayer'd into %2", player, _chosenSlotUnit] call bis_fnc_logFormat;		
		selectPlayer _chosenSlotUnit;
		removeAllActions _chosenSlotUnit;
		if (reviveDisabled < 3) then {
			[_chosenSlotUnit] call rev_addReviveToUnit;	
		};	
	} else {
		//_class = (selectRandom unitList);
		//[player, _class] execVM 'sunday_system\player_setup\switchUnitLoadout.sqf';
		//sleep 1;
		_posToSpawn = [getpos arsenalBox, 3, 15, 3, 0, 30, 0, [], getpos arsenalBox] call BIS_fnc_findSafePos;
		[player, _posToSpawn] call sun_jipNewUnit;
	};
	_allHCs = entities "HeadlessClient_F";
	_currentPlayers = allPlayers - _allHCs;
	_currentPlayers = _currentPlayers - [player];
	_tasks = [_currentPlayers select 0] call BIS_fnc_tasksUnit;
	{
		_taskDesc = [_x] call BIS_fnc_taskDescription;
		_taskDest = [_x] call BIS_fnc_taskDestination;		
		_taskState = [_x] call BIS_fnc_taskState;		
		_taskType = missionNamespace getVariable [(format ["%1_taskType", _x]), "Default"];	
		_id = [_x, player, _taskDesc, _taskDest, _taskState, 1, false, false, _taskType, true] call BIS_fnc_setTask;
		//[_x, _taskType] call BIS_fnc_taskSetType;
	} forEach _tasks;
	player createDiaryRecord ["Diary", ["Briefing", briefingString]];
	_rscLayer cutFadeOut 2;
	enableSentences true;
	cutText ["", "BLACK IN", 3];
	playMusic "";
	[] call fnc_missionText;
	[] call fnc_playerSetup;
};

sleep 0.1;
["objectivesSpawned"] spawn sun_randomCam;


//cutText ["", "BLACK IN", 2];

//["Preload"] spawn BIS_fnc_arsenal;
//sleep 2;
diag_log format ["DRO: Player %1 waiting for factionDataReady", player];
waitUntil {(missionNameSpace getVariable ["factionDataReady", 0]) == 1};
diag_log format ["DRO: Player %1 received factionDataReady", player];
waitUntil {!isNil "topUnit"};


/*
_counter = 0;
while {_counter < 1} do {
	{
		((findDisplay 999991) displayCtrl _x) ctrlSetFade _counter;
		((findDisplay 999991) displayCtrl _x) ctrlCommit 0;
	} forEach [1000, 1001, 1002];
	sleep 0.02;
	_counter = _counter + 0.01;
};
closeDialog 1;
*/

sleep 3;

if (player == topUnit) then {	
	waitUntil {!dialog};
	// Faction dialog
	diag_log "DRO: Create menu dialog";
	_handle = createDialog "sundayDialog";
	diag_log format ["DRO: Created dialog: %1", _handle];
	[] call compile preprocessFileLineNumbers "loadProfile.sqf";
	[] execVM "sunday_system\dialogs\populateStartupMenu.sqf";
	//playSound "Transition1";
};

_rscLayer cutFadeOut 2;

//diag_log format ["DRO: Player %1 waiting for serverReady", player];
//waitUntil {(missionNameSpace getVariable ["serverReady", 0]) == 1};
//diag_log format ["DRO: Player %1 received serverReady", player];

if (player != topUnit) then {
	[toUpper "Подождите, пока идёт процесс создания миссии (обычно это занимает 1 - 2 минуты)", "objectivesSpawned", "objectivesSpawned", 1, ""] spawn sun_callLoadScreen;
};

[] spawn {
	// Turn off menu music
	waitUntil {(missionNameSpace getVariable ["factionsChosen", 0]) == 1};
	10 fadeMusic 0;
};

diag_log format ["DRO: Player %1 waiting for objectivesSpawned", player];
waitUntil{(missionNameSpace getVariable ["objectivesSpawned", 0]) == 1};
diag_log format ["DRO: Player %1 objectivesSpawned == 1", player];


// Get camera target point
_heightEnd = getTerrainHeightASL (missionNameSpace getVariable ["aoCamPos", []]);
_camEndPos = [(missionNameSpace getVariable "aoCamPos") select 0, (missionNameSpace getVariable ["aoCamPos", []]) select 1, 10];
_iconPos = ASLToAGL _camEndPos;

_aoLocationName = (missionNameSpace getVariable "aoLocationName");

// Create camera initial zoom point
_camDir = (random 360);
_initialCamPos = [_camEndPos, 3000, _camDir] call BIS_fnc_relPos;

// Create camera slowdown point
_extendPos = [_camEndPos, 200, _camDir] call BIS_fnc_relPos;
_heightStart = getTerrainHeightASL _extendPos;
if (_heightStart < _heightEnd) then {
	_heightStart = _heightEnd; 
};
if (_heightStart < 20) then {_heightStart = 0};
_camStartPos = [(_extendPos select 0), (_extendPos select 1), (_heightStart+15)];

_initialHeight = (_heightStart+50);
_initialCamPos set [2, _initialHeight];
_attempts = 0;
while {(terrainIntersectASL [_camStartPos, _initialCamPos])} do {
	if (_attempts > 10) exitWith {};
	_initialHeight = _initialHeight + 30;
	_initialCamPos set [2, _initialHeight];	
	_attempts = _attempts + 1;
	diag_log "DRO: Raised _initialCamPos";
};

// Init camera
cam = "camera" camCreate _initialCamPos;
diag_log format ["DRO: Player %1 waiting for randomCamActive", player];
waitUntil {!randomCamActive};
diag_log format ["DRO: Player %1 received randomCamActive", player];
cam cameraEffect ["internal", "BACK"];
cam camSetPos _initialCamPos;
cam camSetTarget _camEndPos;
cam camCommit 0;
if (timeOfDay == 4) then {
	camUseNVG true;
};	
cameraEffectEnableHUD false;
cam camPreparePos _camStartPos;
cam camCommitPrepared 3;

cutText ["", "BLACK IN", 3];
diag_log "DRO: Intro camera begun";

playMusic "";
0 fadeMusic 1;
playmusic [musicIntroSting, 0];

sleep 3;
cam camPreparePos _camEndPos;
cam camPrepareFov 0.2;
cam camCommitPrepared 50;

[
	[
		[toUpper _aoLocationName, "align = 'center' shadow = '0' size = '2' font='EtelkaMonospaceProBold'"]		
	],
	0 * safezoneW + safezoneX,
	0.75 * safezoneH + safezoneY,
	false
] spawn BIS_fnc_typeText2;
sleep 7;

//if ((missionNameSpace getVariable ["lobbyComplete", 0]) == 0) then { removeAllWeapons player;}; // Удаление оружия для тех кто зашел во время создания миссии

cutText ["", "BLACK OUT", 1];
10 fademusic 0;
sleep 1;

closeDialog 1;

cam cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy cam;	
diag_log format ["DRO: Player %1 cam terminated", player];	


//waitUntil{(missionNameSpace getVariable ["dro_introCamComplete", 0]) == 1};
// Open map
_mapOpen = openMap [true, false];
mapAnimAdd [0, 0.05, markerPos "centerMkr"];
mapAnimCommit;
cutText ["", "BLACK IN", 1];
hintSilent "Закройте карту с помощью ESC когда будете готовы";
diag_log format ["DRO: Player %1 map initialised", player];

waitUntil {!visibleMap};
diag_log format ["DRO: Player %1 map closed", player];
hintSilent "";

cutText ["", "BLACK FADED"];

// Open lobby

if (roleDescription player == '[Штаб] Командир взвода') then {
	_handle = CreateDialog "DRO_lobbyDialog";
	diag_log format ["DRO: Player %1 created DRO_lobbyDialog: %2", player, _handle];
	[] execVM "sunday_system\dialogs\populateLobby.sqf";
};

sleep 0.5;
cutText ["", "BLACK IN", 1];

_actionID = nil;

if (roleDescription player == '[Штаб] Командир взвода') then {
	_actionID = player addAction ["Открыть планирование команды", 
		{
			_handle = CreateDialog "DRO_lobbyDialog";
			[] execVM "sunday_system\dialogs\populateLobby.sqf";
		}, nil, 6
	];
};

while {
	((missionNameSpace getVariable ["lobbyComplete", 0]) == 0)
} do {
	sleep 0.2;	
	if ((getMarkerColor "campMkr" == "")) then {
		((findDisplay 626262) displayCtrl 6006) ctrlSetText "Точка старта: Случ";
	} else {
		((findDisplay 626262) displayCtrl 6006) ctrlSetText format ["Точка старта: %1", (mapGridPosition (getMarkerPos 'campMkr'))];			
	};
	{
		if (_x getVariable ["startReady", false] OR !isPlayer _x) then {
			((findDisplay 626262) displayCtrl (_x getVariable "unitNameTagIDC")) ctrlSetTextColor [0.05, 1, 0.5, 1];
		} else {
			((findDisplay 626262) displayCtrl (_x getVariable "unitNameTagIDC")) ctrlSetTextColor [1, 1, 1, 1];
		};
	} forEach (units group player);
	if (player == topUnit) then {
		_allHCs = entities "HeadlessClient_F";
		_allHPs = allPlayers - _allHCs;
		// Только командиру достаточно нажать кнопку "Готов"
		//if (({(_x getVariable ["startReady", false])} count _allHPs) >= count _allHPs) then {
		if (player getVariable ['startReady', false]) then {
			missionNameSpace setVariable ['lobbyComplete', 1, true];	
		};	
	};
};

// Wait for host to press the start button
diag_log format ["DRO: Player %1 waiting for lobbyComplete", player];
waitUntil {((missionNameSpace getVariable ["lobbyComplete", 0]) == 1)};
diag_log format ["DRO: Player %1 received lobbyComplete", player];

// Close dialogs twice in case player has arsenal open
closeDialog 1;	
closeDialog 1;	

1 fadeSound 0;

if (roleDescription player == '[Штаб] Командир взвода') then {
	player removeAction _actionID;
};

(format ["DRO: Player %1 lobby closed", player]) remoteExec ["diag_log", 2, false];

cutText ["", "BLACK FADED"];

(format ["DRO: Player %1 preparing to terminate camera %2", player, camLobby]) remoteExec ["diag_log", 2, false];
camLobby cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy camLobby;
(format ["DRO: Player %1 terminated camera %2", player, camLobby]) remoteExec ["diag_log", 2, false];
player switchCamera playerCameraView;
(format ["DRO: Player %1 switched to cameraView %2", player, cameraView]) remoteExec ["diag_log", 2, false];

waitUntil {count (missionNameSpace getVariable ["startPos", []]) > 0};

3 fadeSound 1;
enableSentences true;
cutText ["", "BLACK IN", 3];

// Mission info readout
[] call fnc_missionText;
[] call fnc_playerSetup;

// Start saving player loadout periodically
[] spawn {
	loadoutSavingStarted = true;
	playerRespawning = false;
	diag_log format ["DRO: Initial respawn loadout = %1", (getUnitLoadout player)];
	while {true} do {
		sleep 5;
		if (alive player && !playerRespawning) then {
			player setVariable ["respawnLoadout", getUnitLoadout player, true]; 
		};
	};
};

