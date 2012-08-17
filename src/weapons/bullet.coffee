Bullet = Ammunition.extend(
    falling_time: 30
    animations:
        fly:
            Default: [129]
        land:
            Default: [130, 131, 132, 130]

    init: (owner, velocity, lifetime, position, z) ->
        @parent(owner, velocity, lifetime, position, z)
        @name = "bullet"
        # y has 3 pixel offset so that it is possible to fire sideways next to a wall
        @updateColRect(11, 2, 14, 2)

    onMapCollision: (collision)->
        if @z < 100
            @setVelocity(0, 0)
            @next_state = 'stateLand'

    stateActive:
        onUpdate: ->
            if (@z >= 100) and (@owner.z < 100) and (@ticks >= @falling_time)
                @z = @owner.z
                Utils.sortEntities()
            @parent()
)
