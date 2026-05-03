local LibAlts = LibStub:GetLibrary("LibAlts-1.0")
if not LibAlts then print("LibAlts-1.0 not found. AltTooltips will not work."); return end

--Cache global variables
local _G = _G
local pairs = pairs

---
-- GLOBALS: 
---
local CHAR_INFO

function AltTooltips_HookSetUnit(...)
    local name = GameTooltip:GetUnit();
    if not name or (UnitName("mouseover") ~= name) then
        return
    end

    local main = AltTooltips_GetMain(name)

    if main then
        local class = CHAR_INFO[main] and CHAR_INFO[main].class
        local colorStr = class and RAID_CLASS_COLORS[strupper(class)].colorStr or "ff00FF00"
        GameTooltip:AddLine("|c"..colorStr..TitleCase(main).."|r|cffffffff's alt|r")
    end
end

function AltTooltips_AddAlt(main, alt)
    LibAlts:SetAlt(main, alt)
end

function AltTooltips_GetMain(alt)
    if LibAlts:IsAlt(alt) then
        return LibAlts:GetMain(alt)
    end

    return nil
end

function AltTooltips_Initialize()
	if not IsInGuild() then
		return
	end

	local names = {}
	CHAR_INFO = {}

	for i=1,GetNumGuildMembers(true) do
		local name, _, _, _, class, _, _, _, _, _ = GetGuildRosterInfo(i);
        if name then
            names[strlower(name)] = name
            CHAR_INFO[name] = {name = name, class = class}
        end
	end

	for i=1, GetNumGuildMembers(true) do
		local alt, rank, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i);
		local success
        if officernote then
            for word in gmatch(strlower(officernote), "[%a\128-\255]+") do
                local main = names[word]
                if main then
                    AltTooltips_AddAlt(main, alt)
                    success = true
                    break
                end
            end
        end
        if not note then return end
		for word in gmatch(strlower(note), "[%a\128-\255]+") do
            local main = names[word]
			if main then
                AltTooltips_AddAlt(main, alt)
				success = true
				break
			end
		end

		if not success and note ~= "" then
			rank = strlower(rank)
			if strfind(rank, "alt") then
				CHAR_INFO[alt] = {name = note, class = class}
			end
		end
	end
end

function TitleCase(str)
    return str:gsub("(%a)([%w_'-]*)", function(first, rest) return first:upper() .. rest:lower() end)
end

function AltTooltips_EventHandler(self, event, ...)
    if event == "GUILD_ROSTER_UPDATE" then
        AltTooltips_Initialize()
    end
end

GameTooltip:HookScript("OnTooltipSetUnit", AltTooltips_HookSetUnit)
GameTooltipStatusBar:HookScript("OnValueChanged", AltTooltips_HookSetUnit)
--GameTooltip:HookScript("GameTooltip_SetDefaultAnchor", AltTooltips_HookSetUnit)
local frame = CreateFrame("Frame", "AltTooltipsFrame", UIParent)
frame:RegisterEvent("GUILD_ROSTER_UPDATE", AltTooltips_Initialize)
frame:SetScript("OnEvent", AltTooltips_EventHandler)
