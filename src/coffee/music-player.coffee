((window, $, templates) ->
  'use strict'

  class MusicPlayer

    constructor: (@container) ->
      options = {
        itemSelector: '#playlist-list .playlist-list-item'
        currentItemSelector: 'playlist-list-item-current'
        ready: () =>
          @onReady()
          return
        setCurrent: (item) =>
          @onSetCurrent(item)
          return
      }
      @playlist = new Playlist @container, options
      return

    onReady: (func) ->
      @controls = @container.find('#audio-controls-audio').first()
      @controls.mediaelementplayer {
        features: ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume'],
        success: func
        error: () =>
          @controls.prepend templates.audioLoadFailure
      }

    onSetCurrent: (item) ->
      @updatePlayer(item)
      window.updateLocation item.data('url')
      return

    updatePlayer: (item) ->
      audio_url = item.data('direct-url')
      wasPlaying = not @controls.paused
      if wasPlaying
        @controls.pause()
      @controls.setSrc(audio_url)
      if wasPlaying
        @controls.play()
      return

  prepareAudio = () ->
    container = $ '#playlist-container'
    if container.length
      player = new MusicPlayer container
    return

  $ prepareAudio
  window.onTabChange prepareAudio

  return
) this, this.jQuery, this.templates
