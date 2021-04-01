--- @class float:number @Floating-point precision decimal number
--- @class XYString:string @String coordinates in the `x,y` format

--- @class debuglibtfm
debug = {}

--- @class oslibtfm
os = {}

--- Global Transformice namespace
tfm = {}

--- Transformice enumerations table
tfm.enum = {}

--- @class TfmMisc
--- @field apiVersion string
--- @field transformiceVersion float

--- @class TfmShamanObject
--- @field angle integer
--- @field baseType integer
--- @field colors string[]
--- @field ghost boolean
--- @field id integer
--- @field type integer
--- @field vx integer @The horizontal speed of the object.
--- @field vy integer @The vertical speed of the object.
--- @field x integer @The horizontal coordinate of the object.
--- @field y integer @The vertical coordinate of the object.

--- @class TfmPlayer
--- @field cheeses integer @The number of cheeses that the player is carrying. This property is useful in multiple-cheese maps (dodue).
--- @field community string @The legacy community of the player. This exists for backward compatibility, consider using `language` instead.
--- @field gender integer
--- @field hasCheese boolean
--- @field id integer
--- @field inHardMode integer @Deprecated. Use `shamanMode` instead.
--- @field isDead boolean
--- @field isFacingRight boolean
--- @field isInvoking boolean
--- @field isJumping boolean
--- @field isShaman boolean
--- @field isVampire boolean
--- @field language string
--- @field look string
--- @field movingLeft boolean
--- @field movingRight boolean
--- @field playerName string
--- @field registrationDate integer
--- @field score integer
--- @field shamanMode integer
--- @field spouseId integer
--- @field spouseName string
--- @field title integer
--- @field tribeId integer
--- @field tribeName string
--- @field vx integer @The horizontal speed of the player.
--- @field vy integer @The vertical speed of the player.
--- @field x integer @The horizontal coordinate of the player.
--- @field y integer @The vertical coordinate of the player.

--- @class XmlMapInfo
--- @field author string
--- @field mapCode integer
--- @field permCode integer
--- @field xml string

--- @class TfmRoom
--- @field community string @The legacy community of the room. This exists for backward compatibility, consider using `language` instead.
--- @field currentMap string
--- @field isTribeHouse boolean
--- @field language string
--- @field maxPlayers integer
--- @field mirroredMap boolean
--- @field name string
--- @field objectList table<integer, TfmShamanObject> @<objectId, objectMeta>
--- @field passwordProtected boolean
--- @field playerList table<string, TfmPlayer> @<playerName, playerMeta>
--- @field uniquePlayers integer|nil @The number of unique IP addresses in the room. Module team only.
--- @field xmlMapInfo XmlMapInfo|nil

--- @class TfmGet @Transformice metadata
--- @field misc TfmMisc
--- @field room TfmRoom
tfm.get = {}

--- Transformice system namespace
system = {}

-- Transformice user interface namespace
ui = {}

--- @class TfmExec
--- Transformice exec namespace
tfm.exec = {}

--- Deactivates the events log.
--- @param activate boolean whether it should be active (default true)
function debug.disableEventLog(activate) end

--- Gets the current lua thread name.
--- @return string @the current thread name
function debug.getCurrentThreadName() end

--- Returns a string with a traceback of the call stack. The optional message string is appended at the beginning of the traceback.
---
--- [View documents](command:extension.lua.doc?["en-US/52/manual.html/pdf-debug.traceback"])
--- @param message? any
--- @param level?   integer
--- @return string  message
function debug.traceback(message, level) end

--- Listens to the player's keyboard events.
--- @param playerName string the player you want to listen keyboard events from
--- @param keyCode integer the code of the key you want to listen
---     - to accurately listen for player movement (both arrows and wasd/zqsd keys), you can use 0 (left), 1 (up), 2 (right) or 3 (down)
---     - regular AS3 keycodes can be found on http://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
--- @param down boolean whether it should listen for the press event, or the release one
--- @param activate boolean whether it should be active (default true)
function system.bindKeyboard(playerName,keyCode,down,activate) end

