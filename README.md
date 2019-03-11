# sompis-sensor-api

UDP Protobuf API for the ESP8266 based sensors

## Usage

### Docker

#### Build

```
$ docker build -t sompisapi .
```

#### Run

```
$ docker run -e REPORT_API_KEY=xyz -p 8000:8000/udp sompisapi
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
