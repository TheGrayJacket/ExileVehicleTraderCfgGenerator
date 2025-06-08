private _debugLog = true;

private _className = "B_MRAP_01_F";
private _displayName = "Hunter MRAP";
private _armor = 120;
private _armorStructural = 1;
private _explosionShielding = 0.8;
private _crewExplosionProtection = 0.3;
private _transportAmmo = 0;
private _transportFuel = 1e12;
private _transportRepair = 1e12;
private _attendant = 0;
private _maxSpeed = 110;
private _terrainCoef = 2.8;
private _maximumLoad = 700;
private _armaments = [[["CUP_Vacannon_2A28","CUP_Vhmg_PKT_veh_noeject","CUP_Vmlauncher_AT3_veh"],"CUP_RscOptics_gunner_CO",[],""]];

// ========== 1. DEFENSE SCORE ==========
private _effectiveArmor = 0;
if (_armorStructural != 0) then {
	_effectiveArmor = _armor * (1 / _armorStructural);
	if (_debugLog) then {diag_log format ["Effective armor calculated: %1", _effectiveArmor];};
} else {
	if (_debugLog) then {diag_log "ArmorStructural is 0 — cannot calculate effectiveArmor";};
};

private _resistanceExplosion = (_effectiveArmor * ((1 - _explosionShielding) + 1)) * 0.5;
private _resistanceCrewExplosion = (_effectiveArmor * (_crewExplosionProtection + 1)) * 0.3;
private _defenseMultiplier = 1.25;
private _defenseScore = (_effectiveArmor + _resistanceExplosion + _resistanceCrewExplosion) * _defenseMultiplier;

if (_debugLog) then {
	diag_log format ["Defense Score: %1", _defenseScore];
};

// ========== 2. SUPPLY SCORE ==========
private _supplyScore = 0;

private _ammoScore = 0;
if (1e12 > 0) then {
	_ammoScore = (_transportAmmo / 1e12) * 15000;
	if (_ammoScore > 15000) then {_ammoScore = 15000};
};

private _fuelScore = 0;
if (1e12 > 0) then {
	_fuelScore = (_transportFuel / 1e12) * 5000;
	if (_fuelScore > 5000) then {_fuelScore = 5000};
};

private _repairScore = 0;
if (1e12 > 0) then {
	_repairScore = (_transportRepair / 1e12) * 10000;
	if (_repairScore > 10000) then {_repairScore = 10000};
};

private _attendantScore = 0;
if (1e12 > 0) then {
	_attendantScore = (_attendant / 1e12) * 5000;
	if (_attendantScore > 5000) then {_attendantScore = 5000};
};

_supplyScore = _ammoScore + _fuelScore + _repairScore + _attendantScore;

if (_debugLog) then {
	diag_log format ["Supply Score: %1", _supplyScore];
};

// ========== 3. MOBILITY SCORE ==========
private _speedScore = 0;
if (_maxSpeed >= 66 && _maxSpeed < 100) then {_speedScore = 2000};
if (_maxSpeed >= 100 && _maxSpeed < 150) then {_speedScore = 5000};
if (_maxSpeed >= 150) then {_speedScore = 8000};

private _mobilityScore = _speedScore * (_terrainCoef / 3);
if (_debugLog) then {
	diag_log format ["Mobility Score: %1", _mobilityScore];
};

// ========== 4. CARGO SCORE ==========
private _cargoScore = 0;
if (_maximumLoad > 500) then {
	_cargoScore = (_maximumLoad - 500) * 10;
	if (_cargoScore > 30000) then {_cargoScore = 30000};
};

if (_debugLog) then {
	diag_log format ["Cargo Score: %1", _cargoScore];
};

// ========== 5. ARMAMENT SCORE ==========
private _armamentScore = 0;
private _unmatchedArmaments = [];
private _scorePatterns = [
	["vlmg", 1000],
	["lmg", 1000],
	["vhmg", 5000],
	["hmg", 5000],
	["vgmg", 8000],
	["gmg", 8000],
	["vacannon", 15000],
	["cannon", 15000],
	["missile", 20000],
	["igla", 20000]
];

private _allWeapons = [];

{
	{
		if (_x isEqualType []) then {
			{
				if (_x isEqualType "" && {_x != ""}) then {
					_allWeapons pushBack _x;
					if (_debugLog) then {diag_log format ["Flattened weapon: %1", _x];};
				};
			} forEach _x;
		} else {
			if (_x isEqualType "" && {_x != ""}) then {
				_allWeapons pushBack _x;
			};
		};
	} forEach _x;
} forEach _armaments;

if (_debugLog) then {diag_log format ["All weapons collected: %1", _allWeapons];};

{
	private _weap = toLower _x;
	private _matched = false;

	{
		private _pattern = _x select 0;
		private _score = _x select 1;

		if (_weap find _pattern > -1) exitWith {
			_armamentScore = _armamentScore + _score;
			_matched = true;
			if (_debugLog) then {
				diag_log format ["Matched weapon '%1' with pattern '%2' for score %3", _weap, _pattern, _score];
			};
		};
	} forEach _scorePatterns;

	if (!_matched && _debugLog) then {
		diag_log format ["Unmatched weapon: %1", _weap];
	};
} forEach _allWeapons;

// ========== 6. FINAL SCORING ==========
private _totalScore = _defenseScore + _supplyScore + _mobilityScore + _cargoScore + _armamentScore;
private _finalScore = if (_totalScore < 10000) then {
	ceil (_totalScore / 100) * 100
} else {
	ceil (_totalScore / 1000) * 1000
};

if (_debugLog) then {
	diag_log format ["Total Score: %1 | Final Rounded Score: %2", _totalScore, _finalScore];
};

systemChat str _finalScore;
