Trooper = Enemy.extend(
    
    # ---- constants ----
    DEFAULT_VELOCITY: 1.0
    RANDOM_WAYPOINT_CHANGE_DELAY: Utils.sec2ticks(2.0)
    ATTACK_DELAY: Utils.sec2ticks(1.5)
    KILL_SCORE: 300
    DIRECTION_TRESHOLD: 10  # pixels, prevent oscillation e.g. between up/leftUp
    GRENADE_SPEED: 2.0
    GRENADE_LIFETIME: 40
    
    # ---- class specific overrides ----
    animations:
        idle:
            Up:        [45]
            RightUp:   [48]
            Right :    [51]
            RightDown: [54]
            Down :     [57]
            LeftDown:  [60]
            Left :     [63]
            LeftUp:    [66]
            Default:   [45]
        run:
            Up:        [45, 46, 47]
            RightUp:   [48, 49, 50]
            Right :    [51, 52, 53]
            RightDown: [54, 55, 56]
            Down :     [57, 58, 59]
            LeftDown:  [60, 61, 62]
            Left :     [63, 64, 65]
            LeftUp:    [66, 67, 68]
            Default:   [45]
            Speed:     0.13
        die:
            Default:   [69, 70]
            Speed:     0.2
        jump:
            RightUp:   [81, 81, 80]
            Right:     [81, 81, 80]
            RightDown: [81, 81, 80]
            LeftDown:  [82, 82, 83]
            Left:      [82, 82, 83]
            LeftUp:    [82, 82, 83]
            Speed:     0.3
        throw:
            Up:        [72, 72]
            RightUp:   [72, 72]
            Right:     [80, 80]
            RightDown: [80, 80]
            Down:      [80, 80]
            LeftDown:  [83, 83]
            Left:      [83, 83]
            LeftUp:    [73, 73]
            Default:   [80, 80]

    # ---- own attributes ----
    redirection_time: null    # previous run direction change
    attack_time: null         # previous attack time
    grenade_type: GRENADE_TYPE_NORMAL
    grenades_thrown: 0        # counts thrown grenades per attack
    grenades_per_attack: null # limits number of grenades per attack
    amount_of_grenades: null  # amount of grenades carried, will decrease when grenades are thrown
    shoot_probability: null   # between 0..1, larger value increases probability
    waypoint: null


    # ---- constructor ----
    init: (x, y, settings) ->
        @parent(x, y, settings)
        # note, collision rect must be as tall as soldier, otherwise
        # drawing might happen in wrong z-order when e.g. enemies are
        # close each others
        @setNormalCollisionBox()
        @move_velocity = @DEFAULT_VELOCITY
        @shoot_probability = Utils.parseNumber(settings?.shoot_probability, 0.66)
        @amount_of_grenades = Utils.parseNumber(settings?.amount_of_grenades, 3)
        @grenades_per_attack = Utils.parseNumber(settings?.grenades_per_attack, 1)


    # ---- utility methods ----
    setNormalCollisionBox: ->
        @updateColRect(6, 12, 2, 22)

    randomWaypoint: (bound_rect) ->
        if not bound_rect
            bound_rect = @level_viewport_rect()
            bound_rect.pos.x += 12
            bound_rect.pos.y += 12
            bound_rect.width -= 24
            bound_rect.height -= 24
        x_off = ~~(bound_rect.width * Math.random())
        y_off = ~~(bound_rect.height * Math.random())
        x = bound_rect.left + x_off
        y = bound_rect.top + y_off
        new_pt = new me.Vector2d(x, y)

    turnToHeroDirection: ->
        @setDirection(the_hero.pos.x - @pos.x, the_hero.pos.y - @pos.y)

    turnToWaypointDirection: ->
        assert(@waypoint, 'Trying to walk towards undefined waypoint')
        @setDirection(@waypoint.x - @pos.x, @waypoint.y - @pos.y)

    setDirection: (x, y) ->
        x = 0 if x < @DIRECTION_TRESHOLD and x > -@DIRECTION_TRESHOLD
        y = 0 if y < @DIRECTION_TRESHOLD and y > -@DIRECTION_TRESHOLD
        @parent(x, y)

    checkAttack: ->
        if @ticks >= @attack_time + @ATTACK_DELAY
            @attack_time = @ticks
            @next_state = 'stateActive.attack'

    waypointToVelocity: ->
        vel = new me.Vector2d(@waypoint.x - @pos.x, @waypoint.y - @pos.y)
        vel.normalize()
        vel.x *= @move_velocity
        vel.y *= @move_velocity
        vel

    waypointCollides: (vel) ->
        col = @collisionMap.checkCollision(@collisionBox, vel)
        col.x or col.y

    waypointOutsideViewport: ->
        clipping = @viewportClipping(@waypoint.x, @waypoint.y)
        clipping.x or clipping.y

    setWaypointVelocity: (vel) ->
        @turnToWaypointDirection()
        @setVelocity(vel.x, vel.y)
        @redirection_time = @ticks

    # ---- callbacks ----
    onMapExit: ->
        me.game.remove(this)

    onMapCollision: (collision) ->
        @setVelocity(0, 0)
        @next_state = 'stateActive.decideWaypoint'

    # ---- State machinery ----
    stateWaiting:
        onEnter: ->
            @setVelocity(0, 0)
            @setAnimation('idle')
            @setDirection(DIRECTIONS.Down)

        onUpdate: ->
            if @inViewport()
                @next_state = 'stateActive.idle'

    stateActive:
        onUpdate: ->
            level_monitor?.enemy_activity()
            @parent()

        idle:
            onEnter: ->
                if not @inViewport()
                    @next_state = 'stateWaiting'
                else
                    @next_state = 'stateActive.run'

        decideWaypoint:
            onEnter: ->
                @setVelocity(0, 0)  # stop to make up the mind for new direction
            onUpdate: ->
                @waypoint = @randomWaypoint()
                vel = @waypointToVelocity()
                if (not @waypointCollides(vel)) and (not @waypointOutsideViewport())
                    @setWaypointVelocity(vel)
                    @next_state = 'stateActive.idle'

        retreat:
            onEnter: ->
                @waypoint = new me.Vector2d(@pos.x, @pos.y - 50)
                vel = @waypointToVelocity()
                if not @waypointCollides(vel)
                    @setWaypointVelocity(vel)
                    @turnToHeroDirection()
                    @next_state = 'stateActive.idle'
                else
                    @next_state = 'stateActive.decideWaypoint'

        run:
            onEnter: ->
                @setAnimation("run")
                if (@vel.x == 0 and @vel.y == 0) or not @waypoint
                    @next_state = 'stateActive.decideWaypoint'

            onUpdate: ->
                @checkAttack()
                if @ticks >= @redirection_time + @RANDOM_WAYPOINT_CHANGE_DELAY
                    @next_state = 'stateActive.decideWaypoint'
                    return
                dx = Math.abs(~~@pos.x - @waypoint.x)
                dy = Math.abs(~~@pos.y - @waypoint.y)
                if dx < 10 and dy < 10
                    @next_state = 'stateActive.decideWaypoint'

        attack:
            onEnter: ->
                if @shoot_probability >= Math.random() or @amount_of_grenades < 1
                    @next_state = 'stateActive.attack.shoot'
                else
                    @next_state = 'stateActive.attack.throwGrenade'

            shoot:
                onEnter: ->
                    @turnToHeroDirection()
                    @machinegun.fire()
                    @next_state = 'stateActive.idle'

            throwGrenade:
                onEnter: ->
                    @turnToHeroDirection()
                    @setVelocity(0, 0)
                    @grenades_thrown = 0 #Keep throwing until @grenades_per_attack is reached
                    @setAnimation 'throw', ->
                        if @grenades_thrown >= @grenades_per_attack
                            @next_state = 'stateActive.idle'
                        else
                            pos = new me.Vector2d(@pos.x, @pos.y)
                            if @grenade_type is GRENADE_TYPE_LAUNCHER
                                pos.x -= 12
                                pos.y += 12
                            grenade = new Grenade(this, @GRENADE_SPEED,
                                @GRENADE_LIFETIME, @grenade_type, pos)
                            grenade.type = me.game.ENEMY_OBJECT
                            @grenades_thrown++

    stateDying:
        onEnter: ->
            @setVelocity(0, 0)
            @setAnimation 'die', ->
                me.game.remove(this)
)