--- Listens to a player's mouse events.
--- @param playerName string the player you want to listen mouse events from
--- @param active boolean whether it should be active (default true)
function system.bindMouse(playerName,active) end

--- Prevents a module command (commands starting with « ! ») to be displayed in the room. If the supplied command is nil, the parameter will apply to all the commands.
--- @param command string the command (without the initial « ! ») to hide (default nil)
--- @param hide boolean whether the command should be hided (default true)
function system.disableChatCommandDisplay(command,hide) end

--- Deactivates the lua script running.
function system.exit() end

--- Gives an event reward to the targeted player.
--- Event elevation only.
--- @param playerName string the player to give the gift to
--- @param giftCode string the gift identifier (given by an admin)
function system.giveEventGift(playerName,giftCode) end

--- Requests the loading of a data file. The event eventFileLoaded is triggered when the file gets loaded.
--- Module team only.
--- @param fileNumber integer the identifier of the file to load (default 0)
--- @return boolean @whether the loading got started
function system.loadFile(fileNumber) end

--- Requests the loading of the player's data for this module. The event eventPlayerDataLoaded is triggered when the player data gets loaded.
--- Module team only.
--- @param playerName string the player about whom you want to get the data
--- @return boolean @whether the loading got started
function system.loadPlayerData(playerName) end

--- Creates a new timer to call a function after a delay, once or continuously.
--- Module team only.
--- @param callback fun(timerId:integer, arg1:any, arg2:any, arg3:any, arg4:any) The function to call. The first argument of this function is the timer's identifier
--- @param time integer the number of milliseconds that the function call should be delayed by
--- @param loop boolean whether the function call should loop or happen only once (default false)
--- @param arg1 any 2nd argument of the callback function (default nil)
--- @param arg2 any 3rd argument of the callback function (default nil)
--- @param arg3 any 4th argument of the callback function (default nil)
--- @param arg4 any 5th argument of the callback function (default nil)
--- @return integer @the new timer id
function system.newTimer(callback,time,loop,arg1,arg2,arg3,arg4) end

--- Destroys a timer.
--- Module team only.
--- @param timerId integer the identifier of the timer to stop
function system.removeTimer(timerId) end

--- Requests the saving of a data file (throttled to one per minute). The event eventFileSaved is triggered when the file get saved.
--- Module team only.
--- @param data string the data to store in the file
--- @param fileNumber integer the identifier (from 0 to 99) of the file to write the data in (default 0)
--- @return boolean @whether the saving got started
function system.saveFile(data,fileNumber) end

--- Saves module data about a player. Please note that this data is per player and per Lua dev, so take care not to overwrite data from another one of your modules.
--- Module team only.
--- @param playerName string the player about whom you want to save data
--- @param data string the player data to save
function system.savePlayerData(playerName,data) end

--- Adds a defilante bonus (token) to the map.
--- @param type integer bonus type (see tfm.enum.bonus) (default 1)
--- @param xPosition integer the horizontal coordinate of the bonus (default 0)
--- @param yPosition integer the vertical coordinate of the bonus (default 0)
--- @param id integer the identifier of the bonus (default 0)
--- @param angle integer the angle of the bonus (default 0)
--- @param visible boolean whether the bonus should be visible (default true)
--- @param targetPlayer string the player who should see the bonus (if nil, applies to all players) (default nil)
function tfm.exec.addBonus(type,xPosition,yPosition,id,angle,visible,targetPlayer) end

--- Adds conjuration to the map. Note: Grid coordinate are regular coordinate divided by 10 (as conjuration is a 10x10 pixel square).
--- @param xPosition integer the horizontal grid coordinate of the conjuration
--- @param yPosition integer the vertical grid coordinate of the conjuration
--- @param duration integer the duration of the conjuration in milliseconds (default 10000)
function tfm.exec.addConjuration(xPosition,yPosition,duration) end

