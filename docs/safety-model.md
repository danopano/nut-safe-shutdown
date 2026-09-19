# Safety model

## Objective

Remove UPS output only after protected systems reach an accepted safe state,
keep output off while utility remains absent, and restore output predictably
when utility returns. The objective includes data integrity, not merely a clean
command transcript.

## Evidence classes

Keep these claims separate:

1. **Configuration/source expectation:** documentation and code indicate what
   should happen.
2. **Command delivery:** a process accepted, attempted, or returned from a
   command.
3. **Physical behavior:** observed output timing and return behavior on the
   exact UPS/firmware/driver combination.
4. **Complete shutdown path:** FSD, clients, operating-system shutdown, late
   hook, and UPS behavior work together with protected machines isolated.
5. **Protected-load acceptance:** an explicit operational decision supported by
   the prior evidence; it is not implied by completing any earlier rung.

An exit status of zero is not physical evidence. Conversely, absence of a late
journal line is not proof that a shutdown hook did not run; journaling may have
already stopped.

## Hazard controls

- Preserve backups and independently power protected computers during UPS
  output characterization.
- Use a visible sacrificial load, such as a simple lamp.
- Keep infrastructure required for coordination and observation—such as the
  network path to a UPS client or the console used to observe it—independently
  powered from the UPS output under test. This prevents premature loss of the
  evidence/control path during testing; it does not imply that production
  networking should generally be left unprotected.
- Keep utility restoration available and conduct physical tests attended.
- Enumerate every executable late hook before testing. A renamed executable can
  still run.
- Make terminal killpower attempts deliberate and bounded. Retrying a device
  command can create behavior different from the tested single attempt.
- Record exact versions, device identity without serial numbers, command line,
  delay variables, timestamps, and physical observations.
- Stop after unexpected behavior. Investigate before repeating.

## Destructive-test gate

Never recommend a destructive UPS test unless:

- strong evidence indicates it will be safe;
- a concrete reason or change addresses known prior failure modes; and
- non-destructive and sacrificial validation has been exhausted as far as
  practical.

A final protected-load outage is optional evidence. It is not automatically
required merely because it is traditional.
