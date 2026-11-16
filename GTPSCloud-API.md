# GTPSCloud Lua API

Referensi API scripting Lua GTPSCloud dalam satu file Markdown.

- Sumber resmi: [GTPSCloud Lua API Docs](https://dash.gtps.cloud/docs).
- Diambil pada: 16 November 2026 (UTC).
- Cakupan: seluruh halaman kelas, callback, fungsi global, dan utilitas yang ditautkan dari navigasi docs.
- Halaman referensi dapat dibaca tanpa login pada saat pengambilan.

## Cara membaca

Nama fungsi, urutan parameter, tipe hasil, deskripsi, dan contoh kode dipertahankan dari sumber berbahasa Inggris agar detail teknis tetap sesuai referensi. `Parameters` berarti parameter masukan; `Returns` berarti nilai hasil. `void` menandakan tidak ada nilai hasil yang didokumentasikan. Tanda `?` pada tipe mengikuti notasi sumber.

Blok kode berasal dari docs: sebagian hanya menunjukkan signature pemanggilan, bukan skrip siap jalan. Parameter tanpa tipe atau nilai default di sumber tetap ditampilkan tanpa menambahkan asumsi. Keterangan parameter opsional mengikuti deskripsi setiap fungsi.

Dokumen ini membahas API Lua di lingkungan GTPSCloud. Autentikasi REST, HTTP endpoint dashboard, rate limit, dan kode status tidak ditambahkan karena bukan cakupan referensi tersebut.

## Daftar isi

- [Player](#bagian-player)
- [World](#bagian-world)
- [Tile](#bagian-tile)
- [Item](#bagian-item)
- [IOTM](#bagian-iotm)
- [Guild](#bagian-guild)
- [ShopItem](#bagian-shop-item)
- [GrowtopiaBot](#bagian-growtopia-bot)
- [Drop](#bagian-drop)
- [PlayerAutofarm](#bagian-player-autofarm)
- [InventoryItem](#bagian-inventory-item)
- [PlayerSubscription](#bagian-player-subscription)
- [DiscordBot](#bagian-discord-bot)
- [DiscordButtonClickEvent](#bagian-discord-button-click-event)
- [DiscordFormSubmitEvent](#bagian-discord-form-submit-event)
- [DiscordMessageCreateEvent](#bagian-discord-message-create-event)
- [DiscordSlashCommandEvent](#bagian-discord-slash-command-event)
- [Font](#bagian-font)
- [RenderTexture](#bagian-render-texture)
- [Sprite](#bagian-sprite)
- [Texture](#bagian-texture)
- [ActiveEffects](#bagian-active-effects)
- [http](#bagian-http)
- [file](#bagian-file)
- [dir](#bagian-dir)
- [timer](#bagian-timer)
- [sqlite](#bagian-sqlite)
- [SqliteDB](#bagian-sqlite-db)
- [bit](#bagian-bit)
- [os](#bagian-os)
- [Callbacks](#bagian-callbacks)
- [Global Functions](#bagian-globals)
- [Utilities](#bagian-utilities)

---

<a id="bagian-player"></a>

## Player

The Player class represents a player. Use these methods to interact with player data, inventory, appearance, and more.

### Player

#### Player:getName()

Returns the name for this avatar.

**Returns:** `string`

```lua
Player:getName()
```

#### Player:enterWorld(worldName, notification, bypass)

Runs the enter world operation for this avatar. It uses worldName, notification, optional bypass.

**Parameters:** `worldName`, `notification`, `bypass`

**Returns:** `void`

```lua
Player:enterWorld(worldName, notification, bypass)
```

#### Player:leaveWorld()

Runs the leave world operation for this avatar.

**Returns:** `void`

```lua
Player:leaveWorld()
```

#### Player:punchBlock(x, y)

Runs the punch block operation for this avatar. It uses x, y.

**Parameters:** `x`, `y`

**Returns:** `void`

```lua
Player:punchBlock(x, y)
```

#### Player:placeBlock(x, y, itemID)

Runs the place block operation for this avatar. It uses x, y, itemID.

**Parameters:** `x`, `y`, `itemID`

**Returns:** `void`

```lua
Player:placeBlock(x, y, itemID)
```

#### Player:getCleanName()

Returns the clean name for this avatar.

**Returns:** `string`

```lua
Player:getCleanName()
```

#### Player:getRealName()

Returns the real name for this avatar.

**Returns:** `string`

```lua
Player:getRealName()
```

#### Player:getRealCleanName()

Returns the real clean name for this avatar.

**Returns:** `string`

```lua
Player:getRealCleanName()
```

#### Player:getTotalWorldLocks()

Returns the total world locks for this avatar.

**Returns:** `number`

```lua
Player:getTotalWorldLocks()
```

#### Player:getUserID()

Returns the user ID for this avatar.

**Returns:** `number`

```lua
Player:getUserID()
```

#### Player:getPosX()

Returns the pos x for this avatar.

**Returns:** `number`

```lua
Player:getPosX()
```

#### Player:getPosY()

Returns the pos y for this avatar.

**Returns:** `number`

```lua
Player:getPosY()
```

#### Player:getBlockPosX()

Returns the block pos x for this avatar.

**Returns:** `number`

```lua
Player:getBlockPosX()
```

#### Player:getBlockPosY()

Returns the block pos y for this avatar.

**Returns:** `number`

```lua
Player:getBlockPosY()
```

#### Player:getMiddlePosX()

Returns the middle pos x for this avatar.

**Returns:** `number`

```lua
Player:getMiddlePosX()
```

#### Player:getMiddlePosY()

Returns the middle pos y for this avatar.

**Returns:** `number`

```lua
Player:getMiddlePosY()
```

#### Player:getNetID()

Returns the net ID for this avatar.

**Returns:** `number`

```lua
Player:getNetID()
```

#### Player:hasMod(modID)

Checks whether this avatar has mod. It uses modID.

**Parameters:** `modID`

**Returns:** `boolean`

```lua
Player:hasMod(modID)
```

#### Player:hasRole(roleID)

Checks whether this avatar has role. It uses roleID.

**Parameters:** `roleID`

**Returns:** `boolean`

```lua
Player:hasRole(roleID)
```

#### Player:setRole(roleID)

Sets the role for this avatar. It uses roleID.

**Parameters:** `roleID`

**Returns:** `void`

```lua
Player:setRole(roleID)
```

#### Player:addMod(modID, value)

Adds mod data or value to this avatar. It uses modID, value.

**Parameters:** `modID`, `value`

**Returns:** `void`

```lua
Player:addMod(modID, value)
```

#### Player:removeMod(modID)

Removes the mod from this avatar. It uses modID.

**Parameters:** `modID`

**Returns:** `void`

```lua
Player:removeMod(modID)
```

#### Player:getMod(modID)

Returns the active effect for the given mod ID, or nil.

**Parameters:** `modID`

**Returns:** `ActiveEffects?`

```lua
Player:getMod(modID)
```

#### Player:changeItem(itemID, itemCount, addBackpack)

Runs the change item operation for this avatar. It uses itemID, itemCount, addBackpack.

**Parameters:** `itemID`, `itemCount`, `addBackpack`

**Returns:** `boolean`

```lua
Player:changeItem(itemID, itemCount, addBackpack)
```

#### Player:getItemAmount(itemID)

Returns the item amount for this avatar.

**Parameters:** `itemID`

**Returns:** `number`

```lua
Player:getItemAmount(itemID)
```

#### Player:getItemAmountBackpack(itemID)

Returns the item amount backpack for this avatar.

**Parameters:** `itemID`

**Returns:** `number`

```lua
Player:getItemAmountBackpack(itemID)
```

#### Player:getXP()

Returns the XP for this avatar.

**Returns:** `number`

```lua
Player:getXP()
```

#### Player:setXP(xp)

Sets the XP for this avatar. It uses xp.

**Parameters:** `xp`

**Returns:** `void`

```lua
Player:setXP(xp)
```

#### Player:removeXP(xp)

Removes the XP from this avatar. It uses xp.

**Parameters:** `xp`

**Returns:** `void`

```lua
Player:removeXP(xp)
```

#### Player:getLevel()

Returns the level for this avatar.

**Returns:** `number`

```lua
Player:getLevel()
```

#### Player:getStats(statType)

Returns the stats for this avatar.

**Parameters:** `statType`

**Returns:** `number`

```lua
Player:getStats(statType)
```

#### Player:setStats(statType, statNumber)

Sets the stats for this avatar. It uses statType, statNumber.

**Parameters:** `statType`, `statNumber`

**Returns:** `void`

```lua
Player:setStats(statType, statNumber)
```

#### Player:getRequiredXP()

Returns the required XP for this avatar.

**Returns:** `number`

```lua
Player:getRequiredXP()
```

#### Player:getGems()

Returns the gems for this avatar.

**Returns:** `number`

```lua
Player:getGems()
```

#### Player:addGems(gems, instantSet, progressQuests)

Adds gems to the avatar, updates the gem display, and optionally progresses gem-related quests.

**Parameters:** `gems`, `instantSet`, `progressQuests`

**Returns:** `void`

```lua
Player:addGems(gems, instantSet, progressQuests)
```

#### Player:removeGems(gems, instantSet)

Removes gems from the avatar and updates the gem display. Returns false if the avatar doesn't have enough.

**Parameters:** `gems`, `instantSet`

**Returns:** `boolean`

```lua
Player:removeGems(gems, instantSet)
```

#### Player:setGems(gems, instantSet)

Sets the avatar gem balance and updates the client display according to the instant flag. Returns true.

**Parameters:** `gems`, `instantSet`

**Returns:** `boolean`

```lua
Player:setGems(gems, instantSet)
```

#### Player:updateGems(instantSet)

Refreshes the avatar gem display on the client.

**Parameters:** `instantSet`

**Returns:** `void`

```lua
Player:updateGems(instantSet)
```

#### Player:getAutofarm()

Returns the autofarm for this avatar.

**Returns:** `PlayerAutofarm`

```lua
Player:getAutofarm()
```

#### Player:onConsoleMessage(message, delay)

Triggers the console message behavior for this avatar. It uses message, optional delay.

**Parameters:** `message`, `delay`

**Returns:** `void`

```lua
Player:onConsoleMessage(message, delay)
```

#### Player:playAudio(message)

Plays the audio for the target client. It uses message.

**Parameters:** `message`

**Returns:** `void`

```lua
Player:playAudio(message)
```

#### Player:onDialogRequest(message, delay, callback)

Shows a dialog. If callback is a function, it is registered for the dialog name found after end_dialog| in the message.

**Parameters:** `message`, `delay`, `callback`

**Returns:** `void`

```lua
Player:onDialogRequest(message, delay, callback)
```

#### Player:onStoreRequest(message, delay)

Triggers the store request behavior for this avatar. It uses message, optional delay.

**Parameters:** `message`, `delay`

**Returns:** `void`

```lua
Player:onStoreRequest(message, delay)
```

#### Player:onStorePurchaseResult(message, delay)

Triggers the store purchase result behavior for this avatar. It uses message, optional delay.

**Parameters:** `message`, `delay`

**Returns:** `void`

```lua
Player:onStorePurchaseResult(message, delay)
```

#### Player:onTalkBubble(netID, message, persistMessage, delay)

Triggers the talk bubble behavior for this avatar. It uses netID, message, persistMessage, optional delay.

**Parameters:** `netID`, `message`, `persistMessage`, `delay`

**Returns:** `void`

```lua
Player:onTalkBubble(netID, message, persistMessage, delay)
```

#### Player:onTextOverlay(message, delay)

Triggers the text overlay behavior for this avatar. It uses message, optional delay.

**Parameters:** `message`, `delay`

**Returns:** `void`

```lua
Player:onTextOverlay(message, delay)
```

#### Player:canFit(items)

Checks whether the avatar inventory can fit the items. items is a table of { id, count } pairs.

**Parameters:** `items`

**Returns:** `boolean`

```lua
Player:canFit(items)
```

#### Player:getCoins()

Returns the coins for this avatar.

**Returns:** `number`

```lua
Player:getCoins()
```

#### Player:addCoins(coins)

Adds coins data or value to this avatar. It uses coins.

**Parameters:** `coins`

**Returns:** `void`

```lua
Player:addCoins(coins)
```

#### Player:setCoins(coins)

Sets the coins for this avatar. It uses coins.

**Parameters:** `coins`

**Returns:** `void`

```lua
Player:setCoins(coins)
```

#### Player:removeCoins(coins, progressQuests)

Removes the coins from this avatar. It uses coins, progressQuests.

**Parameters:** `coins`, `progressQuests`

**Returns:** `boolean`

```lua
Player:removeCoins(coins, progressQuests)
```

#### Player:progressQuests(itemID, itemCount)

Runs the progress quests operation for this avatar. It uses itemID, itemCount.

**Parameters:** `itemID`, `itemCount`

**Returns:** `void`

```lua
Player:progressQuests(itemID, itemCount)
```

#### Player:upgradeInventorySpace(size)

Runs the upgrade inventory space operation for this avatar. It uses size.

**Parameters:** `size`

**Returns:** `void`

```lua
Player:upgradeInventorySpace(size)
```

#### Player:removeInventorySpace(size)

Removes the inventory space from this avatar. It uses size.

**Parameters:** `size`

**Returns:** `void`

```lua
Player:removeInventorySpace(size)
```

#### Player:setInventorySpace(newSize)

Sets the inventory space for this avatar. It uses newSize.

**Parameters:** `newSize`

**Returns:** `void`

```lua
Player:setInventorySpace(newSize)
```

#### Player:isMaxInventorySpace()

Checks whether this avatar is max inventory space.

**Returns:** `boolean`

```lua
Player:isMaxInventorySpace()
```

#### Player:getInventorySize()

Returns the inventory size for this avatar.

**Returns:** `number`

```lua
Player:getInventorySize()
```

#### Player:onRedeemMenu()

Triggers the redeem menu behavior for this avatar.

**Returns:** `void`

```lua
Player:onRedeemMenu()
```

#### Player:getWorldName()

Returns the world name for this avatar.

**Returns:** `string`

```lua
Player:getWorldName()
```

#### Player:getWorld()

Returns the world for this avatar.

**Returns:** `World`

```lua
Player:getWorld()
```

#### Player:onGrow4GoodDonate()

Triggers the grow4 good donate behavior for this avatar.

**Returns:** `void`

```lua
Player:onGrow4GoodDonate()
```

#### Player:getMods()

Returns all active effects for this avatar.

**Returns:** `{ActiveEffects}`

```lua
Player:getMods()
```

#### Player:getClothingItemID(index)

Returns the clothing item ID for this avatar.

**Parameters:** `index`

**Returns:** `number`

```lua
Player:getClothingItemID(index)
```

#### Player:getSubscription(subType)

Returns the subscription of the given type, or nil.

**Parameters:** `subType`

**Returns:** `PlayerSubscription?`

```lua
Player:getSubscription(subType)
```

#### Player:addSubscription(Type, exp)

Adds a subscription of the given type. exp is the expiry timestamp; 0 makes it permanent.

**Parameters:** `Type`, `exp`

**Returns:** `PlayerSubscription`

```lua
Player:addSubscription(Type, exp)
```

#### Player:removeSubscription(type)

Removes the subscription from this avatar. It uses type.

**Parameters:** `type`

**Returns:** `void`

```lua
Player:removeSubscription(type)
```

#### Player:getPlaytime()

Returns the playtime for this avatar.

**Returns:** `number`

```lua
Player:getPlaytime()
```

#### Player:setPlaytime(time)

Sets the playtime for this avatar. It uses time.

**Parameters:** `time`

**Returns:** `void`

```lua
Player:setPlaytime(time)
```

#### Player:addPlaytime(time)

Adds playtime data or value to this avatar. It uses time.

**Parameters:** `time`

**Returns:** `void`

```lua
Player:addPlaytime(time)
```

#### Player:getAccountCreationTime()

Returns the account creation time for this avatar.

**Returns:** `number`

```lua
Player:getAccountCreationTime()
```

#### Player:setAccountCreationTime(time)

Sets the account creation time for this avatar. It uses time.

**Parameters:** `time`

**Returns:** `void`

```lua
Player:setAccountCreationTime(time)
```

#### Player:getAccountCreationDateStr()

Returns the account creation date str for this avatar.

**Returns:** `string`

```lua
Player:getAccountCreationDateStr()
```

#### Player:getTransformProfileButtons()

Returns the transform profile buttons for this avatar.

**Returns:** `string`

```lua
Player:getTransformProfileButtons()
```

#### Player:onTradeHistoryUI(targetPlayer)

Triggers the trade history UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onTradeHistoryUI(targetPlayer)
```

#### Player:onBackpackUI(targetPlayer)

Triggers the backpack UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onBackpackUI(targetPlayer)
```

#### Player:onMentorshipUI()

Triggers the mentorship UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onMentorshipUI()
```

#### Player:onVouchersUI()

Triggers the vouchers UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onVouchersUI()
```

#### Player:onNameIconsUI(targetPlayer)

Triggers the name icons UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onNameIconsUI(targetPlayer)
```

#### Player:onWrenchIconsUI(targetPlayer)

Triggers the wrench icons UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onWrenchIconsUI(targetPlayer)
```

#### Player:onTitlesUI(targetPlayer)

Triggers the titles UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onTitlesUI(targetPlayer)
```

#### Player:onAchievementsUI(targetPlayer)

Triggers the achievements UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onAchievementsUI(targetPlayer)
```

#### Player:onClothesUI(targetPlayer)

Triggers the clothes UI behavior for this avatar. It uses optional targetPlayer.

**Parameters:** `targetPlayer`

**Returns:** `void`

```lua
Player:onClothesUI(targetPlayer)
```

#### Player:getClassicProfileContent(catType, flags)

Returns the classic profile tab content. catType: 1 level up, 2 skills, 3 quests, 4 badges, 5 cheats, 6 locked worlds. flags is only used by the locked worlds tab.

**Parameters:** `catType`, `flags`

**Returns:** `string`

```lua
Player:getClassicProfileContent(catType, flags)
```

#### Player:getDiscordID()

Returns the discord ID for this avatar.

**Returns:** `string`

```lua
Player:getDiscordID()
```

#### Player:onLinkDiscordUI()

Triggers the link discord UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onLinkDiscordUI()
```

#### Player:onUnlinkDiscordUI()

Triggers the unlink discord UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onUnlinkDiscordUI()
```

#### Player:getUnlockedAchievementsCount()

Returns the unlocked achievements count for this avatar.

**Returns:** `number`

```lua
Player:getUnlockedAchievementsCount()
```

#### Player:getBackpackUsedSize()

Returns the backpack used size for this avatar.

**Returns:** `number`

```lua
Player:getBackpackUsedSize()
```

#### Player:onFavItemsUI()

Triggers the fav items UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onFavItemsUI()
```

#### Player:onOnlineStatusUI()

Triggers the online status UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onOnlineStatusUI()
```

#### Player:getOnlineStatus()

Returns the online status for this avatar.

**Returns:** `number`

```lua
Player:getOnlineStatus()
```

#### Player:onPersonalizeWrenchUI()

Triggers the personalize wrench UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onPersonalizeWrenchUI()
```

#### Player:getHomeWorldID()

Returns the home world ID for this avatar.

**Returns:** `number`

```lua
Player:getHomeWorldID()
```

#### Player:getProfileGuildInfo()

Returns the profile guild info for this avatar.

**Returns:** `string`

```lua
Player:getProfileGuildInfo()
```

#### Player:getSubscriptionInfo()

Returns the subscription info for this avatar.

**Returns:** `string`

```lua
Player:getSubscriptionInfo()
```

#### Player:getCardBattleInfo()

Returns the card battle info for this avatar.

**Returns:** `string`

```lua
Player:getCardBattleInfo()
```

#### Player:getProfileAccessButton()

Returns the profile access button for this avatar.

**Returns:** `string`

```lua
Player:getProfileAccessButton()
```

#### Player:getProfileGuildJoinButton()

Returns the profile guild join button for this avatar.

**Returns:** `string`

```lua
Player:getProfileGuildJoinButton()
```

#### Player:onBillboardUI()

Triggers the billboard UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onBillboardUI()
```

#### Player:onNotebookUI()

Triggers the notebook UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onNotebookUI()
```

#### Player:onGrowpassUI()

Triggers the growpass UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onGrowpassUI()
```

#### Player:onGrowmojiUI()

Triggers the growmoji UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onGrowmojiUI()
```

#### Player:onGrow4GoodUI()

Triggers the grow4 good UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onGrow4GoodUI()
```

#### Player:onTradeScanUI()

Triggers the trade scan UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onTradeScanUI()
```

#### Player:getGuildID()

Returns the guild ID for this avatar.

**Returns:** `number`

```lua
Player:getGuildID()
```

#### Player:onGuildNotebookUI()

Triggers the guild notebook UI behavior for this avatar.

**Returns:** `void`

```lua
Player:onGuildNotebookUI()
```

#### Player:onProfileUI(world, tab)

Triggers the profile UI behavior for this avatar. It uses world, tab.

**Parameters:** `world`, `tab`

**Returns:** `void`

```lua
Player:onProfileUI(world, tab)
```

#### Player:onAddNotification(texture, message, audio, num, delay)

Triggers the add notification behavior for this avatar. It uses texture, message, audio, num, optional delay.

**Parameters:** `texture`, `message`, `audio`, `num`, `delay`

**Returns:** `void`

```lua
Player:onAddNotification(texture, message, audio, num, delay)
```

#### Player:onParticleEffect(particleID, posX, posY, num, num2, delay)

Triggers the particle effect behavior for this avatar. It uses particleID, posX, posY, num, num2, optional delay.

**Parameters:** `particleID`, `posX`, `posY`, `num`, `num2`, `delay`

**Returns:** `void`

```lua
Player:onParticleEffect(particleID, posX, posY, num, num2, delay)
```

#### Player:setNextDialogRGBA(R, G, B, A)

Sets the next dialog RGBA for this avatar. It uses R, G, B, A.

**Parameters:** `R`, `G`, `B`, `A`

**Returns:** `void`

```lua
Player:setNextDialogRGBA(R, G, B, A)
```

#### Player:resetDialogColor()

Resets the dialog color for this avatar.

**Returns:** `void`

```lua
Player:resetDialogColor()
```

#### Player:setNextDialogBorderRGBA(R, G, B, A)

Sets the next dialog border RGBA for this avatar. It uses R, G, B, A.

**Parameters:** `R`, `G`, `B`, `A`

**Returns:** `void`

```lua
Player:setNextDialogBorderRGBA(R, G, B, A)
```

#### Player:updateStats(world, type, amount)

Updates the stats for this avatar. It uses world, type, optional amount.

**Parameters:** `world`, `type`, `amount`

**Returns:** `void`

```lua
Player:updateStats(world, type, amount)
```

#### Player:getCountry()

Returns the country for this avatar.

**Returns:** `string`

```lua
Player:getCountry()
```

#### Player:setCountry(country)

Sets the country for this avatar. It uses country.

**Parameters:** `country`

**Returns:** `void`

```lua
Player:setCountry(country)
```

#### Player:getPlatform()

Returns the platform for this avatar.

**Returns:** `string`

```lua
Player:getPlatform()
```

#### Player:sendVariant(variantList, delay, netID)

Sends a variant list packet to the online avatar. variantList is a table of strings, numbers, {x, y} vectors or {x, y, z} vectors.

**Parameters:** `variantList`, `delay`, `netID`

**Returns:** `void`

```lua
Player:sendVariant(variantList, delay, netID)
```

#### Player:sendAction(action_str)

Sends the action to the target client or service. It uses action_str.

**Parameters:** `action_str`

**Returns:** `void`

```lua
Player:sendAction(action_str)
```

#### Player:getInventoryItems()

Returns the inventory items for this avatar.

**Returns:** `{InventoryItem}`

```lua
Player:getInventoryItems()
```

#### Player:disconnect()

Runs the disconnect operation for this avatar.

**Returns:** `void`

```lua
Player:disconnect()
```

#### Player:sendRawPacket(data)

Sends the raw packet to the target client or service. It uses data.

**Parameters:** `data`

**Returns:** `void`

```lua
Player:sendRawPacket(data)
```

#### Player:getType()

Returns the type for this avatar.

**Returns:** `number`

```lua
Player:getType()
```

#### Player:isFacingLeft()

Checks whether this avatar is facing left.

**Returns:** `boolean`

```lua
Player:isFacingLeft()
```

#### Player:isOnline()

Checks whether this avatar is online.

**Returns:** `boolean`

```lua
Player:isOnline()
```

#### Player:addTitle(title_id)

Adds title data or value to this avatar. It uses title_id.

**Parameters:** `title_id`

**Returns:** `void`

```lua
Player:addTitle(title_id)
```

#### Player:hasTitle(title_id)

Checks whether this avatar has title. It uses title_id.

**Parameters:** `title_id`

**Returns:** `boolean`

```lua
Player:hasTitle(title_id)
```

#### Player:removeTitle(title_id)

Removes the title from this avatar. It uses title_id.

**Parameters:** `title_id`

**Returns:** `void`

```lua
Player:removeTitle(title_id)
```

#### Player:getActiveTitles()

Returns the active titles for this avatar.

**Returns:** `{any}`

```lua
Player:getActiveTitles()
```

#### Player:addActiveTitle(title_id)

Adds active title data or value to this avatar. It uses title_id.

**Parameters:** `title_id`

**Returns:** `void`

```lua
Player:addActiveTitle(title_id)
```

#### Player:removeActiveTitle(title_id)

Removes the active title from this avatar. It uses title_id.

**Parameters:** `title_id`

**Returns:** `void`

```lua
Player:removeActiveTitle(title_id)
```

#### Player:addMail(mail)

Adds a mail to the mailbox. Takes { titleID, titleLabel, titleDescription, longDescription, expireTime, rewards = { { id, count } } }.

**Parameters:** `mail`

**Returns:** `void`

```lua
Player:addMail(mail)
```

#### Player:clearMailbox()

Clears the mailbox for this avatar.

**Returns:** `void`

```lua
Player:clearMailbox()
```

#### Player:setNickname(nickname)

Sets the nickname for this avatar. It uses nickname.

**Parameters:** `nickname`

**Returns:** `void`

```lua
Player:setNickname(nickname)
```

#### Player:resetNickname()

Resets the nickname for this avatar.

**Returns:** `void`

```lua
Player:resetNickname()
```

#### Player:getBankBalance()

Returns the bank balance for this avatar.

**Returns:** `number`

```lua
Player:getBankBalance()
```

#### Player:addBankBalance(balance)

Adds bank balance data or value to this avatar. It uses balance.

**Parameters:** `balance`

**Returns:** `void`

```lua
Player:addBankBalance(balance)
```

#### Player:removeBankBalance(balance)

Removes the bank balance from this avatar. It uses balance.

**Parameters:** `balance`

**Returns:** `boolean`

```lua
Player:removeBankBalance(balance)
```

#### Player:setBankBalance(balance)

Sets the bank balance for this avatar. It uses balance.

**Parameters:** `balance`

**Returns:** `void`

```lua
Player:setBankBalance(balance)
```

#### Player:setCountryFlagForeground(item_id)

Sets the country flag foreground for this avatar. It uses item_id.

**Parameters:** `item_id`

**Returns:** `void`

```lua
Player:setCountryFlagForeground(item_id)
```

#### Player:setCountryFlagBackground(item_id)

Sets the country flag background for this avatar. It uses item_id.

**Parameters:** `item_id`

**Returns:** `void`

```lua
Player:setCountryFlagBackground(item_id)
```

#### Player:getCountryFlagForeground()

Returns the country flag foreground for this avatar.

**Returns:** `number`

```lua
Player:getCountryFlagForeground()
```

#### Player:getCountryFlagBackground()

Returns the country flag background for this avatar.

**Returns:** `number`

```lua
Player:getCountryFlagBackground()
```

#### Player:addLevel(level)

Adds level data or value to this avatar. It uses level.

**Parameters:** `level`

**Returns:** `void`

```lua
Player:addLevel(level)
```

#### Player:removeLevel(level)

Removes the level from this avatar. It uses level.

**Parameters:** `level`

**Returns:** `void`

```lua
Player:removeLevel(level)
```

#### Player:setLevel(level)

Sets the level for this avatar. It uses level.

**Parameters:** `level`

**Returns:** `void`

```lua
Player:setLevel(level)
```

#### Player:ban(modDuration, reason, punishedBy, banDevice, banIP)

Runs the ban operation for this avatar. It uses modDuration, reason, punishedBy, banDevice, banIP.

**Parameters:** `modDuration`, `reason`, `punishedBy`, `banDevice`, `banIP`

**Returns:** `void`

```lua
Player:ban(modDuration, reason, punishedBy, banDevice, banIP)
```

#### Player:setRoleQuestLevel(type, newLevel)

Sets the role quest level for this avatar. It uses type, newLevel.

**Parameters:** `type`, `newLevel`

**Returns:** `void`

```lua
Player:setRoleQuestLevel(type, newLevel)
```

#### Player:getRoleQuestLevel(type)

Returns the role quest level for this avatar.

**Parameters:** `type`

**Returns:** `number`

```lua
Player:getRoleQuestLevel(type)
```

#### Player:getIP()

Returns the ip for this avatar.

**Returns:** `string`

```lua
Player:getIP()
```

#### Player:getRID()

Returns the rid for this avatar.

**Returns:** `string`

```lua
Player:getRID()
```

#### Player:setPassword(tankIDPass)

Sets the password for this avatar. It uses tankIDPass.

**Parameters:** `tankIDPass`

**Returns:** `void`

```lua
Player:setPassword(tankIDPass)
```

#### Player:getEmail()

Returns the email for this avatar.

**Returns:** `string`

```lua
Player:getEmail()
```

#### Player:getBackpackItems()

Returns the backpack items for this avatar.

**Returns:** `{InventoryItem}`

```lua
Player:getBackpackItems()
```

#### Player:getGender()

Returns the gender for this avatar.

**Returns:** `number`

```lua
Player:getGender()
```

#### Player:hasActiveBlessing(blessingID)

Checks whether this avatar has active blessing. It uses blessingID.

**Parameters:** `blessingID`

**Returns:** `boolean`

```lua
Player:hasActiveBlessing(blessingID)
```

#### Player:hasBlessing(blessingID)

Checks whether this avatar has blessing. It uses blessingID.

**Parameters:** `blessingID`

**Returns:** `boolean`

```lua
Player:hasBlessing(blessingID)
```

#### Player:removeBlessing(blessingID)

Removes the blessing from this avatar. It uses blessingID.

**Parameters:** `blessingID`

**Returns:** `void`

```lua
Player:removeBlessing(blessingID)
```

#### Player:addBlessing(blessingID)

Adds blessing data or value to this avatar. It uses blessingID.

**Parameters:** `blessingID`

**Returns:** `void`

```lua
Player:addBlessing(blessingID)
```

#### Player:checkPassword(password)

Runs the check password operation for this avatar. It uses password.

**Parameters:** `password`

**Returns:** `boolean`

```lua
Player:checkPassword(password)
```

#### Player:getDiscordInvites()

Returns the discord invites for this avatar.

**Returns:** `number`

```lua
Player:getDiscordInvites()
```

#### Player:doAction(str)

Runs the do action operation for this avatar. It uses str.

**Parameters:** `str`

**Returns:** `void`

```lua
Player:doAction(str)
```

#### Player:doRawPacket(data)

Runs the do raw packet operation for this avatar. It uses data.

**Parameters:** `data`

**Returns:** `void`

```lua
Player:doRawPacket(data)
```

#### Player:getAltAccounts()

Returns the alt accounts for this avatar.

**Returns:** `{Player}`

```lua
Player:getAltAccounts()
```

#### Player:getRole()

Returns the role for this avatar.

**Returns:** `any`

```lua
Player:getRole()
```

#### Player:getTitles()

Returns the titles for this avatar.

**Returns:** `{any}`

```lua
Player:getTitles()
```

#### Player:getOwnedWorlds()

Returns the owned worlds for this avatar.

**Returns:** `{number}`

```lua
Player:getOwnedWorlds()
```

#### Player:getRecentWorlds()

Returns the recent worlds for this avatar.

**Returns:** `{number}`

```lua
Player:getRecentWorlds()
```

#### Player:getAccessWorlds()

Returns the access worlds for this avatar.

**Returns:** `{number}`

```lua
Player:getAccessWorlds()
```

#### Player:getIPHistory()

Returns the iphistory for this avatar.

**Returns:** `{string}`

```lua
Player:getIPHistory()
```

#### Player:getRIDHistory()

Returns the ridhistory for this avatar.

**Returns:** `{string}`

```lua
Player:getRIDHistory()
```

#### Player:getSmallLockedWorlds()

Returns the small locked worlds for this avatar.

**Returns:** `{number}`

```lua
Player:getSmallLockedWorlds()
```

#### Player:setBroadcastWorld(worldName)

Sets the broadcast world for this avatar. It uses worldName.

**Parameters:** `worldName`

**Returns:** `void`

```lua
Player:setBroadcastWorld(worldName)
```

#### Player:getFriends()

Returns the friends for this avatar.

**Returns:** `{number}`

```lua
Player:getFriends()
```

#### Player:addFriend(second_player)

Adds friend data or value to this avatar. It uses second_player.

**Parameters:** `second_player`

**Returns:** `void`

```lua
Player:addFriend(second_player)
```

#### Player:removeFriend(second_player)

Removes the friend from this avatar. It uses second_player.

**Parameters:** `second_player`

**Returns:** `void`

```lua
Player:removeFriend(second_player)
```

#### Player:getLifeGoals()

Returns the life goals for this avatar.

**Returns:** `{any}`

```lua
Player:getLifeGoals()
```

#### Player:getBiweeklyQuests()

Returns the biweekly quests for this avatar.

**Returns:** `{any}`

```lua
Player:getBiweeklyQuests()
```

#### Player:getGrowpassPoints()

Returns the growpass points for this avatar.

**Returns:** `number`

```lua
Player:getGrowpassPoints()
```

#### Player:addGrowpassPoints(points)

Adds growpass points data or value to this avatar. It uses points.

**Parameters:** `points`

**Returns:** `void`

```lua
Player:addGrowpassPoints(points)
```

#### Player:setGrowpassPoints(points)

Sets the growpass points for this avatar. It uses points.

**Parameters:** `points`

**Returns:** `void`

```lua
Player:setGrowpassPoints(points)
```

#### Player:adjustBlockHitCount(adjust)

Runs the adjust block hit count operation for this avatar. It uses adjust.

**Parameters:** `adjust`

**Returns:** `void`

```lua
Player:adjustBlockHitCount(adjust)
```

#### Player:getAdjustedBlockHitCount()

Returns the adjusted block hit count for this avatar.

**Returns:** `number`

```lua
Player:getAdjustedBlockHitCount()
```

#### Player:getPing()

Returns the ping for this avatar.

**Returns:** `number`

```lua
Player:getPing()
```

#### Player:getDungeonScrolls()

Returns the dungeon scrolls for this avatar.

**Returns:** `number`

```lua
Player:getDungeonScrolls()
```

#### Player:setDungeonScrolls(scrolls)

Sets the dungeon scrolls for this avatar. It uses scrolls.

**Parameters:** `scrolls`

**Returns:** `void`

```lua
Player:setDungeonScrolls(scrolls)
```

#### Player:hasGrowID()

Checks whether this avatar has grow id.

**Returns:** `boolean`

```lua
Player:hasGrowID()
```

#### Player:addNote(note)

Adds note data or value to this avatar. It uses note.

**Parameters:** `note`

**Returns:** `void`

```lua
Player:addNote(note)
```

#### Player:setAAPEnabled(aapEnabled)

Sets the aapenabled for this avatar. It uses aapEnabled.

**Parameters:** `aapEnabled`

**Returns:** `void`

```lua
Player:setAAPEnabled(aapEnabled)
```

#### Player:setCustomAutofarmDelay(delay)

Sets the custom autofarm delay for this avatar. It uses delay.

**Parameters:** `delay`

**Returns:** `void`

```lua
Player:setCustomAutofarmDelay(delay)
```

#### Player:getGameVersion()

Returns the game version for this avatar.

**Returns:** `number`

```lua
Player:getGameVersion()
```

#### Player:getItemEffects()

Returns the item effects for this avatar.

**Returns:** `any`

```lua
Player:getItemEffects()
```

#### Player:visualPunch(tile)

Runs the visual punch operation for this avatar. It uses tile.

**Parameters:** `tile`

**Returns:** `void`

```lua
Player:visualPunch(tile)
```

#### Player:visualBuild(tile)

Runs the visual build operation for this avatar. It uses tile.

**Parameters:** `tile`

**Returns:** `void`

```lua
Player:visualBuild(tile)
```

#### Player:getLastOnline()

Returns the last online for this avatar.

**Returns:** `number`

```lua
Player:getLastOnline()
```

#### Player:earnAchievement(type)

Awards the achievement to this avatar. It uses type.

**Parameters:** `type`

**Returns:** `void`

```lua
Player:earnAchievement(type)
```

#### Player:getAchievements()

Returns the achievements for this avatar.

**Returns:** `{any}`

```lua
Player:getAchievements()
```

#### Player:getActivePet()

Returns the active pet for this avatar.

**Returns:** `any`

```lua
Player:getActivePet()
```

#### Player:getEffects()

Returns { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } } for this avatar.

**Returns:** `any`

```lua
Player:getEffects()
```

#### Player:setEffects(effects)

Sets the custom effects for this avatar. Takes a table { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } }. All five numeric fields are required; drops is optional and replaces the existing drops.

**Parameters:** `effects`

**Returns:** `void`

```lua
Player:setEffects(effects)
```

#### Player:deleteEffects()

Deletes the effects resource.

**Returns:** `void`

```lua
Player:deleteEffects()
```

#### Player:getOverlappingTiles()

Returns array of overlapping tiles with player.

**Returns:** `{Tile}`

```lua
Player:getOverlappingTiles()
```

#### Player:setLegendaryWizardTask(currentTaskNum)

Set legendary wizard task ID for player.

**Parameters:** `currentTaskNum`

**Returns:** `void`

```lua
Player:setLegendaryWizardTask(currentTaskNum)
```

#### Player:hasAccessToTile(tile, itemID, isSilent, ignoreReach)

Check if player has access to tile.

**Parameters:** `tile`, `itemID`, `isSilent`, `ignoreReach`

**Returns:** `boolean`

```lua
Player:hasAccessToTile(tile, itemID, isSilent, ignoreReach)
```

#### Player:isPublicTile(tile)

Check whatever the tile is public to the player or not.

**Parameters:** `tile`

**Returns:** `boolean`

```lua
Player:isPublicTile(tile)
```

#### Player:getState()

Returns last registered state of the player.

**Returns:** `number`

```lua
Player:getState()
```

#### Player:hasRoleFlag(flag)

Check if player has role flag, returns boolean.

**Parameters:** `flag`

**Returns:** `boolean`

```lua
Player:hasRoleFlag(flag)
```

#### Player:moveToTile(tile)

NPC only (created with world:createNPC). Pathfinds to the tile. Returns false if the path is blocked or the tile belongs to another world.

**Parameters:** `tile`

**Returns:** `boolean`

```lua
Player:moveToTile(tile)
```

#### Player:moveToPos(x, y)

NPC only. Pathfinds to integer pixel coordinates inside the world. Returns false on failure.

**Parameters:** `x`, `y`

**Returns:** `boolean`

```lua
Player:moveToPos(x, y)
```

#### Player:isMoving()

NPC only. Returns true while the NPC is still following a path.

**Returns:** `boolean`

```lua
Player:isMoving()
```

#### Player:getMovementError()

NPC only. Returns the last movement error message, or nil.

**Returns:** `string?`

```lua
Player:getMovementError()
```

#### Player:setLifeGoalQuestProgress(taskID, value)

Sets the completed value of the life goal task with the given task ID. Completes it when the target is reached.

**Parameters:** `taskID`, `value`

**Returns:** `void`

```lua
Player:setLifeGoalQuestProgress(taskID, value)
```

#### Player:setBiweeklyQuestProgress(taskID, value)

Sets the completed value of the biweekly quest task with the given task ID. Completes it when the target is reached.

**Parameters:** `taskID`, `value`

**Returns:** `void`

```lua
Player:setBiweeklyQuestProgress(taskID, value)
```

#### Player:triggerFindGeiger()

Triggers the found-Geiger event for this avatar in its current world.

**Returns:** `void`

```lua
Player:triggerFindGeiger()
```

#### Player:setFishingWaitTime(time)

Overrides the fishing wait time for this avatar.

**Parameters:** `time`

**Returns:** `void`

```lua
Player:setFishingWaitTime(time)
```

#### Player:setSkinColor(r, g, b, a)

Sets the skin color for this avatar and refreshes its appearance.

**Parameters:** `r`, `g`, `b`, `a`

**Returns:** `void`

```lua
Player:setSkinColor(r, g, b, a)
```

#### Player:createGuild(guildName, guildStatement)

Creates a guild in the world the avatar owns. Errors if the avatar is already in a guild, doesn't own a World Lock world, or the name/statement is invalid (name 3-16 chars, statement 3-32 chars).

**Parameters:** `guildName`, `guildStatement`

**Returns:** `void`

```lua
Player:createGuild(guildName, guildStatement)
```

Sumber: [Player](https://dash.gtps.cloud/docs/player).

---

<a id="bagian-world"></a>

## World

The World class represents a Growtopia world. Use these methods to manage tiles, players, drops, and world properties.

### World

#### World:getName()

Returns the name for this world.

**Returns:** `string`

```lua
World:getName()
```

#### World:getOwner()

Returns the owner for this world.

**Returns:** `Player`

```lua
World:getOwner()
```

#### World:setOwner(user_id)

Sets the owner for this world. It uses user_id.

**Parameters:** `user_id`

**Returns:** `void`

```lua
World:setOwner(user_id)
```

#### World:removeOwner()

Removes the owner from this world.

**Returns:** `void`

```lua
World:removeOwner()
```

#### World:addPunishment(player, type, expiresAt, reason, invoker_id)

Adds a world punishment. expiresAt is stored as an absolute unix timestamp (use os.time() + seconds), not a duration.

**Parameters:** `player`, `type`, `expiresAt`, `reason`, `invoker_id`

**Returns:** `void`

```lua
World:addPunishment(player, type, expiresAt, reason, invoker_id)
```

#### World:removePunishment(player, type)

Removes the punishment from this world. It uses player, type.

**Parameters:** `player`, `type`

**Returns:** `void`

```lua
World:removePunishment(player, type)
```

#### World:getPunishment(player, type)

Returns the punishment for this world.

**Parameters:** `player`, `type`

**Returns:** `any`

```lua
World:getPunishment(player, type)
```

#### World:getAllPunishments()

Returns the all punishments for this world.

**Returns:** `{any}`

```lua
World:getAllPunishments()
```

#### World:getID()

Returns the ID for this world.

**Returns:** `number`

```lua
World:getID()
```

#### World:getTile(x, y)

Returns the tile for this world.

**Parameters:** `x`, `y`

**Returns:** `Tile`

```lua
World:getTile(x, y)
```

#### World:spawnItem(x, y, itemID, itemCount, center_item)

Spawns an item drop at the provided world coordinates. Returns the Drop, or nil if it couldn't spawn. center_item (1/0, default 1) adds a small random offset.

**Parameters:** `x`, `y`, `itemID`, `itemCount`, `center_item`

**Returns:** `Drop?`

```lua
World:spawnItem(x, y, itemID, itemCount, center_item)
```

#### World:spawnGems(x, y, gemsCount, player)

Spawns gem drops at the provided world coordinates, optionally attributed to a player.

**Parameters:** `x`, `y`, `gemsCount`, `player`

**Returns:** `void`

```lua
World:spawnGems(x, y, gemsCount, player)
```

#### World:adjustGems(player, tile, gemsCount, showParticles)

Adjusts gems collected from a tile for the specified player and returns the gem count. showParticles: 1 shows particles.

**Parameters:** `player`, `tile`, `gemsCount`, `showParticles`

**Returns:** `number`

```lua
World:adjustGems(player, tile, gemsCount, showParticles)
```

#### World:onLoot(player, tile, gemsCount)

Runs the world loot handling logic for a player and tile.

**Parameters:** `player`, `tile`, `gemsCount`

**Returns:** `void`

```lua
World:onLoot(player, tile, gemsCount)
```

#### World:useItemEffect(netID, itemID, secondNetID, effectDelay)

Runs the use item effect operation for this world. It uses netID, itemID, secondNetID, effectDelay.

**Parameters:** `netID`, `itemID`, `secondNetID`, `effectDelay`

**Returns:** `void`

```lua
World:useItemEffect(netID, itemID, secondNetID, effectDelay)
```

#### World:useItemTileEffect(tile, netID, itemID, reverse, effectDelay)

Runs the use item tile effect operation for this world. It uses tile, netID, itemID, reverse, effectDelay.

**Parameters:** `tile`, `netID`, `itemID`, `reverse`, `effectDelay`

**Returns:** `void`

```lua
World:useItemTileEffect(tile, netID, itemID, reverse, effectDelay)
```

#### World:getPlayers()

Returns the players for this world.

**Returns:** `{Player}`

```lua
World:getPlayers()
```

#### World:getPlayersCount(show_all)

Returns the players count for this world.

**Parameters:** `show_all`

**Returns:** `number`

```lua
World:getPlayersCount(show_all)
```

#### World:getVisiblePlayersCount()

Returns the visible players count for this world.

**Returns:** `number`

```lua
World:getVisiblePlayersCount()
```

#### World:isGameActive()

Checks whether this world is game active.

**Returns:** `boolean`

```lua
World:isGameActive()
```

#### World:onGameWinHighestScore()

Triggers the game win highest score behavior for this world.

**Returns:** `void`

```lua
World:onGameWinHighestScore()
```

#### World:updateClothing(player)

Updates the clothing for this world. It uses player.

**Parameters:** `player`

**Returns:** `void`

```lua
World:updateClothing(player)
```

#### World:onCreateChatBubble(posX, posY, message, persistMessage)

Triggers the create chat bubble behavior for this world. It uses posX, posY, message, persistMessage.

**Parameters:** `posX`, `posY`, `message`, `persistMessage`

**Returns:** `void`

```lua
World:onCreateChatBubble(posX, posY, message, persistMessage)
```

#### World:onCreateExplosion(posX, posY, radius, power)

Triggers the create explosion behavior for this world. It uses posX, posY, radius, power.

**Parameters:** `posX`, `posY`, `radius`, `power`

**Returns:** `void`

```lua
World:onCreateExplosion(posX, posY, radius, power)
```

#### World:setTileForeground(tile, id, visual_update, player)

Sets the tile foreground for this world. It uses tile, id, optional visual_update, optional player.

**Parameters:** `tile`, `id`, `visual_update`, `player`

**Returns:** `void`

```lua
World:setTileForeground(tile, id, visual_update, player)
```

#### World:setTileBackground(tile, id, visual_update, player)

Sets the tile background for this world. It uses tile, id, optional visual_update, optional player.

**Parameters:** `tile`, `id`, `visual_update`, `player`

**Returns:** `void`

```lua
World:setTileBackground(tile, id, visual_update, player)
```

#### World:getWorldSizeX()

Returns the world size x for this world.

**Returns:** `number`

```lua
World:getWorldSizeX()
```

#### World:getWorldSizeY()

Returns the world size y for this world.

**Returns:** `number`

```lua
World:getWorldSizeY()
```

#### World:getWorldType()

Returns the world type for this world.

**Returns:** `number`

```lua
World:getWorldType()
```

#### World:getTiles()

Returns the tiles for this world.

**Returns:** `{Tile}`

```lua
World:getTiles()
```

#### World:getEmptyTiles()

Returns the empty tiles for this world.

**Returns:** `{Tile}`

```lua
World:getEmptyTiles()
```

#### World:getNoCollisionTiles()

Returns the no collision tiles for this world.

**Returns:** `{Tile}`

```lua
World:getNoCollisionTiles()
```

#### World:getDroppedItems()

Returns the dropped items for this world.

**Returns:** `{Drop}`

```lua
World:getDroppedItems()
```

#### World:getTileDroppedItems(tile)

Returns the tile dropped items for this world.

**Parameters:** `tile`

**Returns:** `{Drop}`

```lua
World:getTileDroppedItems(tile)
```

#### World:addXP(player, xp_amount)

Adds XP data or value to this world. It uses player, xp_amount.

**Parameters:** `player`, `xp_amount`

**Returns:** `void`

```lua
World:addXP(player, xp_amount)
```

#### World:setPlayerPosition(player, x, y, no_packet)

Sets the player position for this world. It uses player, x, y, optional no_packet.

**Parameters:** `player`, `x`, `y`, `no_packet`

**Returns:** `void`

```lua
World:setPlayerPosition(player, x, y, no_packet)
```

#### World:removeDroppedItem(uid)

Removes the dropped item from this world. It uses uid.

**Parameters:** `uid`

**Returns:** `void`

```lua
World:removeDroppedItem(uid)
```

#### World:removeDroppedItemsByID(id)

Removes the dropped items by ID from this world. It uses id.

**Parameters:** `id`

**Returns:** `void`

```lua
World:removeDroppedItemsByID(id)
```

#### World:removeAllDroppedItems()

Removes the all dropped items from this world.

**Returns:** `void`

```lua
World:removeAllDroppedItems()
```

#### World:updateTile(tile, player)

Updates the tile for this world. It uses tile, optional player.

**Parameters:** `tile`, `player`

**Returns:** `void`

```lua
World:updateTile(tile, player)
```

#### World:sendPlayerMessage(player, message)

Sends the player message to the target client or service. It uses player, message.

**Parameters:** `player`, `message`

**Returns:** `void`

```lua
World:sendPlayerMessage(player, message)
```

#### World:punchTile(tile, player)

Runs the punch tile operation for this world. It uses tile, optional player.

**Parameters:** `tile`, `player`

**Returns:** `void`

```lua
World:punchTile(tile, player)
```

#### World:placeTile(tile, id, player)

Runs the place tile operation for this world. It uses tile, id, optional player.

**Parameters:** `tile`, `id`, `player`

**Returns:** `void`

```lua
World:placeTile(tile, id, player)
```

#### World:hasTileAccess(player, tile)

Checks whether the player has access to the specified tile.

**Parameters:** `player`, `tile`

**Returns:** `boolean`

```lua
World:hasTileAccess(player, tile)
```

#### World:hasAccess(player)

Checks whether the player has world-level access.

**Parameters:** `player`

**Returns:** `boolean`

```lua
World:hasAccess(player)
```

#### World:addTileAccess(player, tile)

Adds tile access data or value to this world. It uses player, tile.

**Parameters:** `player`, `tile`

**Returns:** `void`

```lua
World:addTileAccess(player, tile)
```

#### World:addAccess(player, admin_type)

Adds access data or value to this world. It uses player, admin_type.

**Parameters:** `player`, `admin_type`

**Returns:** `void`

```lua
World:addAccess(player, admin_type)
```

#### World:removeTileAccess(player, tile)

Removes the tile access from this world. It uses player, tile.

**Parameters:** `player`, `tile`

**Returns:** `void`

```lua
World:removeTileAccess(player, tile)
```

#### World:removeAllTileAccess()

Removes the all tile access from this world.

**Returns:** `void`

```lua
World:removeAllTileAccess()
```

#### World:removeAccess(player)

Removes the access from this world. It uses player.

**Parameters:** `player`

**Returns:** `void`

```lua
World:removeAccess(player)
```

#### World:kill(player, force_respawn_on_white_door)

Kills the player in this world and optionally forces respawn on the white door.

**Parameters:** `player`, `force_respawn_on_white_door`

**Returns:** `void`

```lua
World:kill(player, force_respawn_on_white_door)
```

#### World:setClothing(player, item_id)

Sets the clothing for this world. It uses player, item_id.

**Parameters:** `player`, `item_id`

**Returns:** `void`

```lua
World:setClothing(player, item_id)
```

#### World:createNPC(name, x, y)

Creates the NPC resource or entry. It uses name, x, y.

**Parameters:** `name`, `x`, `y`

**Returns:** `Player`

```lua
World:createNPC(name, x, y)
```

#### World:removeNPC(player)

Removes the NPC from this world. It uses player.

**Parameters:** `player`

**Returns:** `void`

```lua
World:removeNPC(player)
```

#### World:findNPCByName(name)

Runs the find npcby name operation for this world. It uses name.

**Parameters:** `name`

**Returns:** `{Player}`

```lua
World:findNPCByName(name)
```

#### World:getAllNPC()

Returns the all NPC for this world.

**Returns:** `{Player}`

```lua
World:getAllNPC()
```

#### World:redeemCode(player, code)

Redeems the code for this world. It uses player, code.

**Parameters:** `player`, `code`

**Returns:** `void`

```lua
World:redeemCode(player, code)
```

#### World:setWeather(weatherID)

Sets the weather for this world. It uses weatherID.

**Parameters:** `weatherID`

**Returns:** `void`

```lua
World:setWeather(weatherID)
```

#### World:getWorldLock()

Returns the world lock for this world.

**Returns:** `Tile`

```lua
World:getWorldLock()
```

#### World:getMagplantRemoteTile(player)

Returns the magplant remote tile for this world.

**Parameters:** `player`

**Returns:** `Tile`

```lua
World:getMagplantRemoteTile(player)
```

#### World:setMagplantRemoteTile(player, tile)

Sets the magplant remote tile for this world. It uses player, tile.

**Parameters:** `player`, `tile`

**Returns:** `void`

```lua
World:setMagplantRemoteTile(player, tile)
```

#### World:hasFlag(flag)

Checks whether this world has flag. It uses flag.

**Parameters:** `flag`

**Returns:** `boolean`

```lua
World:hasFlag(flag)
```

#### World:addFlag(flag)

Adds flag data or value to this world. It uses flag.

**Parameters:** `flag`

**Returns:** `void`

```lua
World:addFlag(flag)
```

#### World:useConsumable(player, tile, id, noCallback)

Uses a consumable item for a player on a tile, optionally skipping callback execution.

**Parameters:** `player`, `tile`, `id`, `noCallback`

**Returns:** `void`

```lua
World:useConsumable(player, tile, id, noCallback)
```

#### World:spawnGhost(tile, id, sb, wd, sp)

Spawns ghost in the relevant game context. It uses tile, id, sb, wd, sp.

**Parameters:** `tile`, `id`, `sb`, `wd`, `sp`

**Returns:** `void`

```lua
World:spawnGhost(tile, id, sb, wd, sp)
```

#### World:findPathByTile(tile_1, tile_2, max_rad_x, max_rad_y)

Runs the find path by tile operation for this world. It uses tile_1, tile_2, max_rad_x, max_rad_y.

**Parameters:** `tile_1`, `tile_2`, `max_rad_x`, `max_rad_y`

**Returns:** `{any}`

```lua
World:findPathByTile(tile_1, tile_2, max_rad_x, max_rad_y)
```

#### World:isNuked()

Checks whether this world is nuked.

**Returns:** `boolean`

```lua
World:isNuked()
```

#### World:nuke(ownerBanTime, adminsBanTime, everyoneElseBanTime)

Nukes the world. Ban times are in minutes; pass 0 to skip that group.

**Parameters:** `ownerBanTime`, `adminsBanTime`, `everyoneElseBanTime`

**Returns:** `void`

```lua
World:nuke(ownerBanTime, adminsBanTime, everyoneElseBanTime)
```

#### World:removeNuke(unbanBannedUsers)

Removes the nuke from this world. Pass 1 to also unban the users banned by it.

**Parameters:** `unbanBannedUsers`

**Returns:** `void`

```lua
World:removeNuke(unbanBannedUsers)
```

#### World:getGuildID()

Returns the guild ID for this world.

**Returns:** `number`

```lua
World:getGuildID()
```

#### World:getMachineCap(item_id)

Returns the machine cap for this world.

**Parameters:** `item_id`

**Returns:** `number`

```lua
World:getMachineCap(item_id)
```

#### World:setMachineCap(item_id, item_count)

Sets the machine cap for this world. It uses item_id, item_count.

**Parameters:** `item_id`, `item_count`

**Returns:** `void`

```lua
World:setMachineCap(item_id, item_count)
```

#### World:getMachineCaps()

Returns the machine caps for this world.

**Returns:** `{any}`

```lua
World:getMachineCaps()
```

#### World:removeMachineCap(item_id)

Removes the machine cap from this world. It uses item_id.

**Parameters:** `item_id`

**Returns:** `void`

```lua
World:removeMachineCap(item_id)
```

#### World:getEffects()

Returns { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } } for this world.

**Returns:** `any`

```lua
World:getEffects()
```

#### World:setEffects(effects)

Sets the custom effects for this world. Takes a table { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } }. All five numeric fields are required; drops is optional and replaces the existing drops.

**Parameters:** `effects`

**Returns:** `void`

```lua
World:setEffects(effects)
```

#### World:deleteEffects()

Deletes the effects resource.

**Returns:** `void`

```lua
World:deleteEffects()
```

#### World:getCached(item_id)

Returns the cached for this world.

**Parameters:** `item_id`

**Returns:** `{Tile}`

```lua
World:getCached(item_id)
```

#### World:delete()

Runs the delete operation for this world.

**Returns:** `void`

```lua
World:delete()
```

#### World:save()

Runs the save operation for this world.

**Returns:** `void`

```lua
World:save()
```

#### World:new(name, sizeX, sizeY, worldType)

Static: World.new(...). Creates a new unsaved world. Size max 255x255; worldType must be a valid world type.

**Parameters:** `name`, `sizeX`, `sizeY`, `worldType`

**Returns:** `World`

```lua
World:new(name, sizeX, sizeY, worldType)
```

#### World:newFromTemplate(name, templateName)

Static: World.newFromTemplate(...). Creates a new world from an exported template file.

**Parameters:** `name`, `templateName`

**Returns:** `World`

```lua
World:newFromTemplate(name, templateName)
```

#### World:newFromGlobalTemplate(name, templateName)

Static: World.newFromGlobalTemplate(...). Creates a new world from a global template file.

**Parameters:** `name`, `templateName`

**Returns:** `World`

```lua
World:newFromGlobalTemplate(name, templateName)
```

#### World:hasAccessByType(player, adminType)

Checks whether the player has the given admin type in this world.

**Parameters:** `player`, `adminType`

**Returns:** `boolean`

```lua
World:hasAccessByType(player, adminType)
```

#### World:setTileOwner(tile, userID)

Changes the owner of a small lock tile (and every tile it controls) to the given user ID.

**Parameters:** `tile`, `userID`

**Returns:** `void`

```lua
World:setTileOwner(tile, userID)
```

#### World:export()

Exports this world to a .dat file named after the world (max 100 exports). Errors on an unsafe world name.

**Returns:** `void`

```lua
World:export()
```

#### World:import(importName)

Imports a previously exported .dat file into this world. Errors if the file doesn't exist or the world is a guild world.

**Parameters:** `importName`

**Returns:** `void`

```lua
World:import(importName)
```

Sumber: [World](https://dash.gtps.cloud/docs/world).

---

<a id="bagian-tile"></a>

## Tile

The Tile class represents a single tile in a world. Access tile properties like foreground, background, and flags.

### Tile

#### Tile:getTileID()

Returns the tile ID for this tile.

**Returns:** `number`

```lua
Tile:getTileID()
```

#### Tile:getTileItem()

Returns the tile item for this tile.

**Returns:** `Item`

```lua
Tile:getTileItem()
```

#### Tile:getLastPunched()

Returns the last punched for this tile.

**Returns:** `number`

```lua
Tile:getLastPunched()
```

#### Tile:getPosX()

Returns the tile X position in pixels (tile X * 32).

**Returns:** `number`

```lua
Tile:getPosX()
```

#### Tile:getPosY()

Returns the tile Y position in pixels (tile Y * 32).

**Returns:** `number`

```lua
Tile:getPosY()
```

#### Tile:getNote()

Returns the note for this tile.

**Returns:** `string`

```lua
Tile:getNote()
```

#### Tile:getTileForeground()

Returns the tile foreground for this tile.

**Returns:** `number`

```lua
Tile:getTileForeground()
```

#### Tile:getTileBackground()

Returns the tile background for this tile.

**Returns:** `number`

```lua
Tile:getTileBackground()
```

#### Tile:getTileData(data_type)

Returns extra tile data. data_type: 0 seed fruits, 1 seed planted time, 2 magplant count, 3 vending count, 4 sign text, 5 door text, 6 door open, 7 door destination, 8 door ID, 9 vending item ID, 10 vending price, 11 vending earned, 12 display block item ID, 13 magplant item ID, 14 magplant active, 15 magplant magnet, 16 magplant space, 17 magplant gems, 18 magplant second item ID, 19 magplant enabled, 20 magplant harvest trees, 21 magplant collect seeds.

**Parameters:** `data_type`

**Returns:** `any`

```lua
Tile:getTileData(data_type)
```

#### Tile:setTileData(data_type, data_value)

Sets extra tile data. Same data_type values as getTileData. Boolean fields take 1 or 0.

**Parameters:** `data_type`, `data_value`

**Returns:** `void`

```lua
Tile:setTileData(data_type, data_value)
```

#### Tile:setTileDataInt(data_type, data_value)

Alias of setTileData.

**Parameters:** `data_type`, `data_value`

**Returns:** `void`

```lua
Tile:setTileDataInt(data_type, data_value)
```

#### Tile:getFlags()

Returns the flags for this tile.

**Returns:** `number`

```lua
Tile:getFlags()
```

#### Tile:setFlags(flags)

Sets the flags for this tile. It uses flags.

**Parameters:** `flags`

**Returns:** `void`

```lua
Tile:setFlags(flags)
```

Sumber: [Tile](https://dash.gtps.cloud/docs/tile).

---

<a id="bagian-item"></a>

## Item

The Item class represents an item definition. Access item properties and metadata.

### Item

#### Item:getPlaymods()

Returns the playmods for this item.

**Returns:** `{any}`

```lua
Item:getPlaymods()
```

#### Item:getName()

Returns the name for this item.

**Returns:** `string`

```lua
Item:getName()
```

#### Item:setName(value)

Sets the name for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setName(value)
```

#### Item:getDescription()

Returns the description for this item.

**Returns:** `string`

```lua
Item:getDescription()
```

#### Item:getID()

Returns the ID for this item.

**Returns:** `number`

```lua
Item:getID()
```

#### Item:getPrice()

Returns the price for this item.

**Returns:** `number`

```lua
Item:getPrice()
```

#### Item:setPrice(newPrice)

Sets the price for this item. It uses newPrice.

**Parameters:** `newPrice`

**Returns:** `void`

```lua
Item:setPrice(newPrice)
```

#### Item:isObtainable()

Checks whether this item is obtainable.

**Returns:** `boolean`

```lua
Item:isObtainable()
```

#### Item:getInfo()

Returns the info for this item.

**Returns:** `{string}`

```lua
Item:getInfo()
```

#### Item:getActionType()

Returns the action type for this item.

**Returns:** `number`

```lua
Item:getActionType()
```

#### Item:getRarity()

Returns the rarity for this item.

**Returns:** `number`

```lua
Item:getRarity()
```

#### Item:getGems(world, player)

Returns the gems for this item.

**Parameters:** `world`, `player`

**Returns:** `number`

```lua
Item:getGems(world, player)
```

#### Item:getXP(world, player)

Returns the XP for this item.

**Parameters:** `world`, `player`

**Returns:** `number`

```lua
Item:getXP(world, player)
```

#### Item:getGrowTime()

Returns the grow time for this item.

**Returns:** `number`

```lua
Item:getGrowTime()
```

#### Item:getCategoryType()

Returns the category type for this item.

**Returns:** `number`

```lua
Item:getCategoryType()
```

#### Item:getEditableType()

Returns the editable type for this item.

**Returns:** `number`

```lua
Item:getEditableType()
```

#### Item:setCategoryType(value)

Sets the category type for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setCategoryType(value)
```

#### Item:setEditableType(value)

Sets the editable type for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setEditableType(value)
```

#### Item:setGrowTime(value)

Sets the grow time for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setGrowTime(value)
```

#### Item:setActionType(value)

Sets the action type for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setActionType(value)
```

#### Item:setDescription(value)

Sets the description for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setDescription(value)
```

#### Item:getTexture()

Returns the texture for this item.

**Returns:** `string`

```lua
Item:getTexture()
```

#### Item:getTextureHash()

Returns the texture hash for this item.

**Returns:** `number`

```lua
Item:getTextureHash()
```

#### Item:setTextureHash(hash)

Sets the texture hash for this item. It uses hash.

**Parameters:** `hash`

**Returns:** `void`

```lua
Item:setTextureHash(hash)
```

#### Item:getTextureX()

Returns the texture x for this item.

**Returns:** `number`

```lua
Item:getTextureX()
```

#### Item:getTextureY()

Returns the texture y for this item.

**Returns:** `number`

```lua
Item:getTextureY()
```

#### Item:setTexture(value)

Sets the texture for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setTexture(value)
```

#### Item:setTextureX(x)

Sets the texture x for this item. It uses x.

**Parameters:** `x`

**Returns:** `void`

```lua
Item:setTextureX(x)
```

#### Item:setTextureY(y)

Sets the texture y for this item. It uses y.

**Parameters:** `y`

**Returns:** `void`

```lua
Item:setTextureY(y)
```

#### Item:getClothingType()

Returns the clothing type for this item.

**Returns:** `number`

```lua
Item:getClothingType()
```

#### Item:setClothingType(value)

Sets the clothing type for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setClothingType(value)
```

#### Item:getPricedRarity()

Returns the priced rarity for this item.

**Returns:** `number`

```lua
Item:getPricedRarity()
```

#### Item:getEffects()

Returns { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } } for this item.

**Returns:** `any`

```lua
Item:getEffects()
```

#### Item:setEffects(effects)

Sets the custom effects for this item. Takes a table { extra_gems, extra_xp, one_hit, break_range, build_range, drops = { { id, count, chance } } }. All five numeric fields are required; drops is optional and replaces the existing drops.

**Parameters:** `effects`

**Returns:** `void`

```lua
Item:setEffects(effects)
```

#### Item:deleteEffects()

Deletes the effects resource.

**Returns:** `void`

```lua
Item:deleteEffects()
```

#### Item:getObtainability()

Returns the obtainability for this item.

**Returns:** `string`

```lua
Item:getObtainability()
```

#### Item:getMachineCap()

Returns the machine cap for this item.

**Returns:** `number`

```lua
Item:getMachineCap()
```

#### Item:setMachineCap(value)

Sets the machine cap for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setMachineCap(value)
```

#### Item:removeMachineCap()

Removes the machine cap from this item.

**Returns:** `void`

```lua
Item:removeMachineCap()
```

#### Item:getFarmability()

Returns the farmability for this item.

**Returns:** `boolean`

```lua
Item:getFarmability()
```

#### Item:setFarmability(value)

Sets the farmability for this item. It uses value.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setFarmability(value)
```

#### Item:getMaxFruitDropCount()

Returns the max fruit drop count for this item.

**Returns:** `number`

```lua
Item:getMaxFruitDropCount()
```

#### Item:getMinFruitDropCount()

Returns the min fruit drop count for this item.

**Returns:** `number`

```lua
Item:getMinFruitDropCount()
```

#### Item:getSpreadType()

Returns the spread type for this item.

**Returns:** `number`

```lua
Item:getSpreadType()
```

#### Item:setSpreadType(value)

Sets the spread type for this item.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setSpreadType(value)
```

#### Item:getCollisionType()

Returns the collision type for this item.

**Returns:** `number`

```lua
Item:getCollisionType()
```

#### Item:setCollisionType(value)

Sets the collision type for this item.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setCollisionType(value)
```

#### Item:getKindType()

Returns the item kind for this item.

**Returns:** `number`

```lua
Item:getKindType()
```

#### Item:setKindType(value)

Sets the item kind for this item.

**Parameters:** `value`

**Returns:** `void`

```lua
Item:setKindType(value)
```

#### Item:getChi()

Returns the chi element: 0 Earth, 1 Fire, 2 other, 3 Water, 4 none (clothes).

**Returns:** `number`

```lua
Item:getChi()
```

Sumber: [Item](https://dash.gtps.cloud/docs/item).

---

<a id="bagian-iotm"></a>

## IOTM

Methods and properties for the IOTM class.

### IOTM

#### IOTM:getID()

Returns the ID for this iotm.

**Returns:** `number`

```lua
IOTM:getID()
```

#### IOTM:getAmount()

Returns the amount for this iotm.

**Returns:** `number`

```lua
IOTM:getAmount()
```

#### IOTM:setAmount(newAmount)

Sets the amount for this iotm. It uses newAmount.

**Parameters:** `newAmount`

**Returns:** `void`

```lua
IOTM:setAmount(newAmount)
```

Sumber: [IOTM](https://dash.gtps.cloud/docs/iotm).

---

<a id="bagian-guild"></a>

## Guild

Methods and properties for the Guild class.

### Guild

#### Guild:getTitle()

Returns the title for this guild.

**Returns:** `string`

```lua
Guild:getTitle()
```

#### Guild:getDescription()

Returns the description for this guild.

**Returns:** `string`

```lua
Guild:getDescription()
```

#### Guild:getNotebook()

Returns the notebook for this guild.

**Returns:** `string`

```lua
Guild:getNotebook()
```

#### Guild:getID()

Returns the ID for this guild.

**Returns:** `number`

```lua
Guild:getID()
```

#### Guild:getWorldID()

Returns the world ID for this guild.

**Returns:** `number`

```lua
Guild:getWorldID()
```

#### Guild:getXP()

Returns the XP for this guild.

**Returns:** `number`

```lua
Guild:getXP()
```

#### Guild:getLevel()

Returns the level for this guild.

**Returns:** `number`

```lua
Guild:getLevel()
```

#### Guild:getPoints()

Returns the points for this guild.

**Returns:** `number`

```lua
Guild:getPoints()
```

#### Guild:getSettings()

Returns the settings for this guild.

**Returns:** `number`

```lua
Guild:getSettings()
```

#### Guild:getCreatedDate()

Returns the created date for this guild.

**Returns:** `number`

```lua
Guild:getCreatedDate()
```

#### Guild:getMascotForegroundID()

Returns the mascot foreground ID for this guild.

**Returns:** `number`

```lua
Guild:getMascotForegroundID()
```

#### Guild:getMascotBackgroundID()

Returns the mascot background ID for this guild.

**Returns:** `number`

```lua
Guild:getMascotBackgroundID()
```

#### Guild:getDisplayGuildMascot()

Returns the display guild mascot for this guild.

**Returns:** `number`

```lua
Guild:getDisplayGuildMascot()
```

#### Guild:getOnlinePlayers()

Returns the online players for this guild.

**Returns:** `{Player}`

```lua
Guild:getOnlinePlayers()
```

#### Guild:setXP(xp)

Sets the guild XP, capped just below the XP needed for the next level.

**Parameters:** `xp`

**Returns:** `void`

```lua
Guild:setXP(xp)
```

#### Guild:addXP(xp)

Adds XP to the guild and handles level ups.

**Parameters:** `xp`

**Returns:** `void`

```lua
Guild:addXP(xp)
```

#### Guild:setLevel(level)

Sets the guild level (max 15).

**Parameters:** `level`

**Returns:** `void`

```lua
Guild:setLevel(level)
```

Sumber: [Guild](https://dash.gtps.cloud/docs/guild).

---

<a id="bagian-shop-item"></a>

## ShopItem

Methods and properties for the ShopItem class.

### ShopItem

#### ShopItem:getCategory()

Returns the category for this shop item.

**Returns:** `string`

```lua
ShopItem:getCategory()
```

#### ShopItem:getTexture()

Returns the texture for this shop item.

**Returns:** `string`

```lua
ShopItem:getTexture()
```

#### ShopItem:getTexturePosX()

Returns the texture pos x for this shop item.

**Returns:** `number`

```lua
ShopItem:getTexturePosX()
```

#### ShopItem:getTexturePosY()

Returns the texture pos y for this shop item.

**Returns:** `number`

```lua
ShopItem:getTexturePosY()
```

#### ShopItem:getItemID()

Returns the item ID for this shop item.

**Returns:** `number`

```lua
ShopItem:getItemID()
```

#### ShopItem:getTitle()

Returns the title for this shop item.

**Returns:** `string`

```lua
ShopItem:getTitle()
```

#### ShopItem:getDescription()

Returns the description for this shop item.

**Returns:** `string`

```lua
ShopItem:getDescription()
```

#### ShopItem:getPrice()

Returns the price for this shop item.

**Returns:** `number`

```lua
ShopItem:getPrice()
```

#### ShopItem:isRPC()

Checks whether this shop item is rpc.

**Returns:** `boolean`

```lua
ShopItem:isRPC()
```

#### ShopItem:isGrowtoken()

Checks whether this shop item is growtoken.

**Returns:** `boolean`

```lua
ShopItem:isGrowtoken()
```

#### ShopItem:isVoucher()

Checks whether this shop item is voucher.

**Returns:** `boolean`

```lua
ShopItem:isVoucher()
```

#### ShopItem:getRequiredEvent()

Returns the required event for this shop item.

**Returns:** `number`

```lua
ShopItem:getRequiredEvent()
```

#### ShopItem:getItemsDescription()

Returns the items description for this shop item.

**Returns:** `string`

```lua
ShopItem:getItemsDescription()
```

#### ShopItem:getItems()

Returns the items for this shop item.

**Returns:** `{any}`

```lua
ShopItem:getItems()
```

#### ShopItem:makePurchaseItems(Count)

Runs the make purchase items operation for this shop item. It uses Count.

**Parameters:** `Count`

**Returns:** `{any}`

```lua
ShopItem:makePurchaseItems(Count)
```

#### ShopItem:getRollAmount()

Returns the roll amount for this shop item.

**Returns:** `number`

```lua
ShopItem:getRollAmount()
```

#### ShopItem:isRandom()

Checks whether this shop item is random.

**Returns:** `boolean`

```lua
ShopItem:isRandom()
```

Sumber: [ShopItem](https://dash.gtps.cloud/docs/shop-item).

---

<a id="bagian-growtopia-bot"></a>

## GrowtopiaBot

Methods and properties for the GrowtopiaBot class.

### GrowtopiaBot

#### GrowtopiaBot:start()

Runs the start operation for this growtopia bot.

**Returns:** `void`

```lua
GrowtopiaBot:start()
```

#### GrowtopiaBot:onReceiveVariantCallback(callback)

Sets the callback that runs when the bot receives a variant packet.

**Parameters:** `callback`

**Returns:** `void`

```lua
GrowtopiaBot:onReceiveVariantCallback(callback)
```

#### GrowtopiaBot:onReceiveTextCallback(callback)

Sets the callback that runs when the bot receives a text packet.

**Parameters:** `callback`

**Returns:** `void`

```lua
GrowtopiaBot:onReceiveTextCallback(callback)
```

#### GrowtopiaBot:onReceiveRawCallback(callback)

Sets the callback that runs when the bot receives a raw game packet.

**Parameters:** `callback`

**Returns:** `void`

```lua
GrowtopiaBot:onReceiveRawCallback(callback)
```

#### GrowtopiaBot:onReceiveTrackCallback(callback)

Sets the callback that runs when the bot receives a track packet.

**Parameters:** `callback`

**Returns:** `void`

```lua
GrowtopiaBot:onReceiveTrackCallback(callback)
```

#### GrowtopiaBot:sendStr(type, str)

Sends the str to the target client or service. It uses type, str.

**Parameters:** `type`, `str`

**Returns:** `void`

```lua
GrowtopiaBot:sendStr(type, str)
```

#### GrowtopiaBot:sendRaw(data)

Sends the raw to the target client or service. It uses data.

**Parameters:** `data`

**Returns:** `void`

```lua
GrowtopiaBot:sendRaw(data)
```

#### GrowtopiaBot:reconnect()

Runs the reconnect operation for this growtopia bot.

**Returns:** `void`

```lua
GrowtopiaBot:reconnect()
```

#### GrowtopiaBot:new(token)

Static: GrowtopiaBot.new(token). Validates the bot verification token with the controller and creates a bot. Errors if the token is invalid.

**Parameters:** `token`

**Returns:** `GrowtopiaBot`

```lua
GrowtopiaBot:new(token)
```

Sumber: [GrowtopiaBot](https://dash.gtps.cloud/docs/growtopia-bot).

---

<a id="bagian-drop"></a>

## Drop

Methods and properties for the Drop class.

### Drop

#### Drop:getItemID()

Returns the item ID for this drop.

**Returns:** `number`

```lua
Drop:getItemID()
```

#### Drop:getItemCount()

Returns the item count for this drop.

**Returns:** `number`

```lua
Drop:getItemCount()
```

#### Drop:getPosX()

Returns the pos x for this drop.

**Returns:** `number`

```lua
Drop:getPosX()
```

#### Drop:getPosY()

Returns the pos y for this drop.

**Returns:** `number`

```lua
Drop:getPosY()
```

#### Drop:getUID()

Returns the uid for this drop.

**Returns:** `number`

```lua
Drop:getUID()
```

#### Drop:getFlags()

Returns the flags for this drop.

**Returns:** `number`

```lua
Drop:getFlags()
```

Sumber: [Drop](https://dash.gtps.cloud/docs/drop).

---

<a id="bagian-player-autofarm"></a>

## PlayerAutofarm

Methods and properties for the PlayerAutofarm class.

### PlayerAutofarm

#### PlayerAutofarm:getTargetBlockID()

Returns the target block ID for this avatar player autofarm.

**Returns:** `number`

```lua
PlayerAutofarm:getTargetBlockID()
```

#### PlayerAutofarm:setTargetBlockID(targetBlock)

Sets the target block ID for this avatar player autofarm. It uses targetBlock.

**Parameters:** `targetBlock`

**Returns:** `void`

```lua
PlayerAutofarm:setTargetBlockID(targetBlock)
```

#### PlayerAutofarm:getNextPosX()

Returns the next pos x for this avatar player autofarm.

**Returns:** `number`

```lua
PlayerAutofarm:getNextPosX()
```

#### PlayerAutofarm:setNextPosX(x)

Sets the next pos x for this avatar player autofarm. It uses x.

**Parameters:** `x`

**Returns:** `void`

```lua
PlayerAutofarm:setNextPosX(x)
```

#### PlayerAutofarm:getNextPosY()

Returns the next pos y for this avatar player autofarm.

**Returns:** `number`

```lua
PlayerAutofarm:getNextPosY()
```

#### PlayerAutofarm:setNextPosY(y)

Sets the next pos y for this avatar player autofarm. It uses y.

**Parameters:** `y`

**Returns:** `void`

```lua
PlayerAutofarm:setNextPosY(y)
```

#### PlayerAutofarm:getDelay()

Returns the delay for this avatar player autofarm.

**Returns:** `number`

```lua
PlayerAutofarm:getDelay()
```

#### PlayerAutofarm:setDelay(autofarmDelay)

Sets the delay for this avatar player autofarm. It uses autofarmDelay.

**Parameters:** `autofarmDelay`

**Returns:** `void`

```lua
PlayerAutofarm:setDelay(autofarmDelay)
```

#### PlayerAutofarm:getSlots()

Returns the slots for this avatar player autofarm.

**Returns:** `number`

```lua
PlayerAutofarm:getSlots()
```

#### PlayerAutofarm:setSlots(autofarmSlots)

Sets the slots for this avatar player autofarm. It uses autofarmSlots.

**Parameters:** `autofarmSlots`

**Returns:** `void`

```lua
PlayerAutofarm:setSlots(autofarmSlots)
```

Sumber: [PlayerAutofarm](https://dash.gtps.cloud/docs/player-autofarm).

---

<a id="bagian-inventory-item"></a>

## InventoryItem

Methods and properties for the InventoryItem class.

### InventoryItem

#### InventoryItem:getItemID()

Returns the item ID for this avatar player inventory item.

**Returns:** `number`

```lua
InventoryItem:getItemID()
```

#### InventoryItem:getItemCount()

Returns the item count for this avatar player inventory item.

**Returns:** `number`

```lua
InventoryItem:getItemCount()
```

Sumber: [InventoryItem](https://dash.gtps.cloud/docs/inventory-item).

---

<a id="bagian-player-subscription"></a>

## PlayerSubscription

Methods and properties for the PlayerSubscription class.

### PlayerSubscription

#### PlayerSubscription:getType()

Returns the type for this avatar player subscription.

**Returns:** `number`

```lua
PlayerSubscription:getType()
```

#### PlayerSubscription:getExpireTime()

Returns the expire time for this avatar player subscription.

**Returns:** `number`

```lua
PlayerSubscription:getExpireTime()
```

#### PlayerSubscription:getActivationTime()

Returns the activation time for this avatar player subscription.

**Returns:** `number`

```lua
PlayerSubscription:getActivationTime()
```

#### PlayerSubscription:isPermanent()

Checks whether this avatar player subscription is permanent.

**Returns:** `boolean`

```lua
PlayerSubscription:isPermanent()
```

#### PlayerSubscription:getNextRewardTime()

Returns the next reward time for this avatar player subscription.

**Returns:** `number`

```lua
PlayerSubscription:getNextRewardTime()
```

Sumber: [PlayerSubscription](https://dash.gtps.cloud/docs/player-subscription).

---

<a id="bagian-discord-bot"></a>

## DiscordBot

Methods and properties for the DiscordBot class.

### DiscordBot

#### DiscordBot:messageCreate(channelID, content, components, flags, type, embed, attachments)

Sends a message to a channel. Returns a request object. Optional: flags, type, embed, attachments (see LuaDiscordHelpers.h). components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }). Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `channelID`, `content`, `components`, `flags`, `type`, `embed`, `attachments`

**Returns:** `any`

```lua
DiscordBot:messageCreate(channelID, content, components, flags, type, embed, attachments)
```

#### DiscordBot:directMessageCreate(userID, content, components, flags, type, embed, attachments)

Sends a direct message to a user. components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }). Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `userID`, `content`, `components`, `flags`, `type`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordBot:directMessageCreate(userID, content, components, flags, type, embed, attachments)
```

#### DiscordBot:messageDelete(messageID, channelID)

Deletes a message. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `messageID`, `channelID`

**Returns:** `void`

```lua
DiscordBot:messageDelete(messageID, channelID)
```

#### DiscordBot:messageEdit(messageID, channelID, content, components, flags, type, embed)

Edits a message's content, components and embed. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `messageID`, `channelID`, `content`, `components`, `flags`, `type`, `embed`

**Returns:** `void`

```lua
DiscordBot:messageEdit(messageID, channelID, content, components, flags, type, embed)
```

#### DiscordBot:globalCommandCreate(name, description, options)

Registers a global slash command. options = { {type="string|integer|user", name, description, required} }. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `name`, `description`, `options`

**Returns:** `void`

```lua
DiscordBot:globalCommandCreate(name, description, options)
```

#### DiscordBot:guildMemberSetNickname(guildID, userID, nick)

Sets a guild member nickname. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`, `userID`, `nick`

**Returns:** `void`

```lua
DiscordBot:guildMemberSetNickname(guildID, userID, nick)
```

#### DiscordBot:guildMemberRemoveRole(guildID, userID, roleID)

Removes a role from a guild member. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`, `userID`, `roleID`

**Returns:** `void`

```lua
DiscordBot:guildMemberRemoveRole(guildID, userID, roleID)
```

#### DiscordBot:guildMemberAddRole(guildID, userID, roleID)

Adds a role to a guild member. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`, `userID`, `roleID`

**Returns:** `void`

```lua
DiscordBot:guildMemberAddRole(guildID, userID, roleID)
```

#### DiscordBot:guildMemberGetRoles(guildID, userID, callback)

Fetches a member's role IDs (as strings) and passes them as a table to callback. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`, `userID`, `callback`

**Returns:** `void`

```lua
DiscordBot:guildMemberGetRoles(guildID, userID, callback)
```

#### DiscordBot:channelCreate(guildID, options)

Creates a text channel in the guild. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`, `options`

**Returns:** `any`

```lua
DiscordBot:channelCreate(guildID, options)
```

#### DiscordBot:channelEdit(channelID, options)

Edits a channel. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `channelID`, `options`

**Returns:** `any`

```lua
DiscordBot:channelEdit(channelID, options)
```

#### DiscordBot:channelDelete(channelID)

Deletes a channel. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `channelID`

**Returns:** `any`

```lua
DiscordBot:channelDelete(channelID)
```

#### DiscordBot:channelGet(channelID)

Fetches a channel. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `channelID`

**Returns:** `any`

```lua
DiscordBot:channelGet(channelID)
```

#### DiscordBot:guildGetChannels(guildID)

Fetches all channels of a guild. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `guildID`

**Returns:** `any`

```lua
DiscordBot:guildGetChannels(guildID)
```

#### DiscordBot:messagePin(messageID, channelID)

Pins a message. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `messageID`, `channelID`

**Returns:** `any`

```lua
DiscordBot:messagePin(messageID, channelID)
```

#### DiscordBot:messageUnpin(messageID, channelID)

Unpins a message. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `messageID`, `channelID`

**Returns:** `any`

```lua
DiscordBot:messageUnpin(messageID, channelID)
```

#### DiscordBot:messageAddReaction(messageID, channelID, emoji)

Adds a reaction to a message. Returns a request object. Call with a dot, not a colon (DiscordBot.method(...)), because argument 1 is the first real argument.

**Parameters:** `messageID`, `channelID`, `emoji`

**Returns:** `any`

```lua
DiscordBot:messageAddReaction(messageID, channelID, emoji)
```

Sumber: [DiscordBot](https://dash.gtps.cloud/docs/discord-bot).

---

<a id="bagian-discord-button-click-event"></a>

## DiscordButtonClickEvent

Methods and properties for the DiscordButtonClickEvent class.

### DiscordButtonClickEvent

#### DiscordButtonClickEvent:getCustomID()

Returns the custom ID for this discord button click event.

**Returns:** `string`

```lua
DiscordButtonClickEvent:getCustomID()
```

#### DiscordButtonClickEvent:getPlayer()

Returns the player for this discord button click event.

**Returns:** `Player`

```lua
DiscordButtonClickEvent:getPlayer()
```

#### DiscordButtonClickEvent:getChannelID()

Returns the channel ID for this discord button click event.

**Returns:** `string`

```lua
DiscordButtonClickEvent:getChannelID()
```

#### DiscordButtonClickEvent:getAuthorID()

Returns the author ID for this discord button click event.

**Returns:** `string`

```lua
DiscordButtonClickEvent:getAuthorID()
```

#### DiscordButtonClickEvent:reply(content, components, flags, embed, attachments)

Replies to the interaction. components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }).

**Parameters:** `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordButtonClickEvent:reply(content, components, flags, embed, attachments)
```

#### DiscordButtonClickEvent:dialog(modal)

Opens a modal form. Takes { id, title, components = { {type="text", id, label, placeholder, min, max, style="short|paragraph"} } }.

**Parameters:** `modal`

**Returns:** `void`

```lua
DiscordButtonClickEvent:dialog(modal)
```

#### DiscordButtonClickEvent:getMessageID()

Returns the message ID for this discord button click event.

**Returns:** `string`

```lua
DiscordButtonClickEvent:getMessageID()
```

#### DiscordButtonClickEvent:editOriginalResponse(content, components, flags, embed, attachments)

Edits the original interaction response.

**Parameters:** `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordButtonClickEvent:editOriginalResponse(content, components, flags, embed, attachments)
```

#### DiscordButtonClickEvent:getRoles()

Returns the roles for this discord button click event.

**Returns:** `{string}`

```lua
DiscordButtonClickEvent:getRoles()
```

#### DiscordButtonClickEvent:delete()

Deletes the message the button is attached to.

**Returns:** `void`

```lua
DiscordButtonClickEvent:delete()
```

Sumber: [DiscordButtonClickEvent](https://dash.gtps.cloud/docs/discord-button-click-event).

---

<a id="bagian-discord-form-submit-event"></a>

## DiscordFormSubmitEvent

Methods and properties for the DiscordFormSubmitEvent class.

### DiscordFormSubmitEvent

#### DiscordFormSubmitEvent:getCustomID()

Returns the custom ID for this discord form submit event.

**Returns:** `string`

```lua
DiscordFormSubmitEvent:getCustomID()
```

#### DiscordFormSubmitEvent:getPlayer()

Returns the player for this discord form submit event.

**Returns:** `Player`

```lua
DiscordFormSubmitEvent:getPlayer()
```

#### DiscordFormSubmitEvent:getChannelID()

Returns the channel ID for this discord form submit event.

**Returns:** `string`

```lua
DiscordFormSubmitEvent:getChannelID()
```

#### DiscordFormSubmitEvent:getAuthorID()

Returns the author ID for this discord form submit event.

**Returns:** `string`

```lua
DiscordFormSubmitEvent:getAuthorID()
```

#### DiscordFormSubmitEvent:getValue(id)

Returns the value for this discord form submit event.

**Parameters:** `id`

**Returns:** `string`

```lua
DiscordFormSubmitEvent:getValue(id)
```

#### DiscordFormSubmitEvent:reply(content, components, flags, embed, attachments)

Replies to the interaction. components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }).

**Parameters:** `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordFormSubmitEvent:reply(content, components, flags, embed, attachments)
```

#### DiscordFormSubmitEvent:getMessageID()

Returns the message ID for this discord form submit event.

**Returns:** `string`

```lua
DiscordFormSubmitEvent:getMessageID()
```

#### DiscordFormSubmitEvent:getRoles()

Returns the roles for this discord form submit event.

**Returns:** `{string}`

```lua
DiscordFormSubmitEvent:getRoles()
```

#### DiscordFormSubmitEvent:delete()

Deletes the source message. Errors if the form was opened from a slash command.

**Returns:** `void`

```lua
DiscordFormSubmitEvent:delete()
```

#### DiscordFormSubmitEvent:editOriginalResponse(content, components, flags, embed, attachments)

Edits the original interaction response.

**Parameters:** `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordFormSubmitEvent:editOriginalResponse(content, components, flags, embed, attachments)
```

Sumber: [DiscordFormSubmitEvent](https://dash.gtps.cloud/docs/discord-form-submit-event).

---

<a id="bagian-discord-message-create-event"></a>

## DiscordMessageCreateEvent

Methods and properties for the DiscordMessageCreateEvent class.

### DiscordMessageCreateEvent

#### DiscordMessageCreateEvent:getContent()

Returns the content for this discord message create event.

**Returns:** `string`

```lua
DiscordMessageCreateEvent:getContent()
```

#### DiscordMessageCreateEvent:getPlayer()

Returns the player for this discord message create event.

**Returns:** `Player`

```lua
DiscordMessageCreateEvent:getPlayer()
```

#### DiscordMessageCreateEvent:getChannelID()

Returns the channel ID for this discord message create event.

**Returns:** `string`

```lua
DiscordMessageCreateEvent:getChannelID()
```

#### DiscordMessageCreateEvent:getAuthorID()

Returns the author ID for this discord message create event.

**Returns:** `string`

```lua
DiscordMessageCreateEvent:getAuthorID()
```

#### DiscordMessageCreateEvent:isBot()

Checks whether this discord message create event is bot.

**Returns:** `boolean`

```lua
DiscordMessageCreateEvent:isBot()
```

#### DiscordMessageCreateEvent:reply(content, components, flags, mention_replied_user, embed)

Replies to the message. components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }).

**Parameters:** `content`, `components`, `flags`, `mention_replied_user`, `embed`

**Returns:** `void`

```lua
DiscordMessageCreateEvent:reply(content, components, flags, mention_replied_user, embed)
```

#### DiscordMessageCreateEvent:getMentionedUsers()

Returns the mentioned users for this discord message create event.

**Returns:** `{string}`

```lua
DiscordMessageCreateEvent:getMentionedUsers()
```

#### DiscordMessageCreateEvent:getMessageID()

Returns the message ID for this discord message create event.

**Returns:** `string`

```lua
DiscordMessageCreateEvent:getMessageID()
```

#### DiscordMessageCreateEvent:getRoles()

Returns the roles for this discord message create event.

**Returns:** `{string}`

```lua
DiscordMessageCreateEvent:getRoles()
```

#### DiscordMessageCreateEvent:delete()

Deletes the message this event was created for.

**Returns:** `void`

```lua
DiscordMessageCreateEvent:delete()
```

Sumber: [DiscordMessageCreateEvent](https://dash.gtps.cloud/docs/discord-message-create-event).

---

<a id="bagian-discord-slash-command-event"></a>

## DiscordSlashCommandEvent

Methods and properties for the DiscordSlashCommandEvent class.

### DiscordSlashCommandEvent

#### DiscordSlashCommandEvent:getCommandName()

Returns the command name for this discord slash command event.

**Returns:** `string`

```lua
DiscordSlashCommandEvent:getCommandName()
```

#### DiscordSlashCommandEvent:getParameter(parameter)

Returns the parameter for this discord slash command event.

**Parameters:** `parameter`

**Returns:** `string`

```lua
DiscordSlashCommandEvent:getParameter(parameter)
```

#### DiscordSlashCommandEvent:getPlayer()

Returns the player for this discord slash command event.

**Returns:** `Player`

```lua
DiscordSlashCommandEvent:getPlayer()
```

#### DiscordSlashCommandEvent:getChannelID()

Returns the channel ID for this discord slash command event.

**Returns:** `string`

```lua
DiscordSlashCommandEvent:getChannelID()
```

#### DiscordSlashCommandEvent:getAuthorID()

Returns the author ID for this discord slash command event.

**Returns:** `string`

```lua
DiscordSlashCommandEvent:getAuthorID()
```

#### DiscordSlashCommandEvent:reply(channelID, content, components, flags, embed, attachments)

Replies to the slash command. components = { { {type="button", label, style="primary|secondary|success|danger", id, emoji} } } (each inner table is one action row); embed = { title, description, color, url, image, thumbnail, footer, timestamp, author = {name, icon}, fields = { {name, value, inline} } } (image, thumbnail and url accept a string or { url = ... }).

**Parameters:** `channelID`, `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordSlashCommandEvent:reply(channelID, content, components, flags, embed, attachments)
```

#### DiscordSlashCommandEvent:editOriginalResponse(channelID, content, components, flags, embed, attachments)

Edits the original slash command response.

**Parameters:** `channelID`, `content`, `components`, `flags`, `embed`, `attachments`

**Returns:** `void`

```lua
DiscordSlashCommandEvent:editOriginalResponse(channelID, content, components, flags, embed, attachments)
```

#### DiscordSlashCommandEvent:dialog(modal)

Opens a modal form. Takes { id, title, components = { {type="text", id, label, placeholder, min, max, style="short|paragraph"} } }.

**Parameters:** `modal`

**Returns:** `void`

```lua
DiscordSlashCommandEvent:dialog(modal)
```

#### DiscordSlashCommandEvent:thinking(ephemeral)

Runs the thinking operation for this discord slash command event. It uses optional ephemeral.

**Parameters:** `ephemeral`

**Returns:** `void`

```lua
DiscordSlashCommandEvent:thinking(ephemeral)
```

#### DiscordSlashCommandEvent:getRoles()

Returns the roles for this discord slash command event.

**Returns:** `{string}`

```lua
DiscordSlashCommandEvent:getRoles()
```

#### DiscordSlashCommandEvent:delete()

Deletes the original interaction response.

**Returns:** `void`

```lua
DiscordSlashCommandEvent:delete()
```

Sumber: [DiscordSlashCommandEvent](https://dash.gtps.cloud/docs/discord-slash-command-event).

---

<a id="bagian-font"></a>

## Font

Methods and properties for the Font class.

### Font

#### Font:loadFromFile(path)

Loads from file from storage or server state. It uses path.

**Parameters:** `path`

**Returns:** `void`

```lua
Font:loadFromFile(path)
```

#### Font:new()

Runs the new operation for this font.

**Returns:** `Font`

```lua
Font:new()
```

Sumber: [Font](https://dash.gtps.cloud/docs/font).

---

<a id="bagian-render-texture"></a>

## RenderTexture

Methods and properties for the RenderTexture class.

### RenderTexture

#### RenderTexture:getWidth()

Returns the width for this render texture.

**Returns:** `number`

```lua
RenderTexture:getWidth()
```

#### RenderTexture:getHeight()

Returns the height for this render texture.

**Returns:** `number`

```lua
RenderTexture:getHeight()
```

#### RenderTexture:clear(r, g, b, a)

Runs the clear operation for this render texture. It uses r, g, b, a.

**Parameters:** `r`, `g`, `b`, `a`

**Returns:** `void`

```lua
RenderTexture:clear(r, g, b, a)
```

#### RenderTexture:saveToFile(path)

Saves to file to persistent storage. It uses path.

**Parameters:** `path`

**Returns:** `void`

```lua
RenderTexture:saveToFile(path)
```

#### RenderTexture:draw(sprite)

Draws a sprite onto this render texture.

**Parameters:** `sprite`

**Returns:** `void`

```lua
RenderTexture:draw(sprite)
```

#### RenderTexture:display()

Runs the display operation for this render texture.

**Returns:** `void`

```lua
RenderTexture:display()
```

#### RenderTexture:drawText(font, str, x, y, size, r, g, b, a)

Draws text onto this render texture.

**Parameters:** `font`, `str`, `x`, `y`, `size`, `r`, `g`, `b`, `a`

**Returns:** `void`

```lua
RenderTexture:drawText(font, str, x, y, size, r, g, b, a)
```

#### RenderTexture:getTextSize(font, str, size)

Returns the width and height of the text for the given font and size.

**Parameters:** `font`, `str`, `size`

**Returns:** `number, number`

```lua
RenderTexture:getTextSize(font, str, size)
```

#### RenderTexture:new(width, height)

Static: RenderTexture.new(width, height). Both must be integers from 1 to 1024.

**Parameters:** `width`, `height`

**Returns:** `RenderTexture`

```lua
RenderTexture:new(width, height)
```

#### RenderTexture:drawRectangle(x, y, width, height, r, g, b, a)

Draws a filled rectangle. Colors must be integers 0-255; coordinates within 16384 px.

**Parameters:** `x`, `y`, `width`, `height`, `r`, `g`, `b`, `a`

**Returns:** `void`

```lua
RenderTexture:drawRectangle(x, y, width, height, r, g, b, a)
```

#### RenderTexture:toPNG()

Flushes the texture and returns it as PNG-encoded bytes in a string.

**Returns:** `string`

```lua
RenderTexture:toPNG()
```

Sumber: [RenderTexture](https://dash.gtps.cloud/docs/render-texture).

---

<a id="bagian-sprite"></a>

## Sprite

Methods and properties for the Sprite class.

### Sprite

#### Sprite:setScale(x, y)

Sets the scale for this sprite. It uses x, y.

**Parameters:** `x`, `y`

**Returns:** `void`

```lua
Sprite:setScale(x, y)
```

#### Sprite:setPosition(x, y)

Sets the position for this sprite. It uses x, y.

**Parameters:** `x`, `y`

**Returns:** `void`

```lua
Sprite:setPosition(x, y)
```

#### Sprite:setRect(x, y, width, height)

Sets the rect for this sprite. It uses x, y, width, height.

**Parameters:** `x`, `y`, `width`, `height`

**Returns:** `void`

```lua
Sprite:setRect(x, y, width, height)
```

#### Sprite:setTexture(texture)

Sets the texture used by this sprite.

**Parameters:** `texture`

**Returns:** `void`

```lua
Sprite:setTexture(texture)
```

#### Sprite:new()

Runs the new operation for this sprite.

**Returns:** `Sprite`

```lua
Sprite:new()
```

Sumber: [Sprite](https://dash.gtps.cloud/docs/sprite).

---

<a id="bagian-texture"></a>

## Texture

Methods and properties for the Texture class.

### Texture

#### Texture:loadFromFile(path)

Loads from file from storage or server state. It uses path.

**Parameters:** `path`

**Returns:** `void`

```lua
Texture:loadFromFile(path)
```

#### Texture:new()

Runs the new operation for this texture.

**Returns:** `Texture`

```lua
Texture:new()
```

Sumber: [Texture](https://dash.gtps.cloud/docs/texture).

---

<a id="bagian-active-effects"></a>

## ActiveEffects

Methods and properties for the ActiveEffects class.

### ActiveEffects

#### ActiveEffects:getType()

Returns the playmod/effect type ID.

**Returns:** `number`

```lua
ActiveEffects:getType()
```

#### ActiveEffects:getExpireTime()

Returns the unix timestamp when this effect expires.

**Returns:** `number`

```lua
ActiveEffects:getExpireTime()
```

#### ActiveEffects:getName(player)

Returns the effect name for the given avatar.

**Parameters:** `player`

**Returns:** `string`

```lua
ActiveEffects:getName(player)
```

#### ActiveEffects:getDescription(player)

Returns the effect description for the given avatar.

**Parameters:** `player`

**Returns:** `string`

```lua
ActiveEffects:getDescription(player)
```

#### ActiveEffects:getItemID()

Returns the icon item ID for this effect.

**Returns:** `number`

```lua
ActiveEffects:getItemID()
```

Sumber: [ActiveEffects](https://dash.gtps.cloud/docs/active-effects).

---

<a id="bagian-http"></a>

## http

Methods and properties for the http class.

### http

#### http:get(url, headers)

Async: must run inside a coroutine. Yields until the request finishes, then resumes with (body, statusCode). statusCode is -1 on failure and body is the error. Blocks local/private IPs; rate limited to one call per 50 ms per thread. headers is an optional { name = value } table.

**Parameters:** `url`, `headers`

**Returns:** `string, number`

```lua
http:get(url, headers)
```

#### http:post(url, headers, postData)

Async: must run inside a coroutine. Same behavior as http.get, but sends postData as the request body.

**Parameters:** `url`, `headers`, `postData`

**Returns:** `string, number`

```lua
http:post(url, headers, postData)
```

Sumber: [http](https://dash.gtps.cloud/docs/http).

---

<a id="bagian-file"></a>

## file

Methods and properties for the file class.

### file

#### file:read(path)

Reads a file inside the server's localStorage folder. Errors if the path is unsafe, missing or too large.

**Parameters:** `path`

**Returns:** `string`

```lua
file:read(path)
```

#### file:write(path, data)

Writes (truncates) a file inside localStorage, creating parent folders. Returns true.

**Parameters:** `path`, `data`

**Returns:** `boolean`

```lua
file:write(path, data)
```

#### file:exists(path)

Checks whether a path inside localStorage exists.

**Parameters:** `path`

**Returns:** `boolean`

```lua
file:exists(path)
```

#### file:delete(path)

Deletes a file inside localStorage. Returns true.

**Parameters:** `path`

**Returns:** `boolean`

```lua
file:delete(path)
```

Sumber: [file](https://dash.gtps.cloud/docs/file).

---

<a id="bagian-dir"></a>

## dir

Methods and properties for the dir class.

### dir

#### dir:create(path)

Creates a directory (and parents) inside localStorage. Returns true.

**Parameters:** `path`

**Returns:** `boolean`

```lua
dir:create(path)
```

#### dir:exists(path)

Checks whether a directory inside localStorage exists.

**Parameters:** `path`

**Returns:** `boolean`

```lua
dir:exists(path)
```

#### dir:delete(path)

Recursively deletes a directory inside localStorage. Returns true.

**Parameters:** `path`

**Returns:** `boolean`

```lua
dir:delete(path)
```

Sumber: [dir](https://dash.gtps.cloud/docs/dir).

---

<a id="bagian-timer"></a>

## timer

Methods and properties for the timer class.

### timer

#### timer:setTimeout(seconds, callback, ...)

Runs callback once after the given seconds. Extra arguments are passed to the callback. Returns a timer ID.

**Parameters:** `seconds`, `callback`, `...`

**Returns:** `number`

```lua
timer:setTimeout(seconds, callback, ...)
```

#### timer:setInterval(seconds, callback, ...)

Runs callback repeatedly every given seconds. Extra arguments are passed to the callback. Returns a timer ID.

**Parameters:** `seconds`, `callback`, `...`

**Returns:** `number`

```lua
timer:setInterval(seconds, callback, ...)
```

#### timer:clear(id)

Cancels a timer created with setTimeout or setInterval.

**Parameters:** `id`

**Returns:** `void`

```lua
timer:clear(id)
```

Sumber: [timer](https://dash.gtps.cloud/docs/timer).

---

<a id="bagian-sqlite"></a>

## sqlite

Methods and properties for the sqlite class.

### sqlite

#### sqlite:open(path)

Opens (or creates) a SQLite database inside localStorage. ATTACH/DETACH and extension loading are disabled. Returns nil and an error message on failure.

**Parameters:** `path`

**Returns:** `SqliteDB`

```lua
sqlite:open(path)
```

Sumber: [sqlite](https://dash.gtps.cloud/docs/sqlite).

---

<a id="bagian-sqlite-db"></a>

## SqliteDB

Methods and properties for the SqliteDB class.

### SqliteDB

#### SqliteDB:query(sql)

Runs one SQL statement. SELECT returns a table of rows (all values are strings); other statements return (true, lastInsertRowID); errors return (nil, message).

**Parameters:** `sql`

**Returns:** `any`

```lua
SqliteDB:query(sql)
```

#### SqliteDB:close()

Closes the database.

**Returns:** `void`

```lua
SqliteDB:close()
```

Sumber: [SqliteDB](https://dash.gtps.cloud/docs/sqlite-db).

---

<a id="bagian-bit"></a>

## bit

Methods and properties for the bit class.

### bit

#### bit:band(a, b)

Bitwise AND.

**Parameters:** `a`, `b`

**Returns:** `number`

```lua
bit:band(a, b)
```

#### bit:bor(a, b)

Bitwise OR.

**Parameters:** `a`, `b`

**Returns:** `number`

```lua
bit:bor(a, b)
```

#### bit:bxor(a, b)

Bitwise XOR.

**Parameters:** `a`, `b`

**Returns:** `number`

```lua
bit:bxor(a, b)
```

#### bit:bnot(a)

Bitwise NOT.

**Parameters:** `a`

**Returns:** `number`

```lua
bit:bnot(a)
```

#### bit:lshift(a, n)

Logical left shift.

**Parameters:** `a`, `n`

**Returns:** `number`

```lua
bit:lshift(a, n)
```

#### bit:rshift(a, n)

Logical right shift.

**Parameters:** `a`, `n`

**Returns:** `number`

```lua
bit:rshift(a, n)
```

#### bit:arshift(a, n)

Arithmetic right shift.

**Parameters:** `a`, `n`

**Returns:** `number`

```lua
bit:arshift(a, n)
```

#### bit:mod(a, b)

Modulo.

**Parameters:** `a`, `b`

**Returns:** `number`

```lua
bit:mod(a, b)
```

Sumber: [bit](https://dash.gtps.cloud/docs/bit).

---

<a id="bagian-os"></a>

## os

Methods and properties for the os class.

### os

#### os:time()

Returns the current unix time in seconds. Only this function exists in the sandboxed os table.

**Returns:** `number`

```lua
os:time()
```

Sumber: [os](https://dash.gtps.cloud/docs/os).

---

<a id="bagian-callbacks"></a>

## Callbacks

Register callbacks to respond to game events. Each callback receives specific parameters from the game.

### Callbacks

#### onPlayerChatCallback

Registers or documents the player chat callback. It receives world, player, message.

**Parameters:** `world`, `player`, `message`

```lua
onPlayerChatCallback(function(world, player, message)
  -- code here
end)
```

#### onBestWorldEndCallback

Registers or documents the best world end callback. It receives world, score.

**Parameters:** `world`, `score`

```lua
onBestWorldEndCallback(function(world, score)
  -- code here
end)
```

#### onPlayerCommandCallback

Registers or documents the player command callback. It receives world, player, command.

**Parameters:** `world`, `player`, `command`

```lua
onPlayerCommandCallback(function(world, player, command)
  -- code here
end)
```

#### onPlayerDialogCallback

> **Project runtime correction:** The user-confirmed [Find](reference/Find-Script.lua) and [Help](reference/Help-Script.lua) scripts receive `(world, player, data)`, where `data` is a table containing `dialog_name`, `buttonClicked`, and submitted fields. Use that payload on this project. The original source description/signature is preserved below. See [In-Game Patterns](GTPSCloud-Ingame-Patterns.md#dialog-callback-payload-important-reference-correction).

Registers or documents the player dialog response callback. It receives world, player, dialogName.

**Parameters:** `world`, `player`, `dialogName`

```lua
onPlayerDialogCallback(function(world, player, dialogName)
  -- code here
end)
```

#### onPlayerLoginCallback

Registers or documents the player login callback. It receives player.

**Parameters:** `player`

```lua
onPlayerLoginCallback(function(player)
  -- code here
end)
```

#### onPlayerFirstTimeLoginCallback

Registers or documents the first-time player login callback. It receives player.

**Parameters:** `player`

```lua
onPlayerFirstTimeLoginCallback(function(player)
  -- code here
end)
```

#### onPlayerRegisterCallback

Registers or documents the player registration callback. It receives world, player.

**Parameters:** `world`, `player`

```lua
onPlayerRegisterCallback(function(world, player)
  -- code here
end)
```

#### onPlayerActionCallback

Registers or documents the player action packet callback. It receives world, player, action.

**Parameters:** `world`, `player`, `action`

```lua
onPlayerActionCallback(function(world, player, action)
  -- code here
end)
```

#### onPlayerEnterWorldCallback

Registers or documents the player entering a world callback. It receives world, player.

**Parameters:** `world`, `player`

```lua
onPlayerEnterWorldCallback(function(world, player)
  -- code here
end)
```

#### onPlayerValidateWorldCallback

Registers or documents the world validation for a player callback. It receives world, player.

**Parameters:** `world`, `player`

```lua
onPlayerValidateWorldCallback(function(world, player)
  -- code here
end)
```

#### onPlayerLeaveWorldCallback

Registers or documents the player leaving a world callback. It receives world, player.

**Parameters:** `world`, `player`

```lua
onPlayerLeaveWorldCallback(function(world, player)
  -- code here
end)
```

#### onPlayerDisconnectCallback

Registers or documents the player disconnect callback. It receives player.

**Parameters:** `player`

```lua
onPlayerDisconnectCallback(function(player)
  -- code here
end)
```

#### onPlayerDeathCallback

Registers or documents the player death callback. It receives world, player, spikeKill.

**Parameters:** `world`, `player`, `spikeKill`

```lua
onPlayerDeathCallback(function(world, player, spikeKill)
  -- code here
end)
```

#### onPlayerTradeCallback

Registers or documents the player trade callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerTradeCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onPlayerBoostClaimCallback

Registers or documents the player boost claim callback. It receives player.

**Parameters:** `player`

```lua
onPlayerBoostClaimCallback(function(player)
  -- code here
end)
```

#### onPlayerTrashCallback

Registers or documents the player trashing an item callback. It receives world, player, itemID, itemCount.

**Parameters:** `world`, `player`, `itemID`, `itemCount`

```lua
onPlayerTrashCallback(function(world, player, itemID, itemCount)
  -- code here
end)
```

#### onPlayerRecycleCallback

Registers or documents the player recycling an item callback. It receives world, player, itemID, itemCount, gems.

**Parameters:** `world`, `player`, `itemID`, `itemCount`, `gems`

```lua
onPlayerRecycleCallback(function(world, player, itemID, itemCount, gems)
  -- code here
end)
```

#### onPlayerCrimeCallback

Registers or documents the player crime reward callback. It receives world, player, rewardID, rewardAmount.

**Parameters:** `world`, `player`, `rewardID`, `rewardAmount`

```lua
onPlayerCrimeCallback(function(world, player, rewardID, rewardAmount)
  -- code here
end)
```

#### onPlayerSurgeryCallback

Registers or documents the player surgery result callback. It receives world, player, resultID, resultAmount, targetPlayer.

**Parameters:** `world`, `player`, `resultID`, `resultAmount`, `targetPlayer`

```lua
onPlayerSurgeryCallback(function(world, player, resultID, resultAmount, targetPlayer)
  -- code here
end)
```

#### onPlayerKillCallback

Registers or documents the player kill event callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerKillCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onPlayerPunchPlayerCallback

Registers or documents the player punching another player callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerPunchPlayerCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onPlayerPunchNPCCallback

Registers or documents the player punching an NPC callback. It receives world, player, npc.

**Parameters:** `world`, `player`, `npc`

```lua
onPlayerPunchNPCCallback(function(world, player, npc)
  -- code here
end)
```

#### onPlayerProviderCallback

Registers or documents the provider collection callback. It receives world, player, tile, itemID, itemAmount.

**Parameters:** `world`, `player`, `tile`, `itemID`, `itemAmount`

```lua
onPlayerProviderCallback(function(world, player, tile, itemID, itemAmount)
  -- code here
end)
```

#### onPlayerHarmonicCallback

Registers or documents the harmonic action reward callback. It receives world, player, tile, itemID, amount.

**Parameters:** `world`, `player`, `tile`, `itemID`, `amount`

```lua
onPlayerHarmonicCallback(function(world, player, tile, itemID, amount)
  -- code here
end)
```

#### onPlayerGeigerCallback

Registers or documents the Geiger action reward callback. It receives world, player, itemID, amount.

**Parameters:** `world`, `player`, `itemID`, `amount`

```lua
onPlayerGeigerCallback(function(world, player, itemID, amount)
  -- code here
end)
```

#### onPlayerCatchGhostCallback

Registers or documents the ghost catch reward callback. It receives world, player, jarID, amount.

**Parameters:** `world`, `player`, `jarID`, `amount`

```lua
onPlayerCatchGhostCallback(function(world, player, jarID, amount)
  -- code here
end)
```

#### onPlayerDNACallback

Registers or documents the DNA result callback. It receives world, player, resultID, resultAmount.

**Parameters:** `world`, `player`, `resultID`, `resultAmount`

```lua
onPlayerDNACallback(function(world, player, resultID, resultAmount)
  -- code here
end)
```

#### onPlayerXPCallback

Registers or documents the player XP change callback. It receives world, player, amount.

**Parameters:** `world`, `player`, `amount`

```lua
onPlayerXPCallback(function(world, player, amount)
  -- code here
end)
```

#### onPlayerFirePutOutCallback

Registers or documents the player putting out fire callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onPlayerFirePutOutCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerGemsObtainedCallback

Registers or documents the player obtaining gems callback. It receives world, player, amount.

**Parameters:** `world`, `player`, `amount`

```lua
onPlayerGemsObtainedCallback(function(world, player, amount)
  -- code here
end)
```

#### onPlayerEarnGrowtokenCallback

Registers or documents the player earning Growtoken progress callback. It receives world, player, progressAmount.

**Parameters:** `world`, `player`, `progressAmount`

```lua
onPlayerEarnGrowtokenCallback(function(world, player, progressAmount)
  -- code here
end)
```

#### onPlayerTrainFishCallback

Registers or documents the player fish training callback. It receives world, player.

**Parameters:** `world`, `player`

```lua
onPlayerTrainFishCallback(function(world, player)
  -- code here
end)
```

#### onPlayerVariantCallback

Registers or documents the player variant packet callback. It receives player, variant, delay, netID.

**Parameters:** `player`, `variant`, `delay`, `netID`

```lua
onPlayerVariantCallback(function(player, variant, delay, netID)
  -- code here
end)
```

#### onPlayerRawPacketCallback

Registers or documents the player raw packet callback. It receives player, packet.

**Parameters:** `player`, `packet`

```lua
onPlayerRawPacketCallback(function(player, packet)
  -- code here
end)
```

#### onServerReceiveRawPacketCallback

Registers or documents the server receiving a raw packet callback. It receives world, player, packet.

**Parameters:** `world`, `player`, `packet`

```lua
onServerReceiveRawPacketCallback(function(world, player, packet)
  -- code here
end)
```

#### onPlayerDropCallback

Registers or documents the player dropping an item callback. It receives world, player, itemID, itemCount.

**Parameters:** `world`, `player`, `itemID`, `itemCount`

```lua
onPlayerDropCallback(function(world, player, itemID, itemCount)
  -- code here
end)
```

#### onPlayerLevelUPCallback

Registers or documents the player level up callback. It receives world, player, level.

**Parameters:** `world`, `player`, `level`

```lua
onPlayerLevelUPCallback(function(world, player, level)
  -- code here
end)
```

#### onPlayerEquipClothingCallback

Registers or documents the player equipping clothing callback. It receives world, player, itemID.

**Parameters:** `world`, `player`, `itemID`

```lua
onPlayerEquipClothingCallback(function(world, player, itemID)
  -- code here
end)
```

#### onPlayerUnequipClothingCallback

Registers or documents the player unequipping clothing callback. It receives world, player, itemID.

**Parameters:** `world`, `player`, `itemID`

```lua
onPlayerUnequipClothingCallback(function(world, player, itemID)
  -- code here
end)
```

#### onPlayerEquippedClothingCallback

Registers or documents the player clothing equipped confirmation callback. It receives world, player, itemID.

**Parameters:** `world`, `player`, `itemID`

```lua
onPlayerEquippedClothingCallback(function(world, player, itemID)
  -- code here
end)
```

#### onPlayerUnequippedClothingCallback

Registers or documents the player clothing unequipped confirmation callback. It receives world, player, itemID.

**Parameters:** `world`, `player`, `itemID`

```lua
onPlayerUnequippedClothingCallback(function(world, player, itemID)
  -- code here
end)
```

#### onPlayerPickupItemCallback

Registers or documents the player picking up an item callback. It receives world, player, itemID, itemCount.

**Parameters:** `world`, `player`, `itemID`, `itemCount`

```lua
onPlayerPickupItemCallback(function(world, player, itemID, itemCount)
  -- code here
end)
```

#### onPlayerEnterDoorCallback

Registers or documents the player entering a door callback. It receives world, player, doorTarget, doorID.

**Parameters:** `world`, `player`, `doorTarget`, `doorID`

```lua
onPlayerEnterDoorCallback(function(world, player, doorTarget, doorID)
  -- code here
end)
```

#### onPlayerPlantCallback

Registers or documents the player planting on a tile callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onPlayerPlantCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerHarvestCallback

Registers or documents the player harvesting a tile callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onPlayerHarvestCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerCatchFishCallback

Registers or documents the player catching fish or fishing reward callback. It receives world, player, rewardID, rewardAmount.

**Parameters:** `world`, `player`, `rewardID`, `rewardAmount`

```lua
onPlayerCatchFishCallback(function(world, player, rewardID, rewardAmount)
  -- code here
end)
```

#### onTileWrenchCallback

Registers or documents the tile wrench action callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onTileWrenchCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerWrenchCallback

Registers or documents the player wrench action callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerWrenchCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onPlayerBlessingClaimCallback

Registers or documents the player blessing claim callback. It receives world, player, blessingID.

**Parameters:** `world`, `player`, `blessingID`

```lua
onPlayerBlessingClaimCallback(function(world, player, blessingID)
  -- code here
end)
```

#### onPlayerConvertItemCallback

Registers or documents the player item conversion callback. It receives world, player, itemID.

**Parameters:** `world`, `player`, `itemID`

```lua
onPlayerConvertItemCallback(function(world, player, itemID)
  -- code here
end)
```

#### onPlayerAddFriendCallback

Registers or documents the player adding a friend callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerAddFriendCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onTileBreakCallback

Registers or documents the tile break callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onTileBreakCallback(function(world, player, tile)
  -- code here
end)
```

#### onTilePlaceCallback

Registers or documents the tile placement attempt callback. It receives world, player, tile, itemID.

**Parameters:** `world`, `player`, `tile`, `itemID`

```lua
onTilePlaceCallback(function(world, player, tile, itemID)
  -- code here
end)
```

#### onTilePlacedCallback

Registers or documents the tile placement completion callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onTilePlacedCallback(function(world, player, tile)
  -- code here
end)
```

#### onTilePunchCallback

Registers or documents the tile punch callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onTilePunchCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerConsumableCallback

Registers or documents the player consumable use callback. It receives world, player, tile, itemID, targetPlayer.

**Parameters:** `world`, `player`, `tile`, `itemID`, `targetPlayer`

```lua
onPlayerConsumableCallback(function(world, player, tile, itemID, targetPlayer)
  -- code here
end)
```

#### onEventChangedCallback

Registers or documents the server event change callback. It receives eventID, oldEventID.

**Parameters:** `eventID`, `oldEventID`

```lua
onEventChangedCallback(function(eventID, oldEventID)
  -- code here
end)
```

#### onPlayerTick

Registers or documents the player tick callback. It receives player.

**Parameters:** `player`

```lua
onPlayerTick(function(player)
  -- code here
end)
```

#### onWorldTick

Registers or documents the world tick callback. It receives world.

**Parameters:** `world`

```lua
onWorldTick(function(world)
  -- code here
end)
```

#### onWorldLoaded

Registers or documents the world load callback. It receives world.

**Parameters:** `world`

```lua
onWorldLoaded(function(world)
  -- code here
end)
```

#### onWorldOffloaded

Registers or documents the world offload callback. It receives world.

**Parameters:** `world`

```lua
onWorldOffloaded(function(world)
  -- code here
end)
```

#### onTick

Registers or documents the server tick callback. It receives no arguments.

```lua
onTick(function()
  -- code here
end)
```

#### onDiscordMessageCreateCallback

Registers or documents the Discord message creation callback. It receives event.

**Parameters:** `event`

```lua
onDiscordMessageCreateCallback(function(event)
  -- code here
end)
```

#### onDiscordButtonClickCallback

Registers or documents the Discord button click callback. It receives event.

**Parameters:** `event`

```lua
onDiscordButtonClickCallback(function(event)
  -- code here
end)
```

#### onDiscordFormSubmitCallback

Registers or documents the Discord form submission callback. It receives event.

**Parameters:** `event`

```lua
onDiscordFormSubmitCallback(function(event)
  -- code here
end)
```

#### onDiscordBotReadyCallback

Registers or documents the Discord bot ready event callback. It receives no arguments.

```lua
onDiscordBotReadyCallback(function()
  -- code here
end)
```

#### onDiscordSlashCommandCallback

Registers or documents the Discord slash command callback. It receives event.

**Parameters:** `event`

```lua
onDiscordSlashCommandCallback(function(event)
  -- code here
end)
```

#### onPlayerDungeonEntitySlainCallback

Registers or documents the dungeon entity slain by a player callback. It receives world, player, entityType.

**Parameters:** `world`, `player`, `entityType`

```lua
onPlayerDungeonEntitySlainCallback(function(world, player, entityType)
  -- code here
end)
```

#### onPlayerStartopiaCallback

Registers or documents the Startopia reward callback. It receives world, player, rewardID, rewardAmount, statusID.

**Parameters:** `world`, `player`, `rewardID`, `rewardAmount`, `statusID`

```lua
onPlayerStartopiaCallback(function(world, player, rewardID, rewardAmount, statusID)
  -- code here
end)
```

#### onPlayerPunchCallback

Registers or documents the player punch coordinates callback. It receives world, player, x, y.

**Parameters:** `world`, `player`, `x`, `y`

```lua
onPlayerPunchCallback(function(world, player, x, y)
  -- code here
end)
```

#### onPlayerCookingCallback

Registers or documents the player-cooking callback. The handler receives the world, player, result item ID, result amount and accuracy.

**Parameters:** `world`, `player`, `resultID`, `resultAmount`, `accuracy`

```lua
onPlayerCookingCallback(function(world, player, resultID, resultAmount, accuracy)
  -- code here
end)
```

#### onHTTPRequest

Registers or documents the incoming HTTP request callback. It receives request.

**Parameters:** `request`

```lua
onHTTPRequest(function(request)
  -- code here
end)
```

#### onPlayerActivateTileCallback

Registers or documents the player activating a tile callback. It receives world, player, tile.

**Parameters:** `world`, `player`, `tile`

```lua
onPlayerActivateTileCallback(function(world, player, tile)
  -- code here
end)
```

#### onPlayerVendingBuyCallback

Registers or documents the player buying from vending callback. It receives world, player, tile, itemID, itemCount.

**Parameters:** `world`, `player`, `tile`, `itemID`, `itemCount`

```lua
onPlayerVendingBuyCallback(function(world, player, tile, itemID, itemCount)
  -- code here
end)
```

#### onPlayerSpliceSeedCallback

Registers or documents the player splicing seeds callback. It receives world, player, tile, seedID.

**Parameters:** `world`, `player`, `tile`, `seedID`

```lua
onPlayerSpliceSeedCallback(function(world, player, tile, seedID)
  -- code here
end)
```

#### onPlayerCardBattleCallback

Registers or documents the player card battle reward callback. It receives world, player, targetPlayer, rewardID, rewardAmount.

**Parameters:** `world`, `player`, `targetPlayer`, `rewardID`, `rewardAmount`

```lua
onPlayerCardBattleCallback(function(world, player, targetPlayer, rewardID, rewardAmount)
  -- code here
end)
```

#### onPlayerDepositCallback

Registers or documents the player depositing an item callback. It receives world, player, tile, itemID, itemCount.

**Parameters:** `world`, `player`, `tile`, `itemID`, `itemCount`

```lua
onPlayerDepositCallback(function(world, player, tile, itemID, itemCount)
  -- code here
end)
```

#### onGetTileExtraDataCallback

Registers or documents the tile extra-data request callback. It receives world, tile, gameVersion, refPlayer.

**Parameters:** `world`, `tile`, `gameVersion`, `refPlayer`

```lua
onGetTileExtraDataCallback(function(world, tile, gameVersion, refPlayer)
  -- code here
end)
```

#### onPlayerRoleChangedCallback

Registers or documents the player role change callback. It receives player, newRoleID, oldRoleID.

**Parameters:** `player`, `newRoleID`, `oldRoleID`

```lua
onPlayerRoleChangedCallback(function(player, newRoleID, oldRoleID)
  -- code here
end)
```

#### onPlayerLoseCardBattleCallback

Registers or documents the player losing a card battle callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerLoseCardBattleCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onLeaderboardEndCallback

Registers or documents the leaderboard completion callback. It receives player, leaderboardType, rank.

**Parameters:** `player`, `leaderboardType`, `rank`

```lua
onLeaderboardEndCallback(function(player, leaderboardType, rank)
  -- code here
end)
```

#### onPlayerEarnAchievementCallback

Registers or documents the player earning an achievement callback. It receives world, player, achievementType.

**Parameters:** `world`, `player`, `achievementType`

```lua
onPlayerEarnAchievementCallback(function(world, player, achievementType)
  -- code here
end)
```

#### onPlayerSewCallback

Registers or documents the player sewing reward callback. It receives world, player, resultID, resultAmount.

**Parameters:** `world`, `player`, `resultID`, `resultAmount`

```lua
onPlayerSewCallback(function(world, player, resultID, resultAmount)
  -- code here
end)
```

#### onPlayerPetBattleCallback

Registers or documents the player pet battle callback. It receives world, player, targetPlayer.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerPetBattleCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onPlayerGemsChangedCallback

Registers or documents the player gem balance change callback. It receives world, player, previousGems.

**Parameters:** `world`, `player`, `previousGems`

```lua
onPlayerGemsChangedCallback(function(world, player, previousGems)
  -- code here
end)
```

#### onPlayerCoinsChangedCallback

Registers or documents the player coin balance change callback. It receives world, player, previousCoins.

**Parameters:** `world`, `player`, `previousCoins`

```lua
onPlayerCoinsChangedCallback(function(world, player, previousCoins)
  -- code here
end)
```

#### onPlayerPlaymodAddedCallback

Registers or documents the playmod added to a player callback. It receives player, modType, lastsForSeconds, applier.

**Parameters:** `player`, `modType`, `lastsForSeconds`, `applier`

```lua
onPlayerPlaymodAddedCallback(function(player, modType, lastsForSeconds, applier)
  -- code here
end)
```

#### onPlayerPlaymodRemovedCallback

Registers or documents the playmod removed from a player callback. It receives player, modType.

**Parameters:** `player`, `modType`

```lua
onPlayerPlaymodRemovedCallback(function(player, modType)
  -- code here
end)
```

#### onPlayerFishingStatusCallback

Registers or documents the player fishing status update callback. It receives world, player, tile, status, itemID.

**Parameters:** `world`, `player`, `tile`, `status`, `itemID`

```lua
onPlayerFishingStatusCallback(function(world, player, tile, status, itemID)
  -- code here
end)
```

#### onPlayerStateChangedCallback

Registers or documents the player state changed callback. It receives world, player, new_state, old_state.

**Parameters:** `world`, `player`, `new_state`, `old_state`

```lua
onPlayerStateChangedCallback(function(world, player, new_state, old_state)
  -- code here
end)
```

#### onPlayerMovedCallback

Registers or documents the player moved callback. It receives world, player, current_x, current_y, previous_x, previous_y.

**Parameters:** `world`, `player`, `current_x`, `current_y`, `previous_x`, `previous_y`

```lua
onPlayerMovedCallback(function(world, player, current_x, current_y, previous_x, previous_y)
  -- code here
end)
```

#### onServerStopCallback

Called when the server is stopping.

```lua
onServerStopCallback(function()
  -- code here
end)
```

#### onPlayerInfectCallback

Called when a player infects another player.

**Parameters:** `world`, `player`, `targetPlayer`

```lua
onPlayerInfectCallback(function(world, player, targetPlayer)
  -- code here
end)
```

#### onNameChangedCallback

Called when a player's name changes.

**Parameters:** `world`, `player`, `oldName`, `changeType`

```lua
onNameChangedCallback(function(world, player, oldName, changeType)
  -- code here
end)
```

#### onPlayerRetrieveCallback

Called when a player retrieves an item from a tile.

**Parameters:** `world`, `player`, `itemID`, `itemCount`, `tile`

```lua
onPlayerRetrieveCallback(function(world, player, itemID, itemCount, tile)
  -- code here
end)
```

#### onToolsUsedCallback

Called when a player uses a tool.

**Parameters:** `world`, `player`, `toolType`, `itemID`, `count`

```lua
onToolsUsedCallback(function(world, player, toolType, itemID, count)
  -- code here
end)
```

Sumber: [Callbacks](https://dash.gtps.cloud/docs/callbacks).

---

<a id="bagian-globals"></a>

## Global Functions

Global utility functions available anywhere in your Lua scripts. No class prefix needed.

### Global Functions

#### registerLuaPlaymod(config)

Registers a playmod and returns its ID. Takes { modID, modName, onAddMessage, onRemoveMessage, iconID, changeSkin = {r, g, b, a}, modState = { ... }, changeMovementSpeed, changeAcceleration, changeGravity, changePunchStrength, changeBuildRange, changePunchRange, changeWaterMovementSpeed }. The first five fields are required.

**Parameters:** `config`

**Returns:** `number`

```lua
registerLuaPlaymod(config)
```

#### registerLuaCommand(config)

Registers a command. Takes { command, roleRequired, description }. roleRequired 0 means no role restriction.

**Parameters:** `config`

**Returns:** `void`

```lua
registerLuaCommand(config)
```

#### registerLuaEvent(config)

Registers a server event. Takes { id, title, description, message }.

**Parameters:** `config`

**Returns:** `void`

```lua
registerLuaEvent(config)
```

#### registerLuaDailyEvent(config)

Registers a daily event. Takes { id, title, description }.

**Parameters:** `config`

**Returns:** `void`

```lua
registerLuaDailyEvent(config)
```

#### registerLuaAchievement(config)

Registers an achievement. Takes { id, icon_id, name, description }. id must be higher than 231.

**Parameters:** `config`

**Returns:** `void`

```lua
registerLuaAchievement(config)
```

#### registerLuaItem(config)

Registers a custom item (and its seed, ID + 1). id must be even and in 21000-24999. All fields are required: id, effect_id, editable_type, item_category, action_type, name, texture, texture_hash, item_kind, texture_x, texture_y, collision_type, extra_file, break_hits, reset_time, grow_time, clothing_type, rarity, description, on_equip, on_remove, playmod, chi ("Earth"|"Water"|"Fire"|other), is_farmable (1/0), hit_sound_type, extra_options, extra_options_2, punch_options, audio_volume, seed_base, seed_overlay, tree_base, tree_leaves, seed_color_r/g/b/a, tree_color_r/g/b/a.

**Parameters:** `config`

**Returns:** `void`

```lua
registerLuaItem(config)
```

#### getItem(itemID)

Returns the item for this Lua API.

**Parameters:** `itemID`

**Returns:** `Item`

```lua
getItem(itemID)
```

#### getItemsCount()

Returns the items count for this Lua API.

**Returns:** `number`

```lua
getItemsCount()
```

#### getMaxItems()

Returns the max items for this Lua API.

**Returns:** `number`

```lua
getMaxItems()
```

#### getRealGTItemsCount()

Returns the real gtitems count for this Lua API.

**Returns:** `number`

```lua
getRealGTItemsCount()
```

#### getServerPlayers()

Returns the server players for this Lua API.

**Returns:** `{Player}`

```lua
getServerPlayers()
```

#### getServerWorlds()

Returns the server worlds for this Lua API.

**Returns:** `{World}`

```lua
getServerWorlds()
```

#### getAllPlayers()

Returns the all players for this Lua API.

**Returns:** `{Player}`

```lua
getAllPlayers()
```

#### getAllWorlds()

Returns the all worlds for this Lua API.

**Returns:** `{World}`

```lua
getAllWorlds()
```

#### getAllGuilds()

Returns the all guilds for this Lua API.

**Returns:** `{Guild}`

```lua
getAllGuilds()
```

#### reloadScripts()

Reloads scripts from disk or server state.

**Returns:** `void`

```lua
reloadScripts()
```

#### reloadConfigs()

Reloads configs from disk or server state. Returns whether the load succeeded.

**Returns:** `boolean`

```lua
reloadConfigs()
```

#### reloadItems()

Reloads items from disk or server state.

**Returns:** `void`

```lua
reloadItems()
```

#### getPlayer(userID)

Returns the player for this Lua API.

**Parameters:** `userID`

**Returns:** `Player`

```lua
getPlayer(userID)
```

#### getPlayerByName(playerName, client)

Returns the players matching the name. client is optional.

**Parameters:** `playerName`, `client`

**Returns:** `{Player}`

```lua
getPlayerByName(playerName, client)
```

#### savePlayer(player)

Saves player to persistent storage.

**Parameters:** `player`

**Returns:** `void`

```lua
savePlayer(player)
```

#### getActiveDailyOffers()

Returns the active daily offers for this Lua API.

**Returns:** `{ShopItem}`

```lua
getActiveDailyOffers()
```

#### getEventOffers()

Returns the event offers for this Lua API.

**Returns:** `{ShopItem}`

```lua
getEventOffers()
```

#### getCurrentServerEvent()

Returns the current server event for this Lua API.

**Returns:** `number`

```lua
getCurrentServerEvent()
```

#### getCurrentServerDailyEvent()

Returns the current server daily event for this Lua API.

**Returns:** `number`

```lua
getCurrentServerDailyEvent()
```

#### getStoreItems()

Returns the store items for this Lua API.

**Returns:** `{ShopItem}`

```lua
getStoreItems()
```

#### getIOTMItem(itemID)

Returns the iotmitem for this Lua API.

**Parameters:** `itemID`

**Returns:** `IOTM`

```lua
getIOTMItem(itemID)
```

#### getEasterBuyTime(userID)

Returns the easter buy time for this Lua API.

**Parameters:** `userID`

**Returns:** `number`

```lua
getEasterBuyTime(userID)
```

#### isDailyOfferPurchased(userID, storeItemID)

Checks whether this Lua API is daily offer purchased.

**Parameters:** `userID`, `storeItemID`

**Returns:** `boolean`

```lua
isDailyOfferPurchased(userID, storeItemID)
```

#### addDailyOfferPurchased(userID, storeItemID)

Adds daily offer purchased data or value to this Lua API. It uses userID, storeItemID.

**Parameters:** `userID`, `storeItemID`

**Returns:** `void`

```lua
addDailyOfferPurchased(userID, storeItemID)
```

#### getEasterEggs(userID)

Returns the easter eggs for this Lua API.

**Parameters:** `userID`

**Returns:** `number`

```lua
getEasterEggs(userID)
```

#### formatStoreTime(targetTime, currentTime)

Formats store time into a script-friendly string. It uses targetTime, currentTime.

**Parameters:** `targetTime`, `currentTime`

**Returns:** `string`

```lua
formatStoreTime(targetTime, currentTime)
```

#### getTopPlayerByBalance()

Returns the top player by balance for this Lua API.

**Returns:** `Player`

```lua
getTopPlayerByBalance()
```

#### getTopWorldByVisitors()

Returns the top world by visitors for this Lua API.

**Returns:** `World`

```lua
getTopWorldByVisitors()
```

#### print(...)

Prints its arguments to the server console, separated by spaces.

**Parameters:** `...`

**Returns:** `void`

```lua
print(...)
```

#### getServerName()

Returns the server name for this Lua API.

**Returns:** `string`

```lua
getServerName()
```

#### getServerID()

Returns the server ID for this Lua API.

**Returns:** `number`

```lua
getServerID()
```

#### getNewsBanner()

Returns the news banner for this Lua API.

**Returns:** `string`

```lua
getNewsBanner()
```

#### getNewsBannerDimensions()

Returns the news banner dimensions for this Lua API.

**Returns:** `string`

```lua
getNewsBannerDimensions()
```

#### getTodaysDate()

Returns the todays date for this Lua API.

**Returns:** `string`

```lua
getTodaysDate()
```

#### getTodaysEvents()

Returns the todays events for this Lua API.

**Returns:** `string`

```lua
getTodaysEvents()
```

#### getMaxLevel()

Returns the max level for this Lua API.

**Returns:** `number`

```lua
getMaxLevel()
```

#### getCurrentEventDescription()

Returns the current event description for this Lua API.

**Returns:** `string`

```lua
getCurrentEventDescription()
```

#### getCurrentDailyEventDescription()

Returns the current daily event description for this Lua API.

**Returns:** `string`

```lua
getCurrentDailyEventDescription()
```

#### getCurrentRoleDayDescription()

Returns the current role day description for this Lua API.

**Returns:** `string`

```lua
getCurrentRoleDayDescription()
```

#### resetColor(message)

Resets the color for this Lua API. It uses message.

**Parameters:** `message`

**Returns:** `string`

```lua
resetColor(message)
```

#### formatTime(targetTime, currentTime)

Formats time into a script-friendly string. It uses targetTime, currentTime.

**Parameters:** `targetTime`, `currentTime`

**Returns:** `string`

```lua
formatTime(targetTime, currentTime)
```

#### getAchievementsCount()

Returns the achievements count for this Lua API.

**Returns:** `number`

```lua
getAchievementsCount()
```

#### getWorld(WorldID)

Returns the world for this Lua API.

**Parameters:** `WorldID`

**Returns:** `World`

```lua
getWorld(WorldID)
```

#### getGuild(GuildID)

Returns the guild for this Lua API.

**Parameters:** `GuildID`

**Returns:** `Guild`

```lua
getGuild(GuildID)
```

#### getWorldByName(worldName)

Returns the world by name for this Lua API.

**Parameters:** `worldName`

**Returns:** `World`

```lua
getWorldByName(worldName)
```

#### saveWorld(world)

Saves world to persistent storage.

**Parameters:** `world`

**Returns:** `void`

```lua
saveWorld(world)
```

#### worldExists(worldName)

Runs the world exists operation for this Lua API. It uses worldName.

**Parameters:** `worldName`

**Returns:** `boolean`

```lua
worldExists(worldName)
```

#### getActiveWorlds()

Returns the active worlds for this Lua API.

**Returns:** `{World}`

```lua
getActiveWorlds()
```

#### getCorruptedSouls(userID)

Returns the corrupted souls for this Lua API.

**Parameters:** `userID`

**Returns:** `number`

```lua
getCorruptedSouls(userID)
```

#### saveDataToServer(uniqueID, data)

Saves a table as JSON under the given unique ID.

**Parameters:** `uniqueID`, `data`

**Returns:** `void`

```lua
saveDataToServer(uniqueID, data)
```

#### loadDataFromServer(uniqueID)

Loads data from server from storage or server state. It uses uniqueID.

**Parameters:** `uniqueID`

**Returns:** `{any}`

```lua
loadDataFromServer(uniqueID)
```

#### saveStringToServer(uniqueID, data)

Saves string to server to persistent storage. It uses uniqueID, data.

**Parameters:** `uniqueID`, `data`

**Returns:** `void`

```lua
saveStringToServer(uniqueID, data)
```

#### loadStringFromServer(uniqueID)

Loads string from server from storage or server state. It uses uniqueID.

**Parameters:** `uniqueID`

**Returns:** `string`

```lua
loadStringFromServer(uniqueID)
```

#### addWorldMenuWorld(world_id, display_name, decimal_color, is_priority)

Adds world menu world data or value to this Lua API. It uses world_id, display_name, decimal_color, is_priority.

**Parameters:** `world_id`, `display_name`, `decimal_color`, `is_priority`

**Returns:** `void`

```lua
addWorldMenuWorld(world_id, display_name, decimal_color, is_priority)
```

#### removeWorldMenuWorld(world_id)

Removes the world menu world from this Lua API. It uses world_id.

**Parameters:** `world_id`

**Returns:** `void`

```lua
removeWorldMenuWorld(world_id)
```

#### hideWorldMenuDefaultSpecialWorlds(hide_default_special_worlds)

Runs the hide world menu default special worlds operation for this Lua API. It uses hide_default_special_worlds.

**Parameters:** `hide_default_special_worlds`

**Returns:** `void`

```lua
hideWorldMenuDefaultSpecialWorlds(hide_default_special_worlds)
```

#### addSocialPortalButton(button_data, callback)

Adds a social portal button. callback runs when the button is used.

**Parameters:** `button_data`, `callback`

**Returns:** `void`

```lua
addSocialPortalButton(button_data, callback)
```

#### getCurrencyShortName()

Returns the currency short name for this Lua API.

**Returns:** `string`

```lua
getCurrencyShortName()
```

#### getCurrencyLongName()

Returns the currency long name for this Lua API.

**Returns:** `string`

```lua
getCurrencyLongName()
```

#### getCurrencyMediumName()

Returns the currency medium name for this Lua API.

**Returns:** `string`

```lua
getCurrencyMediumName()
```

#### getCurrencyIcon()

Returns the currency icon for this Lua API.

**Returns:** `string`

```lua
getCurrencyIcon()
```

#### addSidebarButton(sidebar_button)

Adds sidebar button data or value to this Lua API. It uses sidebar_button.

**Parameters:** `sidebar_button`

**Returns:** `void`

```lua
addSidebarButton(sidebar_button)
```

#### removeSidebarButton(sidebar_button_name)

Removes the sidebar button from this Lua API. It uses sidebar_button_name.

**Parameters:** `sidebar_button_name`

**Returns:** `void`

```lua
removeSidebarButton(sidebar_button_name)
```

#### parseText(str)

Parses text and returns the processed result. It uses str.

**Parameters:** `str`

**Returns:** `{string}`

```lua
parseText(str)
```

#### getBlessingName(blessingID)

Returns the blessing name for this Lua API.

**Parameters:** `blessingID`

**Returns:** `string`

```lua
getBlessingName(blessingID)
```

#### getBlessingInfo(blessingID)

Returns the blessing info for this Lua API.

**Parameters:** `blessingID`

**Returns:** `string`

```lua
getBlessingInfo(blessingID)
```

#### getBlessingRarity(blessingID)

Returns the blessing rarity for this Lua API.

**Parameters:** `blessingID`

**Returns:** `string`

```lua
getBlessingRarity(blessingID)
```

#### setGemEvent(boostGem)

Sets the gem event for this Lua API. It uses boostGem.

**Parameters:** `boostGem`

**Returns:** `void`

```lua
setGemEvent(boostGem)
```

#### setXPEvent(boostXp)

Sets the xpevent for this Lua API. It uses boostXp.

**Parameters:** `boostXp`

**Returns:** `void`

```lua
setXPEvent(boostXp)
```

#### getGemEvent()

Returns the gem event for this Lua API.

**Returns:** `number`

```lua
getGemEvent()
```

#### getXPEvent()

Returns the xpevent for this Lua API.

**Returns:** `number`

```lua
getXPEvent()
```

#### setEvent(event_id)

Sets the event for this Lua API. It uses event_id.

**Parameters:** `event_id`

**Returns:** `void`

```lua
setEvent(event_id)
```

#### setDailyEvent(daily_event_id)

Sets the daily event for this Lua API. It uses daily_event_id.

**Parameters:** `daily_event_id`

**Returns:** `void`

```lua
setDailyEvent(daily_event_id)
```

#### queueRestart(in_seconds, full_restart, message)

Runs the queue restart operation for this Lua API. It uses in_seconds, full_restart, optional message.

**Parameters:** `in_seconds`, `full_restart`, `message`

**Returns:** `void`

```lua
queueRestart(in_seconds, full_restart, message)
```

#### getRoles()

Returns the roles for this Lua API.

**Returns:** `{any}`

```lua
getRoles()
```

#### getTitles()

Returns the titles for this Lua API.

**Returns:** `{any}`

```lua
getTitles()
```

#### getPlaymods()

Returns the playmods for this Lua API.

**Returns:** `{any}`

```lua
getPlaymods()
```

#### getHighestPriorityRole()

Returns the highest priority role for this Lua API.

**Returns:** `any`

```lua
getHighestPriorityRole()
```

#### getEcoQuantity(itemID)

Returns the eco quantity for this Lua API.

**Parameters:** `itemID`

**Returns:** `number`

```lua
getEcoQuantity(itemID)
```

#### getEcoQuantityPlayers(itemID)

Returns the eco quantity players for this Lua API.

**Parameters:** `itemID`

**Returns:** `number`

```lua
getEcoQuantityPlayers(itemID)
```

#### getEcoQuantityWorlds(itemID)

Returns the eco quantity worlds for this Lua API.

**Parameters:** `itemID`

**Returns:** `number`

```lua
getEcoQuantityWorlds(itemID)
```

#### createRedeemCode(config)

Creates a redeem code and returns it (empty string on failure). Takes { redeemCode, obtainGems, obtainCoins, obtainRole, redeemItems = { {id, count} }, maxUses, requireLevel, requireRole, requireGrowID (1/0), requirePlaytime, requireAccountAge, redeemTitles = { {titleID} } }. An empty or over-16-char redeemCode generates a random one.

**Parameters:** `config`

**Returns:** `string`

```lua
createRedeemCode(config)
```

#### setPlaymodDuration(playmod_id, seconds)

Changes the duration of a playmod.

**Parameters:** `playmod_id`, `seconds`

**Returns:** `void`

```lua
setPlaymodDuration(playmod_id, seconds)
```

#### setBroadcastWorld(worldName)

Sets the broadcast world for this Lua API. It uses worldName.

**Parameters:** `worldName`

**Returns:** `void`

```lua
setBroadcastWorld(worldName)
```

#### getJimDailyQuest()

Returns the jim daily quest for this Lua API.

**Returns:** `any`

```lua
getJimDailyQuest()
```

#### deleteAccount(id)

Deletes the account resource. It uses id.

**Parameters:** `id`

**Returns:** `void`

```lua
deleteAccount(id)
```

#### deleteWorld(id)

Deletes the world resource. It uses id.

**Parameters:** `id`

**Returns:** `void`

```lua
deleteWorld(id)
```

#### deleteGuild(id)

Deletes the guild resource. It uses id.

**Parameters:** `id`

**Returns:** `void`

```lua
deleteGuild(id)
```

#### getServerDefaultPort()

Returns the server default port for this Lua API.

**Returns:** `number`

```lua
getServerDefaultPort()
```

#### getEvents()

Returns the events for this Lua API.

**Returns:** `{any}`

```lua
getEvents()
```

#### getDailyEvents()

Returns the daily events for this Lua API.

**Returns:** `{any}`

```lua
getDailyEvents()
```

#### getItemEffects()

Returns the item effects for this Lua API.

**Returns:** `{any}`

```lua
getItemEffects()
```

#### getWorldEffects()

Returns the world effects for this Lua API.

**Returns:** `{any}`

```lua
getWorldEffects()
```

#### getPlayerEffects()

Returns the player effects for this Lua API.

**Returns:** `{any}`

```lua
getPlayerEffects()
```

#### getRoleQuestDay()

Returns the role quest day for this Lua API.

**Returns:** `number`

```lua
getRoleQuestDay()
```

#### getAchievements()

Returns the achievements for this Lua API.

**Returns:** `{any}`

```lua
getAchievements()
```

#### getMachineCaps()

Returns the machine caps for this Lua API.

**Returns:** `{any}`

```lua
getMachineCaps()
```

#### hasFeatureEnabled(name)

Checks whether this Lua API has feature enabled. It uses name.

**Parameters:** `name`

**Returns:** `boolean`

```lua
hasFeatureEnabled(name)
```

#### createTemplate(backupName)

Creates a server template (Diamond tier, max 10). Name is 3-32 chars of [a-zA-Z0-9._-] WITHOUT the .dat suffix.

**Parameters:** `backupName`

**Returns:** `boolean`

```lua
createTemplate(backupName)
```

#### applyTemplate(backupName)

Applies a template and restarts the server (Diamond tier). backupName MUST include the .dat suffix.

**Parameters:** `backupName`

**Returns:** `boolean`

```lua
applyTemplate(backupName)
```

#### getTemplates()

Returns the templates for this Lua API.

**Returns:** `{any}`

```lua
getTemplates()
```

#### hasTemplate(backupName)

Checks whether a template exists (Diamond tier). backupName MUST include the .dat suffix.

**Parameters:** `backupName`

**Returns:** `boolean`

```lua
hasTemplate(backupName)
```

#### deleteTemplate(backupName)

Deletes a template (Diamond tier). backupName MUST include the .dat suffix.

**Parameters:** `backupName`

**Returns:** `boolean`

```lua
deleteTemplate(backupName)
```

#### includeClientFile(url, name)

Downloads a PNG/RTTEX/RTPACK from url and syncs it to clients under name. name must match interface/<name>.rttex or game/<name>.rttex. Returns { url, name, size, width, height, hash }.

**Parameters:** `url`, `name`

**Returns:** `any`

```lua
includeClientFile(url, name)
```

#### enableCaching(item_id)

Enables caching for the target resource. It uses item_id.

**Parameters:** `item_id`

**Returns:** `void`

```lua
enableCaching(item_id)
```

#### disableCaching(item_id)

Disables caching for the target resource. It uses item_id.

**Parameters:** `item_id`

**Returns:** `void`

```lua
disableCaching(item_id)
```

#### getServerDiscordLink()

Returns the server Discord invite link from the config.

**Returns:** `string`

```lua
getServerDiscordLink()
```

#### getServerDiscordHowToPlay()

Returns the how-to-play Discord link from the config.

**Returns:** `string`

```lua
getServerDiscordHowToPlay()
```

#### deleteExport(exportName)

Deletes an exported world file. exportName must include the .dat suffix. Returns false if it doesn't exist.

**Parameters:** `exportName`

**Returns:** `boolean`

```lua
deleteExport(exportName)
```

#### addCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count, combiner_id, builder_level, cook_level, water, startopia_level)

Adds a 3-ingredient combiner recipe. Optional: combiner_id (default 952), builder_level, cook_level, water (1/0), startopia_level.

**Parameters:** `id_1`, `count_1`, `id_2`, `count_2`, `id_3`, `count_3`, `result_id`, `result_count`, `combiner_id`, `builder_level`, `cook_level`, `water`, `startopia_level`

**Returns:** `void`

```lua
addCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count, combiner_id, builder_level, cook_level, water, startopia_level)
```

#### removeCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count)

Removes a combiner recipe matching the first eight arguments.

**Parameters:** `id_1`, `count_1`, `id_2`, `count_2`, `id_3`, `count_3`, `result_id`, `result_count`

**Returns:** `void`

```lua
removeCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count)
```

#### getCombinerRecipes()

Returns all combiner recipes as { id_1, id_2, id_3, count_1, count_2, count_3, result_id, result_count, combiner_id, builder_level, cook_level, startopia_level, need_water }.

**Returns:** `{any}`

```lua
getCombinerRecipes()
```

#### getSpecialStoreItems(player)

Returns event-specific store button strings. The player is optional and used for per-player progress.

**Parameters:** `player`

**Returns:** `{string}`

```lua
getSpecialStoreItems(player)
```

#### setGuildCreatePriceSSUP(price)

Sets the guild creation price for Super Supporters.

**Parameters:** `price`

**Returns:** `void`

```lua
setGuildCreatePriceSSUP(price)
```

#### setGuildCreatePriceSUP(price)

Sets the guild creation price for Supporters.

**Parameters:** `price`

**Returns:** `void`

```lua
setGuildCreatePriceSUP(price)
```

#### setGuildCreatePriceNormal(price)

Sets the guild creation price for regular players.

**Parameters:** `price`

**Returns:** `void`

```lua
setGuildCreatePriceNormal(price)
```

Sumber: [Global Functions](https://dash.gtps.cloud/docs/globals).

---

<a id="bagian-utilities"></a>

## Utilities

Timer, HTTP, File I/O, Database, and Bitwise operation utilities.

### Timer

#### timer.setTimeout(seconds, callback, ...)

Schedules a callback to run once after the given seconds.

**Parameters:** `seconds: number`, `callback: function`, `...: any`

**Returns:** `number (timerID)`

```lua
timer.setTimeout(seconds, callback, ...)
```

#### timer.setInterval(seconds, callback, ...)

Schedules a callback to repeat every given seconds.

**Parameters:** `seconds: number`, `callback: function`, `...: any`

**Returns:** `number (timerID)`

```lua
timer.setInterval(seconds, callback, ...)
```

#### timer.clear(id)

Cancels a timeout or interval by timer ID.

**Parameters:** `id: number`

```lua
timer.clear(id)
```

### HTTP

#### http.get(url)

Performs an async HTTP GET request.

**Parameters:** `url: string`

```lua
http.get(url)
```

#### http.post(url, post_data)

Performs an async HTTP POST request.

**Parameters:** `url: string`, `post_data: string`

```lua
http.post(url, post_data)
```

### File

#### file.read(path)

Reads a file from disk.

**Parameters:** `path: string`

**Returns:** `string`

```lua
file.read(path)
```

#### file.write(path, data)

Writes data to a file.

**Parameters:** `path: string`, `data: string`

```lua
file.write(path, data)
```

#### file.exists(path)

Checks whether a file exists.

**Parameters:** `path: string`

**Returns:** `boolean`

```lua
file.exists(path)
```

#### file.delete(path)

Deletes a file.

**Parameters:** `path: string`

```lua
file.delete(path)
```

#### dir.create(path)

Creates a directory.

**Parameters:** `path: string`

```lua
dir.create(path)
```

#### dir.exists(path)

Checks whether a directory exists.

**Parameters:** `path: string`

**Returns:** `boolean`

```lua
dir.exists(path)
```

#### dir.delete(path)

Deletes a directory.

**Parameters:** `path: string`

```lua
dir.delete(path)
```

### Database

#### db.open(path)

Opens a SQLite database handle.

**Parameters:** `path: string`

**Returns:** `LuaDB`

```lua
db.open(path)
```

#### LuaDB:query(query)

Runs a SQL query against the database.

**Parameters:** `query: string`

```lua
LuaDB:query(query)
```

#### LuaDB:close()

Closes the database handle.

```lua
LuaDB:close()
```

### Bitwise

#### bit.band(a, b?)

Bitwise AND operation.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.band(a, b?)
```

#### bit.bor(a, b?)

Bitwise OR operation.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.bor(a, b?)
```

#### bit.bxor(a, b?)

Bitwise XOR operation.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.bxor(a, b?)
```

#### bit.bnot(a)

Bitwise NOT operation.

**Parameters:** `a: number`

**Returns:** `number`

```lua
bit.bnot(a)
```

#### bit.lshift(a, b?)

Left shift operation.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.lshift(a, b?)
```

#### bit.rshift(a, b?)

Logical right shift.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.rshift(a, b?)
```

#### bit.arshift(a, b?)

Arithmetic right shift.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.arshift(a, b?)
```

#### bit.mod(a, b?)

Bitmask modulo operation.

**Parameters:** `a: number`, `b?: number`

**Returns:** `number`

```lua
bit.mod(a, b?)
```

### Module

#### require(modname)

Loads a Lua module through the sandboxed require.

**Parameters:** `modname: string`

```lua
require(modname)
```

Sumber: [Utilities](https://dash.gtps.cloud/docs/utilities).
