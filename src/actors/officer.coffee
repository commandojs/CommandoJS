OFFICER_DIRECT_MOVE_DISTANCE = 50
OFFICER_EXIT_X_POSITION = 40

Officer = Enemy.extend(
    KILL_SCORE: 2000
    move_velocity: 1.0

    animations:
        idle:
            Default:   [98]
        run:
            LeftDown:  [97, 98]
            RightDown: [99, 100]
        die:
            Default:   [112]
            Speed:     0.5

    stateWaiting:
        onEnter: ->
            @collidable = false
            @setAnimation('idle')

        onUpdate: ->
            if the_doors?.state == 'stateActive'
                @next_state = 'stateActive.outOfTheDoor'

    stateActive:
        outOfTheDoor:
            onEnter: ->
                @collidable = true
                vp_center = ~~(me.game.viewport.getRect().width / 2)
                [x, y] = [vp_center, OFFICER_DIRECT_MOVE_DISTANCE]
                @goTo('run', @move_velocity, x, y)

            onUpdate: ->
                # TODO: create callback mechanism for this (instead of polling)
                if @pos.y >= OFFICER_DIRECT_MOVE_DISTANCE
                    @next_state = 'stateActive.outOfTheScreen'

        outOfTheScreen:
            onEnter: ->
                vp = me.game.viewport.getRect()
                vp_center = ~~(vp.width / 2)
                y = vp.bottom + @height
                if the_hero.pos.x > vp_center
                    x = OFFICER_EXIT_X_POSITION
                else
                    x = vp.right - OFFICER_EXIT_X_POSITION
                @goTo('run', @move_velocity, x, y)

    stateDying:
        onEnter: ->
            @setAnimation 'die', ->
                me.game.remove(this)

    onViewportExit: ->
        me.game.remove(this)

    onMapExit: ->
        me.game.remove(this)
)
