/*
_extractStyles = ["LEAVE"];
_extractWeights = [0.3];
if (insertType == "GROUND") then {
	_extractStyles pushBack "RTB";
	_extractWeights pushBack 0.1;
};


if (!isNil "friendlySquad") then {
	if (({alive _x} count (units friendlySquad)) > 0) then {
		_extractStyles = ["RENDEZVOUS"];
		_extractWeights = [];
		if (count holdAO > 0) then {
			_extractWeights pushBack 0;
		} else {
			_extractWeights pushBack 0.5;
		};
	};
};

if (count holdAO > 0) then {
	_extractStyles pushBack "HOLD";
	_extractWeights pushBack 1;
};


_extractStyle = _extractStyles selectRandomWeighted _extractWeights;
*/
//_extractWeights = [];
//_extractWeights pushBack 1;
_extractStyle = "RTB";

// Filter available helicopters for transportation space
_numPassengers = count (units (grpNetId call BIS_fnc_groupFromNetId));
_heliTransports = [];
{
	if ([_x] call sun_getTrueCargo >= _numPassengers) then {
		_heliTransports pushBack _x;
	};
} forEach pHeliClasses;

//diag_log format ["DRO: _extractStyles = %1", _extractStyles];
//diag_log format ["DRO: _extractWeights = %1", _extractWeights];
//diag_log format ["DRO: _extractStyle = %1", _extractStyle];

	
if (((count _heliTransports) > 0) && !extractHeliUsed) then {	
	_taskCreated = ["taskExtract", true, ["Вернитесь в штаб. Доступна эвакуация вертолётом.", "Вернуться в штаб", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
	diag_log format ["DRO: Extract task created: %1", _taskCreated];
	[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];	
} else {	
	_taskCreated = ["taskExtract", true, ["Вернитесь в штаб. Эвакуация вертолётом недоступна.", "Вернуться в штаб", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
	diag_log format ["DRO: Extract task created: %1", _taskCreated];
};

// Send new enemies to chase players if stealth is not maintained
if (!stealthActive) then {
	if (enemyCommsActive) then {
		diag_log 'DRO: Reinforcing due to mission completion';
		[(leader (grpNetId call BIS_fnc_groupFromNetId)), [2,4]] execVM 'sunday_system\reinforce.sqf';
	};
	// Make existing enemies close in on players
	diag_log "DRO: Init staggered attack";	
	[30] execVM 'sunday_system\generate_enemies\staggeredAttack.sqf';
};

// Extraction success trigger
extractPos = (getMarkerPos "campMkr");
publicVariable "extractPos";
trgExtract = createTrigger ["EmptyDetector", getMarkerPos "campMkr", true];
trgExtract setTriggerArea [50, 50, 0, true];
trgExtract setTriggerActivation ["ANY", "PRESENT", false];
/* trgExtract setTriggerStatements [
	"		
		({vehicle _x in thisList} count allPlayers > 0) &&
		({alive _x} count allPlayers > 0) &&
		
	",
	"
		[] execVM 'sunday_system\endMission.sqf';
	",
	""
]; */
trgExtract setTriggerStatements [
	"		
		({alive _x} count (allPlayers) == {alive _x && _x inArea thisTrigger} count (allPlayers))  && ({alive _x} count allPlayers) > 0
	",
	"
		[] execVM 'sunday_system\endMission.sqf';
	",
	""
];
["LeadTrack02_F_Mark"] remoteExec ["playMusic", 0];
["END_RTB"] spawn dro_sendProgressMessage;
