# woad.Zig - Changes <!-- omit in toc -->


## 0.1.0-alpha1 - 17th November 2026

* Portable colour policy (`colourPolicy`, `refresh`, `isTty`, `supportsColour`, `seqFor`), including `BOLD` and `BLINKING`;
* Unix automatic colour when the writer is a terminal and `TERM` is not `dumb`;
* Windows virtual-terminal gating, `WOAD_SET_CONSOLE_MODE`, and mintty recognition are not in this alpha;
* Continuous integration pins Zig **0.17.1**;


## 0.0.1 - 18th September 2026

* SGR colour and reset codes (`RESET`, `FG_*`, `BG_*`, including bright variants);


<!-- ########################### end of file ########################### -->
