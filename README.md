# sompis-sensor-api

UDP Protobuf API for the ESP8266 based sensors

The protocol buffers [struct](lib/sensor_api/sompadata_pb.rb) is automatically generated using the tools provided by Google's [Protocol Buffers](https://developers.google.com/protocol-buffers/). The definition file will be found here or in the repository for the ESP8266 temperature sensor's source code.

The server responds to the device's message with either:

1) Go to sleep for X seconds - this can be used for example to sync the reporting times of multiple sensors, so that the WiFi hotspot does not have to be transmitting all the time. It can also be used to adjust the reporting frequency if for example the batteries die too fast.
2) Update firmware from $URL - the sensor can perform a firmware upgrade over HTTP.

Currently the server logs the reports to STDOUT and reports them to the API on the website. This requires an API key.

There's zero security on the server side, anyone could send pretty much anything they want to. TODO: investigate how to implement some super simple security mechanism that is lightweight and easy to implement also on the ESP8266 side. Most likely some kind of simple shared-key checksum/signature.

## Usage

### Docker

#### Build

```
$ docker build -t sompisapi .
```

#### Run

```
$ docker run -e REPORT_API_KEY=xyz sompisapi
```

### Ruby

Requires Ruby >= 2.5

#### Install dependencies

```
$ bundle
```

#### Run

```
$ LISTEN_UDP_PORT=8000 REPORT_API_KEY=xyz bin/server
```
