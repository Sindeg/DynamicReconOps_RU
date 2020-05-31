class sundayDialog {
	idd = 52525;
	movingenable = false;
		
	class controls {		
		class menuBackground1: sundayText {
			idc = 1050;	
			x = "safezoneX + (27 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (0 * pixelGridNoUIScale * pixelH)";
			w = "safezoneW - (27 * pixelGridNoUIScale * pixelW)";	
			h = "7 * pixelGridNoUIScale * pixelH";
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class menuBackground2: sundayText {
			idc = 1051;
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (0 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";
			h = "safezoneH";
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class sundayTitlePic: RscPicture
		{
			idc = 1098;
			text = "images\recon_icon.paa";			
			x = "safezoneX + (5 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (0.25 * pixelGridNoUIScale * pixelH)";
			w = "15 * pixelGridNoUIScale * pixelW";	
			h = "15 * pixelGridNoUIScale * pixelH";			
		};
		class mapBox: RscMapControl
		{			
			idc = 1200;			
			x = "safezoneX + (27 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (8 * pixelGridNoUIScale * pixelH)";
			w = 0;
			h = 0;
		};
		class sundayWarningBox: sundayText
		{
			idc = 1052;
			text = "";
			fade = 1;			
			x = "(safezoneX + safezoneW) - (20 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (8 * pixelGridNoUIScale * pixelH)";
			w = "20 * pixelGridNoUIScale * pixelW";
			h = "12 * pixelGridNoUIScale * pixelH";			
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
		};
		class sundayWarningText: sundayText
		{
			idc = 1053;
			type = CT_STRUCTURED_TEXT;
			text = "";
			fade = 1;
			x = "(safezoneX + safezoneW) - (19 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (9 * pixelGridNoUIScale * pixelH)";
			w = "18 * pixelGridNoUIScale * pixelW";
			h = "11 * pixelGridNoUIScale * pixelH";
			size = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			class Attributes {				
				color = "#ffffff";
				valign = "middle";
			};			
		};				
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;			
			style = ST_CENTER;
			text = "Описание"; //--- ToDo: Localize;						
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";			
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			colorBackground[] = {0.20,0.40,0.65,1};
		};		
		
		class menuLeft: DROBasicButton
		{			
			idc = 1150;
			text = "<";
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "2.5 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";
			action = "['LEFT', (findDisplay 52525)] spawn dro_menuSlider";
			soundClick[] = {"A3\missions_f\data\sounds\border_out.ogg",1,1.3};
		};
		class menuRight: DROBasicButton
		{			
			idc = 1151;
			text = ">";
			x = "safezoneX + (23.5 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "2.5 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";	
			action = "['RIGHT', (findDisplay 52525)] spawn dro_menuSlider";
			soundClick[] = {"A3\missions_f\data\sounds\border_in.ogg",1,1.3};
		};
		class sundayTitlePlayer: sundayText
		{
			idc = 1300;
			text = "Фракция игроков"; //--- ToDo: Localize;
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.4)";
			y = "safezoneY + (1 * pixelGridNoUIScale * pixelH)";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "1.5 * pixelGridNoUIScale * pixelH";
		};		
		class sundayComboPlayerFactions: DROCombo
		{
			idc = 1301;
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.4)";
			y = "safezoneY + (3 * pixelGridNoUIScale * pixelH)";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "2.5 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";	
			rowHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			wholeHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 25) * 0.5";
			onLBSelChanged = "pFactionIndex = (_this select 1); publicVariable 'pFactionIndex'";				
		};				
		class sundayTitleEnemy: sundayText
		{
			idc = 1310;
			text = "Фракция противника"; //--- ToDo: Localize;
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) - (((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25) * 0.5)";
			y = "safezoneY + (1 * pixelGridNoUIScale * pixelH)";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "1.5 * pixelGridNoUIScale * pixelH";
		};
		class sundayComboEnemyFactions: DROCombo
		{
			idc = 1311;
			//x = "safezoneX + (52 * pixelGridNoUIScale * pixelW)";
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) - (((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25) * 0.5)";
			y = "safezoneY + (3 * pixelGridNoUIScale * pixelH)";
			//w = "20 * pixelGridNoUIScale * pixelW";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "2.5 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";
			rowHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			wholeHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 25) * 0.5";
			onLBSelChanged = "eFactionIndex = (_this select 1); publicVariable 'eFactionIndex'";
		};
		class sundayTitleCivilians: sundayText
		{
			idc = 1320;
			text = "Фракция гражданских"; //--- ToDo: Localize;
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) + ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.15)";
			y = "safezoneY + (1 * pixelGridNoUIScale * pixelH)";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "1.5 * pixelGridNoUIScale * pixelH";
		};
		class sundayComboCivFactions: DROCombo
		{
			idc = 1321;
			x = "(safezoneX + safezoneW) - ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.5) + ((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.15)";
			y = "safezoneY + (3 * pixelGridNoUIScale * pixelH)";
			w = "((safezoneW - (27 * pixelGridNoUIScale * pixelW)) * 0.25)";
			h = "2.5 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";
			rowHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			wholeHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 25) * 0.5";
			onLBSelChanged = "cFactionIndex = (_this select 1); publicVariable 'cFactionIndex'";			
		};		
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "Начать";
			x = "(safezoneX + safezoneW) - (23 * pixelGridNoUIScale * pixelW)";
			y = "(safezoneY + safezoneH) - (4 * pixelGridNoUIScale * pixelH)";
			w = "23 * pixelGridNoUIScale * pixelW";
			h = "4 * pixelGridNoUIScale * pixelH";	
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2.5) * 0.5";	
			action = "_nil=[]ExecVM 'sunday_system\dialogs\okAO.sqf'";
		};	
		
		// INFO
		class InfoGroup: RscControlsGroup {
			idc = 1140;			
			x = safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";			
			h = "safezoneH - (20 * pixelGridNoUIScale * pixelH)";			
			class Controls {			
				class welcomeHeading: sundayHeading
				{
					idc = 1141;
					text = "Добро пожаловать";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "0 * pixelGridNoUIScale * pixelH";
					w = "20 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
				};			
				class welcomeText: sundayTextMT
				{
					idc = 1142;
					text = "Dynamic Recon Ops - это всегда случайно создаваемый сценарий, с занятой врагом областью и выбором задач, которые необходимо выполнить.\n\nВы можете нажать кнопку СТАРТ в правом нижнем углу, чтобы немедленно создать случайный сценарий, или использовать кнопки со стрелками выше, чтобы настроить миссию более детально.\n\nПриятной игры!";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "3 * pixelGridNoUIScale * pixelH";
					w = "20 * pixelGridNoUIScale * pixelW";	
					h = "safezoneH - (30 * pixelGridNoUIScale * pixelH)";	
				};	
				class clearData: DROBasicButton
				{			
					idc = 1143;
					text = "Сбросить все настройки";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "safezoneH - (24 * pixelGridNoUIScale * pixelH)";
					w = "20 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					action = "[] call dro_clearData";		
				};
			};
		};
		
		// SCENARIO
		class ScenarioGroup: RscControlsGroup {
			idc = 2000;			
			x = -0.4 * safezoneW + safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";			
			h = "safezoneH - (20 * pixelGridNoUIScale * pixelH)";		
			class Controls {				
				class PresetSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2090;										
					y = "0 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2091;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2092;	
							text = "Предустановки";								
							
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2093;							
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2094;
							action = "['MAIN', 2090, true, 'PRESET'] call sun_switchButton";
							tooltip = "";
						};
					};		
				};
				class Spacer0: sundaySpacer {
					idc = 2095;						
					y = "4 * pixelGridNoUIScale * pixelH";					
				};
				class droAOBG: sundayText {
					idc = 2014;			
					text = "";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "5 * pixelGridNoUIScale * pixelH";
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					colorBackground[] = {0,0,0,0.3};													
				};
				class droSelectAOText: sundayText {
					idc = 2010;
					style = ST_CENTER;
					text = "Зона операции: СЛУЧАЙНО";
					font = "PuristaMedium";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "5 * pixelGridNoUIScale * pixelH";
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
				};
				class MapButtons: RscControlsGroupNoScrollbars {
					idc = 2013;
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "8.5 * pixelGridNoUIScale * pixelH";
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					class Controls {
						class droSelectAOClear: DROBasicButton
						{			
							idc = 2012;
							text = "Сбросить";
							x = "0 * pixelGridNoUIScale * pixelW";
							y = 0;
							w = "11.75 * pixelGridNoUIScale * pixelW";	
							h = "3 * pixelGridNoUIScale * pixelH";
							sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
							action = "deleteMarker 'aoSelectMkr'; aoName = nil; ctrlSetText [2010, 'Зона операции: СЛУЧАЙНО']; selectedLocMarker setMarkerColor 'ColorPink';";		
						};
						class droSelectAONew: DROBasicButton
						{			
							idc = 2011;
							text = "Открыть карту";
							x = "12.25 * pixelGridNoUIScale * pixelW";
							y = 0;
							w = "11.75 * pixelGridNoUIScale * pixelW";	
							h = "3 * pixelGridNoUIScale * pixelH";
							sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";			
							action = "[] spawn dro_menuMap";		
						};
					};
				};
				class AOSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2020;	
					y = "12 * pixelGridNoUIScale * pixelH";					
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2021;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\map_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2022;	
							text = "Доп. зоны";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2023;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2024;
							action = "['MAIN', 2020] call sun_switchButton";
							tooltip = "Когда включено, будет добавлено до 3 дополнительных мест в район операции, чтобы сделать общую задействованную площадь больше.";
						};
						
					};		
				};
				class Spacer1: sundaySpacer {
					idc = 2025;					
					y = "16 * pixelGridNoUIScale * pixelH";	
				};
				class AISkillSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2030;
					y = "17 * pixelGridNoUIScale * pixelH";	
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2031;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2032;	
							text = "Уровень AI";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2033;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2034;
							action = "['MAIN', 2030] call sun_switchButton";
							tooltip = "Normal reduces the AI's aiming ability dramatically while leaving their strategic skills almost unchanged. Hard is similar but with slightly better aiming skills. Realism makes no changes to any AI skills and leaves them as set in your Arma options menu.";			
						};
					};		
				};
				
				class droAIBG: sundayText {
					idc = 2042;			
					text = "";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "20.5 * pixelGridNoUIScale * pixelH";
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "5 * pixelGridNoUIScale * pixelH";
					colorBackground[] = {0,0,0,0.3};													
				};
				class sundayTitleAISize: sundayText
				{
					idc = 2040;
					text = "Количество противника: x1.0";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "20 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					colorText[] = {0.75,0.75,0.75,1};
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";	
					font = "PuristaMedium";
					tooltip = "Позволяет настроить количество противника с которым вы столкнетесь.";
				};
				class sundaySliderAISize: sundaySlider
				{
					idc = 2041;
					x = "1.5 * pixelGridNoUIScale * pixelW";
					y = "23.5 * pixelGridNoUIScale * pixelH";	
					w = "23 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";					
					onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 2040) ctrlSetText format ['Количество противника: x%1', _rounded]; aiMultiplier = _rounded; publicVariable 'aiMultiplier'; profileNamespace setVariable ['DRO_aiMultiplier', _rounded];";
				};
				class Spacer2: sundaySpacer {
					idc = 2043;					
					y = "26.5 * pixelGridNoUIScale * pixelH";	
				};				
				class MinesSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2050;
					y = "27.5 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2051;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\mine_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2052;	
							text = "Ограничение техники";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2053;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2054;
							action = "['MAIN', 2050] call sun_switchButton";
							tooltip = "Если включено - арсенал техники в штабе будет доступен не всем игрокам, а только командиру взвода и офицеру.";
						};
					};		
				};
				class CivsSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2060;
					y = "31 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2061;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2062;	
							text = "Гражданские в городах";		
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2063;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2064;
							action = "['MAIN', 2060] call sun_switchButton";
							tooltip = "Включает возможность присутствия гражданских в районе операций.";
						};
					};		
				};
				class StealthSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2070;
					y = "34.5 * pixelGridNoUIScale * pixelH";					
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2071;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\listen_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2072;	
							text = "Скрытность";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2073;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2074;
							action = "['MAIN', 2070] call sun_switchButton";
							tooltip = "Включает или отключает режим скрытности во время игры.";
						};
					};		
				};
				class ReviveSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2080;
					y = "38 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2081;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\heal_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2082;	
							text = "Мед. система";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2083;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2084;
							action = "['MAIN', 2080] call sun_switchButton";
							tooltip = "Встроеная мед. система при отстутствии других.";
						};
					};		
				};
				class DynSimSwitchButton: RscControlsGroupNoScrollbars {
					idc = 2400;
					y = "41.5 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 2401;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 2402;	
							text = "DYNAMIC SIM";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 2403;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 2404;
							action = "['MAIN', 2400] call sun_switchButton";
							tooltip = "Включает или отключает Arma dynamic simulation system. Может повысить производительность когда включена, но 'отключает' AI когда игроки находятся далеко от них.";
						};
					};		
				};
			};
		
		};
		// ENVIRONMENT
		class EnvironmentGroup: RscControlsGroup {
			idc = 3000;			
			x = -0.4 * safezoneW + safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";			
			h = "safezoneH - (20 * pixelGridNoUIScale * pixelH)";
			class Controls {		
				class TimeSwitchButton: RscControlsGroupNoScrollbars {
					idc = 3010;
					y = "0 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 3011;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\wait_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 3012;	
							text = "Время суток";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 3013;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 3014;
							action = "['MAIN', 3010, true, 'TIME'] call sun_switchButton";
							tooltip = "Устанавливает начальное время.";
						};
					};		
				};
				class WeatherSwitchButton: RscControlsGroupNoScrollbars {
					idc = 3020;
					y = "3.5 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 3021;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 3022;	
							text = "Погода";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 3023;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 3024;
							action = "['MAIN', 3020] call sun_switchButtonWeather";
							tooltip = "Устанавливает начальную погоду.";
						};
					};		
				};
				class droAIBG: sundayText {
					idc = 1115;			
					text = "";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "7 * pixelGridNoUIScale * pixelH";
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "5 * pixelGridNoUIScale * pixelH";
					colorBackground[] = {0,0,0,0.3};													
				};				
				class sundaySliderWeatherFair: sundayText
				{
					idc = 1113;
					text = "Хорошая";
					x = "2.5 * pixelGridNoUIScale * pixelW";
					y = "6.5 * pixelGridNoUIScale * pixelH";	
					w = "4 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					colorText[] = {0.75,0.75,0.75,1};
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";	
					font = "PuristaMedium";
				};
				class sundaySliderWeatherBad: sundayText
				{
					idc = 1114;
					style = ST_RIGHT;
					text = "Плохая";
					x = "20 * pixelGridNoUIScale * pixelW";
					y = "6.5 * pixelGridNoUIScale * pixelH";	
					w = "4 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";
					colorText[] = {0.75,0.75,0.75,1};
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";	
					font = "PuristaMedium";
				};
				class sundaySliderWeather: sundaySlider
				{
					idc = 2109;
					x = "1.5 * pixelGridNoUIScale * pixelW";
					y = "10 * pixelGridNoUIScale * pixelH";	
					w = "23 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";						
					onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 3)) / (10 ^ 3); ['MAIN', 3020, true, 1] call sun_switchButtonWeather; weatherOvercast = _rounded; publicVariable 'weatherOvercast';";
				};
				class Spacer3: sundaySpacer {
					idc = 2110;					
					y = "13 * pixelGridNoUIScale * pixelH";	
				};
				class sundayTitleMonth: sundayText
				{
					idc = 1106;
					text = "Месяц";
					x = "1 * pixelGridNoUIScale * pixelW";	
					y = "14 * pixelGridNoUIScale * pixelH";	
					w = "10 * pixelGridNoUIScale * pixelW";	
					h = "1.75 * pixelGridNoUIScale * pixelH";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";	
					font = "PuristaMedium";
				};		
				class sundayCBMonth: DROCombo
				{
					idc = 2104;
					x = "15 * pixelGridNoUIScale * pixelW";
					y = "14 * pixelGridNoUIScale * pixelH";					
					w = "10 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";					
					onLBSelChanged = "[_this] spawn sun_monthSelChange;";		
				};
				class sundayTitleDay: sundayText
				{
					idc = 2300;
					text = "День";
					x = "1 * pixelGridNoUIScale * pixelW";	
					y = "17 * pixelGridNoUIScale * pixelH";	
					w = "10 * pixelGridNoUIScale * pixelW";	
					h = "1.75 * pixelGridNoUIScale * pixelH";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
					font = "PuristaMedium";
				};		
				class sundayCBDay: DROCombo
				{
					idc = 2301;
					x = "15 * pixelGridNoUIScale * pixelW";
					y = "17 * pixelGridNoUIScale * pixelH";					
					w = "10 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";					
					onLBSelChanged = "[_this] spawn sun_daySelChange;";		
				};
				class Spacer4: sundaySpacer {
					idc = 2302;					
					y = "20 * pixelGridNoUIScale * pixelH";
				};				
				class AnimalsSwitchButton: RscControlsGroupNoScrollbars {
					idc = 3030;
					y = "21 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 3031;							
							text = "\A3\ui_f\data\map\vehicleicons\iconAnimal_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 3032;	
							text = "Животные";
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 3033;							
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 3034;
							action = "['MAIN', 3030] call sun_switchButton";
							tooltip = "Включает или отключает присутствие животных.";
						};
					};		
				};				
			};
		};
		
		// OBJECTIVES
		class ObjectivesGroup: RscControlsGroup {
			idc = 4000;			
			x = -0.4 * safezoneW + safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";			
			h = "safezoneH - (20 * pixelGridNoUIScale * pixelH)";
			class Controls {
				class NumObjsSwitchButton: RscControlsGroupNoScrollbars {
					idc = 4010;
					y = "0 * pixelGridNoUIScale * pixelH";
					class Controls {
						class SwitchPic: sundaySelButtonPic
						{			
							idc = 4011;
							text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa";							
						};
						class SwitchTitle: sundaySelButtonTitle
						{			
							idc = 4012;
							text = "Количество заданий";	
						};
						class SwitchText: sundaySelButtonSelect
						{			
							idc = 4013;
							text = "";
						};
						class SwitchButton: sundaySelButton {
							idc = 4014;
							action = "['MAIN', 4010] call sun_switchButton";
						};
					};		
				};				
				class objPrefTitle: sundayText
				{
					idc = 4020;
					text = "Предпочтения в заданиях";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "4 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";
				};
				class objPrefText: sundayTextMT
				{
					idc = 4021;			
					text = "Имейте ввиду, что не всегда возможно создать задания только исходя из ваших предпочтений, это зависит от выбранного места и фракций.";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "6 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "4 * pixelGridNoUIScale * pixelH";
					colorText[] = {1,1,1,0.7};
				};
				class objPrefHVT: DROBasicButton
				{			
					idc = 2200;
					text = "Устранить цель";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "11 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";					
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";					
					action = "if ('HVT' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['HVT']; ((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'HVT'; ((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefPOW: DROBasicButton
				{			
					idc = 2201;
					text = "Спасти заложника";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "14.25 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('POW' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['POW']; ((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'POW'; ((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefIntel: DROBasicButton
				{			
					idc = 2202;
					text = "Получить разведданные";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "17.5 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('INTEL' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['INTEL']; ((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'INTEL'; ((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefCache: DROBasicButton
				{			
					idc = 2203;
					text = "Уничтожить тайник";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "20.75 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";				
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('CACHE' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['CACHE']; ((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'CACHE'; ((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefDestroyAsset: DROBasicButton
				{			
					idc = 2204;
					text = "Уничтожить объекты";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "24 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('MORTAR' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['MORTAR', 'VEHICLE', 'WRECK', 'ARTY', 'HELI']; ((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [1, 1, 1, 1];} else {preferredObjectives pushBackUnique 'MORTAR'; preferredObjectives pushBackUnique 'WRECK'; preferredObjectives pushBackUnique 'VEHICLE'; preferredObjectives pushBackUnique 'ARTY'; preferredObjectives pushBackUnique 'HELI'; ((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};		
				class objPrefVehicleSteal: DROBasicButton
				{			
					idc = 2207;
					text = "Украсть технику";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "27.25 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('VEHICLESTEAL' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['VEHICLESTEAL']; ((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'VEHICLESTEAL'; ((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};		
				class objPrefClear: DROBasicButton
				{			
					idc = 2210;
					text = "Зачистить область";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "30.5 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('CLEARLZ' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['CLEARLZ']; ((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'CLEARLZ'; ((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefFortify: DROBasicButton
				{			
					idc = 2211;
					text = "Построить укрепления";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "33.75 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('FORTIFY' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['FORTIFY']; ((findDisplay 52525) displayCtrl 2211) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'FORTIFY'; ((findDisplay 52525) displayCtrl 2211) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefDisarm: DROBasicButton
				{			
					idc = 2212;
					text = "Разминировать";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "37 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('DISARM' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['DISARM']; ((findDisplay 52525) displayCtrl 2212) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'DISARM'; ((findDisplay 52525) displayCtrl 2212) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
				class objPrefProtect: DROBasicButton
				{			
					idc = 2213;
					text = "Защита гражданских";
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "40.25 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";
					action = "if ('PROTECTCIV' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['PROTECTCIV']; ((findDisplay 52525) displayCtrl 2213) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'PROTECTCIV'; ((findDisplay 52525) displayCtrl 2213) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";		
				};
			};
		};
		// ADDITIONAL FACTIONS
		class AddFactionsGroup: RscControlsGroup {
			idc = 5000;			
			x = -0.4 * safezoneW + safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "26 * pixelGridNoUIScale * pixelW";			
			h = "safezoneH - (20 * pixelGridNoUIScale * pixelH)";
			class Controls {		
				class sundayTextAdvPlayer: sundayTextMT
				{
					idc = 3712;			
					text = "Эти настройки позволяют вам добавить дополнительные фракции в выбранные стороны. Каждый дополнительный выбор добавляет возможности использовать все отряды а так же технику этой фракции."; //--- ToDo: Localize;
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "0 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "6 * pixelGridNoUIScale * pixelH";
				};
				class sundayTitleAdvPlayer: sundayText
				{
					idc = 3704;
					text = "Фракции игроков"; //--- ToDo: Localize;
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "7 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";
				};
				class sundayComboAdvPlayerFactionsG: DROCombo
				{
					idc = 3800;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "9 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";	
					onLBSelChanged = "playersFactionAdv set [0, (_this select 1)]; publicVariable 'playersFactionAdv'";				
				};		
				class sundayComboAdvPlayerFactionsA: DROCombo
				{
					idc = 3801;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "11 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";
					onLBSelChanged = "playersFactionAdv set [1, (_this select 1)]; publicVariable 'playersFactionAdv'";				
				};		
				class sundayComboAdvPlayerFactionsS: DROCombo
				{
					idc = 3802;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "13 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";
					onLBSelChanged = "playersFactionAdv set [2, (_this select 1)]; publicVariable 'playersFactionAdv'";				
				};
				class sundayTitleAdvEnemy: sundayText
				{
					idc = 3708;
					text = "Фракции противника"; //--- ToDo: Localize;
					x = "1 * pixelGridNoUIScale * pixelW";
					y = "15 * pixelGridNoUIScale * pixelH";	
					w = "24 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";
				};		
				class sundayComboAdvEnemyFactionsG: DROCombo
				{
					idc = 3803;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "17 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";
					onLBSelChanged = "enemyFactionAdv set [0, (_this select 1)]; publicVariable 'enemyFactionAdv'";				
				};		
				class sundayComboAdvEnemyFactionsA: DROCombo
				{
					idc = 3804;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "19 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";
					onLBSelChanged = "enemyFactionAdv set [1, (_this select 1)]; publicVariable 'enemyFactionAdv'";			
				};		
				class sundayComboAdvEnemyFactionsS: DROCombo
				{
					idc = 3805;
					x = "4 * pixelGridNoUIScale * pixelW";
					y = "21 * pixelGridNoUIScale * pixelH";					
					w = "18 * pixelGridNoUIScale * pixelW";
					h = "1.75 * pixelGridNoUIScale * pixelH";
					onLBSelChanged = "enemyFactionAdv set [2, (_this select 1)]; publicVariable 'enemyFactionAdv'";				
				};
			};
		};
	};
	
};