function [X, Hex20, ierr] = gen_hex20(X0,Hexes,dat_p3d,verbose)

dim = dat_p3d.dim;

if dim==2
   [X, Hex20, ierr] = gen_hex20_2d(X0,Hexes,dat_p3d,verbose);
elseif dim==3
%   assert(dim==2,'3D is not ready');
   error('gen_hex20: 3D is not ready')
   [X, Hex20, ierr] = gen_hex20_3d(X0,Hexes,dat_p3d,verbose);
else
   error('gen_hex20: inlvaid dimension')
end



function [X, Hex20, ierr] = gen_hex20_2d(X0,Hexes,dat_p3d,verbose)

   t0=tic; if (verbose>0); fprintf('Generate 2nd-Order Mesh ... '); end
   
   nblock = dat_p3d.nblock;
   dim    = dat_p3d.dim;
   idims  = dat_p3d.idims;
   jdims  = dat_p3d.jdims;
   kdims  = dat_p3d.kdims;
   
   ierr = -1;
   method = 'spline'; %'makima'; 
   E = size(Hexes,1);
   Hex20 = zeros(E,3^dim); % use Hex27 data structure but only fill hex20 edges.
   
   % total number of points for all previous blocks
   iE0 = zeros(nblock,1);
   for ib=2:nblock
      iE0(ib) = iE0(ib-1) + (dat_nmf.idims(ib)-1)*(dat_nmf.jdims(ib)-1)*(dat_nmf.kdims(ib)-1);
   end
   
   nX0 = size(X0,1); X=X0; nX=nX0;
   for ib=1:nblock;
      nx = idims(ib); nelx = nx-1;
      ny = jdims(ib); nely = ny-1;
      eid = (iE0(ib)+1):(iE0(ib)+nelx*nely);
   
      if (nx<4 || ny<4); %TODO, maybe switch to makima or linear for this?
         fprintf("ERROR gen h20: block=%d, interp spline needs 4 points,\n",ib);
         X=X0; Hex20=[]; ierr=ib; return
      end
   
      Hex20(eid,[1,3,7,9]) = Hexes(eid,[1,2,4,3]);
   
      % face 1-3: determine y
      for ey=1:nely; ex = 1:nelx;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,1);Hexes(eid(end),2)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,2) = ex + nX;
         if (ey>1)
            eid = (ey-2)*nelx + ex + iE0(ib);
            Hex20(eid,8) = ex + nX;
         end
   
         X=[X;Xnew]; nX=size(X,1);
      end
      ey = nely; ex = 1:nelx;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,4);Hexes(eid(end),3)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
         Hex20(eid,8) = ex + nX;
   
         X=[X;Xnew]; nX=size(X,1);
   
      % face 2-4: determine x
      for ex=1:nelx; ey=1:nely;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,1);Hexes(eid(end),4)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,4) = ey + nX;
         if (ex>1)
            eid = (ey-1)*nelx + ex-1 + iE0(ib);
            Hex20(eid,6) = ey + nX;
         end
   
         X=[X;Xnew]; nX=size(X,1);
      end
      ex = nelx; ey=1:nely;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,2);Hexes(eid(end),3)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,6) = ey + nX;
         X=[X;Xnew]; nX=size(X,1);
   
   end
   
   ierr = 0;
   if (verbose>0); 
      if (verbose>1); fprintf('\n'); end
      fprintf('   method=%s nXnew=%d',method,nX-nX0);
      if (verbose>1); fprintf('\n'); end
      fprintf('   done! (%2.4e sec)\n',toc(t0));
   end


function [X, Hex20, ierr] = gen_hex20_3d(X0,Hexes,dat_p3d,verbose)

   t0=tic; if (verbose>0); fprintf('Generate 2nd-Order Mesh ... '); end
   
   nblock = dat_p3d.nblock;
   dim    = dat_p3d.dim;
   idims  = dat_p3d.idims;
   jdims  = dat_p3d.jdims;
   kdims  = dat_p3d.kdims;
   
   ierr = -1;
   method = 'spline'; %'makima'; 
   E = size(Hexes,1);
   Hex20 = zeros(E,3^dim); % use Hex27 data structure but only fill hex20 edges.
   
   % total number of points for all previous blocks
   iE0 = zeros(nblock,1);
   for ib=2:nblock
      iE0(ib) = iE0(ib-1) + (dat_nmf.idims(ib)-1)*(dat_nmf.jdims(ib)-1)*(dat_nmf.kdims(ib)-1);
   end
   
   nX0 = size(X0,1); X=X0; nX=nX0;
   for ib=1:nblock;
      nx = idims(ib); nelx = nx-1;
      ny = jdims(ib); nely = ny-1;
      nz = kdims(ib); nelz = nz-1;
      eid = (iE0(ib)+1):(iE0(ib)+nelx*nely*nelz);
   
      if (nx<4 || ny<4 || nz<4); %TODO, maybe switch to makima or linear for this?
         fprintf("ERROR gen h20: block=%d, interp spline needs 4 points,\n",ib);
         X=X0; Hex20=[]; ierr=ib; return
      end
   
      Hex20(eid,[1,3,7,9,19,21,25,27]) = Hexes(eid,[1,2,4,3,5,6,8,7]);
   
      % face 1-3: determine y
      for ey=1:nely; ex = 1:nelx;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,1);Hexes(eid(end),2)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,2) = ex + nX;
         if (ey>1)
            eid = (ey-2)*nelx + ex + iE0(ib);
            Hex20(eid,8) = ex + nX;
         end
   
         X=[X;Xnew]; nX=size(X,1);
      end
      ey = nely; ex = 1:nelx;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,4);Hexes(eid(end),3)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
         Hex20(eid,8) = ex + nX;
   
         X=[X;Xnew]; nX=size(X,1);
   
      % face 2-4: determine x
      for ex=1:nelx; ey=1:nely;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,1);Hexes(eid(end),4)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,4) = ey + nX;
         if (ex>1)
            eid = (ey-1)*nelx + ex-1 + iE0(ib);
            Hex20(eid,6) = ey + nX;
         end
   
         X=[X;Xnew]; nX=size(X,1);
      end
      ex = nelx; ey=1:nely;
         eid = (ey-1)*nelx + ex + iE0(ib);
         xid = [Hexes(eid,2);Hexes(eid(end),3)];
   
         xx = X(xid,1); yy = X(xid,2);
         xdif = xx(1:end-1)-xx(2:end);
         ydif = yy(1:end-1)-yy(2:end);
         arc = [0; cumsum(sqrt(xdif.^2+ydif.^2))];
         amid = (arc(1:end-1)+arc(2:end))/2;
   
         xmid = interp1(arc,xx,amid,method);
         ymid = interp1(arc,yy,amid,method);
         Xnew = [xmid,ymid];
   
         Hex20(eid,6) = ey + nX;
         X=[X;Xnew]; nX=size(X,1);
   
   end
   
   ierr = 0;
   if (verbose>0); 
      if (verbose>1); fprintf('\n'); end
      fprintf('   method=%s nXnew=%d',method,nX-nX0);
      if (verbose>1); fprintf('\n'); end
      fprintf('   done! (%2.4e sec)\n',toc(t0));
   end
