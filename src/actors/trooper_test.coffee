module 'Trooper', {
    setup: ->
        actor_module_setup()
        @trooper = new Trooper()
}

test 'Waypoints', 5, ->
    pos = new me.Vector2d(0, 0)
    bounds = new me.Rect(pos, 100, 100)
    for i in [1..5]
        wp = @trooper.randomWaypoint(bounds)
        ok (0 < wp.x < 100) and (0 < wp.y < 100)
