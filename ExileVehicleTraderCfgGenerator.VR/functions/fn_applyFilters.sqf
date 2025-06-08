//// fn_applyFilters.sqf
params ["_className"];

//// === BLACKLIST CHECK ===
// First and foremost: Filter out explicitly blacklisted classnames
// Any classname listed in EVTCG_exceptions will be excluded regardless of other conditions.
if (_className in EVTCG_exceptions) exitWith { false };

//// === USER ARRAY OVERRIDE ===
// If EVTCG_userArray is non-empty, only classnames in this array will be allowed.
// All other filters are skipped.
if ((count EVTCG_userArray) > 0) exitWith {
	_className in EVTCG_userArray
};

//// === HELPER FUNCTIONS ===
private _hasBannedSubstring = {
	params ["_str", "_bannedList"];
	private _lcStr = toLower _str;
	{
		if (_lcStr find toLower _x != -1) exitWith { true };
		false
	} forEach _bannedList;
};

private _getConfig = {
	configFile >> "CfgVehicles" >> _className
};

//// === FILTERS ===

// 1. Filter by mod name
// Only allow classnames that START WITH EVTCG_modName (CASE-SENSITIVE)
private _modCheck = false;

if (EVTCG_modName != "") then { _modCheck = true };

if (_modCheck && !(_className find EVTCG_modName == 0)) exitWith { false };

    
if (EVTCG_DebugMode && !(_className find EVTCG_modName == 0)) exitWith {
	diag_log format ["[ERROR] _className passed filter despite wrong mod tag = %1, tag: %2", _className, EVTCG_modName];
	false
};

// 2. Filter by vehicle type
// If EVTCG_vehicleType is defined and non-empty, only allow matching vehicleClass
private _typesToCheck = if (!isNil "EVTCG_vehicleType" && { count EVTCG_vehicleType > 0 }) then {
	EVTCG_vehicleType
} else {
	["Car", "Tank", "Air", "Ship", "Static"]
};

private _matchesType = false;
{
	if (_className isKindOf _x) exitWith { _matchesType = true };
} forEach _typesToCheck;

if (!_matchesType) exitWith { false };

// 3. Filter by banned substrings in className
private _classBannedSubstrings = [
	"_base",
	"_item_",
	"_weapon_",
	"_lhd_",
	"_lpd_",
	"_canopy",
	"_ejectionseat",
	"wreck"
];
if ([_className, _classBannedSubstrings] call _hasBannedSubstring) exitWith { false };

// 4. Filter by config attributes
private _cfg = call _getConfig;

//Filter out Backpack, Man and UAV (if not included in EVTCG_vehicleType)
if (getNumber (_cfg >> "isBackpack") == 1) exitWith { false };
if (getNumber (_cfg >> "isMan") == 1) exitWith { false };
if (EVTCG_vehicleType find "UAV" == -1) then {
	if (getNumber (_cfg >> "isUav") == 1) exitWith { false };
};

// Filter out hidden/abstract/protected scope
private _scope = getNumber (_cfg >> "scope");
if (isNil "_scope" || _scope == 0) exitWith { false };

// 5. Filter by banned substrings in displayName or textSingular
private _displayName = getText (_cfg >> "displayName");
private _textSingular = getText (_cfg >> "textSingular");

private _textBannedSubstrings = [
	"ground",
	"building",
	"house",
	"test",
	"wreck",
	"unknown"
];

if ([_displayName, _textBannedSubstrings] call _hasBannedSubstring) exitWith { false };
if ([_textSingular, _textBannedSubstrings] call _hasBannedSubstring) exitWith { false };

//// === CUSTOM FILTER ===
if (!isNil "EVTCG_customFilter") then {
	if !(call EVTCG_customFilter) exitWith { false };
};

//// === PASSED ALL FILTERS ===
true
