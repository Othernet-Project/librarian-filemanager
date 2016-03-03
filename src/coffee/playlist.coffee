((window, $) ->
  'use strict'

  class Playlist
    expectedKeys = []

    constructor: (@container, @options) ->
      @items = @container.find(@options['itemSelector'])
      @items.on 'click', 'a', (e) =>
        @_onClick(e)
        return
      current = @items.find(@options['currentItemSelector']).first()
      currentIndex = current.index()
      @options.ready? () =>
        @_setCurrent(currentIndex)
        return

    _setCurrent: (index) ->
      @currentIndex = index
      current = @items.eq index
      current.siblings().removeClass(@options['currentItemSelector'])
      current.addClass(@options['currentItemSelector'])
      @options.setCurrent?(current)
      return

    len: () ->
      @items.length

    moveTo: (index) ->
      if index < 0 or index >= @len
        return
      setCurrent(index)
      return

    next: () ->
      index = (@currentIndex + 1) % @len
      @moveTo(index)

    previous: () ->
      index = (@len + @currentIndex - 1) % @len
      @moveTo(index)

    _onClick: (e) ->
      e.preventDefault()
      e.stopPropagation()
      item = $(e.target).closest(@options['itemSelector'])
      index = @items.index item
      @moveTo index
      return false

  window.Playlist = Playlist

) this, this.jQuery
