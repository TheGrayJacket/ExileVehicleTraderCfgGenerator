////fn_getArmaments.sqf

params [
	["_className", ""]
];

private _debug = true;

private _configPath = configFile >> "CfgVehicles" >> _className;
private _parentClass = configName (inheritsFrom _configPath);
private _parentConfigPath =  configFile >> "CfgVehicles" >> _parentClass;
private _parentParentClass = configName (inheritsFrom _parentConfigPath);
private _parentParentConfigPath = configFile >> "CfgVehicles" >> _parentParentClass;
private _armaments = [];

private _mainTurretWeapons = [];
if (isClass (_configPath >> "Turrets" >> "MainTurret")) then {
	_mainTurretWeapons = getArray (_configPath >> "Turrets" >> "MainTurret" >> "weapons");
					   

  
						
						   

							
												
													   
};

if (_debug) then {diag_log format ["[EVTCG] [getArmaments] _mainTurretWeapons: %1", _mainTurretWeapons];};
												
																			
	 
	
											  

		 
  

private _commanderTurretWeapons = [];
if (isClass (_configPath >> "Turrets" >> "CommanderOptics")) then {
	_commanderTurretWeapons append (getArray (_configPath >> "Turrets" >> "CommanderOptics" >> "weapons")); 
}; 
//sometimes, commander guns are shown here: configfile >> "CfgVehicles" >> "O_MBT_04_command_F" >> "Turrets" >> "MainTurret" >> "Turrets" >> "CommanderOptics" >> "weapons" -> we also need to take that into account
if (isClass (_configPath >> "Turrets" >> "MainTurret" >> "Turrets" >> "CommanderOptics")) then {
	_commanderTurretWeapons append (getArray (_configPath >> "Turrets" >> "MainTurret" >> "Turrets" >> "CommanderOptics" >> "weapons")); 
};
if (_debug) then {diag_log format ["[EVTCG] [getArmaments] _commanderTurretWeapons: %1", _commanderTurretWeapons];};

// Get weapons
private _weapons = [];
if (isArray (_configPath >> "weapons")) then {
	_weapons append (getArray (_configPath >> "weapons")); 
};
if (_debug) then {diag_log format ["[EVTCG] [getArmaments] Weapons: %1", _weapons];};
  

// Get parents weapons
if (isArray (_parentConfigPath >> "weapons")) then {
	private _parentWeapons = getArray (_parentConfigPath >> "weapons");
	_weapons append _parentWeapons; 
	if (_debug) then {diag_log format ["[EVTCG] [getArmaments] Parent weapons: %1", _parentWeapons];};
};

// Get parents parent weapons
if (isArray (_parentParentConfigPath >> "weapons")) then {
	private _parentParentWeapons = getArray (_parentParentConfigPath >> "weapons");
	_weapons append _parentParentWeapons; 
	if (_debug) then {diag_log format ["[EVTCG] [getArmaments] Parent parent weapons: %1", _parentParentWeapons];};
};

if (_debug) then {diag_log format ["[EVTCG] [getArmaments] _weapons: %1", _weapons];};

private _completeArray = _mainTurretWeapons + _commanderTurretWeapons + _weapons;
_completeArray = _completeArray arrayIntersect _completeArray;

				
if (EVTCG_DebugMode) then {
	diag_log format ["[EVTCG] _completeArray for %1 : %2", _classname, _completeArray];
};

_armaments pushback _completeArray;

private _armamentsArray = [];
// Flatten the array and get rid of empty spaces
{
	{
		if (_x isEqualType []) then {
			{
				if (_x isEqualType "" && {_x != ""}) then {
					_armamentsArray pushBack _x;
				};
			} forEach _x;
		} else {
			if (_x isEqualType "" && {_x != ""}) then {
				_armamentsArray pushBack _x;
			};
		};
	} forEach _x;
} forEach _armaments;

if (EVTCG_DebugMode) then {
	diag_log format ["[EVTCG] _armaments for %1 flattened: %2", _classname, _armamentsArray];
};

_armamentsArray
