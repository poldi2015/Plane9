#!/bin/env perl

# This file contains instructions and configurations for the `latexmk` program.
# That program is somewhat like `make`, but tailored to LaTeX.
# LaTeX has a distinct characteristic of regularly requiring *multiple runs* of
# the same program (e.g. `lualatex`) before the build is finished.
# It's a *multi-pass* system.
# In the intermediary runs, latex generates auxiliary files responsible for resolving
# references, links, tables of content etc.

# `latexmk` knows about these dependencies (otherwise we tell it in this very config
# file, see below), detects these and runs latex (and other, outside programs)
# accordingly.

# Now, why do we need *both* `latexmk` and `make`?
# Both automate builds.

# `latexmk` is not powerful enough to cover all use cases.
# `make` is more general and more suitable to be integrated in CI.
# For our latex needs, `make` basically only delegates to `latexmk`.
# We **do not** call e.g. `lualatex` multiple times manually from `make`:
# this logic is left to `latexmk` and `.latexmkrc`.
# However, `make` can also do much more, e.g. cover `pandoc`, clean-up operations etc.
# Therefore, `make` and `latexmkrc` *together* are just super powerful and useful.


# The shebang at the top  is only to get syntax highlighting right across GitLab,
# GitHub and IDEs.
# This file is not meant to be run, but read by `latexmk`.

# ======================================================================================
# Perl `latexmk` configuration file
# ======================================================================================

# ======================================================================================
# PDF Generation/Building/Compilation
# ======================================================================================

# PDF-generating modes are:
# 1: pdflatex, as specified by $pdflatex variable (still largely in use)
# 2: postscript conversion, as specified by the $ps2pdf variable (useless)
# 3: dvi conversion, as specified by the $dvipdf variable (useless)
# 4: lualatex, as specified by the $lualatex variable (best)
# 5: xelatex, as specified by the $xelatex variable (second best)
$pdf_mode = 5;

# Treat undefined references and citations as well as multiply defined references as
# ERRORS instead of WARNINGS.
# This is only checked in the *last* run, since naturally, there are undefined references
# in initial runs.
# This setting is potentially annoying when debugging/editing, but highly desirable
# in the CI pipeline, where such a warning should result in a failed pipeline, since the
# final document is incomplete/corrupted.
#
# However, I could not eradicate all warnings, so that `latexmk` currently fails with
# this option enabled.
# Specifically, `microtype` fails together with `fontawesome`/`fontawesome5`, see:
# https://tex.stackexchange.com/a/547514/120853
# The fix in that answer did not help.
# Setting `verbose=silent` to mute `microtype` warnings did not work.
# Switching between `fontawesome` and `fontawesome5` did not help.
$warnings_as_errors = 0;

# Show used CPU time. Looks like: https://tex.stackexchange.com/a/312224/120853
$show_time = 1;

# Default is 5; we seem to need more owed to the complexity of the document.
# Actual documents probably don't need this many since they won't use all features,
# plus won't be compiling from cold each time.
$max_repeat=3;

# --shell-escape option (execution of code outside of latex) is required for the
#'svg' package.
# It converts raw SVG files to the PDF+PDF_TEX combo using InkScape.
#
# SyncTeX allows to jump between source (code) and output (PDF) in IDEs with support
# (many have it). A value of `1` is enabled (gzipped), `-1` is enabled but uncompressed,
# `0` is off.
# Testing in VSCode w/ LaTeX Workshop only worked for the compressed version.
# Adjust this as needed. Of course, only relevant for local use, no effect on a remote
# CI pipeline (except for slower compilation, probably).
#
# %O and %S will forward Options and the Source file, respectively, given to latexmk.
#
# `set_tex_cmds` applies to all *latex commands (latex, xelatex, lualatex, ...), so
# no need to specify these each. This allows to simply change `$pdf_mode` to get a
# different engine. Check if this works with `latexmk --commands`.
set_tex_cmds("--shell-escape --synctex=1 %O %S");

# Additional path to find .sty library
ensure_path('TEXINPUTS', './preamble', './scenes//', './appendix//', './lib//')
