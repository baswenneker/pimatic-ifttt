module.exports = (env) ->

  sinon = env.require "sinon"
  assert = env.require "assert"

  describe "ifttt", ->

    plugin = null
    config = null
    predicateProv = null

    before ->
      config = {
        "plugins": [
          {
            "plugin": "ifttt",
            "host": "localhost",
            "port": 3002
          }
        ],
        "devices": [
          {
            "id": "ifttt-device",
            "name": "IFTTT device",
            "class": "IFTTTDevice"
          }
        ]
      }
      plugin = (env.require 'pimatic-ifttt') env

    describe 'IFTTTPlugin', ->

      describe "#init()", ->
        
        it "should register the IFTTTTriggerPredicateProvider", ->
          spy = sinon.spy()

          frameworkDummy =
            ruleManager:
              addPredicateProvider: spy
            deviceManager:
              registerDeviceClass: sinon.stub()

          plugin.init(null, frameworkDummy, {})

          assert spy.called
          predicateProv = spy.getCall(0).args[0]
          assert predicateProv?

        it "should register the device class IFTTTDevice", ->
          spy = sinon.spy()

          frameworkDummy =
            ruleManager:
              addPredicateProvider: sinon.stub()
            deviceManager:
              registerDeviceClass: spy

          plugin.init(null, frameworkDummy, {})

          assert spy.called
          deviceClass = spy.getCall(0).args[0]
          assert deviceClass?
          assert "IFTTTDevice", deviceClass
          deviceConf = spy.getCall(0).args[1]
          assert deviceConf?
          assert deviceConf.createCallback?

          iftttDev = deviceConf.createCallback(config.devices[0])
          assert iftttDev?
          assert iftttDev instanceof plugin.IFTTTDevice






