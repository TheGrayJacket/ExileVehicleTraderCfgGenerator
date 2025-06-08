////fn_calculateUtilityScore.sqf

params [
	["_transportAmmo", 0],
	["_transportFuel", 0],
	["_transportRepair", 0],
	["_attendant", 0]
];

private _attendantScore = 0;
if (1e12 > 0) then {
	_attendantScore = (_attendant / 1e12) * EVTCG_US_healBonus;
	if (_attendantScore > EVTCG_US_healBonus) then {_attendantScore = EVTCG_US_healBonus};
};

private _fuelScore = 0;
if (1e12 > 0) then {
	_fuelScore = (_transportFuel / 1e12) * EVTCG_US_refuelBonus;
	if (_fuelScore > EVTCG_US_refuelBonus) then {_fuelScore = EVTCG_US_refuelBonus};
};

private _repairScore = 0;
if (1e12 > 0) then {
	_repairScore = (_transportRepair / 1e12) * EVTCG_US_repairBonus;
	if (_repairScore > EVTCG_US_repairBonus) then {_repairScore = EVTCG_US_repairBonus};
};

private _ammoScore = 0;
if (1e12 > 0) then {
	_ammoScore = (_transportAmmo / 1e12) * EVTCG_US_rearmBonus;
	if (_ammoScore > EVTCG_US_rearmBonus) then {_ammoScore = EVTCG_US_rearmBonus};
};

private _utilityScore = _ammoScore + _fuelScore + _repairScore + _attendantScore;

if (EVTCG_DebugMode) then {
	diag_log format ["Utility Score: %1", _utilityScore];
};

_utilityScore