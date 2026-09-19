# NUT Safe Shutdown

## Preface from the human

I had bought a CyberPower CP1500PFCLCD UPS to act as battery backup for my server and NAS with the intent of connecting the UPS to one system or the other and orchestrate safe shutdown of both systems.
I figured this was not new ground, and I tasked AI (Codex + ChatGPT) with the busywork of setting that up.
However, this quickly turned into a painful, tortuous process, involving many failed attempts and hard shutdowns, betrayed by overconfident AI decision-making.
AT LAST, after maybe a dozen hours, we did get it to work as desired: UPS detects mains power off, server hears this over USB, server tells NAS to shut down, server itself shuts down, UPS stops providing power.
And so, in hopes that someone else may be spared my headaches, I offer this repo of our findings.
Yes, the content is AI generated. But it is tested. I would suggest you have your AI of choice digest this material, and then test on your setup BEFORE connecting your systems to the UPS's outputs.

## Technical overview

This repository is a safety-oriented guide to configuring and validating
[Network UPS Tools (NUT)](https://networkupstools.org/) shutdown behavior.
Its central claim is simple:

> A plausible configuration, a successful command exit, and safe physical UPS
> behavior are three different kinds of evidence.

UPS shutdown behavior depends on the operating system, init system, NUT version
and build, driver, UPS firmware, USB state, and the exact command selected by the
driver. Do not begin validation by pulling utility from a real protected server.

## Evidence ladder

Treat acceptance as a ladder, not a single test:

1. Configuration and source inspection establish expected behavior.
2. Command delivery establishes that software accepted or attempted a request.
3. Sacrificial-load observation establishes physical UPS behavior.
4. An isolated production-path rehearsal establishes end-to-end coordination.
5. Protected-load lifecycle acceptance is a separate decision, not an automatic
   final ritual.

The complete twelve-step method is in
[docs/validation-ladder.md](docs/validation-ladder.md). The governing risk
model is in [docs/safety-model.md](docs/safety-model.md).

## Quick start

1. Inventory the exact OS, systemd, NUT, driver, and UPS combination. Run the
   read-only [scripts/preflight.sh](scripts/preflight.sh) and review its output
   before attaching it to a report.
2. Discover the systemd shutdown-hook directory used by the installed build.
   Audit **every executable** in it; suffixes such as `.bak` and `.distrib` do
   not disable executable hooks.
3. Verify monitoring and fresh-driver initialization without killpower.
4. If supported and justified, prove a harmless HID write in the real late
   shutdown environment.
5. Characterize the intended shutdown command with a lamp or other sacrificial
   load while servers and NAS devices are independently powered. Keep any
   networking or other infrastructure required for coordination and observation
   independently powered from the UPS output under test so it cannot disappear
   prematurely; this does not mean networking should generally be excluded from
   UPS protection in normal production.
6. Rehearse the full production path with protected computers still isolated
   from UPS output. Measure physical margin and inspect the previous boot.
7. Reconnect intended loads and verify normal online monitoring and coordination.
8. Do not manufacture a protected-load outage unless a concrete unresolved
   question remains and the expected evidence justifies the residual risk.

The preflight output is privacy-reduced, not fully sanitized. It intentionally
avoids credentials, serial numbers, and UPS names where practical, but can still
reveal filesystem paths, package/device models, usernames embedded in paths,
custom hook names, and other environment-specific details. Review it before
public sharing.

## Repository map

- [Safety model](docs/safety-model.md)
- [Validation ladder](docs/validation-ladder.md)
- [systemd shutdown environment](docs/systemd-shutdown.md)
- [NUT shutdown semantics](docs/nut-shutdown-semantics.md)
- [Troubleshooting](docs/troubleshooting.md)
- [CyberPower CP1500PFCLCDa case study](docs/cyberpower-cp1500pfclcda-case-study.md)
- [Adaptable examples](examples/)

## Example warning

Files under `examples/` are teaching material, not drop-in production defaults.
Paths, UPS names, users, driver options, service behavior, and supported shutdown
commands vary. In particular, the case-study `offdelay=60`, `ondelay=0`, and
`sdcommands=shutdown.return` combination must not be generalized to other UPSes.

## References

- [NUT documentation](https://networkupstools.org/documentation.html)
- [NUT user manual](https://networkupstools.org/docs/user-manual.chunked/)
- [`usbhid-ups` manual](https://networkupstools.org/docs/man/usbhid-ups.html)
- [`ups.conf` manual](https://networkupstools.org/docs/man/ups.conf.html)
- [`upsmon` manual](https://networkupstools.org/docs/man/upsmon.html)
- [`upssched` manual](https://networkupstools.org/docs/man/upssched.html)
- [NUT source](https://github.com/networkupstools/nut)
- [`systemd-shutdown` manual](https://www.freedesktop.org/software/systemd/man/latest/systemd-shutdown.html)
- [NUT issue #3553](https://github.com/networkupstools/nut/issues/3553): an
  upstream-reported, source-specific failure-propagation concern involving
  shutdown-command handling. It is not a claim that all NUT versions or drivers
  are affected.
- [Debian Bookworm `nut-server` file list](https://packages.debian.org/bookworm/amd64/nut-server/filelist)
  (an older packaging view showing `/lib/systemd/system-shutdown/nutshutdown`).
- [current Debian Sid `nut-server` file list](https://packages.debian.org/sid/amd64/nut-server/filelist)
  (a current packaging view showing `/usr/lib/systemd/system-shutdown/nutshutdown`).
- [Ubuntu Noble `nut-server` file list](https://packages.ubuntu.com/noble/amd64/nut-server/filelist)
  (another packaging view; paths are release/package-specific).
- [Debian NUT 2.8.4+really-2 source](https://sources.debian.org/src/nut/2.8.4%2Breally-2/),
  including configurable systemd shutdown-directory build logic.
- [Debian NUT packaging patch](https://sources.debian.org/patches/nut/2.7.4-13/0009-fix-nutshutdown-install/)
  documenting an older packaging-path correction. These references demonstrate
  variation, not one universal Debian/Ubuntu path; discover the installed path.
- [NUT 2.8.4 `usbhid-ups` manual](https://networkupstools.org/historic/v2.8.4/docs/man/usbhid-ups.html)
- [NUT 2.8.4 `ups.conf` manual](https://networkupstools.org/historic/v2.8.4/docs/man/ups.conf.html)

## License

MIT. See [LICENSE](LICENSE).
