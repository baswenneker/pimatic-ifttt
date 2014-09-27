# https://github.com/fcingolani/node-ifttt

module.exports = (env) ->

  # Require the [bluebird](https://github.com/petkaantonov/bluebird) promise library.
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Matcher for autocompletion of rules
  M = env.matcher

  # Utility library [lodash](http://lodash.com).
  _ = env.require 'lodash'

  connect = env.require 'connect'
  ifttt   = env.require '../index'

  # ###IFTTTPlugin class
  class IFTTTPlugin extends env.plugins.Plugin

    # ####init()
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")
      
      # Add the predicate provider to enable the following rules:
      #   IF my-ifttt-device is triggered
      #   IF my-ifttt-device is waiting
      @framework.ruleManager.addPredicateProvider(new IFTTTTriggerPredicateProvider(@framework))

      @framework.deviceManager.registerDeviceClass("IFTTTDevice", {
        configDef: deviceConfigDef.IFTTTDevice, 
        createCallback: (config) => 
          device = new IFTTTDevice(config)
          return device
      })

      @setupNodeIFTTT()

    setupNodeIFTTT: =>
      


  # ###IFTTTDevice class
  class IFTTTDevice extends env.devices.Device
    
    _triggerState: false

    actions: 
      trigger:
        description: "triggers the switch"

    attributes:
      triggerState:
        description: "state of the trigger"
        type: "boolean"
        labels: ['triggered', 'waiting']

    # Default Device constructor
    constructor: (@config) ->
      @name = @config.name
      @id = @config.id
      super()

    # This action-method is dynamically added to the REST API. Use
    # http://<URL:PORT>/api/device/<device-id>/trigger
    trigger: ->
      @_setTriggerState(true)
      @_setTriggerState(false)

    _setTriggerState: (value) ->
      if @_triggerState is value then return
      @_triggerState = value
      @emit 'triggerState', value

    getTriggerState: -> Promise.resolve(@_triggerState)

  # ###IFTTTTriggerPredicateProvider class
  class IFTTTTriggerPredicateProvider extends env.predicates.PredicateProvider

    constructor: (@framework) ->

    parsePredicate: (input, context) ->
      
      # Get all IFTTTDevices to apply the predicate.
      iftttDevices = 
          _(@framework.deviceManager.devices).values()
            .filter((device) => device instanceof IFTTTDevice).value()

      device = null
      negated = null
      match = null
      
      # Autocomplete filter used by matcher.
      iftttFilter = (v) => v.trim() in ["triggered", "waiting"]

      M(input, context)
        .matchDevice(iftttDevices, (next, d) =>
          next.match(" is")
            .match([" triggered", " waiting"], {acFilter: iftttFilter},(m,s) =>
            
              # Already had a match with another device?
              if device? and device.id isnt d.id
                context?.addError(""""#{input.trim()}" is ambiguous.""")
                return

              device = d
              negated = (s.trim() is "waiting")
              match = m.getFullMatch()
            )
      )
      
      if match?
        assert device?
        assert negated?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          predicateHandler: new IFTTTTriggerPredicateHandler(device, negated)
        }
      else
        return null

  # ###IFTTTTriggerPredicateProvider class
  class IFTTTTriggerPredicateHandler extends env.predicates.PredicateHandler

    constructor: (@device, @negated) ->

    setup: ->
      @triggerListener = (p) => 
        @emit 'change', (if @negated then not p else p)
      
      @device.on 'triggerState', @triggerListener
      super()

    getValue: -> 
      @device.getUpdatedAttributeValue('triggerState').then(
        (p) => (if @negated then not p else p)
      )

    destroy: -> 
      @device.removeListener "triggerState", @triggerListener
      super()

    getType: -> 'state'

  # ###Finally
  # Create a instance of the plugin...
  ifttt = new IFTTTPlugin
  ifttt.IFTTTDevice = IFTTTDevice
  
  # ...and return it to the framework.
  return ifttt