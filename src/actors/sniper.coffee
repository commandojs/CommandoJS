Sniper = Trooper.extend(
    aiming: true
    aim:
        RightDown: [78]
        Down:      [77]
        LeftDown:  [79]

    init: (x, y, settings) ->
        @animations['aim'] = @aim
        @parent(x, y, settings)
        @normal_velocity = @move_velocity

    stateActive:
        idle:
            onEnter: ->
                if @aiming
                    @next_state = 'stateActive.sniping'
                else
                    @parent()

        sniping:
            onEnter: ->
                @setVelocity(0, 0)
                @setAnimation('aim')
            onUpdate: ->
                if @aiming
                    if the_hero.pos.y - @pos.y < 50
                        @aiming = false
                        @z = the_hero.z
                        Utils.sortEntities()
                        @next_state = 'stateActive.retreat'
                    else
                        @turnToHeroDirection()
                        @checkAttack()

        attack:
            onEnter: ->
                if @aiming
                    @machinegun.fire(500)
                    @next_state = 'stateActive.idle'
                else
                    @parent()
)
