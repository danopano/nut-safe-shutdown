# systemd shutdown hooks

`systemd-shutdown` can execute programs from a configured
`system-shutdown` directory late in shutdown. Consult the documentation and the
installed systemd/NUT packaging for the actual path on the target host.

Do not universally assume `/usr/lib/systemd/system-shutdown`. Older or
distribution-specific systems may use `/lib/systemd/system-shutdown`, merged
`/usr` may make paths aliases, and builds or packages may discover/configure a
different location.

Concrete packaging references illustrate why discovery matters: the Debian
Bookworm `nut-server` file list shows `/lib/systemd/system-shutdown/nutshutdown`,
while the current Debian Sid file list shows
`/usr/lib/systemd/system-shutdown/nutshutdown`. Debian's NUT source exposes
configurable systemd shutdown-directory build logic, and an older Debian
packaging patch documents a path correction. These are package or release
examples, not a universal rule:

- [Debian Bookworm `nut-server` file list](https://packages.debian.org/bookworm/amd64/nut-server/filelist)
- [current Debian Sid `nut-server` file list](https://packages.debian.org/sid/amd64/nut-server/filelist)
- [Ubuntu Noble `nut-server` file list](https://packages.ubuntu.com/noble/amd64/nut-server/filelist)
- [Debian NUT 2.8.4+really-2 source](https://sources.debian.org/src/nut/2.8.4%2Breally-2/)
- [Debian NUT packaging path patch](https://sources.debian.org/patches/nut/2.7.4-13/0009-fix-nutshutdown-install/)

Discover the installed path and package ownership on the target; do not infer it
from these examples.

## Audit rules

- Enumerate every directory that is real or aliased on the host.
- Resolve symlinks and inspect their targets.
- Check executable permission, not filename suffix. `hook.distrib`, `hook.bak`,
  and similar names can still execute.
- Determine package ownership and diversion/alternatives state where relevant.
- Expect multiple executable hooks to run in parallel; do not assume one hook's
  sleep delays another hook.
- Check the installed systemd timeout behavior.

## Late-environment constraints

Late shutdown is not ordinary userspace. Services, networking, logging, device
managers, and filesystems may already be stopped or unavailable. A write to the
root filesystem is not a reliable proof channel merely because a script called
`sync`. Prefer a deliberately designed observable, reversible proof and preserve
the test's safety boundary.

Do not infer that libudev linkage requires the udev daemon to be running, or
that stopping a service-managed NUT driver proves the USB device node vanished.
Test each claim independently.

Preflight output is privacy-reduced, not fully sanitized. It avoids credentials,
serial numbers, and UPS names where practical, but useful diagnostics retain
full hook paths, symlink targets, package/device models, permissions, usernames
embedded in paths, and custom hook names. Review it before public sharing.
