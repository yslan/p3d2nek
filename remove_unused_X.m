function [X,Hexes] = remove_unused_X(X,Hexes,verbose)
   % My good old clean_X_by_edge_v2
   % remove un-used points, re-write 11/15

   nX=size(X,1); id_kp=logical(zeros(nX,1));

   vtx=Hexes; vtx_p=vtx(vtx>0);

   % Get id
   id_kp(unique(vtx_p))=1;

   % Deal with ids...
   id_rm=~id_kp;
   id=1:nX; id(id_rm)=[]; id2(id)=1:length(id); % this is confusing but working...
   iXtoUX=id2;

   n1=nX; n2=sum(id_kp);
   if (verbose>1)
      fprintf('Remove un-used points, #old= %d, #new= %d , #un-used= %d\n',n1,n2,n1-n2);
   end

   % Clean up indices, points
   X(id_rm,:)=[];
   vtx(vtx>0)=iXtoUX(vtx_p);Hexes=vtx;
