function [Hexes, status] = gen_con_from_nmf(Hexes0, iHtoiB, dat_nmf, verbose);

% status = -1: something is wrong, do nothing and return
% status =  0; go through all BC and no change is needed.
% status >  0; process all BC, and we patch "status" faces.
t0=tic; if (verbose>0); fprintf('Generate connectivity via nmf ...'); end

dim = dat_nmf.dim;
if (dim==2)
   [Hexes, status] = gen_connectivity_2d(Hexes0, iHtoiB, dat_nmf, verbose);
elseif (dim==3)
   assert(dim==2,'gen_connectivity is not ready for 3D')
end

if (verbose>0); 
   fprintf('   status=%d',status); if (verbose>1); fprintf('\n'); end
   fprintf('   done! (%2.4e sec)\n',toc(t0)); 
end


function [Hexes, status] = gen_connectivity_2d(Hexes0, iHtoiB, dat_nmf, verbose)
   % in 2D, we can ignore the second primary index

   t0=tic;
   status = -1;

   nbc = dat_nmf.nbc;
   nblock = dat_nmf.nblock;
   idims = dat_nmf.idims;
   jdims = dat_nmf.jdims;
   kdims = dat_nmf.kdims;

   % total number of points for all previous blocks
   iX0 = zeros(nblock,1);
   for ib=2:nblock
      iX0(ib) = iX0(ib-1) + dat_nmf.idims(ib)*dat_nmf.jdims(ib)*dat_nmf.kdims(ib);
   end

   nX = max(Hexes0(:));
   iXtoUX = reshape(1:nX,nX,1); iXtoUX0=iXtoUX;
   
   
   for sweep = 1:nblock; nper=0; % dummy loop to fix shared points in 3 blocks.
   for ibc=1:nbc; BC=dat_nmf.BC(ibc);

      if strcmp(BC.type,'ONE_TO_ONE'); nper=nper+1;
         if (length(BC.vec)~=12)
            fprintf('BC vec for ONE_TO_ONE needs 12 integer');
            Hexes = Hexes0; return
         end

         fid     = extract_face_ind(iX0,idims,jdims,kdims,BC.vec(1:6),'');       nf1=length(fid);
         fid_opp = extract_face_ind(iX0,idims,jdims,kdims,BC.vec(7:12),BC.swap); nf2=length(fid_opp);
         if (nf1~=nf2);
            fprintf('BC: ONE_TO_ONE face size mismatched');
            Hexes = Hexes0; return
         end

         fid_new = min([iXtoUX(fid),iXtoUX(fid_opp)],[],2);
         iXtoUX(fid)     = fid_new;
         iXtoUX(fid_opp) = fid_new;
      end

   end 
   end

   ndif=max(abs(iXtoUX(:)-iXtoUX0(:)));
   if ndif>0;
      Hexes = iXtoUX(Hexes0);
      status = nper;
   else
      Hexes = Hexes0;
      status = 0;
   end

   if (verbose>1);
      fprintf('\n   %d face-pairs\n   %d points modified\n',nper,ndif);
   end


function id = extract_face_ind(iX0,idims,jdims,kdims,vec,swap); % TODO, need to figure out 3D mapping
   bid = vec(1); nx = idims(bid); ny = jdims(bid); nz = kdims(bid);
   fid = vec(2);
   i0 = vec(3);
   i1 = vec(4);
   j0 = vec(5);
   j1 = vec(6);

% lexicographic order
%       _f4_
%      |    |
%   f1 |    | f2
%      |____|
%        f3

   assert(nz==1,'TODO: 3D');
   assert(j0==1&&j1==1, 'TODO fix extract_face_ind');

   iloc = reshape(1:(nx*ny*nz),[nx,ny,nz]);

   % old
   if nz==1 % 2D

%      switch fid
%         case 1
%            id = iloc(1,:);
%         case 2
%            id = iloc(end,:);
%         case 3
%            id = iloc(:,1);
%         case 4
%            id = iloc(:,end);
%      end
%      if (i0>i1); id = id(end:-1:1); end

      ii=i0:(i1-1); if(i1-1<i0);ii=(i1-1):i0;end
      jj=j0:(j1-1); if(j1-1<j0);jj=(j1-1):j0;end
      switch fid
         case 1
            id = iloc(1,ii);
         case 2
            id = iloc(end,ii);
         case 3
            id = iloc(ii,1);
         case 4
            id = iloc(ii,end);
      end
      if (strcmp(swap,'T')); id = id(end:-1:1); end

   end



   id = id + iX0(bid);
   id = reshape(id,[length(id),1]);



