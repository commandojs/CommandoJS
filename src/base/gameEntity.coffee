GameEntity = me.ObjectEntity.extend(
    ticks: 0
    sprite_sheet: "empty_pixel"
    sprite_height: 1
    sprite_width: 1
    state: null
    next_state: 'stateWaiting'
    needs_redraw: true  # TODO: implement this functionality to enable dirtyRect handling

    init: (x, y, settings) ->
        if not settings
            settings = {}
        settings.spriteheight = @sprite_height
        settings.spritewidth = @sprite_width
        settings.image = @sprite_sheet
        @parent(x, y, settings)
        @gravity = 0
        @collidable = false
        @visible = false

    update: ->
        @ticks += me.timer.tick
        ObjectStateMachine.process(this)
        @parent(this) or @needs_redraw

    inViewport: ->
        trigger_pt = new me.Vector2d(@pos.x, @pos.y + @height)
        return me.game.viewport.containsPoint(trigger_pt)


    stateWaiting: null
    stateActive: null
    stateDying: null  # TODO: think more logical name for this?
)
