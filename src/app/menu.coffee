TextMenu = Object.extend(
    font: null
    items: null
    current: null
    selected: null

    init: (items) ->
        @font = new me.BitmapFont("font8x8", 8)
        @font.set("center")
        @items = items
        @current = @items
        @first()

    draw: (context, x, y) ->
        return if not @current
        for key of @current
            continue if not @current[key]
            if @current[key].text
                text = @current[key].text
                if @items.highlight is text
                    text = "- " + text + " -"
                @font.draw(context, String(text).toUpperCase(), x, y)
                y += 14

    first: ->
        for key of @current
            @items.highlight = @current[key].text
            @selected = @current[key]
            return

    previous: ->
        return if not @current
        prev = null
        for key of @current
            continue if not @current[key]
            if @current[key].text is @items.highlight
                if prev 
                    @items.highlight = prev.text
                    @selected = prev
                    return
                else
                    @first()
                    return
            prev = @current[key]

    next: ->
        return if not @current
        prev = null
        for key of @current
            continue if not @current[key]
            if prev?.text is @items.highlight
                if @current[key].text
                    @items.highlight = @current[key].text
                    @selected = @current[key]
                    return
            prev = @current[key]

     action: ->
        @selected?.action?()
)
