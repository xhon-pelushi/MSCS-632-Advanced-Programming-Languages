%==============================================================================
% Family Tree Program in Prolog
% MSCS-632-M30 — Assignment 8
% Student: Xhon Pelushi
%
% Basic facts (parent/2, male/1, female/1) plus derived rules for
% child, grandparent, sibling, cousin, ancestor, and descendant.
%==============================================================================

%------------------------------------------------------------------------------
% Gender facts
%------------------------------------------------------------------------------
male(george).
male(john).
male(mike).
male(tom).
male(david).
male(bob).
male(james).

female(helen).
female(lisa).
female(susan).
female(mary).
female(alice).
female(kate).
female(emma).
female(olivia).

%------------------------------------------------------------------------------
% Parent facts: parent(Parent, Child)
%
% Family structure (four generations):
%
%   george + helen
%     ├── john + lisa
%     │     ├── mary + david
%     │     │     ├── emma
%     │     │     └── james
%     │     └── tom
%     └── susan + mike
%           ├── alice
%           └── bob + kate
%                 └── olivia
%------------------------------------------------------------------------------

% Generation 1 → Generation 2
parent(george, john).
parent(helen, john).
parent(george, susan).
parent(helen, susan).

% Spouses who are parents of Generation 3
parent(john, mary).
parent(lisa, mary).
parent(john, tom).
parent(lisa, tom).

parent(susan, alice).
parent(mike, alice).
parent(susan, bob).
parent(mike, bob).

% Generation 3 → Generation 4
parent(mary, emma).
parent(david, emma).
parent(mary, james).
parent(david, james).

parent(bob, olivia).
parent(kate, olivia).

%------------------------------------------------------------------------------
% Derived relationships (rules)
%------------------------------------------------------------------------------

% child(Child, Parent) — inverse of parent/2
child(Child, Parent) :-
    parent(Parent, Child).

% grandparent(Grandparent, Grandchild)
% X is a grandparent of Y if X is a parent of some Z who is a parent of Y.
grandparent(X, Y) :-
    parent(X, Z),
    parent(Z, Y).

% sibling(X, Y) — X and Y share at least one parent and are not the same person.
sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

% cousin(X, Y) — X and Y have parents who are siblings.
cousin(X, Y) :-
    parent(P1, X),
    parent(P2, Y),
    sibling(P1, P2),
    X \= Y.

%------------------------------------------------------------------------------
% Recursive relationships
%------------------------------------------------------------------------------

% ancestor(X, Y) — X is an ancestor of Y (parent, grandparent, great-grandparent, …)
ancestor(X, Y) :-
    parent(X, Y).
ancestor(X, Y) :-
    parent(X, Z),
    ancestor(Z, Y).

% descendant(X, Y) — X is a descendant of Y (child, grandchild, …)
% Defined as the inverse of ancestor so one recursive definition serves both.
descendant(X, Y) :-
    ancestor(Y, X).
