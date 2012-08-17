Prisoner = Actor.extend(
    animations:
        idle:
            Default: [86]
        run:
            Default: [86, 87]
        winning:
            Default: [88, 89, 88, 89, 88, 89]
            Speed:   0.25
    
    escorts: null
    free: false

    stateWaiting:
        onEnter: ->
            @escorts = getEscorts()
            @setAnimation('idle')

        onUpdate: ->
            for escort in @escorts
                if escort.state == 'stateActive.escort'
                    v = config.actors.escorts.velocity
                    @setVelocity(v.x, v.y)
                    @next_state = 'stateActive.follow'
                    break

    stateActive:
        follow:
            onEnter: ->
                @setAnimation('run')

            onUpdate: ->
                @free = true
                for escort in @escorts
                    if escort.alive
                        @free = false
                        break
                if @free
                    @next_state = 'stateActive.winning'

        winning:
            onEnter: ->
                @setVelocity(0, 0)
                @setAnimation 'winning', ->
                    me.game.remove(this)
)
