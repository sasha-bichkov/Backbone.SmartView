# Backbone.SmartView


class SmartView extends Backbone.View

  constructor: (options) ->

    Backbone.View.apply this, arguments

    @_subviews = []

    @_delegateListeners()

    autoRender = @_isAutoRender options

    if autoRender
      @render()


  render: ->
    @clear()

    tplHtml = @renderTemplate()
    @el.innerHTML = tplHtml

    if typeof @_render is 'function'
      @_render.apply this, arguments

    @undelegateEvents()
    @delegateEvents()

    this


  _render: ->
    # override the function


  clear: ->
    @el.innerHTML = ''


  add: (selector, ViewClass, options = {}) ->
    options.el = @_getElement selector
    view = new ViewClass options
    @addSubview view


  append: (selector, view) ->
    if !(selector and view)
      view = selector
      selector = @el

    @mixinView selector, view, 'appendChild'


  renderTemplate: ->
    tpl = @template || @statsTemplate
    if tpl
      data = @serialize()
      tpl.render data
    else
      ''


  mixinView: (selector, view, action) ->
    el = @_getElement selector
    el[action] view.el
    @addSubview(view);


  serialize: ->
    if @model then return @model.toJSON()
    if @collection then return collection: @collection.toJSON()
    {}


  _getElement: (selector) ->
    @el.querySelector selector


  _isAutoRender: (opt) ->
    if (opt && 'autoRender' in opt)
      opt.autoRender
    else
      true


  _delegateListeners: ->
    return if not @listen

    for key of @listen
      method = @listen[key]
      if typeof method isnt 'function'
        method = this[method]

      if typeof method isnt 'function'
        errorText = 'View#delegateListeners: ' + key + 'must be function'
        throw new Error errorText

      @delegateListener key, method


  delegateListener: (key, callback) ->
    parts = key.split ' '

    if parts[0] is 'sub'
      eventName = @_sliceEventName parts
      @subscribeEvent eventName, callback
    else if parts[0][0] is '@'
      propName = parts[0].slice(1)
      target = if propName then this[propName] else this
      eventName = @_sliceEventName parts
      @listenTo target, eventName, callback
    else
      @on key, callback, this


  dispose: ->
    if @disposed then return
    @disposed = true

    if @_subviews.length
      for i in [0..@_subviews.length]
        @_subviews[i].dispose()

    @stopListening()
    @off()

    if typeof @onDispose is 'function'
      @onDispose()

    this.el.remove()

    properties = ['el', 'options', 'model', 'collection', '_subviews', '_callbacks']

    for i in [0..properties.length]
      prop = properties[i]
      delete this[prop]


  addSubview: (view) ->
    @_subviews.push view
    view


  removeSubview: (view) ->
    while (pos = @_subviews.indexOf(view)) isnt -1
      @_subviews.splice pos, 1


  _sliceEventName: (parts) ->
    parts.slice(1).join ' '
