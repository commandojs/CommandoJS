Z_LEVEL_HUD  = 999
Z_LEVEL_FLY  = 998
Z_LEVEL_JUMP = 997
PRESS_ENTER  = "HIT ENTER TO RETURN TO MENU"

player = null
level_monitor = null

class App
    hero: null

    g_resources: [
        {
            name: "game_music",
            type: "audio",
            src:  "resources/sounds/",
            channel: 1
        },
        {
            name: "death",
            type: "audio",
            src:  "resources/sounds/",
            channel: 2
        },
        {
            name: "collect",
            type: "audio",
            src:  "resources/sounds/",
            channel: 2
        },
        {
            name: "grenade_fly",
            type: "audio",
            src:  "resources/sounds/",
            channel: 2
        },
        {
            name: "life_up",
            type: "audio",
            src:  "resources/sounds/",
            channel: 2
        },
        {
            name: "victory",
            type: "audio",
            src:  "resources/sounds/",
            channel: 2
        },
        {
            name: "sprites_small",
            type: "image",
            src:  "resources/images/sprites_small.png"
        },
        {
            name: "sprites_big",
            type: "image",
            src:  "resources/images/sprites_big.png"
        },
        {
            name: "static_small",
            type: "image",
            src:  "resources/images/static_small.png"
        },
        {
            name: "static_big",
            type: "image",
            src:  "resources/images/static_big.png"
        },
        {
            name: "font8x8",
            type: "image",
            src:  "resources/images/font8x8.png"
        },
        {
            name: "empty_screen",
            type: "image",
            src:  "resources/images/empty_screen.png"
        },
        {
            name: "empty_pixel",
            type: "image",
            src:  "resources/images/empty_pixel.png"
        },
        {
            name: "title",
            type: "image",
            src:  "resources/images/title.png"
        },
        {
            name: "level1",
            type: "tmx",
            src:  config.context[config.context.active].file
        },
    ]

    entity_mapping: [
        ["hero",             Hero],
        ["respawn",          SpawnPoint],
        ["trooper",          Trooper],
        ["trooperGenerator", TrooperGenerator],
        ["jumper",           Jumper],
        ["jumperGenerator",  JumperGenerator],
        ["sniper",           Sniper],
        ["prisoner",         Prisoner],
        ["escort",           Escort],
        ["grenadier",        Grenadier],
        ["biker",            Biker],
        ["officer",          Officer],
        ["grenades",         GrenadeBox],
        ["doorTrigger",      DoorTrigger]
    ]

    key_mapping: [
        # key code, action, cancel_press
        [me.input.KEY.LEFT,  "left",          false],
        [me.input.KEY.RIGHT, "right",         false],
        [me.input.KEY.UP,    "up",            false],
        [me.input.KEY.DOWN,  "down",          false],
        [me.input.KEY.X,     "shoot",         false],
        [me.input.KEY.ENTER, "enter",         true],
        [me.input.KEY.C,     "throw",         true],
        [me.input.KEY.H,     "hitbox",        true],
        [me.input.KEY.M,     "music",         true],
        [me.input.KEY.I,     "invulnerable",  true],
        [me.input.KEY.E,     "effects",       true],
        [me.input.KEY.S,     "effects",       true],
        [me.input.KEY.ESC,   "abort",         true],
        [me.input.KEY.SPACE, "pause",         true],
    ]

    getScreenScale: ->
        INNER_GAP = 70
        [sw, sh] = [config.ac.screen.width, config.ac.screen.height]
        sratio = sw / sh
        [iw, ih] = [window.innerWidth, window.innerHeight]
        iratio = iw / ih
        if iratio < sratio then scale = (iw - INNER_GAP) / sw else scale = (ih - INNER_GAP) / sh
        scale

    onload: ->
        ObjectStateMachine.trace_enters = config.debug.statemachine.traces.enters
        ObjectStateMachine.trace_exits = config.debug.statemachine.traces.exits
        ObjectStateMachine.trace_updates = config.debug.statemachine.traces.updates
        ObjectStateMachine.traced_classes = config.debug.statemachine.traces.classes

        player = new Player()

        if not me.video.init('app', config.ac.screen.width, config.ac.screen.height,
                             true, @getScreenScale())
            alert("Sorry but your browser does not support html 5 canvas.")
        window.onresize = =>
            me.video.updateDisplaySize(@getScreenScale())

        me.audio.init("mp3,ogg")
        me.loader.onload = this.loaded.bind(this)
        me.loader.preload(@g_resources)
        me.state.change(me.state.LOADING)

    loaded: ->
        for [name, cls] in @entity_mapping
            me.entityPool.add(name, cls)
        me.state.set(me.state.PLAY, new PlayScreen())
        me.state.set(me.state.MENU, new TitleScreen())
        me.state.set(me.state.RESULT, new ResultScreen())
        me.state.set(me.state.SETTINGS, new HelpScreen())
        me.state.set(me.state.CREDITS, new CreditsScreen())
        for [code, name, cancel_press] in @key_mapping
            me.input.bindKey(code, name, cancel_press)
        me.state.transition('fade', '#000000', 300)
        me.state.change(me.state.MENU)

