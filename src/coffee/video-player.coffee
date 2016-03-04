((window, $, templates) ->
  'use strict'

  class VideoPlayer

    constructor: (@container) ->
      options = {
        itemSelector: '#clips-list .clips-list-item'
        currentItemSelector: '.clips-list-item-current'
        ready: () =>
          @onReady()
          return
        setCurrent: (item) =>
          @onSetCurrent(item)
          return
      }
      @playlist = new Playlist @container, options
      return

    onReady: () ->
      @controls = @container.find('#video-controls-video').first()
      @controls.mediaelementplayer {
        features: ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume'],
        success: (mediaElement) =>
          @onPlayerReady(mediaElement)
          return
        error: () =>
          @controls.prepend templates.videoLoadFailure
          return
      }

    onPlayerReady: (mediaElement) ->
      @player = mediaElement
      return

    onSetCurrent: (item) ->
      @updatePlayer(item)
      window.changeLocation item.data('url')
      return

    updatePlayer: (item) ->
      videoUrl = item.data('direct-url')
      [width, height] = [item.data('width'), item.data('height')]
      wasPlaying = not @player.paused
      if wasPlaying
        @player.pause()
      @player.setSrc(videoUrl)
      @player.setVideoSize(width, height)
      @player.play()
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
