AudioPlayer.setup '/audio-player/player.swf'
  width: 200

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
      #as = audiojs.createAll()

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
  
  $('.guess').live 'click', ->
    track = $('.info')
    $.post(
      '/ajax/match/'
      title: $('.input-title').val()
      id: track.data('id')
      (data) ->
        if data == 'true'
          track.css('background', 'green')
          card = $(".card[data-id=#{track.data('id')}]")
          coverLink = $('.panel-image > img').attr('src')
          card.html("<img src=\"#{coverLink}\"/>")
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
    else if $('.close-panel').length == 0
      openPanel()

  $('.open-panel').live 'click', -> openPanel()
  $('.close-panel').live 'click', -> closePanel()
