#!/usr/bin/env bash
# Print sample family-tree queries (SWI-Prolog via Flatpak when needed).
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

if command -v swipl >/dev/null 2>&1; then
  SWIPL=(swipl)
else
  SWIPL=(flatpak run --filesystem=home --command=swipl org.swi_prolog.swipl)
fi

"${SWIPL[@]}" -q -l "$DIR/family_tree.pl" -g "
  format('?- parent(dritan, Kid).~n', []),
  forall(parent(dritan, Kid), format('Kid = ~w~n', [Kid])),
  nl,
  format('?- setof(S, sibling(blerina, S), Sibs).~n', []),
  setof(S, sibling(blerina, S), Sibs),
  format('Sibs = ~w.~n~n', [Sibs]),
  format('?- cousin(blerina, teuta).~n', []),
  (cousin(blerina, teuta) -> writeln('true.') ; writeln('false.')),
  nl,
  format('?- setof(G, grandparent(G, arta), GPs).~n', []),
  setof(G, grandparent(G, arta), GPs),
  format('GPs = ~w.~n~n', [GPs]),
  format('?- setof(C, cousin(blerina, C), Cousins).~n', []),
  setof(C, cousin(blerina, C), Cousins),
  format('Cousins = ~w.~n~n', [Cousins]),
  format('?- setof(GC, grandparent(arben, GC), Grandkids).~n', []),
  setof(GC, grandparent(arben, GC), Grandkids),
  format('Grandkids = ~w.~n~n', [Grandkids]),
  format('?- setof(D, descendant(D, arben), Down).~n', []),
  setof(D, descendant(D, arben), Down),
  format('Down = ~w.~n~n', [Down]),
  format('?- setof(A, ancestor(A, arta), Up).~n', []),
  setof(A, ancestor(A, arta), Up),
  format('Up = ~w.~n', [Up]),
  halt.
"
