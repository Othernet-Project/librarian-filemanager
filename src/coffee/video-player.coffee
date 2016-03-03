((window, $, templates) ->
  'use strict'

  class VideoPlayer

    constructor: (@container) ->
      options = {
        itemSelector: '#clips-list .clips-list-item'
        currentItemSelector: 'clips-list-item-current'
        ready: () =>
          @onReady()
          return
        setCurrent: (item) =>
          @onSetCurrent(item)
          return
      }
      @clips = new Playlist @container, options
      return

    onReady: (func) ->
      @controls = @container.find('#video-controls-video').first()
      @controls.mediaelementplayer {
        features: ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume'],
        success: func
        error: () =>
          @controls.prepend templates.videoLoadFailure
      }

    onSetCurrent: (item) ->
      @updatePlayer(item)
      window.updateLocation item.data('url')
      return

    updatePlayer: (item) ->
      audio_url = item.data('direct-url')
      [width, height] = [item.data('width'), item.data('height')]
      wasPlaying = not @controls.paused
      if wasPlaying
        @controls.pause()
      @controls.setSrc(audio_url)
      @controls.setVideoSize(width, height)
      if wasPlaying
        @controls.play()
      return

  prepareVideo = () ->
    container = $ '#clips-container'
    if container.length
      player = new VideoPlayer container
    return

  $ prepareVideo
  window.onTabChange prepareVideo

  return
) this, this.jQuery, this.templates
