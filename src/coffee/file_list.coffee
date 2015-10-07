((window, $) ->

  UP = 38
  DOWN = 40
  fileList = $ '#file-list'
  body = $ document.body

  body.on 'keydown', '.file-list-link', (e) ->
    elem = $ @
    listItem = elem.parents '.file-list-item'

    switch e.which
      when UP
        listItem.prev().find('a').focus()
        e.preventDefault()
      when DOWN
        listItem.next().find('a').focus()
        e.preventDefault()

) this, this.jQuery
