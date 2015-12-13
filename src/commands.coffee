window.Commands =
  toggle:
    invoke: (event) ->
      Rikai.toggle()
      event.target.validate()
    validate: (event) ->
      event.target.toolTip  = if Rikai.enabled() then "Disable Rikai" else "Enable Rikai"
      event.target.image    = safari.extension.baseURI + (if Rikai.enabled() then "IconEnabled.png" else "IconDisabled.png")
