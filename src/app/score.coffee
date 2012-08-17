ScoreObject = me.HUD_Item.extend(
    init: (x, y) ->
        @parent(x, y)
        @value = null
        @font = new me.BitmapFont("font8x8", 8)
        # Font is aligned to right by default

    addPadding: (numbers, value, min, max) ->
        value = min if min and value < min
        value = max if max and value > max
        text = value
        padding = numbers-1
        while value >= 10
            padding -= 1
            value = value / 10
        while padding > 0
            padding -= 1
            text = '0' + text
        return text

    draw: (context, x, y) ->
        if @value and @value != null
            text = "SCORE " + @addPadding(6, @value.points, 0, 999999) +
                   "    <=" + @addPadding(2, @value.grenades, 0, 99) +
                   "  MEN " + @addPadding(2, @value.lives, 0, 99) +
                   "     HI " + @addPadding(6, @value.high_score, 0, 999999)
            @font.draw(context, text, @pos.x+x, @pos.y+y)
)
