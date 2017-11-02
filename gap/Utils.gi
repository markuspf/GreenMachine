
InstallGlobalFunction(IsCommutator,
function(f, w)
	local fp := CommutatorFactorGroup(f);
	local hom := GroupHomomorphismByImages(f, fp, [f.1, f.2], [fp.1, fp.2])
	return IsOne(Image(hom, w));
end);


