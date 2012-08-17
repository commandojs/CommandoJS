# ---- constants ----
DIRECTIONS =
    Up:        [0, -1]
    RightUp:   [1, -1]
    Right:     [1, 0]
    RightDown: [1, 1]
    Down:      [0, 1]
    LeftDown:  [-1, 1]
    Left:      [-1, 0]
    LeftUp:    [-1, -1]
    Default:   [0, 0]   # default = unknown or not stated

MOVE_DIAGONAL_MULTIPLIER = 0.85
DEFAULT_ANIMATION_SPEED  = 0.07  # seconds
FASTEST_ANIMATION_SPEED  = 0.001 # seconds

AnimatedEntity = GameEntity.extend(
    # ---- class specific overrides ----
    sprite_sheet: "sprites_small"
    sprite_height: 24
    sprite_width: 24

    # ---- own attributes ----
    direction: DIRECTIONS.Default
    prev_pos: null
    movement: 0
    move_velocity: 1.5

    # ---- constructor ----
    init: (x, y, settings) ->
        @parent(x, y, settings)
        @setMaxVelocity(@move_velocity, @move_velocity)
        @addAnimation("disabled", [44, 44])
        @addAnimations()
        @collidable = true
        @visible = true

    # ---- utility methods ----
    # Returns full animation name based on params. Example:
    #  directedAnimationName('run', DIRECTIONS.Up) -> 'runUp'
    directedAnimationName: (anim_name, direction) ->
        if not direction
            direction = DIRECTIONS.Default
        direction_name = ""
        for name, val of DIRECTIONS
            if Utils.compareArraysShallow(direction, val)
                direction_name = name
                break
        
        anim_found = false
        first_direction_name = ""
        for a_name, a_data of @animations
            if a_name != anim_name
                continue
            for a_direction_name, a_indices of a_data
                if a_direction_name == direction_name
                    anim_found = true
                    break
                if not first_direction_name
                    first_direction_name = a_direction_name
            if anim_found
                break

        if not anim_found
            direction_name = first_direction_name
        "#{anim_name}#{direction_name}"

    addAnimations: ->
        for anim, anim_data of @animations
            speed = DEFAULT_ANIMATION_SPEED
            for name, data of anim_data
                speed = data if name == 'Speed'
            for name, data of anim_data
                if name != 'Speed'
                    anim_name = "#{anim}#{name}"
                    @addAnimation(anim_name, data)
                    @anim[anim_name].speed = speed

    # sets the current velocity based on given vector. Compensates on diagonal movement
    setVelocity: (x, y) ->
        if x and y
            x = MOVE_DIAGONAL_MULTIPLIER * x
            y = MOVE_DIAGONAL_MULTIPLIER * y
        @vel = new me.Vector2d(x, y)

    # Sets current direction (one of DIRECTIONS) based on given movement direction vector
    setDirection: (x, y) ->
        dx = if x == 0 then 0 else x / Math.abs(x)
        dy = if y == 0 then 0 else y / Math.abs(y)
        # only set direction if it differs from default
        if not Utils.compareArraysShallow([dx, dy], DIRECTIONS.Default)
            @direction = [dx, dy]

    # changes current animation. Note: setDirection calls affect the outcome
    #   of selected animation.
    setAnimation: (name, onAnimationFinished) ->
        speed = DEFAULT_ANIMATION_SPEED
        if not @disabled
            name = @directedAnimationName(name, @direction)
            speed = @anim[name].speed or DEFAULT_ANIMATION_SPEED
            if not @isCurrentAnimation(name)
                @setCurrentAnimation(name, onAnimationFinished)
        speed = FASTEST_ANIMATION_SPEED if speed < FASTEST_ANIMATION_SPEED
        @animationspeed = me.sys.fps * speed

    level_viewport_rect: ->
        vp = me.game.viewport.getRect()
        vp.height -= me.game.HUD.height
        vp

    # separate map collisions clearly from entity collisions
    onCollision: -> (coll_vec, entity) ->
        @onEntityCollision(coll_vec, entity)

    onEntityCollision: (coll_vec, entity) ->

    onMapCollision: (coll_vec) ->

    onViewportExit: (clipping) ->

    onMapExit: ->

    _check_entity_collisions: ->
        collision = me.game.collide(this)
        if collision
            @onEntityCollision(collision, collision.obj)

    _check_map_collisions: ->
        collision = @collisionMap.checkCollision(@collisionBox, @vel, 2)
        if (collision.x or collision.y)
            @onMapCollision(collision)

    _track_movement: ->
        @movement = 0
        if @prev_pos
            @prev_pos.sub(@pos)
            @prev_pos.abs()
            @movement = @prev_pos.length()
        @prev_pos = new me.Vector2d(@pos.x, @pos.y)

    viewportClipping: (next_x, next_y) ->
        vp = @level_viewport_rect()
        clipping = new me.Vector2d(0, 0)
        if next_y < vp.top
            clipping.y = next_y - vp.top
        else if next_y + @height > vp.bottom
            clipping.y = next_y + @height - vp.bottom
        if next_x < vp.left
            clipping.x = next_x - vp.left
        else if next_x + @width > vp.right
            clipping.x = next_x + @width - vp.right
        clipping

    _check_viewport_exit: (next_x, next_y) ->
        clipping = @viewportClipping(next_x, next_y)
        if clipping.x or clipping.y
            @onViewportExit(clipping)

    _check_map_exit: (next_x, next_y) ->
        if next_x < 0 or next_x > me.game.currentLevel.realwidth or
           next_y < 0 or next_y > me.game.currentLevel.realheight
            @onMapExit()

    # can be overridden in subclasses to specialize the movement
    _move: ->
        @pos.add(@vel)

    
    stateActive:
        onUpdate: ->
            # TODO: optimize, perhaps only check for moving objects?
            #       -> requires ensuring that collision handlers are in right places
            if @collidable
                @_check_entity_collisions()

            @_track_movement()
            next_x = @pos.x
            next_y = @pos.y
            if @vel.x or @vel.y
                next_x = @pos.x + @vel.x
                next_y = @pos.y + @vel.y
                @_check_map_exit(next_x, next_y)
                if @collidable
                    @_check_map_collisions()
            @_check_viewport_exit(next_x, next_y)
            if @vel.x or @vel.y
                @_move()
)
