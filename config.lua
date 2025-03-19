return {
    Debug = false,
    Zones = {
        ["police"] = {
            job = 'police',
            zone = {    
                points = {
                    vec3(362.0, -617.0, 29.0),
                    vec3(365.0, -609.0, 29.0),
                    vec3(374.0, -611.0, 29.0),
                    vec3(368.0, -618.0, 29.0),
                },
                thickness = 4.0,
            },
            duty = {
                coords = vec3(370.6229, -612.3512, 28.8611),
                distance = 3.0, 
                useTarget = true, -- if enabled distance becomes the radius of the target
                marker = { -- only required if useTarget is false
                    type = 2,
                    red = 255,
                    green = 0,
                    blue = 0,
                    opacity = 50,
                }
            },
            blip = {
                coords = vec3(370.6229, -612.3512, 28.8611),
                enabled = true, -- enable/disable blip
                label = 'UwuJob',
                DutyRequired = true, -- only show blip if at least 1 player is on duty
                sprite = 631,
                color = 2,
                scale = 0.8,
                display = 4,
            }
    
        },
    }
}
