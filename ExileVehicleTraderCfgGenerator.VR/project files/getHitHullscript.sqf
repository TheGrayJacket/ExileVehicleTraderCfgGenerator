// Get the classname of the object the cursor is pointing at
private _className = typeOf cursorObject;

// Construct the config path to the vehicle's class
private _configPath = configFile >> "CfgVehicles" >> _className;

// Initialize variable to store HitHull properties
private _armorHull = "NoHull";

// Check if the HitHull class exists within HitPoints
if (isClass (_configPath >> "HitPoints" >> "HitHull")) then {
    // Get the HitHull config path
    private _hitHullPath = _configPath >> "HitPoints" >> "HitHull";

    // Get the properties within HitHull
    private _properties = configProperties [_hitHullPath];
    
    // Initialize an empty array to store property values
    private _propertyValues = [];

    // Iterate through each property and get its value
    {
        private _propertyValue;
        
        // Determine the type of the property and get its value accordingly
        if (isNumber (_hitHullPath >> _x)) then {
            _propertyValue = getNumber (_hitHullPath >> _x);
        } else {
            if (isText (_hitHullPath >> _x)) then {
                _propertyValue = getText (_hitHullPath >> _x);
            } else {
                if (isArray (_hitHullPath >> _x)) then {
                    _propertyValue = getArray (_hitHullPath >> _x);
                } else {
                    _propertyValue = "UnknownType";
                };
            };
        };
        
        // Add the property value to the array
        _propertyValues pushBack _propertyValue;
    } forEach _properties;

    // Copy the array of property values to the clipboard and display a hint
    copyToClipboard str _propertyValues;
    hint str _propertyValues;
} else {
    // If HitHull class doesn't exist, copy and display "NoHull"
    copyToClipboard str _armorHull;
    hint str _armorHull;
};
