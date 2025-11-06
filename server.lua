local Parties = {}
local PlayerParty = {} 

-- /cparty
RegisterCommand('cparty', function(source)

    if PlayerParty[source] then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'You are already in a party.' } })
        return
    end

    Parties[source] = { members = { source }, invites = {} }


    PlayerParty[source] = source


    TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Party created successfully.' } })
end)

-- /pinv
RegisterCommand('pinv', function(source, args)
    local target = tonumber(args[1])
    if not target or not GetPlayerName(target) then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Invalid player ID.' } })
        return
    end
    local leader = PlayerParty[source]
    if not leader then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'You are not in a party.' } })
        return
    end
    if leader ~= source then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Only the party leader can invite players.' } })
        return
    end
    if PlayerParty[target] then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'That player is already in a party.' } })
        return
    end
    local party = Parties[leader]
    if not party then return end
    party.invites[target] = os.time() + 20
    TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Invite sent to ' .. GetPlayerName(target) .. '.' } })
    TriggerClientEvent('chat:addMessage', target, { args = { '[Party]', 'You were invited to join ' .. GetPlayerName(source) .. '\'s party. Type /acpinv to accept (20s).' } })
end)

-- /acpinv
RegisterCommand('acpinv', function(source)
    for leader, data in pairs(Parties) do
        local expiry = data.invites[source]
        if expiry then
            if os.time() <= expiry then
                table.insert(data.members, source)
                PlayerParty[source] = leader
                data.invites[source] = nil

                TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'You joined the party.' } })
                for _, member in ipairs(data.members) do
                    TriggerClientEvent('chat:addMessage', member, { args = { '[Party]', GetPlayerName(source) .. ' joined the party.' } })
                end
            else
                data.invites[source] = nil
                TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Invite expired.' } })
            end
            return
        end
    end

    TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'You have no pending invites.' } })
end)

-- /pkick
RegisterCommand('pkick', function(source, args)
    local target = tonumber(args[1])
    if not target then return end

    local leader = PlayerParty[source]
    if not leader or leader ~= source then
        TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'You are not the party leader.' } })
        return
    end
    local party = Parties[leader]
    for i, member in ipairs(party.members) do
        if member == target then
            table.remove(party.members, i)
            PlayerParty[target] = nil

            TriggerClientEvent('chat:addMessage', target, { args = { '[Party]', 'You were kicked from the party.' } })
            TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', GetPlayerName(target) .. ' has been kicked.' } })
            return
        end
    end
    TriggerClientEvent('chat:addMessage', source, { args = { '[Party]', 'Player not found in your party.' } })
end)

-- Remove from party on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    local leader = PlayerParty[src]
    if not leader then return end
    local party = Parties[leader]
    if not party then return end
    for i, member in ipairs(party.members) do
        if member == src then
            table.remove(party.members, i)
            break
        end
    end
    PlayerParty[src] = nil
    if leader == src then
        for _, m in ipairs(party.members) do
            PlayerParty[m] = nil
            TriggerClientEvent('chat:addMessage', m, { args = { '[Party]', 'Party disbanded (leader left).' } })
        end
        Parties[leader] = nil
    else
        for _, m in ipairs(party.members) do
            TriggerClientEvent('chat:addMessage', m, { args = { '[Party]', GetPlayerName(src) .. ' left the party.' } })
        end
    end
end)

-- Get members of a player's party
exports('GetPartyMembers', function(playerId)
    local leader = PlayerParty[playerId]
    if not leader then return nil end
    local party = Parties[leader]
    if not party then return nil end
    return party.members
end)

--Check if player is in a party
exports('IsInParty', function(playerId)
    return PlayerParty[playerId] ~= nil
end)

--Get size of a player's party
exports('GetPartySize', function(playerId)
    local leader = PlayerParty[playerId]
    if not leader then return 0 end
    local party = Parties[leader]
    if not party then return 0 end
    return #party.members
end)
