Generator = Place.extend(
    amount: null
    delay: null
    _created_amount: 0
    _prev_creation_ticks: 0

    init: (x, y, settings) ->
        @parent(x, y, settings)
        @amount = Utils.parseNumber(settings.amount, 3)
        @delay = Utils.parseNumber(settings.delay, 500)

    stateActive:
        onUpdate: ->
            if ((@_created_amount < @amount) or (@amount < 0)) and
               (((@_prev_creation_ticks + @delay) <= @ticks) or (@_prev_creation_ticks == 0))
                if config.debug.generators.generate
                    @_created_amount++ if @generate()
                @_prev_creation_ticks = @ticks
            @parent()

    generate: ->
        true
)
