GRENADE_TYPE_NORMAL   = 1
GRENADE_TYPE_LAUNCHER = 2

Grenade = Ammunition.extend(
    grenade_type: null
    gpos: null  # Ground position

    animations:
        fly1:
            Default: [122, 121, 120, 121, 122]
        fly2:
            Default: [125, 124, 123, 124, 125]
        land:
            Default: [126, 127, 128]

    init: (owner, velocity, lifetime, grenade_type, position) ->
        @grenade_type = grenade_type or GRENADE_TYPE_NORMAL
        @animations['fly'] =
            if @grenade_type is GRENADE_TYPE_LAUNCHER then @animations.fly2 else @animations.fly1
        @parent(owner, velocity, lifetime, position, Z_LEVEL_FLY)
        @updateColRect(0, 24, 0, 24)
        @collidable = false  # flies over obstacles
        @name = "Grenade"
        @gpos = new me.Vector2d(@pos.x, @pos.y)
        Utils.sortEntities()

    # override move to get arc to the movement
    _move: ->
        @gpos.add(@vel)  # doesn't care about blockers
        @pos.x = @gpos.x
        @pos.y = @gpos.y
        @pos.y -= Math.sin(3.1459 * @ticks / @lifetime) * 50

    landAction: ->
        @pos = @gpos
        res = me.game.collide(this)
        if res?.obj?.onEntityCollision and @owner.type != res.obj.type
            @setVelocity(0, 0)
            res.obj.onEntityCollision(me.Vector2d(0, 0), this)

    onViewportExit: (vec) ->
        if vec.y >= 0
            me.game.remove(this)
)
