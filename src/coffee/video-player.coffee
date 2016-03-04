((window, $, templates) ->
  'use strict'

  clipListRetract = templates.clipListRetract

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
        features: ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume', 'fullscreen'],
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

  toggleSidebar = (e) ->
    ($ '#clips-container').toggleClass 'wide'

  prepareVideo = () ->
    container = $ '#clips-container'
    if not container.length
      return
    clipListRetractButton = $ clipListRetract
    (container.find '.clips-list-container').prepend clipListRetractButton
    clipListRetractButton.on 'click', toggleSidebar
    player = new VideoPlayer container
    return

  prepareVideo()
  window.onTabChange prepareVideo

  return
) this, this.jQuery, this.templates
