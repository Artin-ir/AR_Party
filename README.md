## Party System for FiveM
## Commands

`/cparty`
`/pinv [id]`
`/acpinv` 
`/pkick [id]`


**Example**
```lua

RegisterCommand('startrob', function(source)
    -- Check if player is in a party
    if not exports['party_system']:IsInParty(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { 'AR', 'You must be in a party to start this robbery!' } })
        return
    end
    -- Check if the party has exactly 2 members to
    local members = exports['party_system']:GetPartyMembers(source)
    if not members or #members ~= 2 then
        TriggerClientEvent('chat:addMessage', source, { args = { '[AR]', 'This robbery requires 2 players in your party!' } })
        return
    end
    -- Start robbery for all party members or blah blah whatever you want to do
    for _, id in ipairs(members) do
        TriggerClientEvent('chat:addMessage', id, { args = { '[AR]', 'Your party has started a robbery!' } })
        TriggerClientEvent('robbery:start', id, members)
    end
end)

