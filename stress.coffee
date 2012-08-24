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
      'line-height': r * 2 + 'px'

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

make_card_envoy = (card) ->
  $ 'div'
  $div = $ '<div/>',
    class: 'g-entity card'
    text: [null,'A',2,3,4,5,6,7,8,9,10,'J','Q','K'][card.n]
  $div.data 'card', card
  $div.appendTo $ '#container'
  make_touch_draggable $div
  expand_on_touch_circle $div
  return $div

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

  # place enemy hands
  _.each $('.enemy-hand'), (eh, i) ->
    pad = $('#row1').width() - $(eh).width() * 6
    $(eh).css
      left: (pad / 6 + $(eh).width()) * i + pad / 7 / 2
      top: $('#row1').height() / 2 - $(eh).height() / 2

  # place client hands
  _.each $('.client-hand'), (ch, i) ->
    left_offset = 210
    $(ch).css
      left: (i % 3) * ($('#row4').width()/2 - left_offset - $(ch).width()/2) + left_offset
      top: (reduce ['#row1', '#row2', '#row3'], 0, (a, n) -> a + $(n).height()) + 150 + Math.floor(i / 3) * 220

  # make deck
  deck = reduce (_.map [[{n: n, suit: suit} for n in [1..13]] for suit in [0...4]][0], (a) -> a[0]), [], (a,b) -> a.concat b
  log "generated #{deck.length} cards"

  table_state =
    open_hand: null

  # place initial table cards
  for i in [0...4]
    $ce = $(make_card_envoy(deck[i]))
    $ce.css
      left: 120 + i * 200
      top: (reduce ['#row1'], 0, (a, n) -> a + $(n).height()) + 110

  # fill client hands
  _.each $('.client-hand'), (h) -> $(h).data('cards', [])
  log "filled empty client hands"
  for i in [4...4 + 24]
    $target_hand = $((_.filter $('.client-hand'), (ch) -> $(ch).data('cards').length < 4)[0])
    $target_hand.data('cards').push deck[i]

  # enable client hands open
  enable_client_hand = (ch) ->
    $ch = $(ch)
    table_state.open_hand = $ch
    expand_on_touch_circle $ch

    log 'B'
    $ch.bind 'touchstart', (e) ->
      log 'C'
      log "clicked hand #{[c.n for c in ($ch.data 'cards')]}"
      _.each $('.client-hand').not($ch), (el) -> $(el).unbind 'touchstart touchmove touchend'
      $ch.data 'card_envoys', _.map ($ch.data 'cards'), make_card_envoy
      center = [$ch.offset().x + $ch.width() / 2, $ch.offset().y + $ch.height() / 2]
      _.each ($ch.data 'card_envoys'), (ce, i) ->
        angle_offset = 1.2
        $(ce).css
          left: parseInt($ch.css 'left') + $ch.width() / 2 + Math.cos(-Math.PI / 2 - angle_offset + angle_offset * 2/3 * i) * 160 - $(ce).width() / 2
          top : parseInt($ch.css 'top') + $ch.height() / 2 + Math.sin(-Math.PI / 2 - angle_offset + angle_offset * 2/3 * i) * 160 - $(ce).height() / 2
      log 'D'

    log 'E'
    $ch.bind 'touchend', ->
      _.each ($ch.data 'card_envoys'), (ce) -> 
        $(ce).remove()
      $ch.data 'card_envoys', []
      table_state.open_hand = null
      _.each $('.client-hand').not($ch), enable_client_hand
      log 'F'

  _.each $('.client-hand'), enable_client_hand
