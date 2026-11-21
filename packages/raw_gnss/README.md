# raw_gnss

Local Flutter plugin used by Sprint Tracker. Streams every fix from Android's
hardware `gps` provider (`LocationManager.GPS_PROVIDER`, minTime 0) including
Doppler speed and its accuracy.

It is a real plugin (not a channel in `MainActivity`) so it is registered in
every Flutter engine, including the one the foreground tracking service
starts. The host app must hold location permission before listening.
