-- Credits/Comments ------------------------------------------------------

-- Duck sound from: https://pixabay.com/sound-effects/075176-duck-quack-40345
-- Converted to FiveM using: https://github.com/Renewed-Scripts/Audiotool
-- Credit and thanks to: Ehbw, CodeWalker, ChatDisabled, uShifty

-- If you're smart enough to work out how to override the default footstep sounds,
-- you're a wizard. I'm not: so we hack together a solution my way.
-- Experimented with a combination of:
    -- SetForceFootstepUpdate()
    -- UseFootstepScriptSweeteners()
    -- OverridePlayerGroundMaterial()
-- Did not work as expected.

-- Variables ---------------------------------------------------------------

local duckMode = false -- Toggle for duck footsteps
local lastFootstepTime = 0 -- Timestamp of last footstep sound
local footstepThread = nil -- Reference to the footstep detection thread
local lastToggleTime = 0 -- Prevent spam toggling

-- Helper functions ---------------------------------------------------------

-- Load the custom audio bank
local function loadAudioFile()
    if not RequestScriptAudioBank('audiodirectory/duck_sounds', false) then
        while not RequestScriptAudioBank('audiodirectory/duck_sounds', false) do
            Wait(0)
        end
    end

    return true
end

-- Enable/disable default ped footstep sounds
---@param ped number entity id of the ped
---@param toggle boolean -- true to enable footsteps sounds, false to disable
local function editFootsteps(ped, toggle)
    SetPedAudioFootstepQuiet(ped, toggle) -- Enables/disables ped's "quiet" footstep sound.
    SetPedAudioFootstepLoud(ped, toggle) -- Enables/disables ped's "loud" footstep sound.
end

-- Cleanup duck mode state
---@param releaseAudio boolean whether to release the audio bank (only on resource stop)
local function cleanupDuckMode(releaseAudio)
    duckMode = false
    local currentPed = PlayerPedId()
    editFootsteps(currentPed, true) -- Restore normal footsteps
    if releaseAudio then
        ReleaseScriptAudioBank()
    end
end

-- PlaySoundFromCoord wrapper
---@param soundId integer sound ID from GetSoundId()
---@param soundName string name of the sound in the audio bank
---@param x number x coordinate
---@param y number y coordinate
---@param z number z coordinate
---@param soundSet string sound set name
---@param p6 boolean no idea what this does
---@param maxDistance number maximum distance for the sound to be heard
---@param p8 boolean no idea what this does
local function doDaQuack(soundId, soundName, x, y, z, soundSet, p6, maxDistance, p8)
    PlaySoundFromCoord(soundId, soundName, x, y, z, soundSet, p6, maxDistance, p8)
end

-- Main logic ---------------------------------------------------------------

