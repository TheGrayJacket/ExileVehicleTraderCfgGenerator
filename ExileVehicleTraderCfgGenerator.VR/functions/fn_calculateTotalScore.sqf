////fn_calculateTotalScore.sqf
    params [
        ["_multipliedScore", 0],
        ["_armamentScore", 0]
    ];
	
	private _totalScore = _multipliedScore + _armamentScore;
	
	if (EVTCG_DebugMode) then {
		diag_log format ["Total Score: %1", _totalScore];
	};
		
	private _finalScore = if (_totalScore < 10000) then {
		ceil (_totalScore / 100) * 100
	} else {
		ceil (_totalScore / 1000) * 1000
	};

	if (EVTCG_DebugMode) then {
		diag_log format ["Final Rounded Score: %1", _finalScore];
	};
	
    _finalScore