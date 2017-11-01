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
