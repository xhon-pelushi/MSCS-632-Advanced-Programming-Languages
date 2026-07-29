% MSCS-632 Assignment 8 — Family relationships in Prolog
% Xhon Pelushi

% Gender
male(arben).
male(dritan).
male(genti).
male(agim).
male(ilir).
male(besnik).
male(endrit).

female(lule).
female(ana).
female(elira).
female(blerina).
female(teuta).
female(mira).
female(arta).
female(rina).

% parent(Older, Younger)
%
%   arben -- lule
%      |         \
%   dritan+ana   elira+genti
%    /     \       /      \
% blerina  agim  teuta  besnik+mira
%  +ilir                      |
%  /   \                     rina
% arta endrit

parent(arben, dritan).
parent(lule, dritan).
parent(arben, elira).
parent(lule, elira).

parent(dritan, blerina).
parent(ana, blerina).
parent(dritan, agim).
parent(ana, agim).

parent(elira, teuta).
parent(genti, teuta).
parent(elira, besnik).
parent(genti, besnik).

parent(blerina, arta).
parent(ilir, arta).
parent(blerina, endrit).
parent(ilir, endrit).

parent(besnik, rina).
parent(mira, rina).

% --- derived ---

child(Kid, Adult) :-
    parent(Adult, Kid).

grandparent(GP, GC) :-
    parent(GP, Mid),
    parent(Mid, GC).

sibling(A, B) :-
    parent(Shared, A),
    parent(Shared, B),
    A \== B.

cousin(Person, Other) :-
    parent(ParentA, Person),
    parent(ParentB, Other),
    sibling(ParentA, ParentB),
    Person \== Other.

% recursive climb of the parent chain
ancestor(Older, Younger) :-
    parent(Older, Younger).
ancestor(Older, Younger) :-
    parent(Older, Between),
    ancestor(Between, Younger).

descendant(Younger, Older) :-
    ancestor(Older, Younger).
