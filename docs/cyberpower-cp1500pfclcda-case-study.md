# CyberPower CP1500PFCLCDa empirical case study

This is a bounded observation of one device and software combination, not a
generic CyberPower recipe.

## Test identity

- UPS: CyberPower CP1500PFCLCDa
- NUT: 2.8.4
- Driver: `usbhid-ups`
- Serial number: deliberately omitted

Version-pinned interpretation should start with the [NUT 2.8.4
`usbhid-ups` manual](https://networkupstools.org/historic/v2.8.4/docs/man/usbhid-ups.html)
and [`ups.conf` manual](https://networkupstools.org/historic/v2.8.4/docs/man/ups.conf.html),
including the documented `sdcommands` and delay options. Current upstream
documentation remains useful, but later versions or builds may differ.

Normal runtime configuration remained `offdelay=0`, `ondelay=0`, and
`pollonly`. The 60-second off delay was used only as an override for one fresh
terminal driver command:

```sh
usbhid-ups -a ups -x offdelay=60 -x ondelay=0 \
  -x sdcommands=shutdown.return -k
```

The command was deliberately attempted once, without retry. Debug output showed
`load.on.delay 0` followed by `load.off.delay 60`.

## Sacrificial-load result

With utility absent, protected computers and networking independently powered,
and only a lamp on UPS output:

- the command returned essentially immediately;
- output remained present for about 60 seconds;
- output then turned off;
- output remained off for more than three minutes while utility was absent;
- restoring utility returned output within seconds.

One earlier `shutdown.return` output cycle left the USB/HID endpoint
unresponsive until USB-cable re-enumeration. A later cycle did not. This is an
intermittent observation, not a universal CP1500PFCLCDa claim. After a successful
terminal shutdown command, post-command USB availability was not required for
the power sequence.

## Isolated production rehearsal

The server, NAS, and networking were independently wall-powered; only the lamp
depended on UPS output. Approximate elapsed observations after utility removal:

| Time | Observation |
|---:|---|
| T+2:15 | Server shutdown activity began |
| T+3:05 | NAS appeared to reach Safe Shutdown |
| T+4:05 | Server visibly powered off |
| T+5:05 | UPS/lamp output removed |
| T+8:35 | Output still off with utility absent |
| after restoration | Output returned within seconds |

This demonstrated about 60 seconds of observed physical margin between visible
server poweroff and UPS output removal. The previous-boot journal showed orderly
filesystem/storage shutdown before final `systemd-shutdown` processing.

## Critical CyberPower warning

Do **not** generalize `offdelay=60`, `ondelay=0`, or this command path to all
CyberPower UPSes. NUT documentation warns that many CyberPower devices have
60-second delay granularity and that some models with positive `offdelay` may
restart output while utility is still absent. This tested device did not exhibit
that behavior in this test. Every exact UPS/firmware/driver combination requires
sacrificial-load characterization before trust.
