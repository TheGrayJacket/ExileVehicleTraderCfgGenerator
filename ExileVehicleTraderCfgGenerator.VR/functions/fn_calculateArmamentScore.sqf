// fn_calculateArmamentScore.sqf

params [
	["_armamentsArray", []],
	["_classname", ""]
];

private _armamentScore = 0;
private _unmatchedArmaments = [];


// Step 1: Exact matches (EVTCG_AS_classnameList)
{
	private _weap = toLower _x;
	private _matched = false;

	{
		private _entryName = toLower (_x select 0);
		private _score = _x select 1;

		if (_weap == _entryName) then {
			_armamentScore = _armamentScore + _score;
			_matched = true;
		};
	} forEach EVTCG_AS_classnameList;

	if (!_matched) then {
		_unmatchedArmaments pushBackUnique _weap;
	};
} forEach _armamentsArray;

if (EVTCG_DebugMode) then {
	diag_log format ["[EVTCG] [ArmScore] Unmatched armaments after exact match: %1", _unmatchedArmaments];
};

// Step 2: Keyword matches (EVTCG_AS_keywordList)
{
	private _weap = _x;
	private _matched = false;

	{
		private _keyword = toLower (_x select 0);
		private _score = _x select 1;

		if (_weap find _keyword > -1) then {
			_armamentScore = _armamentScore + _score;
			_matched = true;
			if (EVTCG_DebugMode) then {
				diag_log format ["[EVTCG] [ArmScore] Keyword match: '%1' contains '%2' for score %3", _weap, _keyword, _score];
			};
		};
	} forEach EVTCG_AS_keywordList;

	if (!_matched) then {
		diag_log format ["[WARNING] Weapon '%1' for vehicle '%2' — no score assigned", _weap, _classname];
		diag_log format ["Weapon classname not found in EVTCG_AS_classnameList"];
		diag_log format ["Partial keyword not found in EVTCG_AS_keywordList"];
		diag_log format ["Please include this weapon classname in either list and run the script for that classname again"];
	};
} forEach _unmatchedArmaments;

if (EVTCG_DebugMode) then {
	diag_log format ["Armament Score: %1", _armamentScore];
};

// Step 4: Return total score
_armamentScore
