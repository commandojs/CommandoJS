Place = GameEntity.extend(
    object_height: 24 # FIXME: Default height of generated sprites, as constant somewhere?
    settings: null
    _viewport_entry_ticks: 0
    _initial_delay: 0

    init: (x, y, settings) ->
        @settings = settings
        @parent(x, y, settings)
        @gravity = 0
        @collidable = false
        @visible = false
        @_initial_delay = Utils.parseNumber(settings.initial_delay, 0)

    stateWaiting:
        onUpdate: ->
            if @inViewport()
                if @_viewport_entry_ticks == 0
                    @next_state = 'stateInitialDelay'
                else
                    @next_state = 'stateActive'

    stateInitialDelay:
        onEnter: ->
            @_viewport_entry_ticks = @ticks

        onUpdate: ->
            if @ticks > (@_viewport_entry_ticks + @_initial_delay)
                @next_state = 'stateActive'

    stateActive:
        onUpdate: ->
            if not @inViewport()
                @next_state = 'stateWaiting'
)
