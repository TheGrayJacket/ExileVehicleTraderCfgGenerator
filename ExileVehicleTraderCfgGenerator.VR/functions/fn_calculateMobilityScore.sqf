////fn_calculateMobilityScore.sqf

params [
	["_maxSpeed", 0],
	["_terrainCoef", 3]
];


private _speedScore = _maxSpeed * EVTCG_MS_perSpeed;											
private _terrainCoefMult = _maxSpeed * ((_terrainCoef / 3) * EVTCG_MS_terrainCoefMult);

private _mobilityScore = _speedScore + _terrainCoefMult;

if (EVTCG_DebugMode) then {
	diag_log format ["Mobility Score: %1", _mobilityScore];
};

_speedScore
