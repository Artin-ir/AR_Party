# AR_PartySystem
Party System for FiveM

## Commands

| Command | Description |
|----------|-------------|
| `/cparty` | Create a new party (you become the leader) |
| `/pinv [id]` | Invite a player to your party (leader only) |
| `/acpinv` | Accept the latest invite (expires in 20 seconds) |
| `/pkick [id]` | Kick a player from your party (leader only) |


**Example:**
```lua
if not exports['party_system']:IsInParty(source) then
 TriggerClientEvent('chat:addMessage', source, { args = { '[Example]', 'You must be in a party to use this feature.' } })
 return
end
