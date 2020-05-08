timeOfDay = 2;
publicVariable "timeOfDay";

month = profileNamespace getVariable ["DRO_month", 0];
publicVariable "month";

day = profileNamespace getVariable ["DRO_day", 0];
publicVariable "day";

weatherOvercast = profileNamespace getVariable ["DRO_weatherOvercast", "RANDOM"];
publicVariable "weatherOvercast";

aiSkill = profileNamespace getVariable ["DRO_aiSkill", 0];
publicVariable "aiSkill";

//animalsEnabled = profileNamespace getVariable ['DRO_animalsEnabled', 0];
animalsEnabled = 1;

aiMultiplier = profileNamespace getVariable ["DRO_aiMultiplier", 1];
publicVariable "aiMultiplier";

numObjectives = profileNamespace getVariable ["DRO_numObjectives", 3];
publicVariable "numObjectives";

preferredObjectives = profileNamespace getVariable ["DRO_objectivePrefs", []];
publicVariable "preferredObjectives";

aoOptionSelect = profileNamespace getVariable ["DRO_aoOptionSelect", 0];
publicVariable "aoOptionSelect";

//minesEnabled = profileNamespace getVariable ["DRO_minesEnabled", 0];
minesEnabled = 1;
publicVariable "minesEnabled";

//civiliansEnabled = profileNamespace getVariable ["DRO_civiliansEnabled", 0];
civiliansEnabled = 3;
publicVariable "civiliansEnabled";

//stealthEnabled = profileNamespace getVariable ["DRO_stealthEnabled", 0];
stealthEnabled = 2;
publicVariable "stealthEnabled";

//reviveDisabled = profileNamespace getVariable ["DRO_reviveDisabled", 0];
reviveDisabled = 3;
publicVariable "reviveDisabled";

missionPreset = profileNamespace getVariable ["DRO_missionPreset", 0];
publicVariable "missionPreset";

insertType = 1;
publicVariable "insertType";

randomSupports = profileNamespace getVariable ["DRO_randomSupports", 0];
publicVariable "randomSupports";

customSupports = profileNamespace getVariable ["DRO_supportPrefs", []];
publicVariable "customSupports";

//dynamicSim = profileNamespace getVariable ["DRO_dynamicSim", 0];
dynamicSim = 1;

publicVariable "dynamicSim";

diag_log "DRO: variables loaded from profile";
