_missionName = _this select 0;

// Mission name diary entry
_missionText = "";
if (count _missionName > 0) then {
	//_missionName = [_missionName, 15] call BIS_fnc_trimString;
	_missionText = format ["<font size='20' face='PuristaBold'>%1</font>",_missionName];	
};

// Insertion diary entry
_textLocation = "";
if (count "campMkr" > 0) then {
	_markerText = markerText "campMkr";
	switch (insertType) do {
		case "GROUND": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />С местоположения <marker name=%4>%5</marker> команда %6 начинает свою спецоперацию в <marker name=%3>%1</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText, playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />С места развертывания полевого штаба <marker name=%4>%5</marker> команда %6 начинает движение в %2 <marker name=%3>%1.</marker> Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText, playerCallsign];
			};
		};
		case "SEA": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Отряд %5 начинает операцию на лодке с указанного <marker name=%4>места</marker>. С этого места они начинают движение в %1 <marker name=%3>локация</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Отряд %5 начинает операцию на лодке с указанного <marker name=%4>места</marker>.С этого места они начинают движение в %2 <marker name=%3>%1</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
		case "HELI": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Отряд %5 прибывает на вертолете в отмеченное <marker name=%4>место</marker>. С этого места они начинают движение в %1 <marker name=%3>локация</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Отряд %5 прибывает на вертолете в отмеченное <marker name=%4>место</marker>. С этого места они начинают движение в %2 <marker name=%3>%1</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
		case "HALO": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Отряд %5 будет сброшен на парашутах в указанном <marker name=%4>месте</marker>. С этого места они начинают движение в %1 <marker name=%3>локация</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Отряд %5 будет сброшен на парашутах в указанном <marker name=%4>месте</marker>. С этого места они начинают движение в %2 <marker name=%3>%1</marker>. Проверьте список своих задач.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
	};	
};

// Enemy makeup diary entry
_textEnemies = "";
_numEnemies = 0;
{
	if (side _x == enemySide) then {
		_numEnemies = _numEnemies + 1;
	};
} forEach allUnits;

if (_numEnemies < 60) then {
	_textEnemies = format ["<br /><br />Разведка сообщает, что %1 имеет небольшое количество войск в этом регионе. ", enemyFactionName];
};
if (_numEnemies >= 60 && _numEnemies < 80) then {
	_textEnemies = format ["<br /><br />Разведка сообщает, что в этом регионе находится довольно большое количество войск %1.", enemyFactionName];
};
if (_numEnemies >= 80) then {
	_textEnemies = format ["<br /><br />Известно, что %1 сконцетрировало в этом регионе большое число войск; ожидайте сильного сопротивления. ", enemyFactionName];
};

_textSecondaryLocs = "";
if (count AOLocations > 1) then {
	_aoNames = [];	
	{
		if (_forEachIndex > 0) then {
			if ((_x select 4) == 0) then {
				_secondaryLoc = nearestLocation [_x select 0, ""];
				_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];							
				_aoNames pushBack (format ["<marker name=%2>%1</marker>", (text _secondaryLoc), _mkrName]);
			};
		};
	} forEach AOLocations;
	if (count _aoNames > 0) then {
		_aoNamesFull = [_aoNames] call sun_stringCommaList;			
		_reportText = selectRandom ["получили сообщения о присутствии сил", "обнаружили присутствие ", "были проинформированы о войсках"];
		if (count _aoNames > 1) then {		
			_textSecondaryLocs = format [" Мы так же %3 %1 в %2.", enemyFactionName, _aoNamesFull, _reportText];
		} else {
			_textSecondaryLocs = format [" Мы так же %3 %1 в %2.", enemyFactionName, _aoNamesFull, _reportText];
		};
	};
} else {
	_textSecondaryLocs = "";
};

// Civilians present diary entry
_textCivs = "";
if (!isNil "civTrue") then {	
	if (civTrue) then {
		_textCivs = "Кроме того, командование ожидает присутствие гражданских лиц в районе операций, поэтому будьте предельно осторожны, прежде чем открывать огонь. Командование считает любой сопутствующий ущерб неприемлемым, а нарушение прав собственности может привести к суровому наказанию.";		
		if (!isNil "hostileCivIntel") then {
			_randHostileCivs = selectRandom [
				"<br /><br />У нас есть основания полагать, что в регионе действуют враждебные ополченцы, которые прячутся среди гражданского населения.",
				"<br /><br />Наш информатор сообщает, что ряд мирных жителей объединились, чтобы сформировать ополчение, враждебное нашим силам.",
				"<br /><br />Недавние сообщения показывают, что в городе располагается враждебное ополчение, которое поддерживает противника."
			];
			_textCivs = format [" %1%2 %3 Вы попадете в сложную ситуацию, которая потребует пристального внимания к окружению. Имейте это в виду и убедитесь, что сопутствующий ущерб сведен к минимуму.", _textCivs, _randHostileCivs, hostileCivIntel];
		};
	} else {
		_textCivs = " Район операции свободен от мирных жителей. Вы можете использовать любую технику и вооружение для выполнения поставленных задач.";
	};	
};

_textResupply = if (getMarkerColor "resupplyMkr" == "") then {
	""
} else {
	"<br /><br />Местные ополченцы подготовили для вас <marker name='resupplyMkr'>снаряжение</marker>, в котором содержится базовый набор для использования в полевых условиях, включая медицину и взрывчатые вещества для решения любых задач, которые могут вам потребоваться.";
};

_textCancel = "<br /><br />Если вы не можете выполнить одну из задач, у вас есть возможность отменить её.";

_textStealth = if (stealthEnabled == 1) then {
	format ["<br /><br />Войска %1 не будут ожидать появления %2 рядом с %3, чем вы можете воспользоваться. Действуйте скрытно и уничтожайте врагов, прежде чем они смогут поднять тревогу, тогда вы останетесь незамеченными.", enemyFactionName, playersFactionName, aoName]
} else {
	""
};

_textFriendly = if (!isNil "friendlyText") then {friendlyText} else {""};

briefingString = format["%1%2%9%7%4%3%5%8%6", _missionText, _textLocation, _textSecondaryLocs, _textCivs, _textResupply, _textCancel, _textEnemies, _textStealth, _textFriendly];
publicVariable "briefingString";
/*
{
	[_x, ["Diary", ["Briefing", _briefingString]]] remoteExec ["createDiaryRecord", _x, true];
} forEach allPlayers;
*/

//[_briefingString] remoteExec ["sun_briefingJIP", 0, true];

//player createDiaryRecord ["Diary", ["Briefing", _briefingString]];
[briefingString, {player createDiaryRecord ["Diary", ["Инструктаж", _this]]}] remoteExec ["call", 0, true];

["BRIEFING"] spawn dro_sendProgressMessage;
