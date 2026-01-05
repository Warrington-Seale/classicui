--[[-------------------------------------------------------------------------
-- BlizzardFrames.lua
--
-- This file contains the definitions of the blizzard frame integration
-- options. These settings will not apply until the user interface is
-- reloaded.
--
-- Events registered:
--   * ADDON_LOADED - To watch for loading of the ArenaUI
-------------------------------------------------------------------------]]--

---@class CliqueAddon
local addon = select(2, ...)
local L = addon.L

function addon:FindHealthManaBars(obj)
    local checked = {}
    local health = nil
    local mana = nil

    local traverse

    traverse = function(current)
        if type(current) ~= "table" then return end
        if checked[current] then return end

        checked[current] = true
        for key, value in pairs(current) do
            if key == "HealthBar" then
                health = value
            elseif key == "ManaBar" then
                mana = value
            elseif type(value) == "table" then
                traverse(value)
            end
        end
    end

    traverse(obj)
    return health, mana
end

local buffParentKeysExact = {
    ["Debuff1"] = true,
    ["Debuff2"] = true,
    ["Debuff3"] = true,
    ["centerStatusIcon"] = true,
    ["CenterDefensiveBuff"] = true,
}

local buffGlobalNamePatterns = {
    "^.+Buff%d$",
    "^.+Debuff%d$",
    "^.+DispelDebuff1$",
    "^.+CenterStatusIcon$",
}

function addon:FindBuffFrames(obj)
    local checked = {}
    local found = {}

    local traverse
    traverse = function(current)
        if type(current) ~= "table" then return end
        if checked[current] then return end

        checked[current] = true
        for key, value in pairs(current) do

            -- Check the parent key names exactly
            if key and buffParentKeysExact[key] then
                table.insert(found, value)
            elseif type(value) == "table" and value.GetName and pcall(value.GetName, value) and type(value:GetName()) == "string" then
                local name = value:GetName()
                for _, pattern in ipairs(buffGlobalNamePatterns) do
                    if name:match(pattern) then
                        table.insert(found, value)
                    end
                end
            elseif type(value) == "table" then
                traverse(value)
            end
        end
    end

    traverse(obj)
    return found
end

local function registerFrameOutOfcombat(frame)
        -- Stash the frame in case we later convert it
    local frameName = frame

    -- Convert a frame name to the global object
    if type(frame) == "string" then
        frameName = frame
        frame = _G[frameName]
        if not frame then
            addon:Printf(L["Error registering frame: %s"], tostring(frameName))
            return
        end
    end

    if not frame then
        addon:Printf(L["Unable to register empty frame: %s]"], tostring(frameName))
        return
    end

    -- Never allow forbidden frames, we can't do anything with those!
    local forbidden = frame.IsForbidden and frame:IsForbidden()
    if forbidden then
        return
    end

    local buttonish = frame and frame.RegisterForClicks
    local protected = frame.IsProtected and frame:IsProtected()
    local nameplateish = frame and frame.GetName and frame:GetName() and frame:GetName():match("^NamePlate")
    local anchorRestricted = frame.IsAnchoringRestricted and frame:IsAnchoringRestricted()

    -- A frame must be a button, and must be protected, and must not be a nameplate, anchor restricted
    local valid = buttonish and protected and (not nameplateish) and (not anchorRestricted)

    local statusBarFix = addon.settings.blizzframes.statusBarFix
    if statusBarFix then
        local health, mana = addon:FindHealthManaBars(frame)

        if health and health.SetPropagateMouseMotion then
            health:SetPropagateMouseMotion(true)
        end
        if mana and mana.SetPropagateMouseMotion then
            mana:SetPropagateMouseMotion(true)
        end
    end

    local buffFrames = addon:FindBuffFrames(frame)
    for _, value in ipairs(buffFrames) do
        if value.SetPropagateMouseMotion then
            value:SetPropagateMouseMotion(true)
        end
    end

    if valid then
        ClickCastFrames[frame] = true
    end
end

-- Register a Blizzard frame for click-casting, with some additional protection
function addon:RegisterBlizzardFrame(frame)
    if InCombatLockdown() then
        local deferred = function()
            registerFrameOutOfcombat(frame)
        end

        addon:Defer(deferred)
    else
        registerFrameOutOfcombat(frame)
    end
end
