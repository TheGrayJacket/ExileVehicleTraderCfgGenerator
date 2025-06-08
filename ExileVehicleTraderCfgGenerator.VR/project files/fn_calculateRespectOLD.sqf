////fn_calculateRespect.sqf

params [
	["_className", "undefined"],
	["_displayName", "unnamed"],
	["_armor", 0],
	["_armorStructural", 1],
	["_explosionShielding", 1],
	["_crewExplosionProtection", 0],
	["_transportAmmo", 0],
	["_transportFuel", 0],
	["_transportRepair", 0],
	["_attendant", 0],
	["_maxSpeed", 0],
	["_terrainCoef", 3],
	["_maximumLoad", 0],
	["_armaments", []]
];

private _respect = 1;

// 1. ARMOR RESPECT
private _effectiveArmor = 0;
if (_armorStructural != 0) then {
	_effectiveArmor = _armor * (1 / _armorStructural);
};

if (_effectiveArmor >= 81 && _effectiveArmor <= 120) then {_respect = _respect + 1};
if (_effectiveArmor >= 121 && _effectiveArmor <= 250) then {_respect = _respect + 2};
if (_effectiveArmor >= 251 && _effectiveArmor <= 450) then {_respect = _respect + 3};
if (_effectiveArmor > 450) then {_respect = _respect + 4};

// 2. SUPPLY RESPECT
if (_transportFuel > 0) then {_respect = _respect + 1};       // Refuel
if (_transportRepair > 0) then {_respect = _respect + 1};     // Repair
if (_transportAmmo > 0) then {_respect = _respect + 1};       // Rearm

// 3. SPEED RESPECT
if (_maxSpeed > 200) then {_respect = _respect + 1};

// 4. CARGO RESPECT
if (_maximumLoad >= 3001 && _maximumLoad <= 4000) then {_respect = _respect + 1};
if (_maximumLoad > 4000) then {_respect = _respect + 2};

// 5. ARMAMENT RESPECT
private _respectWeapons = [
	"m134", "minigun", "lmg",
	"m2", "hmg",
	"gmg", "mk19",
	"rcws",
	"rocket",
	"vulcan",
	"cannon",
	"artillery"
];

private _allWeapons = [];

{
	{
		if (_x isEqualType []) then {
			{
				if (_x isEqualType "" && {_x != ""}) then {
					_allWeapons pushBack _x;
				};
			} forEach _x;
		} else {
			if (_x isEqualType "" && {_x != ""}) then {
				_allWeapons pushBack _x;
			};
		};
	} forEach _x;
} forEach _armaments;

private _alreadyCounted = [];

{
	private _weapon = toLower _x;

	{
		private _pattern = _x;
		if (_weapon find _pattern > -1) then {
			if (!(_pattern in _alreadyCounted)) then {
				_respect = _respect + 1;
				_alreadyCounted pushBack _pattern;

				if (ETCG_DebugMode) then {
					diag_log format ["Weapon matched for respect: %1", _pattern];
				};
			};
		};
	} forEach _respectWeapons;
} forEach _allWeapons;

// Final cap and logging
if (_respect > 6) then {
	if (ETCG_DebugMode) then {
		diag_log format ["Respect %1 is above cap. Capping at 6.", _respect];
	};
	_respect = 6;
};

if (ETCG_DebugMode) then {
	diag_log format ["Final Respect Score for %1 (%2): %3", _displayName, _className, _respect];
};

_respect