function [dim,ierr] = chk_input(dat_p3d,dat_nmf);

dim = dat_p3d.dim; ierr = 1; 

if dat_p3d.dim ~= dat_nmf.dim; ierr = 1; return; end
if dat_p3d.nblock ~= dat_nmf.nblock; ierr = 2; return; end

if max(abs(dat_p3d.idims(:) - dat_nmf.idims(:))) > 0; ier = 3; return; end
if max(abs(dat_p3d.jdims(:) - dat_nmf.jdims(:))) > 0; ier = 4; return; end
if max(abs(dat_p3d.kdims(:) - dat_nmf.kdims(:))) > 0; ier = 5; return; end

ierr = 0;
