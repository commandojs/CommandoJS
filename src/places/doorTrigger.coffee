the_doors = null

DoorTrigger = Place.extend(
    opened: false
    opened_doors: null
    closed_doors: null

    init: (x, y, settings) ->
        @parent(x, y, settings)
        the_doors = this
        @opened_doors = me.game.currentLevel.getLayerByName('Opened Doors')
        @closed_doors = me.game.currentLevel.getLayerByName('Closed Doors')
        @opened_doors.visible = @opened = false
        @closed_doors.visible = true

    reset: ->
        # melonjs needs both door layers to be visible when level shown second time
        @opened_doors.visible = true
        @closed_doors.visible = true

    stateActive:
        onEnter: ->
            @opened_doors.visible = true
            @closed_doors.visible = false
            @opened = true

        # just override out of viewport checks, remains active till the level end
        onUpdate: ->
)
