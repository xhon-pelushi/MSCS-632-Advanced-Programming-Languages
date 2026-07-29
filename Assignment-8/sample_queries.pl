% Sample queries for family_tree.pl (SWI-Prolog)
% Load with: swipl -l family_tree.pl

% Children of dritan
% ?- parent(dritan, Kid).
% Kid = blerina ; Kid = agim.

% Siblings of blerina
% ?- setof(S, sibling(blerina, S), Sibs).
% Sibs = [agim].

% Cousin check
% ?- cousin(blerina, teuta).
% true.

% Grandparents of arta
% ?- setof(G, grandparent(G, arta), GPs).
% GPs = [ana, dritan].

% Cousins of blerina
% ?- setof(C, cousin(blerina, C), Cousins).
% Cousins = [besnik, teuta].

% Grandchildren of arben
% ?- setof(GC, grandparent(arben, GC), Grandkids).
% Grandkids = [agim, besnik, blerina, teuta].

% All descendants of arben (recursive)
% ?- setof(D, descendant(D, arben), Down).
% Down = [agim, arta, besnik, blerina, dritan, elira, endrit, rina, teuta].

% All ancestors of arta (recursive)
% ?- setof(A, ancestor(A, arta), Up).
% Up = [ana, arben, blerina, dritan, ilir, lule].
