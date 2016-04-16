# Backbone.SmartView


class SmartView extends Backbone.View

  constructor: (options) ->

    Backbone.View.apply this, arguments

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


  append: (selector, view) ->
    if !(selector and view)
      view = selector
      selector = @el

    @mixinView selector, view


  renderTemplate: ->
    tpl = @template || @statsTemplate
    if tpl
      data = @serialize()
      tpl.render data
    else
      ''


  mixinView: (selector, view) ->
    $el = @_getElement selector
    $el.appendChild view.el


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


  _sliceEventName: (parts) ->
    parts.slice(1).join ' '


module.exports = SmartView