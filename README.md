This script processes a Verilog file by:

* Loading it into `emacs`.
* Expanding all AUTOS found using `verilog-mode.el` in `emacs`
* Saving the file

All in batch mode. This brings the AUTO expansion capability
of `emacs` verilog-mode to non emacs users as a command line
utility.

Note that `verilog-mode.el` is included here for convenience. 
Should be part of your emacs distribution as well.

Dependencies:

* `perl`
* `emacs` should be in the path


Even though is a simple script, it is licensed under GPL due to the
fact that its functionality is intimally related to emacs and
verilog-mode.el both licensed under GPL.
