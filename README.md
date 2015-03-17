## Docker-Nagios  [![Docker Build Status](http://72.14.176.28/cpuguy83/nagios)](https://registry.hub.docker.com/u/cpuguy83/nagios)

Basic Docker image for running Nagios.<br />
This is running Nagios 3.5.1

You should either link a mail container in as "mail" or set MAIL_SERVER, otherwise
mail will not work.

### Knobs ###
- NAGIOSADMIN_USER=nagiosadmin
- NAGIOSAMDIN_PASS=nagios
- CYCLE_NOTIFICATIONS=0 (defaults to off, non-zero turns on cycle of notifications at startup)
- CYCLE_OFF_PAUSE 10 (pause before turning off notifications at startup)
- CYCLE_ON_PAUSE 300 (pause before turning notifications back on)

### Web UI ###
The Nagios Web UI is available on port 80 of the container<br />
