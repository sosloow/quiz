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


matchTitle = (track) ->
  unless data == 'false'
    card = $(".card[data-id=#{$('.info').data('id')}]")
    cardContent = card.children[0].children[0]
    cardContent.text()
  else
    $('.panel-content').css('border-color', 'red')  

$ ->

  loadCards(70)
  
  $('.guess').live 'click', ->
    track = $('.info')
    $.ajax
      type: 'post'
      url: '/ajax/match/'
      data:
        title: $('.input-title').val()
        id: track.data('id')
      success: matchTitle(data)

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
