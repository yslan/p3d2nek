function print_BC_map(CBC,BC_map,verbose)

   nbcid = max(CBC(:));
   if (nbcid~=length(BC_map)); return; end

   cbc_dmy=cell(nbcid,1);
   cbc_dmy{1}='W  ';
   for ig=2:nbcid
      cbc_dmy{ig}=['W' sprintf('%02d',ig-1)];
   end

   if (verbose>0)
      fprintf('INFO BoundaryIdMap: (id/CBC/name(NMF)/nface\n');
      for i=1:nbcid
         fprintf('   %2d %3s %12s   %d\n',i,cbc_dmy{i},BC_map{i},sum(CBC(:)==i));
      end 
   end