--- Displays an image on the map.
--- @param imageId string the image identifier
--- @param target string the game element to attach the image to
---     - #mobileId
---     - $playerName (on the mouse sprite)
---     - %playerName (with the mouse sprite removed)
---     - ?backgroundLayerDepth
---     - _groundLayerDepth
---     - !foregroundLayerDepth
---     - &fixedLayerDepthBeforeLuaInterfaces
---     - :fixedLayerDepthBehindLuaInterfaces
--- @param xPosition integer the horizontal offset of the anchor of the image, relative to the game element (0 being the middle of the game element) (default 0)
--- @param yPosition integer the vertical offset of the anchor of the image, relative to the game element (0 being the middle of the game element) (default 0)
--- @param targetPlayer string the player who will see the image (if nil, applies to all players) (default nil)
--- @param xScale float the horizontal (width) scale of the image (default 1)
--- @param yScale float the vertical (height) scale of the image (default 1)
--- @param angle float the rotation angle about anchor of the image, in radians (default 0)
--- @param alpha float the opacity of the image, from 0 (transparent) to 1 (opaque) (default 1)
--- @param xAnchor float the horizontal offset (in 0 to 1 scale) of the image's anchor, relative to the image (0 being the left of the image) (default 0)
--- @param yAnchor float the vertical offset (in 0 to 1 scale) of the image's anchor, relative to the image (0 being the top of the image) (default 0)
--- @return integer @the image identifier
function tfm.exec.addImage(imageId,target,xPosition,yPosition,targetPlayer,xScale,yScale,angle,alpha,xAnchor,yAnchor) end

--- @alias JointType
---| '0' # distance joint
---| '1' # prismatic joint
---| '2' # pulley joint
---| '3' # revolute joint

