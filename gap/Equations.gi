# Solving equations over Free Groups

InstallGlobalFunction(FreeGroupEquationSolve,
function(w,u)
    local vars, consts;

    vars := GeneratorsOfGroup(FreeGroupOfWord(w));
    consts := GeneratorsOfGroup(FreeGroupOfWord(u));

end);


#	ex and ey are the x- and y-exponent sums of the word w respectively.
#	q is the quotient of the exponent sums, e.g. if exponent sums are 3 and 7 then q=2, as 2x3+1=7
#	aut:=[x', y'] is a list consisting of the Neilsen generating pair corresponding to the Moldovanskii rewriting.
#	That is, if w' is the rewritten form of w then there exists an automorphism
#	\phi of F(x, y) such that \phi(w)=w'. In aut, x' and y' are such that
#	\phi(x)=x', \phi(y)=y'. For example, for mold:=Moldovanskii(u); where u is
#	some word over x and y, then mold[1]; and MappedWord(u, [x, y], mold[2]); are
#	the same word.
# NOTE: It may be that MappedWord is better than Eliminated word
#	for our purposes? As might not use syllable notation! (Section 36.3-1 of GAP
#	documentation.)

# TODO: Tests: Some words to rewrite + test that applying the auotmorphism
#              stabilises them.
#       Check whether w is a commutator, and error if it is
#       Error("w is a commutator");
#       Error("");

InstallGlobalFunction(MoldovanskiiRewritingByGenerators,
function(w,x,y)
	  local ex, ey, q, aut;

	  ex := ExponentSumWord(w, x);
	  ey := ExponentSumWord(w, y);
	  aut := [x, y];

	  while ex<>0 and ey<>0 do
		    if AbsInt(ey)>=AbsInt(ex) then
			      q := -QuoInt(ey, ex); # QuoInt is quotient of integers
			      w := MappedWord(w, [x], [x*y^q] );
			      aut[1] := MappedWord(aut[1], [x], [x*y^q] );
			      aut[2] := MappedWord(aut[2], [x], [x*y^q] );
			      ey := ExponentSumWord(w, y);
		    elif AbsInt(ex)>AbsInt(ey) then
			      q := -QuoInt(ex, ey);
			      w := MappedWord(w, [y], [y*x^q] );
			      aut[1] := MappedWord(aut[1], [y], [y*x^q] );
			      aut[2] := MappedWord(aut[2], [y], [y*x^q] );
			      ex := ExponentSumWord(w, x);
		    fi;
	  od;
	  return [w, aut];
end);

# We're looking for solutions to w(x,y) = u(a,b)
# 1. Rewrite w(x,y) as w_0(xy^-1x, y)
#    If expoent sum of x <> 0 or y <> 0 then do
#    Moldovanski rewriting to get one of htem to 0.
#    Also remember the rewriting step
# 2. If  w_0 is in <x^eps y x, y> or <y^eps x y, x >
#    (If w_0 in <y^-1xy, x> then reinterpret x->x_0, y->x_0y_0

# Solves the equation w(x,y) = u(a,b) where w in F(x,y) :wq
# There is no real reason to not use
# list and not just 2 variables
InstallGlobalFunction(IsSolution,
function(w, u, xs, ixs)
    return MappedWord(w, xs, ixs) = u;
end);

# Find solutions to an equation w(x,y) = u(a,b)
# up to length n by brute force
# w(x, y) is a function of variables
# u(a, b) is a function of constants
# Trying to solve for x and y

InstallGlobalFunction(ShortSolutions,
function(w, u, n)
    local f, gens, const, consts, vars, copy, solutions;

	solutions := [];

    # TODO: Make sure this gives is the correct generators all
    #       the time
    vars := GeneratorsOfGroup(FreeGroupOfWord(w));
	gens := GeneratorsOfGroup(FreeGroupOfWord(u));
    
	if Length(vars) <> 2 then
        Error("Can only handle precisely two variables currently");
    fi;

	f := FreeGroup(String(gens[1]), String(gens[2]), 
				   String(vars[1]), String(vars[2]));
	consts := [f.1, f.1^-1, f.2, f.2^-1];
	w := MappedWord(w, vars, [f.3, f.4]);
	u := MappedWord(u, gens, [f.1, f.2]);

	for const in consts do
		copy := MappedWord(w, [f.3], [const]);
		if copy = u then
			Add(solutions, const);
		fi;
	od;
	return solutions;
end);

InstallMethod(FreeGroupOfWord, "for a word over the free group",
              [IsWord], w -> FamilyObj(w)!.freeGroup);

GreenTest := function(n)
    local w, u, F, U, x, y, a, b;

    F := FreeGroup("x", "y");
    x := F.1; y := F.2;

    U := FreeGroup("a", "b");
    a := U.1; b := U.2;

    w := x * y * x;
    u := a^2 * b^2 * a^2;

    return ShortSolutions(w, u, n);
end;

