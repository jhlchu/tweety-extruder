Tweety Extruder
===============

A compact direct-drive extruder for the Prusa i3 Mendel RepRap 3D printer.

Description
-----------

Gain a little extra height on your Prusa i3 with this simple direct drive extruder. Requires an inverted "mini" x-carriage or you can use the Universal 24-to-30mm GT2 X-Carriage also included here.

In contrast to the "Compact Extraptor" design (in my Prusa3 fork) the Tweety is meant to be much simpler. It has no separate mounting and requires no long back-to-front screws. Instead of mounting with nuts on the screw posts, the clamp is secured with screws from the front. The SCAD is highly simplified, as well. All components are aligned with reference to the central point where the gear and bearing grab the filament.

The SCAD is set up by default for a 2engineers 50:1 geared stepper motor, MK7 filament drive gear, 3mm filament, and a 608 idler bearing. As a highly parametric SCAD it should be relatively easy to adapt for your specific motor and dimensional preferences.

Assembly
--------

Print the parts, then connect them in the following order:

* First: Insert M3 locknuts deep into the nut traps in the extruder body.
* Assemble the idler with the axle and a 608 bearing.
* Attach the idler to the body with an M3x20mm bolt or 3mm filament.
* Add idler tensioner shoulder bolts, 2x M3x30mm, with nuts
* Attach the motor to the body with 2x M3x15mm bolts
* Insert the hot-end into the extruder.
* Add a short M3 bolt to the fan mounting hinge.
* Attach the fan to the fan mount.
* Attach the hot-end clamp and fan mount with 2x M3x30mm bolts.
* Attach the assembled extruder to the x-carriage with 3x short M3 bolts.

Customizing the SCAD
--------------------

This SCAD has lots of tunable parameters. You can change the filament width, motor size, idler axle offset, mounting height, and much more. Most parameters can be altered and produce a usable object, but there may be a few that create some weird results. Experiment and let me know if you need help.

As usual, all the parts that will come into contact with the hot-end must be printed in ABS (or any heat-tolerant material).