-- Duck mode management
---@param enable boolean true to enable duck mode, false to disable
---@param reason string optional reason for the state change (for logging)
local function setDuckMode(enable, reason)
    reason = reason or "manual toggle"

    -- Stop command spam toggling
    local currentTime = GetGameTimer()
    if reason == "command" and currentTime - lastToggleTime < 500 then
        print("Duck mode toggle cooldown active, please wait...")
        return
    end
    lastToggleTime = currentTime

    print("Duck mode " .. (enable and "enabled" or "disabled") .. " - " .. reason)

    if not enable then
        -- Disable duck mode
        cleanupDuckMode(reason == "resource stop")
        return
    end

    duckMode = true

    if not loadAudioFile() then
        error("Failed to load duck sound audio bank")
        duckMode = false
        return
    end

    local currentPed = PlayerPedId()
    editFootsteps(currentPed, false) -- Mute default footsteps

    -- No spammy thready (kill before a new one)
    if footstepThread then
        footstepThread = nil
    end

    -- Start footstep detection thread
    footstepThread = CreateThread(function()
        while duckMode do
            local ped = PlayerPedId()
            if DoesEntityExist(ped) and IsPedOnFoot(ped) then
                -- maths by Claude (I didn't pay attention to this class in school)
                local velocity = GetEntityVelocity(ped)
                local speed = math.sqrt(velocity.x^2 + velocity.y^2)

                if speed > 1.5 and not IsPedFalling(ped) and not IsPedJumping(ped) then
                    local footstepTime = GetGameTimer()
                    local footstepInterval = speed > 4.0 and 280 or 450 -- Faster for running

                    if footstepTime - lastFootstepTime > footstepInterval then
                        local soundDistance = math.max(1.0, math.min(300.0, Config.SoundDistance))

                        -- Quack quack quack
                        TriggerServerEvent(
                            'mad-duck:server:footstepSound',
                            soundDistance
                        )

                        lastFootstepTime = footstepTime
                    end
                end

                local waitTime = speed > 0 and 50 or 100
                Wait(waitTime)
            else
                Wait(100)
            end
        end

        footstepThread = nil
    end)
end

-- Export toggle function for external use (like inventory items)
exports("quack", function()
    setDuckMode(not duckMode, "inventory item")
end)

-- Commands -------------------------------------------------------------

print("Config.EnableCommand is: " .. tostring(Config.EnableCommand))
if Config.EnableCommand then
    RegisterCommand('quack', function()
        setDuckMode(not duckMode, "command")
    end, false)

    TriggerEvent('chat:addSuggestion', '/quack', 'Toggle ducky footsteps')
end

-- Event Handling --------------------------------------------------------

print("Config.AlwaysStart is: " .. tostring(Config.AlwaysStart))
if Config.AlwaysStart then
    -- Handle resource start (for initial load)
    AddEventHandler('onClientResourceStart', function(resourceName)
        if GetCurrentResourceName() == resourceName then
            setDuckMode(true, 'onClientResourceStart')
        end
    end)

    -- Handle player loaded/unloaded events for frameworks
    local frameworkEvents = {
        { resource = 'ox_core',loginEvent = 'ox:playerLoaded', logoutEvent = 'ox:playerLogout' },
        { resource = 'qb-core', loginEvent = 'QBCore:Client:OnPlayerLoaded', logoutEvent = 'QBCore:Client:OnPlayerUnload' },
        { resource = 'es_extended', loginEvent = 'esx:playerLoaded', logoutEvent = 'esx:onPlayerLogout' }
    }

    for _, framework in ipairs(frameworkEvents) do
        if GetResourceState(framework.resource) == 'started' then
            print(framework.resource .. " detected as started")
            -- Register login event
            RegisterNetEvent(framework.loginEvent, function()
                setDuckMode(true, framework.loginEvent)
            end)
            -- Register logout event
            RegisterNetEvent(framework.logoutEvent, function()
                setDuckMode(false, framework.logoutEvent)
            end)
        end
    end
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        setDuckMode(false, "resource stop")
    end
end)

-- Sound sync ----------------------------------------------------------

-- Because I used this resource as a reference:
-- https://github.com/plunkettscott/interact-sound/tree/master
-- I'm including the license below of which this code is based on.

-- MIT License

-- Copyright (c) 2017 Scott Plunkett

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- Receive networked duck sound from server and play it locally if within range
RegisterNetEvent('mad-duck:client:playSoundAtLocation')
AddEventHandler('mad-duck:client:playSoundAtLocation', function(otherPlayerCoords, maxDistance)
	local myCoords = GetEntityCoords(PlayerPedId())
	local distance = #(myCoords - otherPlayerCoords)

	if distance < maxDistance then
		if not loadAudioFile() then
			print("Failed to load duck sound audio bank for networked sound")
			return
		end

		local soundId = GetSoundId()
		if soundId == -1 then
			print("Failed to get sound ID for duck sound")
			return
		end

        -- Quack quack quack
		doDaQuack(soundId,
            "quack",
            otherPlayerCoords.x,
            otherPlayerCoords.y,
            otherPlayerCoords.z,
            'mad_soundset',
            false,
            maxDistance,
            false
        )

		ReleaseSoundId(soundId)
	end
end)


