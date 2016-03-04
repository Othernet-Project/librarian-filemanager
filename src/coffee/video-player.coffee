((window, $, templates) ->
  'use strict'

  clipListRetract = templates.clipListRetract

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
