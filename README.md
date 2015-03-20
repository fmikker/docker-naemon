## Docker-Naemon  
Originated from [Docker Build Status](http://72.14.176.28/cpuguy83/naemon)](https://registry.hub.docker.com/u/cpuguy83/naemon)

Basic Docker image for running Naemon 1.0<br />


### Knobs ###
- NAEMONADMIN_USER=naemonadmin
- NAEMONAMDIN_PASS=naemon
- CYCLE_NOTIFICATIONS=0 (defaults to off, non-zero turns on cycle of notifications at startup)
- CYCLE_OFF_PAUSE 10 (pause before turning off notifications at startup)
- CYCLE_ON_PAUSE 300 (pause before turning notifications back on)

### Web UI ###
The Naemon Web UI is available on port 80 and 443 of the container<br />
