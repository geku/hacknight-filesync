# Demo Commands


## Change

{"command": "CHANGE", "payload": {"filepath": "test.txt", "line": "0", "change": "Hello World\n"}}
{"command": "CHANGE", "payload": {"filepath": "test.txt", "line": "1", "change": "It works"}}

## Quit

{"command": "QUIT"}


## Invalid

{"command": "ANY", "payload": "nothing"}