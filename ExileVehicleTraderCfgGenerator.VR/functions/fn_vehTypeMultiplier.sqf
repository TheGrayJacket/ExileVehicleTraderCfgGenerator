////fn_vehTypeMultiplier.sqf
    params [
        ["_partialScore", 0],
		["_className", objNull]
    ];
	
	// Default multiplier
	private _typeMultiplier = 1;
	private _type = "any";
	
	// Determine vehicle type and find multiplier
	{
		private _typeName = _x select 0;
		private _multiplier = _x select 1;
		
		if ((_className isEqualType "" && { _className isKindOf _typeName })
		) exitWith {
			_typeMultiplier = _multiplier;
			_type = _typeName;
		};
	} forEach EVTCG_TS_perVehTypeMult;

	// Apply multiplier
	private _multipliedScore = _partialScore * _typeMultiplier;
	
	if (EVTCG_DebugMode) then {
		diag_log format ["Vehicle Type Multiplier: %1 ( %2 )", _typeMultiplier, _type];
	};
		
    _multipliedScore