ControlScreen = me.ScreenObject.extend(
    _pauseable: false
    _paused: false
    _plays_music: false
    font: null

    init: ->
        @parent(true)
        @font = new me.BitmapFont("font8x8", 8)
        @font.set("left")

    pause: ->
        if @_pauseable
            @_paused = true
        player.pause() if player.music_enabled

    resume: ->
        @_paused = false
        player.play() if player.music_enabled

    onUpdateFrame: ->
        if me.input.isKeyPressed('music')
            player.musicEnabledToggle()
            console.log "Music playback: ", player.music_enabled
            if @_plays_music
                if player.music_enabled and player.music_state == player.MUSIC_STOPPED
                    player.play()
                else if player.music_state == player.MUSIC_PLAYING
                    player.stop()

        if me.input.isKeyPressed('effects')
            player.effectsEnabledToggle()
            console.log "Sound effects: ", player.effects_enabled

        if me.input.isKeyPressed('invulnerable') and the_hero
            the_hero.invulnerable = not the_hero.invulnerable
            console.log "Hero invulnerable: ", the_hero.invulnerable

        if me.input.isKeyPressed('abort')
            if not me.state.isCurrent(me.state.MENU)
                player.stop()
                @_paused = false
                me.state.change(me.state.MENU)

        if me.input.isKeyPressed('pause')
            if @_paused then @resume() else @pause()

        if @_paused
            # update screen, but skip the other stuff from melon
            me.game.draw()
            @drawPauseText()
            me.video.blitSurface()
        else
            @parent()

    drawPauseText: ->
        ctxt = me.video.getScreenFrameBuffer()
        # TODO: Fix all font placement constants with proper calculations
        @font.draw(ctxt, "PAUSED", 145, 85)
        @font.draw(ctxt, "PRESS SPACE TO RESUME", 85, 99)
)

TextScreen = ControlScreen.extend(
    background: null

    init: ->
        @parent()
        @background = me.loader.getImage("empty_screen")

    onResetEvent: ->
        me.game.HUD.visible = false if me.game.HUD
        player.stop() if player.music_enabled
        # enable key-locking
        me.input.bindKey(me.input.KEY.UP, "up", true)
        me.input.bindKey(me.input.KEY.DOWN, "down", true)

    draw: (context, x, y) ->
        context.drawImage(@background, 0, 0)
)

TitleScreen = TextScreen.extend(
    title: null
    status: ""
    menu: null
    menuitems:
        play:
            text: "Play"
            action: ->
                @status = "LOADING, PLEASE WAIT"
                the_hero.score.reset(false) if the_hero
                me.state.change(me.state.PLAY)
        options:
            text: "CONTROLS"
            action: ->
                me.state.change(me.state.SETTINGS)
        credits:
            text: "Credits"
            action: ->
                me.state.change(me.state.CREDITS)
        highlight: "Play"

    init: ->
        @parent()
        @title = me.loader.getImage("title")
        @menu = new TextMenu(@menuitems)

    onResetEvent: ->
        @parent()
        the_doors?.reset()
        @status = "PRESS ENTER TO SELECT"

    draw: (context, x, y) ->
        @parent(context, x, y)
        context.drawImage(@title, 10, 20)
        @font.draw(context, @status, 90, 155)
        @menu.draw(context, @rect.width/2, 90)

    update: ->
        if me.input.isKeyPressed('up')
            @menu.previous()
            me.game.repaint()
        if me.input.isKeyPressed('down')
            @menu.next()
            me.game.repaint()
        if me.input.isKeyPressed('enter')
            @menu.action()
)

HelpScreen = TextScreen.extend(
    music_status: ""
    effects_status: ""
    draw: (context, x, y) ->
        @parent(context, x, y)
        txt_y1 = 30
        txt_x2 = 80
        txt_x3 = 65
        h = 14
        @font.draw(context, "ARROWS     MOVE",                       txt_x2, txt_y1+(1*h))
        @font.draw(context, "X          FIRE",                       txt_x2, txt_y1+(2*h))
        @font.draw(context, "C          GRENADE",                    txt_x2, txt_y1+(3*h))
        @font.draw(context, "SPACE      PAUSE",                      txt_x2, txt_y1+(5*h))
        @font.draw(context, "ESC        ABORT",                      txt_x2, txt_y1+(6*h))
        @font.draw(context, "E          EFFECTS (#{@music_status})", txt_x2, txt_y1+(7*h))
        @font.draw(context, "M          MUSIC (#{@effects_status})", txt_x2, txt_y1+(8*h))

        @font.draw(context, PRESS_ENTER, txt_x3, 170)

    update: ->
        if me.input.isKeyPressed('enter')
            me.state.change(me.state.MENU)
        else
            @parent()
            @music_status = if player.effects_enabled then "ON" else "OFF"        
            @effects_status = if player.music_enabled then "ON" else "OFF"
)

