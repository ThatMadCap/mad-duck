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

-- Receive footstep event from client and broadcast to all nearby players
RegisterNetEvent('mad-duck:server:footstepSound')
AddEventHandler('mad-duck:server:footstepSound', function(maxDistance)
    local src = source
    local DistanceLimit = 300

    if maxDistance < DistanceLimit then
        TriggerClientEvent(
            'mad-duck:client:playSoundAtLocation',
            -1,
            GetEntityCoords(GetPlayerPed(src)),
            maxDistance
        )
    else
        print(('%s attempted to trigger mad-duck:server:footstepSound over the distance limit: '
        .. DistanceLimit):format(GetPlayerName(src)))
    end
end)