# Assignment 8 — Building a Family Tree in Prolog

Four-generation kinship network in **SWI-Prolog**, with `parent/2`, `male/1`,
and `female/1` facts plus rules for child, grandparent, sibling, cousin,
ancestor, and descendant.

## Tree

```
arben -- lule
   |         \
dritan+ana   elira+genti
 /     \       /      \
blerina agim teuta  besnik+mira
 +ilir                     |
 /   \                    rina
arta endrit
```

## Files

| File | Description |
|------|-------------|
| `family_tree.pl` | Facts and relationship rules |
| `sample_queries.pl` | Documented sample queries |
| `run_queries.sh` | Prints query results non-interactively |

## Run

```bash
swipl -l family_tree.pl
# or
./run_queries.sh
```
