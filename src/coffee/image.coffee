((window, $, templates) ->
  'use strict'

  LEFT_ARROW = 37
  RIGHT_ARROW = 39
  SPACE = 32

  gallery =
    initialize: (container) ->
      @currentImage = container.find('.gallery-current-image img').first()
      @currentImageLabel = container.find('#playlist-metadata .playlist-item-title').first()
      container.find('#gallery-control-previous').click (e) =>
        e.preventDefault()
        e.stopPropagation()
        @previous()
        return
      container.find('#gallery-control-next').click (e) =>
        e.preventDefault()
        e.stopPropagation()
        @next()
        return
      currentItemClass = 'gallery-list-item-current'
      options = {
        itemSelector: '#playlist-list .gallery-list-item',
        currentItemClass: currentItemClass,
        currentItemSelector: '.' + currentItemClass,
        toggleSidebarOnSelect: false,
        setCurrent: (current, previous) =>
          @onSetCurrent(current, previous)
      }
      @playlist = new Playlist container, options
      return

    onSetCurrent: (current, previous) ->
      title = current.data('title')
      image_url = current.data('direct-url')
      @currentImage.attr {
        'src': image_url
        'title': title
        'alt': title
      }
      @currentImageLabel.html(title)
      previousUrl = previous.data('url')
      nextUrl = current.data('url')
      if previousUrl != nextUrl
        window.changeLocation nextUrl
      return

    next: () ->
      @playlist.next()
      return

    previous: () ->
      @playlist.previous()
      return


  handleKeyEvent = (e) ->
    gallery = e.data
    if e.which in [RIGHT_ARROW, SPACE]
      gallery.next()
    else if e.which is LEFT_ARROW
      gallery.previous()
    return


  prepareGallery = () ->
    galleryContainer = $ '#views-container'
    if not galleryContainer.length
      galleryContainer.off 'keydown', handleKeyEvent
      return
    gallery.initialize galleryContainer
    galleryContainer.on 'keydown', gallery, handleKeyEvent
    galleryContainer.attr 'tabindex', -1
    galleryContainer.focus()
    return

  $ prepareGallery
  window.onTabChange prepareGallery

  return
) this, this.jQuery
