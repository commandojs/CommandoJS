Actor = AnimatedEntity.extend(
    machinegun: null

    init: (x, y, settings) ->
        @parent(x, y, settings)
        @machinegun = new MachineGun(this)

    goTo: (animation, velocity, pos_x, pos_y) ->
        @setDirection(pos_x - @pos.x, pos_y - @pos.y)
        vel = new me.Vector2d(pos_x - @pos.x, pos_y - @pos.y)
        vel.normalize()
        vel.x *= velocity
        vel.y *= velocity
        @setVelocity(vel.x, vel.y)
        @setAnimation(animation)
)
