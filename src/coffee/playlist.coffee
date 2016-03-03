((window, $) ->
  'use strict'

  class MusicPlayer
    currentItemClass = 'playlist-list-item-current'

    constructor: (@container) ->
      @audioList = @container.find('#playlist-list .playlist-list-item')
      @currentIndex = 0
      for item, index in @audioList
        if $(item).hasClass currentItemClass
          @currentIndex = index
          break
      @controls = @container.find('#audio-controls-audio').first()
      @controls.mediaelementplayer {
        'features': ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume'],
        'success': (mediaElement, domElement) =>
          @player = mediaElement
          @updateAudio(@currentIndex)
          return
      }
      @audioList.on 'click', 'a', (e) =>
        @onClick(e)
        return

    updateAudio: (newIndex) ->
      @currentIndex = newIndex
      item = @audioList.eq(@currentIndex)
      @updatePlaylistState(item)
      @updatePlayer(item)
      return

    updatePlaylistState: (item) ->
      item.addClass(currentItemClass).siblings().removeClass(currentItemClass)
      return

    updatePlayer: (item) ->
      audio_url = item.data('direct-url')
      wasPlaying = not @player.paused
      if wasPlaying
        @player.pause()
      @player.setSrc(audio_url)
      if wasPlaying
        @player.play()
      return

    updateLocation: () ->
      item = $(@audioList.get @currentIndex)
      url = item.data('url')
      window.history.pushState null, null, url
      return

    moveTo: (index) ->
      if index < 0 or index >= @audioList.length
        return
      @updateAudio(index)
      @updateLocation()
      return

    next: () ->
      index = (@currentIndex + 1) % @audioList.length
      @moveTo(index)

    previous: () ->
      index = (@audioList.length + @currentIndex - 1) % @audioList.length
      @moveTo(index)

    onClick: (e) ->
      e.preventDefault()
      e.stopPropagation()
      item = $(e.target).closest('.playlist-list-item')
      @moveTo(@audioList.index item)
      return false


  prepareAudio = () ->
    container = $ '#playlist-container'
    if container.length
      player = new MusicPlayer container
      return

  $ prepareAudio
  window.onTabChange prepareAudio

  return

) this, this.jQuery
