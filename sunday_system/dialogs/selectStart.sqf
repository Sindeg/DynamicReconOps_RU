closeDialog 1;

//camLobbyPos = getPos camLobby;
//camLobbyTimePaused = time;

camLobby cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy camLobby;	

_mapOpen = openMap [true, false];
mapAnimAdd [0, 0.05, markerPos "centerMkr"];
mapAnimCommit;

player switchCamera "INTERNAL";
[
	"mapStartSelect",
	"onMapSingleClick",
	{		
		deleteMarker "campMkr";
		customPos = _pos;
		publicVariable "customPos";
		markerPlayerStart = createMarker ["campMkr", _pos];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerSize [1, 1];
		markerPlayerStart setMarkerText "Точка старта";
		publicVariable "markerPlayerStart";			
	},
	[]
] call BIS_fnc_addStackedEventHandler;

waitUntil {!visibleMap};
["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
player switchCamera playerCameraView;
_handle = CreateDialog "DRO_lobbyDialog";
[] execVM "sunday_system\dialogs\populateLobby.sqf";