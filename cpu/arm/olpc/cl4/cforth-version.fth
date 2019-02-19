\ This file controls which CForth source version to include in the OFW build
\ and the method for fetching it

\ If CFORTH_VERSION is "modify", the repository will be cloned with git+ssh: so can push changes.
\ You need ssh access to the server.
\ macro: CFORTH_VERSION modify

\ If CFORTH_VERSION is "clone", the repository will be cloned with git:.  You won't be able to
\ push changes, but you will get the full metadata so you can use commands like git grep.
\ You don't need ssh access to the server.
\ macro: CFORTH_VERSION clone

\ Otherwise, the source code will be will be downloaded as a tarball.
macro: CFORTH_VERSION d111f9ffe1732b706addb08a96d4cba7e26bb93a

macro: CFORTH_BUILD_DIR cforth/build/arm-xo-cl4
