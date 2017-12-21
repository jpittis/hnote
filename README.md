hnote
Jake Pitis (jpittis)
version: 0.1
license: MIT

setup
-----

1. Compile with ghc.
2. Export `HNOTE_ROOT` to be the top level directory which will hold your notes.
3. Notes will be stored with the path `<HNOTE_ROOT>/<category>/<yyy-mm-dd>`.

usage
-----

`hnote <category> - create or open a note for today in the category directory`

templates
---------

If a template file by the name of `<HNOTE_ROOT>/<category>/template` is
found in one of your category directory, it's content will be used as the
initial content for newly created note.
