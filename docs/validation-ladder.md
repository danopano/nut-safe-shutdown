# Validation ladder

Advance only when the previous rung is understood. Record observations,
inferences, open questions, and acceptance decisions separately.

1. **Inventory.** Record OS, kernel, systemd, NUT packages, driver, UPS model,
   configuration parameters, live variables, and supported instant commands.
   Exclude credentials and serial numbers from shared reports.
2. **Read-only monitoring.** Verify stable online status and expected telemetry.
3. **Late-hook audit.** Discover the installed system-shutdown directory and
   enumerate every executable, symlink, target, owner, mode, and package source.
4. **Fresh-driver initialization.** In an appropriately designed harmless test,
   establish whether a fresh driver can initialize in the real late environment
   without `-k` or another output-affecting command.
5. **Harmless device write.** If the exact device supports a reversible harmless
   command, use it to distinguish initialization from write capability. Validate
   the command first; a buzzer or panel action is not harmless in every setting.
6. **Sacrificial physical characterization.** Independently power servers and
   NAS devices, and independently power any networking or infrastructure needed
   to coordinate and observe the test. Put only a lamp or equivalent disposable
   load on UPS output. This is a test-isolation requirement, not a general
   production recommendation to leave networking off UPS protection. Exercise
   the exact intended shutdown command.
7. **Observe the complete power state.** Measure delay before output removal,
   behavior during continuing utility absence, and behavior after utility
   restoration. Do not restore utility too early and mistake that for stay-off
   proof.
8. **Isolated production-path rehearsal.** Run the real FSD and shutdown path
   while protected computers remain independently powered.
9. **Measure physical margin.** Observe the interval between each protected
   system reaching its accepted endpoint and UPS output removal.
10. **Inspect the previous boot.** Confirm orderly service termination,
    filesystem unmounts, storage teardown, shutdown targets, and final sync.
11. **Reconnect and verify online.** Restore the intended load topology and
    verify services, telemetry, FSD state, client connections, hook inventory,
    permissions, symlinks, and hashes under normal utility.
12. **Decide whether more risk is justified.** Do not automatically perform a
    protected-load outage. Require a concrete unresolved question and explain
    what evidence the test would add.

## Acceptance record

A useful record identifies the exact scope, for example:

- sacrificial-load behavior: PASS;
- isolated production path: PASS;
- online reconnection: PASS;
- protected-load outage lifecycle: NOT TESTED;
- commissioned on the combined evidence: YES, with stated boundaries.
