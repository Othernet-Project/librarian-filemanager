((window, $, templates) ->
  'use strict'

  class MusicPlayer extends MediaPlayer
    constructor: (container) ->
      features = {
        toggleSidebarOnSelect: false
      }
      super container, features

    onReady: () =>
      @controls = @container.find('#audio-controls-audio').first()
      @controls.mediaelementplayer {
        features: ['playpause', 'progress', 'duration', 'volume'],
        success: (mediaElement) =>
          @onPlayerReady(mediaElement)
          return
        error: () =>
          @controls.prepend templates.audioLoadFailure
          return
      }
      return

  prepareAudio = () ->
    controls = $ '#audio-controls'
    if not controls.length
      return
    player = new MusicPlayer $ "#views-container"
    return

  $ prepareAudio
  window.onTabChange prepareAudio

  return
) this, this.jQuery, this.templates
