////fn_applyFilters.sqf

params ["_className"];

//// === FILTERING ===
//ETCG_modName = "CUP";	// Modded objects have classnames that ALWAYS begin with mod tag (in this case - CUP) and this is a reliable way to filter out mod objects. This does NOT apply to vanilla objects (they do not begin with e.g. BI - Bohemia Interactive)
//ETCG_vehicleType = [];	// if empty, it should include ALL vehicleTypes. Else, the code should only allow types listed in this array
//ETCG_exceptions = [];		// the code should filter out any classname in this array.
//// or you can just specify vehicles in this array (skips above checks)
//ETCG_userArray = [
//
//];		// if user array is empty, all other filters should be applied. Else, the filters should be skipped and only the classnames in this array should be checked for score.
//ETCG_customFilter = {
//	true
//};		// this allows user to determine their own filtering contition, should they require so.


if ((count ETCG_userArray) == 0) then {
	if !(_className find ETCG_modName == 0) exitWith { false };
};				  
if !(toLower _className find "_base" == -1) exitWith { false };
if !(toLower _className find "_item_" == -1) exitWith { false };
if !(toLower _className find "_weapon_" == -1) exitWith { false };
if !(toLower _className find "_lhd_" == -1) exitWith { false };
if !(toLower _className find "_lpd_" == -1) exitWith { false };
if !(toLower _className find "_canopy" == -1) exitWith { false };
if !(toLower _className find "_ejectionseat" == -1) exitWith { false };
if !(toLower _className find "wreck" == -1) exitWith { false };

//Backpack: configfile >> "CfgVehicles" >> "B_Carryall_ocamo_Eng" >> "isbackpack" (number: 1-true, 0 or nil-false)
//Human/Unit: configfile >> "CfgVehicles" >> "B_CTRG_Soldier_F" >> "isMan" (same as above)
//UAV: configfile >> "CfgVehicles" >> "B_UAV_06_F" >> "isUav"

private _configPath = configFile >> "CfgVehicles" >> _className;

private _scope = getNumber (_configPath >> "scope");
if (_scope isEqualTo 0) exitWith { false };

private _maxSpeed = getNumber (_configPath >> "maxSpeed");
if (_maxSpeed isEqualTo 24) exitWith { false };

private _displayName = getText (_configPath >> "displayName");
if !(toLower _displayName find "ground" == -1 ) exitWith { false };
if !(toLower _displayName find "building" == -1 ) exitWith { false };
if !(toLower _displayName find "house" == -1 ) exitWith { false };
if !(toLower _displayName find "test" == -1 ) exitWith { false };
if !(toLower _displayName find "wreck" == -1) exitWith { false };
if !(toLower (getText (_configPath >> "textSingular")) find "unknown" == -1) exitWith { false };

true