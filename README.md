#pimatic-ifttt

`pimatic-ifttt` is a [pimatic](http://pimatic.org) plugin which allows IFTTT to trigger certain actions in pimatic. Here are a few usecases:

 * If you're in the proximity of your home turn on the lights.
 * Turn off the lights if you're leaving town.
 * Rinkle a bell when a friend posts to Facebook.
 * Etc.

With `pimatic-ifttt` you use IFTTT events to trigger your home automation!

## Setup

### Step 1: Setting up pimatic
Add the following to the `plugins` section of `config.json`:
```json
{
    "plugin": "ifttt"
}
```

Pimatic will automatically download the plugin.

Now add a device to the `devices` section :

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
http://<pimatic-ip-address>:[portnumber]/api/device/ifttt-device/trigger
```

In the pimatic message interface you'll see the log message.

### Step 2: Setting up IFTTT
To have IFTTT trigger pimatic, use (this)[https://github.com/captn3m0/ifttt-webhook] guide.

In short: you set up IFTTT to create a Wordpress blog post when an event is triggered. The post is send to a website which in turn triggers the pimatic-ifttt API. 

__For this to work the pimatic API should be publicly accessible.__ Your router should route traffic from outside your local lan to pimatic. This is a drawback although I'm not sure of the risks. I have only tested this while authentication was disabled. See the _Contribute/TODO_ section below for a solution.

### Using pimatic-ifttt
To use this plugin just add a device like explained above. Then use the `pimatic` rule editor to add actions when the device (or IFTTT event) is triggered.

## Contribute
Here's how to set up `pimatic-ifttt` for development:

```bash
$ cd <pimatic-root-directory>/node_modules
$ git clone https://github.com/baswenneker/pimatic-ifttt.git
$ cd pimatic-ifttt

# To install all dependencies, execute:
$ npm install
```

Tip: use [vagrant-pimatic-dev](https://github.com/baswenneker/vagrant-pimatic-dev) to set up a virtual pimatic development environment.

### TODO: integrate node-ifttt
At the moment the pimatic API should be publicly accessible so that a webservice is able to trigger the pimatic-ifttt plugin. This is not preferable because this allows other people to switch off your lights from the other side of the world :)

To overcome [node-ifttt](https://github.com/fcingolani/node-ifttt) should be integrated with `pimatic-ifttt`. A short intro to `node-ifttt`:

>This connect middleware exposes a fake WordPress compliant XMLRPC API, so you can use it as an endpoint for an IFTTT WordPress channel.

With `node-ifttt` integrated we don't have to expose the `pimatic` API: we only have to allow requests to the `node-ifttt` server which in turn triggers the `pimatic` API.
