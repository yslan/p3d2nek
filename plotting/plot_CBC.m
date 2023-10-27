function plot_CBC(ifig,X,Hexes,CBC,BC_map)
if(ifig==0);return;end; if(ifig<0); ifig=abs(ifig); hold off; end; figure(ifig);
    
d = size(X,2);

plot_mesh(ifig,X,Hexes);

if (d==2)
   plot_2d(X,Hexes,CBC,BC_map);
elseif (d==3)
   plot_3d(X,Hexes,CBC,BC_map);
end

axis equal;drawnow



function plot_2d(X,Hexes,CBC,BC_map)
   slw = 'LineWidth'; lw = 4;
   E = size(Hexes,1);

   nv = 4;
   nface = 4;
   iftoiv = [1,2;2,3;3,4;4,1];
   Htmp=Hexes';

   nbcid = max(CBC(:));
   if(length(BC_map)~=nbcid);BC_map=cell(nbcid,1);end

   pp=[]; ss={};
   for ibc=1:nbcid; clr=mycolor(ibc); sid=BC_map{ibc};
      [e,f] = find(CBC==ibc);
      edge = [Htmp((e-1)*nv+iftoiv(f,1)),...
              Htmp((e-1)*nv+iftoiv(f,2))];
      xedge=reshape(X(edge,1),size(edge,1),2);
      yedge=reshape(X(edge,2),size(edge,1),2);
      p=plot(xedge',yedge',clr,slw,lw); hold on

      s=sprintf('BCid=%d (%s)',ibc,sid);
      pp=[pp;p(1)]; ss{end+1}=s;
   end
   legend(pp,ss);


function plot_3d(X,Hexes,mode)
   assert(1==2,'plot_mesh3d is not ready')
