
#! @Description
#! Performs Moldovanskii rewriting on the word <A>w</A> and the
#! generators <A>x</A> and <A>y</A>.
#!
#! From the theory of one-relator groups (cf Magnus' method).
#! If <x, y; w> has abelianisation NOT ZxZ, then the JSJ-decomposition
#! of the equation w(x, y)=u can be read directly off of the rewritten
#! form of w.
#!
#! Returns the rewritten word and the automorphism
DeclareGlobalFunction("MoldovanskiiRewritingByGenerators");

DeclareGlobalFunction("ShortSolutions");
DeclareGlobalFunction("IsSolution");

