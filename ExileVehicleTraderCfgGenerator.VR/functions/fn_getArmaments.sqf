//// fn_getArmaments.sqf

params [
	["_className", ""]
];

private _debug = true;

private _configPath = configFile >> "CfgVehicles" >> _className;
private _parentClass = configName (inheritsFrom _configPath);
private _parentConfigPath = configFile >> "CfgVehicles" >> _parentClass;
private _parentParentClass = configName (inheritsFrom _parentConfigPath);
private _parentParentConfigPath = configFile >> "CfgVehicles" >> _parentParentClass;
						

// Recursive function to collect all weapons from any turret, any depth
private _getWeaponsFromTurrets = {
	params ["_turretPath"];
	private _weapons = [];

	{
		if (isClass _x) then {
			private _subTurret = _x;

			// Add weapons if defined
			if (isArray (_subTurret >> "weapons")) then {
				_weapons append getArray (_subTurret >> "weapons");
			};

			// Recursively scan nested turrets
			if (isClass (_subTurret >> "Turrets")) then {
				_weapons append ([_subTurret >> "Turrets"] call _getWeaponsFromTurrets);
			};
		};
	} forEach ("true" configClasses _turretPath);

	_weapons
};

private _turretWeapons = [];
if (isClass (_configPath >> "Turrets")) then {
	_turretWeapons = [(_configPath >> "Turrets")] call _getWeaponsFromTurrets;
};

if (_debug) then {
	diag_log format ["[EVTCG] [getArmaments] All turret weapons: %1", _turretWeapons];
};
																													

// Get direct weapons
private _weapons = [];
if (isArray (_configPath >> "weapons")) then {
	_weapons append getArray (_configPath >> "weapons");
  
	if (_debug) then { diag_log format ["[EVTCG] [getArmaments] Weapons: %1", _weapons]; };
};

// Get parent weapons
if (isArray (_parentConfigPath >> "weapons")) then {
	private _parentWeapons = getArray (_parentConfigPath >> "weapons");
	_weapons append _parentWeapons;
	if (_debug) then { diag_log format ["[EVTCG] [getArmaments] Parent weapons: %1", _parentWeapons]; };
};

// Get parent-parent weapons
if (isArray (_parentParentConfigPath >> "weapons")) then {
	private _parentParentWeapons = getArray (_parentParentConfigPath >> "weapons");
	_weapons append _parentParentWeapons;
	if (_debug) then { diag_log format ["[EVTCG] [getArmaments] Parent parent weapons: %1", _parentParentWeapons]; };
};

// Merge, deduplicate

private _completeArray = (_turretWeapons + _weapons) arrayIntersect (_turretWeapons + _weapons);
															  

// Final logging
if (EVTCG_DebugMode) then {
	diag_log format ["[EVTCG] _completeArray for %1 : %2", _className, _completeArray];
};

// Flattening and cleanup

private _armamentsArray = [];
												
{
  
	if (_x isEqualType []) then {
	
		{ if (_x isEqualType "" && {_x != ""}) then { _armamentsArray pushBack _x; } } forEach _x;
								 
	  
				
	} else {
		if (_x isEqualType "" && {_x != ""}) then {
			_armamentsArray pushBack _x;
		};
	};
} forEach _completeArray;
					 

if (EVTCG_DebugMode) then {
	diag_log format ["[EVTCG] _armaments for %1 flattened: %2", _className, _armamentsArray];
};

_armamentsArray
