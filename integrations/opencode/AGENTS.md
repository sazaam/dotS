# dotS knowledge layer

This machine runs dotS as its knowledge base (install dir: ~/.config/dots; `dots where` prints it).
dotS is ON-DEMAND — never load skills eagerly. Route knowledge questions:

- dots find <topic>                     # locate skill + block
- dots get skills/<skill>.s @block      # pull just the block you need
- dots run skills/<skill>.s @run.x      # execute a playbook
- dots tokens                           # audit dotS footprint

The routing map lives in index.s (@quickRef shortcuts, @byTask task→skill,
@index summaries). Read index.s first when routing a request.
Never echo secrets (sudo passwords, key passphrases) into conversations or files.
