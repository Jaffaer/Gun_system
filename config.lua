---------------------------|
----- JF  GUN CLUTCH ------|
---------------------------|

JF = {}

JF.Debug = false

JF.Framework = "qb"

JF.Clutch = {
    ["EnableCooldown"] = false,
    ["CooldownTime"] = 3000,
    ["ClutchDuration"] = 1800,
    ["BlockedJobs"] = {
        police = true,
        ambulance = true,
        sheriff = true
        -- Add more if you want 
        -- realestate = true,
        -- taxi = true,
        -- mechanic = true,
        -- cardealer = true 
    }
}

---------------------------|
----- JF  GUN JAMMING -----|
---------------------------|

JF.Jamming = {
    ["Enabled"] = true,
    ["Cooldown"] = 5,
    ["Animation"] = { 
        ["Dict"] = "mp_missheist_countrybank@nervous",
        ["Anim"] = "nervous_idle"
    },
    ["Chance"] = {
        [80] = 15,
        [50] = 10,
        [40] = 15,
        [30] = 20,
        [20] = 25,
        [10] = 30
    }
}

JF.Notification = function(data)
    lib.notify(data)
end

JF.Labels = {
    ["has_jammed"] = {
        ["title"] = "Vapnet Jammade!",
        ["description"] = "Ditt vapen har jammat! Kolla dess skick!",
        ["type"] = "error",
        ["icon"] = "fa-solid fa-triangle-exclamation",
    },
    ["has_unjammed"] = {
        ["title"] = "Ojammat!",
        ["description"] = "Du har ojammat ditt vapen!",
        ["type"] = "success",
        ["icon"] = "fa-solid fa-person-rifle",
    },

}
