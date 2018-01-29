Things
====
github.com / BrestJS / 2018-iot
github.com / _shimaore_

introduction



Node.js
Raspberry Pi
_embedded_

Raspberry Pi 3
HDMI, USB
wifi, bluetooth

Alpine Linux

alpinelinux.org/downloads/

```
alpine-rpi-3.7.0-armhf.tar.gz
```

```
echo 'enable_uart=1' > usercfg.txt
```

```
setup-alpine -e
lbu commit     # local backup
lbu commit -d  # purge overlays
reboot
```

```
apk update
apk upgrade
apk add nodejs git
```




`notes-alpine.md`



Arduino

arduino.cc

```
File
 Examples
  Firmata
   StandardFirmata
```

```
Tools
 Board
Sketch
 Upload
 ```

```
npm install firmata
```

```
var Board = require('firmata')
var board = new Board('/dev/ttyUSB0')
```

```
var Board = require('firmata')
var board = new Board('COM1')
```

```
board.on('error', (error) => … )
```

```
const LED = 13
board.on('ready', () => {
  board.digitalWrite(LED,board.HIGH)
})
```

```
const BUTTON = 2
/*** Initialize ***/
board.pinMode( BUTTON,
  board.MODES.PULLUP | board.MODES.INPUT )
/*** Handle ***/
board.digitalRead(BUTTON, (value) => {
  board.digitalWrite(LED,value)
})
```

```
/*** Initialize ***/
board.pinMode( BUTTON,
  board.MODES.PULLUP | board.MODES.INPUT )
board.reportDigitalPin(BUTTON,1)
/*** Stream ***/
var most = require('most')
var stream = most
  .fromEvent('digital-read',board)
```

```
var counter = 0
stream
.filter( ({pin}) => pin === 2 )
.filter( ({value}) => value === board.HIGH )
.forEach( () => counter ++ )
```




```
var counter = 0
stream
.filter( ({pin}) => pin === 2 )
.filter( ({value}) => value === board.HIGH )
.debounce(250)
.tap( () => counter ++ )
```


❦ Merci! ❧
==========
github.com / BrestJS / 2018-iot
github.com / _shimaore_
Credits: _Joanna Kosinska_, _Todd Quackenbush_,
_Philip Swinburn_, _Alejandro Alvarez_,
_Scott Webb_, _Kristopher Roller_, on _Unsplash_
