////fn_calculateArmamentScore.sqf

params [
	["_armaments", []]
];

private _armamentScore = 0;
private _unmatchedArmaments = [];

private _allWeapons = [];

{
	{
		if (_x isEqualType []) then {
			{
				if (_x isEqualType "" && {_x != ""}) then {
					_allWeapons pushBack _x;
					if (ETCG_DebugMode) then {diag_log format ["Flattened weapon: %1", _x];};
				};
			} forEach _x;
		} else {
			if (_x isEqualType "" && {_x != ""}) then {
				_allWeapons pushBack _x;
			};
		};
	} forEach _x;
} forEach _armaments;

if (ETCG_DebugMode) then {diag_log format ["All weapons collected: %1", _allWeapons];};

{
	private _weap = toLower _x;
	private _matched = false;

	{
		private _pattern = _x select 0;
		private _score = _x select 1;

		if (_weap find _pattern > -1) exitWith {
			_armamentScore = _armamentScore + _score;
			_matched = true;
			if (ETCG_DebugMode) then {
				diag_log format ["Matched weapon '%1' with pattern '%2' for score %3", _weap, _pattern, _score];
			};
		};
	} forEach ETCG_AS_perArmament;

	if (!_matched) then {
		diag_log format ["Unmatched weapon: %1", _weap];
	};
} forEach _allWeapons;

_armamentScore