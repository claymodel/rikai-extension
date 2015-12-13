window.Rikai =
  initialize: ->
    @queryWord = ""
    @result    = ""

  sendStatus: (page) ->
    page.dispatchMessage "status", enabled: @enabled(), highlightText: safari.extension.settings.highlightText is 'on'

  enabled: ->
    safari.extension.settings.enabled is 'on'

  toggle: ->
    safari.extension.settings.enabled = if @enabled() then 'off' else 'on'
    @updateStatus()

  lookup: (word, url, page) ->
    if @enabled()
      if @queryWord isnt word
        @queryWord = word
        @result = @dict.find @queryWord, safari.extension.settings.resultsLimit
      page.dispatchMessage "showResult", word: @result.match, url: url, result: @result.results

  status: (page) -> @sendStatus page

  updateStatus: ->
    @prepareDictionary()
    for win in safari.application.browserWindows
      @sendStatus tab.page for tab in win.tabs

  prepareDictionary: ->
    if @enabled()
      @dict ||= new Dictionary
      @dict.load()
    else
      @dict?.unload()
      @dict = null

Rikai.initialize()
Rikai.prepareDictionary()

safari.application.addEventListener "command", (e) ->
  Commands[e.command]?.invoke?(e)

safari.application.addEventListener 'validate', (e) ->
  Commands[e.command]?.validate?(e)

safari.extension.settings.addEventListener "change", (e) ->
  Rikai.updateStatus()

safari.application.addEventListener "message", (e) ->
  messageData = e.message
  switch e.name
    when "lookupWord" then Rikai.lookup messageData.word, messageData.url, e.target.page
    when "queryStatus" then Rikai.status e.target.page
