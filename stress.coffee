log = -> console.log.apply console, arguments
reduce = (list, memo, iterator) -> _.reduce list, iterator, memo

log 'STRESS'

make_touch_draggable = (el) ->
  $el = $(el)
  tx = 'touch-draggable-last-mouse-x'
  ty = 'touch-draggable-last-mouse-y'

  $el.bind 'touchstart', (e) ->
    e.preventDefault()
    e.stopPropagation()
    touch = e.originalEvent.targetTouches[0]

    $el.data tx, touch.clientX
    $el.data ty, touch.clientY

  $el.bind 'touchmove', (e) ->
    e.preventDefault()
    e.stopPropagation()
    touch = e.originalEvent.targetTouches[0]

    oldposx = parseInt($el.css 'left')
    oldposy = parseInt($el.css 'top')
    # log "old pos: " + [oldposx, oldposy]

    newx = oldposx + touch.clientX - $el.data(tx)
    newy = oldposy + touch.clientY - $el.data(ty)
    # log "new pos: " + [newx, newy]

    $el.css
      left: newx
      top : newy
    # log "current (post) css: " + [($el.css 'left'), ($el.css 'top')]

    $el.data tx, touch.clientX
    $el.data ty, touch.clientY


$ =>
  indicate = (color) -> $('.indicator').css background: color

  $('body').bind 'touchstart touchmove', (e) -> e.preventDefault()

  $('.table-card').bind 'touchstart', ->
    indicate '#0f0'

  $('.table-card').bind 'touchmove', ->
    indicate '#00f'

  $('.table-card').bind 'touchend', ->
    indicate '#f00'

  _.each $('.g-entity'), (el, i) ->
    $(el).css top: i * 85 + 30

  deck = reduce (_.map [[{n: n, suit: suit} for n in [1..13]] for suit in [0...4]][0], (a) -> a[0]), [], (a,b) -> a.concat b
  log "generated #{deck.length} cards"

  _.each $('.enemy-hand'), make_touch_draggable
