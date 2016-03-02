((window, $) ->
  'use strict'
  prepareAudio = () ->
    audio = $ '#audio-control-audio'
    if audio.length
      audio.mediaelementplayer()
      return

  $ prepareAudio
  window.onTabChange prepareAudio

  return

) this, this.jQuery
