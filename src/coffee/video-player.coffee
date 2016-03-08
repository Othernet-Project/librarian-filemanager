((window, $, templates) ->
  'use strict'

  class VideoPlayer extends MediaPlayer

    onReady: () ->
      @controls = @container.find('#video-controls-video').first()
      @controls.mediaelementplayer {
        features: ['playpause', 'progress', 'duration', 'volume', 'fullscreen'],
        success: (mediaElement) =>
          @onPlayerReady(mediaElement)
          return
        error: () =>
          @controls.prepend templates.videoLoadFailure
          return
      }

    updatePlayer: (item) ->
      super item
      @player.play()
      return

  prepareVideo = () ->
    controls = $ '#video-controls'
    if not controls.length
      return
    player = new VideoPlayer $ '#views-container'
    return

  prepareVideo()
  window.onTabChange prepareVideo

  return
) this, this.jQuery, this.templates
