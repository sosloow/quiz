audiojs.events.ready ->
  as = audiojs.createAll()

loadCards = (num) ->
  $.ajax
    type: 'post'
    url: '/ajax/loadcards/'
    data: 'num=' + num
    success: (cards) ->
      $('.deck').append(cards)
    

loadTrackPanel = (id) ->
  $.ajax
    type: 'post'
    url: '/ajax/loadtrack/'
    data: 'id=' + id
    success: (trackPanel) ->
      $('.panel-content').html(trackPanel)
      as = audiojs.createAll()

closePanel = ->
  $('.panel').animate
    bottom: '-170px'
    'slow'
    -> $('.close-panel').attr('class', 'open-panel')

openPanel = ->
  $('.panel').animate
    bottom: '0'
    'slow'
    -> $('.open-panel').attr('class', 'close-panel')
            
$ ->

  loadCards(70)
  
  $('.guess').click ->
    track = $(this).parent()
    $.get(
      '/ajax/match/'
      title: track.children('.title').val()
      id: track.data('id')
      (data) ->
        if data == 'true'
          track.css('background', 'green')
        else
          track.css('background', 'red')
    )

  $('.card').live 'click', ->
    unless $(this).data('id') == $('.info').data('id')
      if $('.close-panel').length == 0
        loadTrackPanel $(this).data('id')
      else
        $('.panel').animate
          bottom: '-170px'
          'slow'
          =>
            $('.close-panel').attr('class', 'open-panel')
            loadTrackPanel $(this).data('id')
      openPanel()

  $('.open-panel').live 'click', -> openPanel()
  $('.close-panel').live 'click', -> closePanel()
