Ammunition = AnimatedEntity.extend(
    owner: null
    move_velocity: 1
    lifetime: 10
    next_state: 'stateActive'

    init: (owner, velocity, lifetime, position, z) ->
        @owner = owner
        @direction = owner.direction
        [x, y] = if position then [position.x, position.y] else [owner.pos.x,
                 owner.pos.y+owner.hHeight]
        @move_velocity = velocity or 4.0
        @lifetime = lifetime or 25
        @parent(x, y)
        @type = owner.type
        @z = z or owner.z
        me.game.add(this, @z)
        Utils.sortEntities()

    stateActive:
        onEnter: ->
            x = @direction[0] * @move_velocity
            y = @direction[1] * @move_velocity
            @setVelocity(x, y)
            @setAnimation('fly')

        onUpdate: ->
            @next_state = 'stateLand' if @ticks > @lifetime
            @parent()

    stateLand:
        onEnter: ->
            @setVelocity(0, 0)
            @setAnimation 'land', ->
                @landAction()
                me.game.remove(this)

    landAction: ->

    onViewportExit: (vec) ->
        me.game.remove(this)

    onMapExit: ->
        me.game.remove(this)
)
