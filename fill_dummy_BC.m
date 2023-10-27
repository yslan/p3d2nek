function  [CBC,BC_map] = fill_dummy_BC(CBC,con_table,BC_map,verbose)

nbcid = length(BC_map);

% fill the rest with dummy BC 
id_bdry=con_table==0;
id_unset=CBC==0;
id_dummyBC = id_bdry&id_unset;

nf=sum(id_dummyBC(:));
if (nf>0); nbcid=nbcid+1;
   BC_map{nbcid} = 'DUMMY';
   CBC(id_dummyBC)=nbcid;
end

if (verbose>0); fprintf('Fill the rest of CBC: nface=%d\n',nf); end
