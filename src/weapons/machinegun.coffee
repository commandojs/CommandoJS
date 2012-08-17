MachineGun = Object.extend(
    owner: null
    fire_delay: 60
    ammo_velocity: 2.0
    ammo_lifetime: 55
    last_fire: 0

    init: (owner) ->
        @owner = owner

    fire: (z) ->
        if @owner != null
            dt = @owner.ticks - @last_fire
            if dt > @fire_delay
                new Bullet(@owner, @ammo_velocity, @ammo_lifetime, @pos, z)
                @last_fire = @owner.ticks
)
