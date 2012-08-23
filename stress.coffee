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

    $el.css
      left: parseInt($el.css 'left') + touch.clientX - $el.data(tx)
      top : parseInt($el.css 'top') + touch.clientY - $el.data(ty)
    # log "current (post) css: " + [($el.css 'left'), ($el.css 'top')]

    $el.data tx, touch.clientX
    $el.data ty, touch.clientY

expand_on_touch_circle = (el) ->
  rads = [50, 60]
  $el = $(el)
  set_size = (r) ->
    $el.css
      width: r * 2
      height: r * 2
      'border-top-left-radius': r
      'border-top-right-radius': r
      'border-bottom-left-radius': r
      'border-bottom-right-radius': r

  $el.bind 'touchstart', ->
    set_size(rads[1])
    $el.css
      left: parseInt($el.css('left')) + rads[0] - rads[1]
      top : parseInt($el.css('top')) + rads[0] - rads[1]
    # if $el.data 'touch-draggable-last-mouse-x' != undefined
    #   $el.data 'touch-draggable-last-mouse-x', $el.data('touch-draggable-last-mouse-x') + rads[1] - rads[0]
    #   $el.data 'touch-draggable-last-mouse-y', $el.data('touch-draggable-last-mouse-y') + rads[1] - rads[0]

  $el.bind 'touchend', ->
    set_size(rads[0])
    $el.css
      left: parseInt($el.css('left')) + rads[1] - rads[0]
      top : parseInt($el.css('top')) + rads[1] - rads[0]

$ =>
  indicate = (color) -> $('.indicator').css background: color

  # disable page scrolling
  _.each ['touchstart', 'touchmove'], (evn) -> _.each [document, document.body], (thing) -> thing.addEventListener evn, (e) -> e.preventDefault()

  $('#container').css height: $(document).height()

  $('.table-card').bind 'touchstart', ->
    indicate '#0f0'

  $('.table-card').bind 'touchmove', ->
    indicate '#00f'

  $('.table-card').bind 'touchend', ->
    indicate '#f00'

  _.each $('.enemy-hand'), (eh, i) ->
    pad = $('#row1').width() - $(eh).width() * 6
    $(eh).css
      top: $('#row1').height() / 2
      left: (pad / 7 + $(eh).width()) * i + pad / 7 / 2

  deck = reduce (_.map [[{n: n, suit: suit} for n in [1..13]] for suit in [0...4]][0], (a) -> a[0]), [], (a,b) -> a.concat b
  log "generated #{deck.length} cards"

  _.each $('.enemy-hand'), make_touch_draggable

  _.each $('.enemy-hand'), expand_on_touch_circle
