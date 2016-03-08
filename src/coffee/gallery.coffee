((window, $, templates) ->
  'use strict'

  class Gallery

    constructor: (@container, @listContainer) ->
      currentItemClass = 'gallery-list-item-current'
      options = {
        itemSelector: '#gallery-list .gallery-list-item',
        currentItemClass: currentItemClass,
        currentItemSelector: '.' + currentItemClass,
        toggleSidebarOnSelect: false,
        ready: () =>
          @onReady()
          return
        setCurrent: (current, previous) =>
          @onSetCurrent(current, previous)
      }
      @playlist = new Playlist @listContainer, options
      return

    onReady: () ->
      @currentImage = @container.find('.gallery-current-image img').first()
      @currentImageLabel = @container.find('.gallery-image-title').first()
      @container.find('#gallery-control-previous').click (e) =>
        e.preventDefault()
        e.stopPropagation()
        @previous()
        return
      @container.find('#gallery-control-next').click (e) =>
        e.preventDefault()
        e.stopPropagation()
        @next()
        return
      return

    onSetCurrent: (current, previous) ->
      title = item.data('title')
      image_url = item.data('direct-url')
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

  prepareGallery = () ->
    galleryListContainer = $ '#gallery-list-container'
    if not galleryListContainer.length
      return
    galleryContainer = $ '#gallery-container'
    gallery = new Gallery galleryContainer, galleryListContainer
    return

  $ prepareGallery
  window.onTabChange prepareGallery

  return
) this, this.jQuery
