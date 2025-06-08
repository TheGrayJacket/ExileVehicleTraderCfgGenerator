//// fn_calculateDefenseScore.sqf

params [
    ["_armor", 0],
    ["_armorStructural", 1],  // default to 1 to avoid division by 0
    ["_explosionShielding", 0],
    ["_crewExplosionProtection", 0]
];

private _ASDebug = true;

if (EVTCG_DebugMode) then {
    diag_log format ["Input - Armor: %1, Structural: %2, Shielding: %3, CrewProtection: %4",
        _armor, _armorStructural, _explosionShielding, _crewExplosionProtection];
};

private _effectiveArmor = 0;
if (!isNil "_armorStructural" && {_armorStructural != 0}) then {
	_effectiveArmor = _armor * _armorStructural;
	if (EVTCG_DebugMode) then {diag_log format ["Effective armor calculated: %1", _effectiveArmor];};
} else {
	if (EVTCG_DebugMode) then {diag_log "ArmorStructural is 0 — cannot calculate effectiveArmor";};
};

_effectiveArmor = _effectiveArmor * EVTCG_DS_perEffectiveHP;
if (EVTCG_DebugMode && _ASDebug) then {diag_log format ["_effectiveArmor Score: %1 ( %2 )",_effectiveArmor,EVTCG_DS_perEffectiveHP];};

private _resistanceExplosion = (_effectiveArmor * (10 - _explosionShielding)) * EVTCG_DS_explosionShieldingMult;
if (EVTCG_DebugMode && _ASDebug) then {diag_log format ["_resistanceExplosion Score: %1 ( %2 )",_resistanceExplosion,EVTCG_DS_explosionShieldingMult];};
private _resistanceCrewExplosion = (_effectiveArmor * (_crewExplosionProtection + 1)) * EVTCG_DS_crewExplosionProtectionMult;
if (EVTCG_DebugMode && _ASDebug) then {diag_log format ["_resistanceCrewExplosion Score: %1 ( %2 )",_resistanceCrewExplosion,EVTCG_DS_crewExplosionProtectionMult];};
private _defenseScore = _effectiveArmor + _resistanceExplosion + _resistanceCrewExplosion;

if (EVTCG_DebugMode) then {
	diag_log format ["Defense Score: %1", _defenseScore];
};

_defenseScore