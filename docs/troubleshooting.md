# Troubleshooting

## Output changes too early

1. Audit every executable systemd-shutdown hook.
2. Look for diverted, backup, or distribution copies that remain executable.
3. Remember that parallel hooks bypass one another's sleeps.
4. Trace the exact command selected by wrappers and `sdcommands`.
5. Compare elapsed policy time, OS shutdown progression, and physical cutoff.

## Output never turns off

Separate these questions:

- Did FSD become armed?
- Did the late hook execute?
- Could a fresh driver initialize?
- Could it perform a harmless device write?
- Which shutdown command did the driver select?
- Did the selected command report failure, and did a wrapper preserve it?
- Was USB/HID responsive after prior command cycles?

Do not jump from a missing journal line to “the hook did not run.” Do not jump
from a linked libudev library to “udev shutdown removed USB access.”

## Output returns while utility is absent

Treat this as unsafe for unattended protected loads until characterized. Test
the exact UPS, firmware, driver, command, `offdelay`, and `ondelay` with a
sacrificial load. Do not assume settings proven on another model transfer.

## USB/HID errors

Capture versions and the error without publishing serial numbers. Check device
node presence, ownership, competing driver instances, kernel logs, and whether
USB re-enumeration changes behavior. An intermittent endpoint wedge is evidence
about reliability, not proof of a universal model defect.

## Reporting checklist

Include privacy-reduced preflight output, command line, elapsed timeline, physical
topology, utility state, exact observations, previous-boot shutdown evidence,
and a clear label for facts versus hypotheses.