CreditsScreen = TextScreen.extend(
    draw: (context, x, y) ->
        @parent(context, x, y)
        txt_y1 = 16
        txt_x1 = 30
        txt_x2 = 65
        h = 14
        @font.draw(context, "PROGRAMMING    K.P & J.O", txt_x1,         txt_y1+(1*h))
        @font.draw(context, "   GRAPHICS    RORY GREEN", txt_x1,        txt_y1+(2*h))
        @font.draw(context, "               CHRIS HARVEY", txt_x1,      txt_y1+(3*h))
        @font.draw(context, "               JON ION", txt_x1,           txt_y1+(4*h))
        @font.draw(context, "               K.P & J.O", txt_x1,         txt_y1+(5*h))
        @font.draw(context, "      SOUND    ROB HUBBARD", txt_x1,       txt_y1+(6*h))
        @font.draw(context, " COPYRIGHTS    CAPCOM ELITE 1985", txt_x1, txt_y1+(7*h))
        @font.draw(context, "               MELONJS 2012", txt_x1,      txt_y1+(8*h))
        @font.draw(context, "               K.P & J.O 2012", txt_x1,    txt_y1+(9*h))

        @font.draw(context, PRESS_ENTER, txt_x2, 170)

    update: ->
        if me.input.isKeyPressed('enter')
            me.state.change(me.state.MENU)
        else
            @parent()
)

ResultScreen = TextScreen.extend(
    draw: (context, x, y) ->
        @parent(context, x, y)
        txt_x = 65
        if the_hero.score.lives > 0
            txt = "          YOU WON"
        else
            txt = "   TOUGH LUCK, GAME OVER"
        @font.draw(context, txt, txt_x, 80)
        @font.draw(context, PRESS_ENTER,  txt_x, 94)

    update: ->
        if me.input.isKeyPressed('enter')
            me.state.change(me.state.MENU)
        else
            @parent()
)

PlayScreen = ControlScreen.extend(
    show_hitbox: false

    init: ->
        @parent()
        @_pauseable = true
        @_plays_music = true

    onResetEvent: ->
        if not me.game.HUD
            me.game.addHUD(0, 186, 336, 14, "#000000")
            me.game.HUD.addItem("score", new ScoreObject(336, 6))
        me.levelDirector.loadLevel("level1")
        level_monitor = new LevelMonitor(the_doors)
        me.game.HUD.visible = config.context[config.context.active].hud.visible
        player.play() if player.music_enabled
        # disable key-locking
        me.input.bindKey(me.input.KEY.UP, "up", false)
        me.input.bindKey(me.input.KEY.DOWN, "down", false)

    update: ->
        Utils.sortEntities()
        @show_hitbox = not @show_hitbox if me.input.isKeyPressed('hitbox')
        me.debug.renderHitBox = @show_hitbox
        @parent()
)

Player = Object.extend(
    effects_enabled: true
    music_enabled: true
    MUSIC_PLAYING: 0
    MUSIC_STOPPED: 1
    MUSIC_PAUSED: 2
    music_state: null

    init: ->
        @music_state = @MUSIC_STOPPED

    play: ->
        return if not @music_enabled
        if @music_state == @MUSIC_PAUSED
            me.audio.resumeTrack()
        else
            me.audio.playTrack("game_music")
        @music_state = @MUSIC_PLAYING

    stop: ->
        me.audio.stopTrack()
        @music_state = @MUSIC_STOPPED

    pause: ->
        me.audio.pauseTrack()
        @music_state = @MUSIC_PAUSED

    finale: (name) ->
        return if not @music_enabled
        @stop()
        @music_state = @MUSIC_PLAYING
        me.audio.play name, false, ->
            @music_state = @MUSIC_STOPPED

    effect: (name) ->
        me.audio.play(name) if @effects_enabled

    musicEnabledToggle: ->
        @music_enabled = not @music_enabled

    effectsEnabledToggle: ->
        @effects_enabled = not @effects_enabled
)

LevelMonitor = Object.extend(
    doors: null
    enemy_activity_ticks: null
    countdown_ticks: null

    init: (doors) -> 
        @doors = doors

    enemy_activity: ->
        @enemy_activity_ticks = @doors.ticks

    update: ->
        if @doors.opened and @doors.inViewport() and not @countdown_ticks
            @countdown_ticks = @doors.ticks
        # For when hero is respawn
        @countdown_ticks = null if not @doors.inViewport()
        # For when level is reloaded
        @countdown_ticks = null if not @doors.opened

    completed: ->
        @enemy_activity_ticks and (@enemy_activity_ticks + 120) < @doors.ticks and
        @countdown_ticks and (@countdown_ticks + 100) < @doors.ticks
)

main = ->
    app = new App
    app.onload()
