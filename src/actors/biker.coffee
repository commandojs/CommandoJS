BIKER_APPROACH = 0
BIKER_THROW    = 1
BIKER_LEAVE    = 2

Biker = Enemy.extend(
    sprite_sheet: "sprites_big"
    sprite_width: 48
    move_velocity: 2
    acc: 0.2
    KILL_SCORE: 1000

    animations:
        idle:
            Default: [2]
        drive:
            Default: [2]
        throw:
            Default: [0, 1]
            Speed: 0.2
        die:
            Default: [8]
            Speed: 0.6

    onEntityCollision: (coll_vec, entity) ->
        if entity instanceof Grenade
            @parent(coll_vec, entity)

    # ---- State machinery ----
    stateWaiting:
        onEnter: ->
            @setAnimation('idle')
            @direction = DIRECTIONS.Down
            @type = me.game.ENEMY_OBJECT

        onUpdate: ->
            if @inViewport()
                @next_state = 'stateActive.approach'

    stateActive:
        approach:
            onEnter: ->
                @setAnimation('drive')
                @setVelocity(-@move_velocity, 0)

            onUpdate: ->
                if @pos.x < (me.game.viewport.width / 2)
                    if @vel.x <= -@acc
                        @setVelocity(@vel.x + @acc, 0)
                    else
                        @setVelocity(0, 0)
                        @next_state = 'stateActive.throwing'

        throwing:
            onEnter: ->
                @setAnimation 'throw',  ->
                    pos = new me.Vector2d(@pos.x + 6, @pos.y)
                    # FIXME: harmonize constants with trooper
                    grenade = new Grenade(this, 2.0, 40, GRENADE_TYPE_NORMAL, pos)
                    @next_state = 'stateActive.leave'

        leave:
            onEnter: ->
                @setAnimation('drive')

            onUpdate: ->
                if @vel.x > -@move_velocity
                    @setVelocity(@vel.x - @acc, 0)
                else
                    @setVelocity(-@move_velocity, 0)
                if @pos.x < 0 # Loop for testing purposes
                    @pos.x = 280
                    @next_state = 'stateActive.approach'

    stateDying:
        onEnter: ->
            @setAnimation 'die', ->
                me.game.remove(this)
)
