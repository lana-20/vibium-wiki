# vibium-wiki — Project Instructions

## Before any push

Run both test suites and confirm all pass:

```sh
cd ~/vibium-wiki/tests
./run-tests.sh          # graph.html — must be 629/629
bash run-layered-tests.sh  # graph-layered.html — must be 303/303
```

Do not push if either suite has failures.
