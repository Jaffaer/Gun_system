local utils = {}

function utils.jfDebugger(...)
    if JF.Debug then
        local args = {...}
        local printResult = "^3[jf_jamming] | "
        for i, arg in ipairs(args) do
            if type(arg) == "table" then
                utils.dumpTable(arg)
            else
                printResult = printResult .. tostring(arg) .. "\t"
            end
        end
        printResult = printResult .. "\n"
        print(printResult)
    end
end

function utils.dumpTable(t, indent)
    if JF.Debug then
        indent = indent or 0
        for k,v in pairs(t) do
            local formatting = string.rep("    ", indent) .. k .. ": "
            if type(v) == "table" then
                print(formatting)
                utils.dumpTable(v, indent + 1)
            else
                print(formatting .. tostring(v))
            end
        end
    end
end

local function orderedPairs(t, compareFunc)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    table.sort(keys, compareFunc)

    local i = 0
    return function()
        i = i + 1
        local key = keys[i]
        if key then
            return key, t[key]
        end
    end
end

local function getChance(d)
    local prevKey = nil
    for key in orderedPairs(JF.Jamming["Chance"], function (a, b) return a > b end) do
        if prevKey and d > key and d < prevKey then
            return JF.Jamming["Chance"][prevKey]
        end
        prevKey = key
    end
    return 0
end

function utils.getJammingChance(value)
    local chance = getChance(value)
    math.randomseed(GetGameTimer() * math.random(30568, 90214))
    local random = math.random(1, 100)
    utils.jfDebugger("Random är ", random, " chans är ", chance)
    return random < chance
end

return utils