-- NOTE: to remove joint custom type description when/if lua-vscode
-- supports expanding alias description of fields
--- @class JointDef
--- @field type JointType @0 -> distance joint, 1 -> prismatic joint, 2 -> pulley joint, 3 -> revolute joint
--- @field point1 XYString @location of the ground1 anchor (default: the ground1's center)
--- @field point2 XYString @location of the ground2 anchor (default: the ground2's center), only used with distance and pulley joints
--- @field point3 XYString @location of the pulley's first anchor, only used with pulley joints
--- @field point4 XYString @location of the pulley's second anchor, only used with pulley joints
--- @field frequency float @distance joints' frequency
--- @field damping float @distance joints' damping ratio
--- @field axis XYString @prismatic joints' axis
--- @field angle XYString @prismatic joints' angle
--- @field limit1 float @prismatic and revolute joints' translation/rotation first limit
--- @field limit2 float @prismatic and revolute joints' translation/rotation second limit
--- @field forceMotor float @prismatic and revolute joints' motor power
--- @field speedMotor float @prismatic and revolute joints' motor speed
--- @field ratio float @revolute joints' ratio
--- @field line integer @draw line's thickness
--- @field color integer float @draw line's color
--- @field alpha float @draw line's opacity
--- @field foreground boolean @whether the draw line is foreground

--- Adds a joint between two physic objects. . Note: In map XML codes, you can also add a « lua="id" » property in a joint definition to be able to interact with it with LUA code.
--- @param id integer the identifier of the joint
--- @param ground1 integer the first ground the joint will affect
--- @param ground2 integer the second ground the joint will affect
--- @param jointDef JointDef the ground description (table)
function tfm.exec.addJoint(id,ground1,ground2,jointDef) end

--- @class BodyDef
--- @field type integer
--- @field width integer
--- @field height integer
--- @field foreground boolean
--- @field friction float
--- @field restitution float
--- @field angle integer
--- @field color integer
--- @field miceCollision boolean
--- @field groundCollision boolean
--- @field dynamic boolean
--- @field fixedRotation boolean
--- @field mass integer
--- @field linearDamping float
--- @field angularDamping float

--- Spawns a ground.
--- @param id integer the identifier of the physic object
--- @param xPosition integer the horizontal coordinate of the center of the ground
--- @param yPosition integer the vertical coordinate of the center of the ground
--- @param bodyDef BodyDef the ground description (table)
function tfm.exec.addPhysicObject(id,xPosition,yPosition,bodyDef) end

--- Spawns a shaman object.
--- @param objectType integer the type of the shaman object to spawn
--- @param xPosition integer the horizontal position of the spawn
--- @param yPosition integer the vertical position of the spawn
--- @param angle integer the rotation angle of the object, in degrees (default 0)
--- @param xSpeed integer the horizontal speed of the object (default 0)
--- @param ySpeed integer the vertical speed of the object (default 0)
--- @param ghost boolean whether the spawned object should be transparent (default false)
--- @return integer @the shaman object identifier
function tfm.exec.addShamanObject(objectType,xPosition,yPosition,angle,xSpeed,ySpeed,ghost) end

--- Changes the size of a player.
--- @param playerName string the player's nickname
--- @param size float the new size of the player (between 0.1 and 5) (default 1)
function tfm.exec.changePlayerSize(playerName,size) end

--- Displays a chat message.
--- Module team only.
--- @param message string the chat message to display
--- @param playerName string the player who will get the message (if nil, applies to all players) (default nil)
function tfm.exec.chatMessage(message,playerName) end

--- Deactivates the automatic afk death.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableAfkDeath(activate) end

--- Deactivates all shaman skills.
--- @param active boolean whether the deactivation should be active (default true)
function tfm.exec.disableAllShamanSkills(active) end

--- Deactivates the automatic renewal of rounds.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableAutoNewGame(activate) end

--- Deactivates the automatic scoring management.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableAutoScore(activate) end

--- Deactivates the automatic selection of shaman.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableAutoShaman(activate) end

--- Deactivates the automatic remaining time change to 20s (when the shaman dies for example).
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableAutoTimeLeft(activate) end

--- Disables the effects of the /debug command.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableDebugCommand(activate) end

--- Disables the minimalist mode.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableMinimalistMode(activate) end

--- Disables the /mort command.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableMortCommand(activate) end

--- Deactivates physical consumables (like in racing and bootcamp rooms).
--- @param active boolean whether the deactivation should be active (default true)
function tfm.exec.disablePhysicalConsumables(active) end

--- Enables or disables the shaman objects prespawn preview.
--- @param display boolean whether the prespawn preview should not be displayed (default true)
function tfm.exec.disablePrespawnPreview(display) end

--- Disables the effects of the /watch command.
--- @param activate boolean whether the deactivation should be active (default true)
function tfm.exec.disableWatchCommand(activate) end

--- Displays a particle.
--- @param particleType integer the kind of particle you want to display
--- @param xPosition integer the horizontal coordinate of the particle
--- @param yPosition integer the vertical coordinate of the particle
--- @param xSpeed float the horizontal speed of the particle (default 0)
--- @param ySpeed float the vertical speed of the particle (default 0)
--- @param xAcceleration float the horizontal acceleration of the particle (default 0)
--- @param yAcceleration float the vertical acceleration of the particle (default 0)
--- @param targetPlayer string the player who should see the particle (if nil, applies to all players) (default nil)
function tfm.exec.displayParticle(particleType,xPosition,yPosition,xSpeed,ySpeed,xAcceleration,yAcceleration,targetPlayer) end

--- Throws an explosion.
--- @param xPosition integer the horizontal coordinate of the center of the explosion
--- @param yPosition integer the vertical coordinate of the center of the explosion
--- @param power integer the maximum power of the explosion
--- @param radius integer the explosion radius (players further away won't be affected)
--- @param miceOnly boolean whether the explosion should affect only mice, or objects too (default false)
function tfm.exec.explosion(xPosition,yPosition,power,radius,miceOnly) end

--- Freezes the selected player.
--- @param playerName string the player to freeze
--- @param freeze boolean whether the player should be frozen (default true)
function tfm.exec.freezePlayer(playerName,freeze) end

--- Gets the player who is the room's current synchronizer.
--- Module team only.
--- @return string @the player's nickname
function tfm.exec.getPlayerSync() end

--- Gives the cheese to a player.
--- @param playerName string the player who should get the cheese
function tfm.exec.giveCheese(playerName) end

--- Gives consumables to the targeted player.
--- @param playerName string the player to give the gift to
--- @param consumableId string the consumable identifier
--- @param amount string the amount of consumables to give (default "1")
function tfm.exec.giveConsumables(playerName,consumableId,amount) end

--- Gives the meep competence to a player, or removes it.
--- @param playerName string the player's nickname
--- @param canMeep boolean whether the player should be able to meep (default true)
function tfm.exec.giveMeep(playerName,canMeep) end

--- Gives the transformations to a player, or removes them.
--- @param playerName string the player's nickname
--- @param canTransform boolean whether the player should be able to use transformations (default true)
function tfm.exec.giveTransformations(playerName,canTransform) end

--- Kills the selected player.
--- @param playerName string the player to kill
function tfm.exec.killPlayer(playerName) end

--- Allows to link players like in soulmate maps.
--- @param playerName1 string the first player's nickname
--- @param playerName2 string the second player's nickname
--- @param linked boolean whether the two players should be linked (default true)
function tfm.exec.linkMice(playerName1,playerName2,linked) end

--- Lowers the synchronization delay of a player to 400ms max
--- Module team only.
--- @param playerName string the player who should have a lower sync delay
function tfm.exec.lowerSyncDelay(playerName) end

--- Defines the speed and position of a shaman object.
--- @param objectId integer the shaman object identifier
--- @param xPosition integer the horizontal coordinate of the point where the object will be moved
--- @param yPosition integer the vertical coordinate of the point where the object will be moved
--- @param positionOffset boolean whether the specified position is an offset to apply to the current one, or the absolute one (default false)
--- @param xSpeed integer the horizontal coordinate of the speed to give to the object (default 0)
--- @param ySpeed integer the vertical coordinate of the speed to give to the object (default 0)
--- @param speedOffset boolean whether the specified speed is an offset to apply to the current one, or the absolute one (default false)
--- @param angle integer the angle of the object (default 0)
--- @param angleOffset boolean whether the specified angle is an offset to apply to the current one, or the absolute one (default false)
function tfm.exec.moveObject(objectId,xPosition,yPosition,positionOffset,xSpeed,ySpeed,speedOffset,angle,angleOffset) end

--- Defines the speed and position of a player.
--- @param playerName string the player to move
--- @param xPosition integer the horizontal coordinate of the point where the player will be moved
--- @param yPosition integer the vertical coordinate of the point where the player will be moved
--- @param positionOffset boolean whether the specified position is an offset to apply to the current one, or the absolute one (default false)
--- @param xSpeed integer the horizontal coordinate of the speed to give to the player (default 0)
--- @param ySpeed integer the vertical coordinate of the speed to give to the player (default 0)
--- @param speedOffset boolean whether the specified speed is an offset to apply to the current one, or the absolute one (default false)
function tfm.exec.movePlayer(playerName,xPosition,yPosition,positionOffset,xSpeed,ySpeed,speedOffset) end

--- Starts a new game
--- @param mapCode string the map code (default nil)
---     - nil (a random map)
---     - 6 (vanilla map)
---     - @42583 (editor map)
---     - #4 (perm category map)
---     - anything beginning with '<' (xml map)
--- @param flipped boolean whether the map should be flipped (default nil (randomly mirrored in racing and bootcamp rooms, unless))
function tfm.exec.newGame(mapCode,flipped) end

--- Makes a player do an emote.
--- @param playerName string the player who should do the emote
--- @param emoteId integer the emote to do
--- @param emoteArg string the emote attribute (for the flag emote for example) (default nil)
function tfm.exec.playEmote(playerName,emoteId,emoteArg) end

--- Makes a player enter the hole. It only works if the player already has a cheese!
--- @param playerName string the player who should win
function tfm.exec.playerVictory(playerName) end

--- Removes a defilante bonus (token).
--- @param id integer the identifier of the bonus (default 0)
--- @param targetPlayer string the player whom should have the bonus removed (if nil, applies to all players) (default nil)
function tfm.exec.removeBonus(id,targetPlayer) end

--- Takes away the cheese from a player.
--- @param playerName string the player who should get their cheese removed
function tfm.exec.removeCheese(playerName) end

--- Removes an image.
--- @param imageId integer the image identifier
function tfm.exec.removeImage(imageId) end

--- Removes a joint from the game.
--- @param id integer the identifier of the joint to remove
function tfm.exec.removeJoint(id) end

--- Removes a shaman object.
--- @param objectId integer the shaman object identifier
function tfm.exec.removeObject(objectId) end

--- Removes a ground from the game.
--- @param id integer the identifier of the ground to remove
function tfm.exec.removePhysicObject(id) end

--- Respawns a player.
--- @param playerName string the player to respawn
function tfm.exec.respawnPlayer(playerName) end

--- Sets whether the following maps should be flipped (always, never, or TFM's default behaviour).
--- @param flipped boolean whether the maps should be flipped (default nil (the default TFM behaviour))
function tfm.exec.setAutoMapFlipMode(flipped) end

--- Sets the game remaining time.
--- @param time integer the remaining time in seconds
--- @param init boolean whether the remaining time should change even if the specified remaining time is higher than the current one (default true)
function tfm.exec.setGameTime(time,init) end

--- Changes a player's nickname's color.
--- @param playerName string the player whose nickname  should be colored
--- @param color integer the color of the nickname
function tfm.exec.setNameColor(playerName,color) end

--- Sets the player's score.
--- @param playerName string the player who should get his or her score changed
--- @param score integer the score
--- @param add boolean whether the current score should be added to the specified one (default false)
function tfm.exec.setPlayerScore(playerName,score,add) end

--- Changes the room's current synchronizer (or resets it).
--- Module team only.
--- @param playerName string the player who should become the room sync (use nil to let the server decide) (default nil)
function tfm.exec.setPlayerSync(playerName) end

--- Sets the max number of players in a room.
--- @param maxPlayers integer the maximum number of players the room can hold
function tfm.exec.setRoomMaxPlayers(maxPlayers) end

--- Password-protects a room.
--- @param password string the string to set as the password (an empty string removes the protection)
function tfm.exec.setRoomPassword(password) end

--- Makes a player a shaman.
--- @param playerName string the player who should become a shaman
--- @param makeAShaman boolean whether the player should be a shaman (default true)
function tfm.exec.setShaman(playerName,makeAShaman) end

--- Changes the shaman mode of a player.
--- @param playerName string the player's nickname who will have another shaman mode
--- @param mode integer the new shaman mode of the target (use nil to use the player's real mode) (default nil)
function tfm.exec.setShamanMode(playerName,mode) end

--- Makes a player a vampire.
--- @param playerName string the player to make a vampire
--- @param makeAVampire boolean whether the player should be a vampire (default true)
function tfm.exec.setVampirePlayer(playerName,makeAVampire) end

--- Changes the world acceleration along the horizontal (wind) and vertical (gravity) axes.
--- @param xAcceleration integer the horizontal acceleration of the world (default 0)
--- @param yAcceleration integer the vertical acceleration of the world (default 10)
function tfm.exec.setWorldGravity(xAcceleration,yAcceleration) end

--- Makes the snow fall.
--- @param duration integer the snowfall duration in seconds (default 60)
--- @param snowballPower integer  (default 10)
function tfm.exec.snow(duration,snowballPower) end

--- Displays a popup.
--- @param id integer the identifier of the popup
--- @param type integer the popup type (0 for simple, 1 for yes or no, 2 for player input)
--- @param text string the text to display
--- @param targetPlayer string the player who will see the popup (if nil, applies to all players)
--- @param x integer the horizontal coordinate of the top-left corner (default 50)
--- @param y integer the vertical coordinate of the top-left corner (default 50)
--- @param width integer the width in pixels of the popup (if 0, it will be ajusted to the text width) (default 0)
--- @param fixedPos boolean whether the position is fixed or if it should follow the player's camera on long maps (default false)
function ui.addPopup(id,type,text,targetPlayer,x,y,width,fixedPos) end

--- Displays a text area.
--- @param id integer the identifier of the text area
--- @param text string the text to display
--- @param targetPlayer string the player who will see the text area (if nil, applies to all players) (default nil)
--- @param x integer the horizontal coordinate of the top-left corner (default 50)
--- @param y integer the vertical coordinate of the top-left corner (default 50)
--- @param width integer the width in pixels of the text area (if 0, it will be ajusted to the text width) (default 0)
--- @param height integer the height in pixels of the text area (if 0, it will be ajusted to the text height) (default 0)
--- @param backgroundColor integer the background color of the text area (default 0x324650)
--- @param borderColor integer the border color of the text area (default 0)
--- @param backgroundAlpha float the background's opacity, from 0 (transparent) to 1 (opaque) (default 1)
--- @param fixedPos boolean whether the position is fixed or if it should follow the player's camera on long maps (default false)
function ui.addTextArea(id,text,targetPlayer,x,y,width,height,backgroundColor,borderColor,backgroundAlpha,fixedPos) end

--- Removes a text area.
--- @param id integer the identifier of the text area
--- @param targetPlayer string the player whom the text area will disappear (if nil, applies to all players) (default nil)
function ui.removeTextArea(id,targetPlayer) end

--- Sets the map name.
--- @param text string the text to display as the map name
function ui.setMapName(text) end

--- Sets the shaman name.
--- @param text string the text to display as the shaman name
function ui.setShamanName(text) end

--- Displays a color picker.
--- @param id integer the identifier of the color picker
--- @param targetPlayer string the player who will see the color picker (if nil, applies to all players) (default nil)
--- @param defaultColor integer the default color on the color picker (default 0)
--- @param title string the title of the color picker (default nil)
function ui.showColorPicker(id,targetPlayer,defaultColor,title) end

--- Updates the content of a text area.
--- @param id integer the identifier of the text area
--- @param text string the new text to display
--- @param targetPlayer string the player who will get displayed the new text (if nil, applies to all players) (default nil)
function ui.updateTextArea(id,text,targetPlayer) end

--- Sets the map name.
--- @param text string the text to display as the map name
--- @deprecated
--- @see ui.setMapName
function tfm.exec.setUIMapName(text) end

--- Sets the shaman name. This function is **deprecated**, see `ui.setShamanName`.
--- @param text string the text to display as the shaman name
--- @deprecated
--- @see ui.setShamanName
function tfm.exec.setUIShamanName(text) end

--- Listens to the player's keyboard events. This function is **deprecated**, see `system.bindKeyboard`.
--- @param playerName string the player you want to listen keyboard events from
--- @param keyCode integer the code of the key you want to listen
---     - to accurately listen for player movement (both arrows and wasd/zqsd keys), you can use 0 (left), 1 (up), 2 (right) or 3 (down)
---     - regular AS3 keycodes can be found on http://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
--- @param down boolean whether it should listen for the press event, or the release one
--- @param activate boolean whether it should be active (default true)
--- @deprecated
--- @see system.bindKeyboard
function tfm.exec.bindKeyboard(playerName,keyCode,down,activate) end

--- @class osdatetfm
--- four digits
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.year"])
--- @field year integer
--- 1-12
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.month"])
--- @field month integer
--- 1-31
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.day"])
--- @field day integer
--- 0-23
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.hour"])
--- @field hour integer
--- 0-59
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.min"])
--- @field min integer
--- 0-61
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.sec"])
--- @field sec integer
--- weekday, 1–7, Sunday is 1
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.wday"])
--- @field wday integer
--- day of the year, 1–366
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.yday"])
--- @field yday integer
--- daylight saving flag, a boolean
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-osdate.isdst"])
--- @field isdst boolean

--- Returns a string or a table containing date and time, formatted according to the given string `format`.
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-os.date"])
--- @param format? string
--- @param time? integer time in milliseconds
--- @return string|osdatetfm
function os.date(format, time) end

--- Returns the difference, in milliseconds, from time `t1` to time `t2`.
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-os.difftime"])
--- @param t2 integer time in milliseconds
--- @param t1 integer time in milliseconds
--- @return integer @time in milliseconds
function os.difftime(t2, t1) end

--- Returns the current time when called without arguments, or a time representing the local date and time specified by the given table.
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-os.time"])
--- @param date? osdatetfm
--- @return integer @time in milliseconds
function os.time(date) end
