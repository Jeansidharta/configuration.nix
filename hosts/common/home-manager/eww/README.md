# EWW Config

Here are all scripts necessary for running the Eww bar, alongside the it's
configuration itself. The `config` folder contains the yuck files for
configurint eww. The `scripts` contains the scripts necessary for that
configuration to work.

## `config`

These are just the yuck and css files necessary for the bar to work. These files
are then passed to a script that replaces everything between two `@` symbols
with external variables. This allows to insert variables in the script in
compilation time. For example, `@colorPrimary@` would be replaced with the
variable called `colorPrimary`
