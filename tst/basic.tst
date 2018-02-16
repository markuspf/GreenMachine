#
gap> F := FreeGroup("x", "y");; x := F.1;; y := F.2;;
gap> x * y = y * x;
false

#
gap> MoldovanskiiRewritingByGenerators(x^2*y, x, y);
[ x^2*y*x^-2, [ x, y*x^-2 ] ]

#
gap> F := FreeGroup("x", "y");;
gap> w := F.1 * F.2;;
gap> IsCommutator(F, w);
false

#

#
gap> x := F.1 * F.2 * F.1^-1 * F.2^-1;;
gap> IsCommutator(F, x);
true

#
gap> f := FreeGroup("x", "y");;
gap> g := FreeGroup("a", "b");;
gap> w := f.1 * f.2;;
gap> u := g.1 * g.2;;
gap> ShortSolutions(w, u, 5);
[ [ a, b ], [ b, b^-1*a*b ], [ a^-1, a^2*b ], [ b^-1, b*a*b ] ]

