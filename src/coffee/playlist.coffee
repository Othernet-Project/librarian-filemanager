((window, $) ->
  'use strict'

  class Playlist
    defaults = {
      toggleSidebarOnSelect: true
    }

    constructor: (@container, options) ->
      @options = $.extend {}, defaults, options
      @items = @container.find(@options['itemSelector'])
      @items.on 'click', 'a', (e) =>
        @_onClick(e)

      @options.ready?()

      current = @container.find(@options['currentItemSelector']).first()
      if current.length
        @currentIndex = current.index()
      else
        @currentIndex = 0
      @_setCurrent(@currentIndex)
      return

    _setCurrent: (index) ->
      previous = @items.eq @currentIndex
      @currentIndex = index
      current = @items.eq index
      current.siblings().removeClass(@options['currentItemClass'])
      current.addClass(@options['currentItemClass'])
      @options.setCurrent?(current, previous)
      return

    length: () ->
      @items.length

    moveTo: (index) ->
      if index < 0 or index >= @length()
        return
      @_setCurrent(index)
      return

    next: () ->
      index = (@currentIndex + 1) % @length()
      @moveTo(index)

    previous: () ->
      index = (@length + @currentIndex - 1) % @length()
      @moveTo(index)

    _onClick: (e) ->
      e.preventDefault()
      e.stopPropagation()
      item = $(e.target).closest(@options['itemSelector'])
      index = @items.index item
      @moveTo index
      if @options.toggleSidebarOnSelect
        ($ window).trigger 'views-sidebar-toggle'
      return

  window.Playlist = Playlist

) this, this.jQuery
