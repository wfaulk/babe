# babe
Babe, the Blue(tooth) Ox(imeter)

There is a "Beyond Oximeter" app that seems to power all of the Bluetooth fingertip oximeters. It wants you to sign up for an account before it will let you record data, despite showing you the data without having to do that. I'd prefer to keep my medical data to myself, thanks.

This is intended to be a replacement for "Beyond Oximeter".

So far, all I have is a general proof of concept, which I'll document here:

I have an Innovo iP900BP-B. It is accessible via Bluetooth LE (henceforth "BLE"). It publishes a service with the intuitive name "6E400001-B5A3-F393-E0A9-E50E24DCCA9E", with three characteristics, FFF0, FFF1, and FFF2. If you subscribe to notifications from both FFF0 and FFF1, you will get notifications from FFF1. The data is line-oriented, and each line is either a 4-hex-digit number that seems to describe the pulse graph, or a 26-hex-digit number that encodes the four pieces of data calculated by the device and shown on the display. The pulse graph line seems to be 24Hz, and the calculated data is 1Hz.

The data can be accessed on MacOS by installing [`blew`](https://stass.github.io/blew/) and then running `blew exec "connect -n iP900BPB; sub -b fff0; sub fff1; sleep 0"`.

The pulse data seems to always be `01xx`. I don't know if the value of `xx` has any inherent meaning, but graphing it seems to recreate the on-device graph.

The calculated data is in the form `3ess00pp00rr2000000000iif0` where `ss` is SpO₂ as a percentage, `pp` is pulse rate in bpm, `rr` is respiration rate in breaths per minute, and `ii` is perfusion index as ten times the percentage. The `3e` seems to be consistent. `20000000` in the middle and the `f0` at the end seem to contain flags for error conditions (finger removed, etc.). I'm not sure if the other two `00`s (and maybe some of the `00`s before `ii`) are leading digits or not.

I'm initially going to upload an awk script that will just show the calculated data in real time. To use it: `stdbuf -oL blew exec "connect -n iP900BPB; sub -b fff0; sub fff1; sleep 0" | awk -f rtdata.awk`.
