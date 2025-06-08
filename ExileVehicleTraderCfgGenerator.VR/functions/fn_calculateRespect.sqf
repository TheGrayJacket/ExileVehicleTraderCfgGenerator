////fn_calculateRespect.sqf

params [
	["_className", "undefined"],
	["_displayName", "unnamed"],
	["_armor", 0],
	["_armorStructural", 1],
	["_transportAmmo", 0],
	["_transportFuel", 0],
	["_transportRepair", 0],
	["_maxSpeed", 0],
	["_armamentsArray", []]
];

private _respect = 1;

//if (_className isKindOf "Helicopter") then { _respect = 2 };

// 1. DEFENSE RESPECT
private _effectiveArmor = 0;
if (_armorStructural != 0) then {
	_effectiveArmor = _armor * _armorStructural;
};

if (_effectiveArmor > 400) then {_respect = _respect + 1};

// 2. UTILITY RESPECT
if ((_transportFuel > 0) || (_transportRepair > 0) || (_transportAmmo > 0)) then {_respect = _respect + 1};

// 3. MOBILITY RESPECT
if (_maxSpeed > 200) then {_respect = _respect + 1};

// 4. CARGO respect
// none

// 5. ARMAMENT RESPECT
private _maxWeaponRespect = 0;
private _unmatchedArmaments = [];

// Step 1: Exact matches (EVTCG_AS_classnameList)
{
	private _weap = toLower _x;
	private _matched = false;

	{
		private _entryName = toLower (_x select 0);
		private _score = _x select 2;

		if (_weap == _entryName) then {
			if (_score > _maxWeaponRespect) then {
				_maxWeaponRespect = _score;
			};
			_matched = true;
		};
	} forEach EVTCG_AS_classnameList;

	if (!_matched) then {
		_unmatchedArmaments pushBackUnique _weap;
	};
} forEach _armamentsArray;

// Step 2: Keyword matches (EVTCG_AS_keywordList)
{
	private _weap = _x;
	private _matched = false;

	{
		private _keyword = toLower (_x select 0);
		private _score = _x select 2;

		if (_weap find _keyword > -1) then {
			if (_score > _maxWeaponRespect) then {
				_maxWeaponRespect = _score;
			};
			_matched = true;
		};
	} forEach EVTCG_AS_keywordList;

	if (!_matched) then {
		diag_log format ["[WARNING] [RespectCalc] Could not find match '%1' for vehicle '%2'", _weap, _className];
	};
} forEach _unmatchedArmaments;

//if (_className isKindOf "Tank") then { _respect = _respect + 4 };

_respect = _respect + _maxWeaponRespect;


// Final cap and logging
if (_respect > 6) then {
	if (EVTCG_DebugMode) then {
		diag_log format ["Respect %1 is above cap. Capping at 6.", _respect];
	};
	_respect = 6;
};

if (EVTCG_DebugMode) then {
	diag_log format ["Final Respect Score for %1 (%2): %3", _displayName, _className, _respect];
};

_respect