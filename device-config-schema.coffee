module.exports = {
  title: "pimatic-ifttt device config schemas"
  IFTTTDevice: {
    title: "IFTTTDevice config options"
    type: "object"
    properties: {}
      ###host:
        description: "the ip or hostname to ping"
        type: "string"
        default: ""
      interval:
        description: "the delay between pings"
        type: "number"
        default: 5000###
  }
}