#pimatic-ifttt

## Setup

### Setting up pimatic
Add the following to the `plugins` section of `config.json`:
```json
{
    "plugin": "ifttt"
}
```

Then add a device to the `devices` section:
```json
{
    "id": "ifttt-device",
    "name": "IFTTT device",
    "class": "IFTTTDevice"
}
```

To test if the API works, add the following rule
```json
{
    "id": "ifttt-test-rule",
    "name": "ifttt-test-rule",
    "rule": "if IFTTT device is triggered then log \"API is triggered\"",
    "active": true,
    "logging": true
}
```

Now restart the `pimatic.js` daemon and trigger the api:

```
http://localhost:[portnumber]/api/device/ifttt-device/trigger
```

In the pimatic message interface you'll see the log message.

### Setting up IFTTT
To have IFTTT trigger pimatic, use (this)[https://github.com/captn3m0/ifttt-webhook] guide.

## Development
To do some development, clone the git

```bash
$ cd pimatic/node_modules
$ git clone https://github.com/baswenneker/pimatic-ifttt.git
$ cd pimatic-ifttt
$ npm install
```