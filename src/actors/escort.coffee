getEscorts = ->
    me.game.getEntityByName('escort')

Escort = Enemy.extend(
    animations:
        idle:
            Default:   [106]
        run:
            Default:   [106, 107]
        die:
            Default:   [69, 70, 113, 113]
            Speed:     0.3

    KILL_SCORE: 1000

    stateWaiting:
        onEnter: ->
            @setVelocity(0, 0)
            @setAnimation('idle')

        onUpdate: ->
            if @inViewport()
                @next_state = 'stateActive.waitApproach'

    stateActive:
        waitApproach:
            onUpdate: ->
                if the_hero.pos.y - @pos.y < config.actors.escorts.trigger_distance
                    for e in getEscorts()
                        e.next_state = 'stateActive.escort'

        escort:
            onEnter: ->
                v = config.actors.escorts.velocity
                @setVelocity(v.x, v.y)
                @setAnimation('run')

    stateDying:
        onEnter: ->
            # FIXME: the same as with trooper, remove duplication
            @setVelocity(0, 0)
            @alive = false
            @setAnimation 'die', ->
                me.game.remove(this)

    onViewportExit: (clipping) ->
        # if one of the escorts reach map border, remove both escorts and
        # prisoner from map
        for e in getEscorts()
            me.game.remove(e)
        me.game.remove(me.game.getEntityByName('prisoner')[0])
)
