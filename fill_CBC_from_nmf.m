function [CBC,BC_map,status] = fill_CBC_from_nmf(CBC,dat_nmf,verbose)

t0=tic; if (verbose>0); fprintf('Fill CBC from NMF ...'); end
[CBC,BC_map,status] = fill_CBC_from_nmf_aux(CBC,dat_nmf,verbose);

if (verbose>0); 
   if (verbose>1); fprintf('\n'); end
   fprintf('   status=%d',status); 
   if (verbose>1); fprintf('\n');
      for i=1:length(BC_map)
         fprintf('   %d %12s  nf=%d\n',i,BC_map{i},sum(CBC(:)==i));
      end
   end
   fprintf('   done! (%2.4e sec)\n',toc(t0)); 
end

function [CBC,BC_map,status] = fill_CBC_from_nmf_aux(CBC,dat_nmf,verbose)

   status = -1;
   face_map = [4,2,1,3,5,6]; % lexicographic to nek's order

   nbc = dat_nmf.nbc;
   nblock = dat_nmf.nblock;
   idims = dat_nmf.idims;
   jdims = dat_nmf.jdims;
   kdims = dat_nmf.kdims;

   % total number of points for all previous blocks
   iE0 = zeros(nblock,1);
   for ib=2:nblock
      iE0(ib) = iE0(ib-1) + (dat_nmf.idims(ib)-1)*(dat_nmf.jdims(ib)-1)*(dat_nmf.kdims(ib)-1);
   end
 
   BC_map = cell(nbc,1); nbcid=0; nfill=0;
   
   for ibc=1:nbc; BC=dat_nmf.BC(ibc);

      if strcmp(BC.type,'ONE_TO_ONE'); % do nothing about periodic
      else
         bcid = find(strcmp(BC_map,BC.type));
         if (isempty(bcid)); % add new BC into list
            nbcid=nbcid+1; bcid=nbcid;
            BC_map{bcid} = BC.type;
         end
         if (length(BC.vec)~=6)
            fprintf('BC vec for %s needs 6 integer\n',BC.type);
            BC_map=cell(0); return;
         end

         bid = BC.vec(1);
         fid = BC.vec(2);
         eid = extract_element_ind(iE0,idims,jdims,kdims,BC.vec);
         CBC(eid,face_map(fid)) = bcid;
         nfill = nfill + length(eid);

      end

   end

   BC_map = BC_map(1:nbcid);
   status = nfill;


function id = extract_element_ind(iE0,idims,jdims,kdims,vec); % TODO, need to figure out 3D mapping
   bid = vec(1); 
   fid = vec(2);
   i0 = vec(3);
   i1 = vec(4);
   j0 = vec(5);
   j1 = vec(6);
   nx = idims(bid); ny = jdims(bid); nz = kdims(bid);
   nelx = nx-1; nely = ny-1; nelz = nz-1;

% lexicographic order
%       _f4_
%      |    |
%   f1 |    | f2
%      |____|
%        f3

   assert(nz==1,'TODO: 3D');
   assert(j0==1&&j1==1, 'TODO fix extract_face_ind');

   if nz==1 % 2D

      iloc = reshape(1:(nelx*nely),[nelx,nely]);
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

   end

   id = id + iE0(bid);
   id = reshape(id,[length(id),1]);
