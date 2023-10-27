function [X, Hexes, iHtoiB] = gen_mesh(dat_p3d,verbose);

t0=tic; if (verbose>0); fprintf('Generate Mesh ... '); end

d = dat_p3d.dim;
if (d==2)
   [X, Hexes, iHtoiB] = gen_mesh_2d(dat_p3d);
elseif (d==3)
   [X, Hexes, iHtoiB] = gen_mesh_3d(dat_p3d);
end

if (verbose>0); 
   if (verbose>1); fprintf('\n'); end
   fprintf('   E=%d nX=%d',size(Hexes,1),size(X,1)); 
   if (verbose>1); fprintf('\n'); end
   fprintf('   done! (%2.4e sec)\n',toc(t0)); 
end


function [X, Hexes, iHtoiB] = gen_mesh_2d(dat_p3d)

   nb = dat_p3d.nblock;
   Hexes=[]; X=[]; iHtoiB=[];

   for i=1:nb; x=dat_p3d.coord(i).x; y=dat_p3d.coord(i).y; nX0=size(X,1);

      nx = dat_p3d.idims(i); nelx=nx-1; 
      ny = dat_p3d.jdims(i); nely=ny-1;
      E = nelx*nely;
   
      [ex,ey]=ndgrid(1:nelx,1:nely); ex=ex(:); ey=ey(:);
      eHx = [ex, ex+1, ex+1, ex];
      eHy = [ey, ey, ey+1, ey+1];
      Htmp = (eHy-1)*nx + eHx;
   
      % TODO, if nblock is large, avoid re-allocate by static mem
      X = [X; x(:), y(:)];
      Hexes = [Hexes; Htmp+nX0];
      iHtoiB = [iHtoiB; ones(E,1)*i];
   end


function [X, Hexes, iHtoiB] = gen_mesh_3d(dat_p3d)

   nb = dat_p3d.nblock;
   Hexes=[]; X=[]; iHtoiB=[];
   for i=1:nb; x=dat_p3d.coord(i).x; y=dat_p3d.coord(i).y; x=dat_p3d.coord(i).x; nX0=size(X,1);

      nx = dat_p3d.idims(i); nelx=nx-1; 
      ny = dat_p3d.jdims(i); nely=ny-1;
      nz = dat_p3d.kdims(i); nelz=nz-1;
      E = nelx*nely*nelz;
   
      [ex,ey,ez]=ndgrid(1:nelx,1:nely,1:nelz); ex=ex(:); ey=ey(:); ez=ez(:);
      eHx = [ex, ex+1, ex+1, ex, ex, ex+1, ex+1, ex];
      eHy = [ey, ey, ey+1, ey+1, ey, ey, ey+1, ey+1];
      eHz = [ez, ez, ez, ez, ez+1, ez+1, ez+1, ez+1];
      Htmp = (eHz-1)*ny*nx + (eHy-1)*nx + eHx;

      % TODO, if nblock is large, avoid re-allocate by static mem
      X = [X; x(:), y(:), z(:)];
      Hexes = [Hexes; Htmp+nX0];
      iHtoiB = [iHtoiB; ones(E,1)*i];
   
   end
