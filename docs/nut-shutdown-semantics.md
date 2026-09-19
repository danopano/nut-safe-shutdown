# NUT shutdown semantics

NUT drivers map generic requests to device-specific command sequences. Read the
manual and source for the installed version and driver; names do not guarantee
identical firmware behavior.

## Common command intents

- `shutdown.return`: request output shutdown followed by return when utility is
  available, subject to device behavior and delay settings.
- `shutdown.stayoff`: request output shutdown without automatic return, where
  supported.
- `shutdown.reboot`: request an output cycle, where supported.
- `shutdown.default`: let the driver select its default sequence. The selected
  fallback path can differ by driver and version.

`sdcommands` can explicitly select or override the command sequence used for a
driver shutdown. This is powerful and device-specific. Confirm support with
read-only command/variable discovery and source documentation, then characterize
physical behavior with a sacrificial load.

## `-k`, wrappers, and success

The driver `-k` operation is a force-shutdown path. A wrapper such as
`upsdrvctl shutdown` ultimately invokes driver logic, but a successful wrapper
exit must not be treated as proof that UPS output changed. Upstream issue
[#3553](https://github.com/networkupstools/nut/issues/3553) reports a
source-specific failure-propagation concern in shutdown-command handling. Treat
that as an upstream-reported concern for affected source paths, not as a claim
that all NUT versions or drivers are affected; compare the exact installed
source and version.

## Delays

For `usbhid-ups`, `offdelay` is the requested delay, in seconds, between the
driver's shutdown command and UPS output removal when the device supports that
setting. `ondelay` is the requested delay, in seconds, before output is
re-enabled after the return-to-utility part of a supported shutdown sequence.
The values may be supplied in `ups.conf` or overridden for one invocation with
`-x offdelay=...` and `-x ondelay=...`; those are separate from normal
service/runtime configuration. Device firmware can quantize delays (including
coarse granularity), reject or reinterpret them, expose live values that differ
from configuration, or restart output while utility is absent. The exact
driver/device/firmware behavior must therefore be characterized physically.

The version-pinned [NUT 2.8.4 `usbhid-ups` manual](https://networkupstools.org/historic/v2.8.4/docs/man/usbhid-ups.html)
and [NUT 2.8.4 `ups.conf` manual](https://networkupstools.org/historic/v2.8.4/docs/man/ups.conf.html)
are useful when interpreting the case study. In that case study, one tested
`shutdown.return` path issued `load.on.delay 0` followed by `load.off.delay 60`.
That is an observed fact for that exact combination, not a universal
`usbhid-ups` sequence.
