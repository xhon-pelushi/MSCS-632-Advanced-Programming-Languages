# Assignment 8 — Building a Family Tree in Prolog

A four-generation family tree in **SWI-Prolog** with facts for `parent/2`,
`male/1`, and `female/1`, plus rules for child, grandparent, sibling, cousin,
ancestor, and descendant relationships.

## Family structure

```
george + helen
  ├── john + lisa
  │     ├── mary + david
  │     │     ├── emma
  │     │     └── james
  │     └── tom
  └── susan + mike
        ├── alice
        └── bob + kate
              └── olivia
```

## Files

| File | Description |
|------|-------------|
| `family_tree.pl` | Facts and relationship rules |
| `sample_queries.pl` | Documented sample queries with expected answers |
| `run_queries.sh` | Non-interactive runner that prints query results |

## Run

Requires [SWI-Prolog](https://www.swi-prolog.org/). On this machine the Flatpak
build was used:

```bash
# Interactive
swipl -l family_tree.pl

# Or run all sample queries at once
./run_queries.sh
```

### Example queries

```prolog
?- parent(john, Child).
?- setof(S, sibling(mary, S), Siblings).
?- cousin(mary, alice).
?- setof(G, grandparent(G, emma), Grandparents).
?- setof(D, descendant(D, george), Descendants).
```
