
InstallGlobalFunction(IsCommutator,
function(f, w)
	local fp, hom, res;
	fp := CommutatorFactorGroup(f);
	hom := GroupHomomorphismByImages(f, fp, [f.1, f.2], [fp.1, fp.2]);
	res :=  IsOne(Image(hom, w));
	return res;
end);


