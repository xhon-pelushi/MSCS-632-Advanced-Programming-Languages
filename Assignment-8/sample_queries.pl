%==============================================================================
% Sample Queries for family_tree.pl
% Run with:  swipl -l family_tree.pl
% Then enter the queries below at the ?- prompt.
%==============================================================================

% --- 1. Children of a person ---
% Who are the children of john?
% ?- parent(john, Child).
% Expected:
%   Child = mary ;
%   Child = tom.

% --- 2. Siblings of a person ---
% Who are the siblings of mary?
% ?- setof(S, sibling(mary, S), Siblings).
% Expected:
%   Siblings = [tom].

% --- 3. Cousin check ---
% Is alice a cousin of mary?
% ?- cousin(mary, alice).
% Expected:
%   true.

% --- 4. Grandparents ---
% Who are the grandparents of emma?
% ?- setof(G, grandparent(G, emma), Grandparents).
% Expected:
%   Grandparents = [john, lisa].

% --- 5. Cousins of a person ---
% Who are mary's cousins?
% ?- setof(C, cousin(mary, C), Cousins).
% Expected:
%   Cousins = [alice, bob].

% --- 6. Grandchildren (grandparent query inverted) ---
% Who are the grandchildren of george?
% ?- setof(GC, grandparent(george, GC), Grandchildren).
% Expected:
%   Grandchildren = [alice, bob, mary, tom].

% --- 7. Recursive descendants ---
% Who are all descendants of george?
% ?- setof(D, descendant(D, george), Descendants).
% Expected:
%   Descendants = [alice, bob, emma, james, john, mary, olivia, susan, tom].

% --- 8. Recursive ancestors ---
% Who are all ancestors of emma?
% ?- setof(A, ancestor(A, emma), Ancestors).
% Expected:
%   Ancestors = [david, george, helen, john, lisa, mary].
