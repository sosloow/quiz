AudioPlayer.setup '/audio-player/player.swf'
  width: 200

loadCards = (num) ->
  $.ajax
    type: 'get'
    url: '/ajax/loadcards/'
    data: 'num=' + num
    success: (cards) ->
      $('.deck').append(cards)
      

loadTrackPanel = (id) ->
  $.ajax
    type: 'get'
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


matchTitle = ->
  track = $('.info')
  $.ajax
    type: 'post'
    url: '/ajax/match/'
    data:
      title: $('.input-title').val()
      id: track.data('id')
    dataType: 'json'
    success: (data) ->
      card = $(".card[data-id=#{$('.info').data('id')}]")
      thumb = card.children()
      if data.urls
        img = $('<img/>').attr('src', data.urls.cover_small)
        div = $('<div></div>').addClass('card-img')
        div.html(img)
        thumb.html(div)
        thumb.removeClass().addClass('thumbnail card-content')
      else
        thumb.text('?!')
      closePanel()

$ ->

  loadCards(70)
  
  $('.guess').live 'click', ->
    matchTitle()

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
