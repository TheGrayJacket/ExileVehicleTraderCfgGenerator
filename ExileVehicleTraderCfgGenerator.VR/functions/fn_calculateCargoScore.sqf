////fn_calculateCargoScore.sqf

params [
	["_maximumLoad", 0],
	["_transportSoldier", 0]
];

private _maxLoadScore = (_maximumLoad * EVTCG_CS_perLoad);

private _perSeatScore = (_transportSoldier * EVTCG_CS_perSeat);

private _cargoScore = _maxLoadScore + _perSeatScore;

if (EVTCG_DebugMode) then {
	diag_log format ["Cargo Score: %1", _cargoScore];
};

_cargoScore