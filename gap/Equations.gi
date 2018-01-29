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

InstallGlobalFunction(SubwordLength,
function(word_string, i)
	local subword, exp, next_exp, subcount, letter, j;
	subcount := 0;
	while i <= Length(word_string) do
		next_exp := 0;
		letter := word_string[i];
		if IsAlphaChar(letter) then
			if word_string[i+1] = '^' then
				next_exp := Int([word_string[i+2]]);
				i := i + 3;
				while IsDigitChar(word_string[i]) do
					next_exp := 10*next_exp;
					next_exp := next_exp + Int([word_string[i]]);
					i := i + 1;
				od;
				subcount := subcount + next_exp;
			else
				subcount := subcount + 1;
				i := i + 1;
			fi;
		elif letter = ')' then
			return subcount;
		elif letter = '(' then
			subword := SubwordLength(word_string, i + 1);
			j := 0;
			while word_string[i + j] <> ')' do
				j := j + 1;
			od;
			i := i + j + 1;
			exp := 1;
			if i >= Length(word_string) then
				return -1;
			fi;
			if word_string[i] = '^' then
				exp := Int([word_string[i + 1]]);
				i := i + 2;
				while IsDigitChar(word_string[i]) do
					exp := 10*exp;
					exp := exp + Int([word_string[i]]);
					i := i + 1;
				od;
			fi;
			subcount := subcount + (exp * subword);
			if i >= Length(word_string) then
				return -1;
			fi;
		else
			i := i + 1;
		fi;
	od;
end);

# Find solutions to an equation w(x,y) = u(a,b)
# up to length n by brute force
# w(x, y) is a function of variables
# u(a, b) is a function of constants
# Trying to solve for x and y

InstallGlobalFunction(ShortSolutions,
function(w, u, n)
    local variables, constants, f, gens, const, consts, vars, copy, solutions, tree, c1, c2, c3, c4, nodes, word_string, letter, subcount, i, next_exp;
	solutions := [];
	tree := rec();
	nodes := [1];

    variables := FreeGroupOfWord(w);
	constants := FreeGroupOfWord(u);

	f := FreeGroup(Concatenation(List(GeneratorsOfGroup(constants), String),
								 List(GeneratorsOfGroup(variables), String)));
	gens := GeneratorsOfGroup(f){[1 .. Length(GeneratorsOfGroup(variables))]};
	vars := GeneratorsOfGroup(f){[Length(GeneratorsOfGroup(variables)) + 1 ..
								  Length(GeneratorsOfGroup(f))]};
	consts := Concatenation(gens, List(gens, Inverse));
	tree.children := List(consts, x -> rec(value := x, parent := tree));
	tree.value := f.1 * f.1^-1;
	w := MappedWord(w, GeneratorsOfGroup(variables), vars);
	u := MappedWord(u, GeneratorsOfGroup(constants), consts);

	if u = f.1 * f.1^-1 then
		word_string := String(w);		
		if IsDigitChar(word_string[Length(word_string)]) then
			if word_string[1] = '(' then
				subcount := SubwordLength(word_string, 2);
				if subcount > 0 then
					w := Subword(w, 1, subcount);
				fi;
			fi;
		fi;
	fi;

	for const in consts do
		copy := MappedWord(w, [vars[1]], [const]);
		if copy = u then
			Add(solutions, [const, 0]);
		fi;
		solutions := BuildTree(const, consts, tree, copy, u, f, solutions, 0, n, nodes);
	od;
	# Print(nodes[1]);
	# Print("\n");
	return solutions;
end);

InstallGlobalFunction(BuildTree,
function(x, consts, node, copy, u, f, solutions, n, limit, nodes)
	local child, const, word, grandchild, c, child_rec;
	nodes[1] := nodes[1] + 1;
	if n > limit then
		return solutions;
	fi;
	for child in node.children do
		child.children := [];
		c := MappedWord(copy, [f.4], [child.value]);
		if c = u then
			Add(solutions, [x, child.value]);
		fi;
		for const in consts do
			word := child.value * const;
			if word = child.parent.value then
				continue;
			fi;
			child_rec := rec();
			child_rec.value := word;
			child_rec.parent := child;
			Add(child.children, child_rec);
		od;
	od;
	for child in node.children do
		BuildTree(x, consts, child, copy, u, f, solutions, n + 1, limit, nodes);
	od;
	return solutions;
end);

InstallMethod(FreeGroupOfWord, "for a word over the free group",
              [IsWord], w -> FamilyObj(w)!.freeGroup);

GreenTest := function(n)
    local w, u, F, U, x, y, a, b;

    F := FreeGroup("x", "y");
    x := F.1; y := F.2;


    w := x * y * x;
    u := a^2 * b^2 * a^2;

    return ShortSolutions(w, u, n);
end;

