#!/usr/bin/env bash
# Run the sample family-tree queries non-interactively (SWI-Prolog via Flatpak).
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
SWIPL=(flatpak run --filesystem=home --command=swipl org.swi_prolog.swipl)

"${SWIPL[@]}" -q -l "$DIR/family_tree.pl" -g "
  format('?- parent(john, Child).~n', []),
  forall(parent(john, Child), format('Child = ~w~n', [Child])),
  nl,
  format('?- setof(S, sibling(mary, S), Siblings).~n', []),
  setof(S, sibling(mary, S), Siblings),
  format('Siblings = ~w.~n~n', [Siblings]),
  format('?- cousin(mary, alice).~n', []),
  (cousin(mary, alice) -> writeln('true.') ; writeln('false.')),
  nl,
  format('?- setof(G, grandparent(G, emma), Grandparents).~n', []),
  setof(G, grandparent(G, emma), Grandparents),
  format('Grandparents = ~w.~n~n', [Grandparents]),
  format('?- setof(C, cousin(mary, C), Cousins).~n', []),
  setof(C, cousin(mary, C), Cousins),
  format('Cousins = ~w.~n~n', [Cousins]),
  format('?- setof(GC, grandparent(george, GC), Grandchildren).~n', []),
  setof(GC, grandparent(george, GC), Grandchildren),
  format('Grandchildren = ~w.~n~n', [Grandchildren]),
  format('?- setof(D, descendant(D, george), Descendants).~n', []),
  setof(D, descendant(D, george), Descendants),
  format('Descendants = ~w.~n~n', [Descendants]),
  format('?- setof(A, ancestor(A, emma), Ancestors).~n', []),
  setof(A, ancestor(A, emma), Ancestors),
  format('Ancestors = ~w.~n', [Ancestors]),
  halt.
"
