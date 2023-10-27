function [UX,Hexes,status]=unique_Vpts_v2(X0,Hexes0,tol,verbose)
% status = 0: do nothing
% status = >0; merge points
% note: MATLAB's uniquetol is faster, but this has less dependency

t0=tic; if (verbose>0); fprintf('UNIQUE_VPTS (tol=%2.2e) ... ',tol); end
status=0; nX0=size(X0,1); 

iXtoUX=zeros(nX0,1); UX=0*X0;
[X,isort]=sortrows(X0); jsort(isort)=1:nX0;
Xlast=X(1,:); UX(1,:)=Xlast; iXtoUX(1)=1; iux=1;
for i=2:nX0
   if norm(X(i,:)-Xlast) > tol
      Xlast=X(i,:);
      iux=iux+1;UX(iux,:)=Xlast;
   end
   iXtoUX(i)=iux;
end
iXtoSUX=iXtoUX(jsort)';
UX = UX(1:iux,:); nUX=size(UX,1);

% restrore if no points are merged (so it recovers ordering)
ndif = nX0-nUX;
if (ndif==0)
   status = 0; UX = X0; Hexes = Hexes0;
else
   status = ndif; Hexes = iXtoSUX(Hexes0);
end

if (verbose>0)
   if (verbose>1); 
      fprintf('\n   #old=%d, #new=%d, #diff=%d\n',nX0,nUX,ndif);
   end
   fprintf('   status=%d',status); if (verbose>1); fprintf('\n'); end
   fprintf('   done! (%2.4e sec)\n',toc(t0));
end



