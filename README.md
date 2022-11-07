## mix jet_cli.*

Provides `jet_cli` installer as an archive.

To install from Hex, run:

    $ mix archive.install hex jet_cli

To build and install it locally,
ensure any previous archive versions are removed:

    $ mix archive.uninstall jet_cli

Then run:

    $ MIX_ENV=prod mix do archive.build, archive.install
