module.exports = {
  title: "pimatic-ifttt device config schemas"
  IFTTTDevice: {
    title: "IFTTTDevice config options"
    type: "object"
    properties: {}
      host:
        description: "the ip or hostname of the fake XMLRPC Server"
        type: "string"
        default: "localhost"
      port:
        description: "the portnumber of the fake XMLRPC Server"
        type: "number"
        default: 3001

  }
}