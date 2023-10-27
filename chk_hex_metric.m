function dat=chk_hex_metric(X,Hexes,str,verbose,varargin)

t0=tic; 
dim = size(X,2); nv=2^dim;
E=size(Hexes,1); N=8;%distribution

if(length(varargin)>0);N=varargin{1};end
for d=1:dim; Xtmp=X(Hexes,d); Xl(:,:,d)=reshape(Xtmp,E,nv); end % GtoL 

mma=@(v)[min(v(:)),max(v(:)),sum(v(:))/numel(v)]; % [min,max,ave]

% spacing
if (dim==3)
   iv1=[1,1,1]; iv2=[2,4,5];
else
   iv1=[1,1]; iv2=[2,4];
end
Xdif=Xl(:,iv1,:)-Xl(:,iv2,:); Elen=sqrt(sum(Xdif.^2,3)); dxmin=min(Elen,[],2);
dat.dxmin=mma(dxmin);

% scaled Jac
jacm=comp_Jacobian_v3_2(Xl); jacm=reshape(jacm,nv,E)'; sc_jac=min(jacm,[],2)./max(jacm,[],2);
dat.sc_jac=mma(sc_jac);

% aspect ratio
if (dim==3); % 12 edges
   iv1=[1,2,3,4,5,6,7,8,1,2,3,4];
   iv2=[2,3,4,1,6,7,8,5,5,6,7,8];
else; % 4 edges
   iv1=[1,2,3,4];
   iv2=[2,3,4,1];
end
Xdif=Xl(:,iv1,:)-Xl(:,iv2,:); Elen=sqrt(sum(Xdif.^2,3)); aratio=max(Elen,[],2)./min(Elen,[],2);
dat.aratio=mma(aratio);

% max multiplicity
dat.max_mult=max(accumarray(Hexes(:),1)); % only works for water tight mesh.

ifhist=0; if(exist('histcounts')==2); ifhist=1; end

if(ifhist==1);
   stt=@(v,n)histcounts(v,linspace(min(v(:)),max(v(:)),n));
   [c1,e1]=stt(dxmin,N); c1=int8(c1/E*100);
   [c2,e2]=stt(sc_jac,N);c2=int8(c2/E*100);
   [c3,e3]=stt(aratio,N);c3=int8(c3/E*100);
else
   N=0;
end

if (verbose>0)
stype='Hex'; if (dim==2); stype='Quad'; end
fprintf('INFO %s metrics: %s (min/max/ave | distr) (%2.4e sec)\n',stype,str,toc(t0));
fprintf('  GLL grid spacing %9.2e %2.2e %2.2e |',dat.dxmin); for i=1:N-1;fprintf(' %3d',c1(i));end;fprintf('\n'); 
fprintf('  scaled Jacobian  %9.2e %2.2e %2.2e |',dat.sc_jac);for i=1:N-1;fprintf(' %3d',c2(i));end;fprintf('\n');
fprintf('  aspect ratio     %9.2e %2.2e %2.2e |',dat.aratio);for i=1:N-1;fprintf(' %3d',c3(i));end;fprintf('\n');
fprintf('  max multiplicity %d\n',dat.max_mult);
end
