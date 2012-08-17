Jumper = Trooper.extend(
    jump_start_ticks: null
    gpos: null  # Ground position

    init: (x, y, settings) ->
        @parent(x, y, settings)
        @updateColRect(6, 12, 20, 2)
        @next_state = 'stateActive.hilling'

    _move: ->
        if @state == 'stateActive.jumping'
            @gpos.add(@vel)
            @pos.x = @gpos.x
            @pos.y = @gpos.y
            @pos.y -= Math.sin(3.1459 * (@ticks - @jump_start_ticks) / 40) * 10
        else
            @parent()

    stateActive:
        hilling:
            onEnter: ->
                if @pos.x < (me.game.viewport.width / 2)
                    @direction = DIRECTIONS.Right
                else
                    @direction = DIRECTIONS.Left
                @setVelocity(@direction[0] * @move_velocity, 0)
                @setAnimation 'run'

        jumping:
            onEnter: ->
                @jump_start_ticks = @ticks
                @gpos = new me.Vector2d(@pos.x, @pos.y)
                @setAnimation 'jump',  ->
                    @setNormalCollisionBox()
                    @collidable = true
                    @z = the_hero.z
                    @next_state = 'stateActive.run'

    onMapCollision: (collision) ->
        if @state == 'stateActive.hilling'
            @collidable = false
            @next_state = 'stateActive.jumping'
        else
            @parent()
)
