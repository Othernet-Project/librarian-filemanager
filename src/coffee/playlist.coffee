((window, $) ->
  'use strict'
  prepareAudio = () ->
    audio = $ '#audio-control-audio'
    if audio.length
      audio.mediaelementplayer()
      return

  $ prepareAudio
  window.mainContainer.on 'filemanager:tabchanged', (event) ->
    prepareAudio()
    return

  return

) this, this.jQuery
