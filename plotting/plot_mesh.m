function plot_mesh(ifig,X,Hexes,varargin)
if(ifig==0);return;end; if(ifig<0); ifig=abs(ifig); hold off; end; figure(ifig);
    
d = size(X,2);

mode = ''; if (length(varargin)==1); mode = varargin{1}; end

if (d==2)
   plot_mesh2d(X,Hexes,mode);
elseif (d==3)
   plot_mesh3d(X,Hexes,mode);
end

axis equal;drawnow



function plot_mesh2d(X,Hexes,mode)
   slw = 'LineWidth'; lw = 2;
   E = size(Hexes,1);

   % slow version
%   for e=1:E
%      edge=Hexes(e,[1,2,3,4,1]);
%      plot(X(edge,1),X(edge,2),'k-',slw,lw);hold on
%   end

   % fast version
   edge = Hexes(:,[1,2,3,4,1]);
   xedge=reshape(X(edge,1),E,5);
   yedge=reshape(X(edge,2),E,5);
   plot(xedge',yedge','k-',slw,lw); hold on

   if strcmp(mode,'label') % label vertex and element id 
      for i=1:size(X,1);
         plot(X(i,1),X(i,2),'ko');hold on; 
         text(X(i,1),X(i,2),num2str(i));
      end

      xmid = (X(Hexes(:,1),:)+X(Hexes(:,2),:)+X(Hexes(:,3),:)+X(Hexes(:,4),:))/4;
      for i=1:size(xmid,1);
         text(xmid(i,1),xmid(i,2),num2str(i),'Color','b');
      end
   end

function plot_mesh3d(X,Hexes,mode)

   slw = 'LineWidth'; lw = 2;
   E = size(Hexes,1);
   
   % slow version
%   for e=1:E
%      edge=Hexes(e,[1,2,3,4,1]);
%      plot(X(edge,1),X(edge,2),'k-',slw,lw);hold on
%   end

   % fast version

   % face 5
   edge = Hexes(:,[1,2,3,4,1]);

   edge = zeros(E,2,12);
   edge(:,:,1) = Hexes(:,[1,2]);
   edge(:,:,2) = Hexes(:,[2,3]);
   edge(:,:,3) = Hexes(:,[3,4]);
   edge(:,:,4) = Hexes(:,[4,1]);

   edge(:,:,5) = Hexes(:,[5,6]);
   edge(:,:,6) = Hexes(:,[6,7]);
   edge(:,:,7) = Hexes(:,[7,8]);
   edge(:,:,8) = Hexes(:,[8,5]);

   edge(:,:, 9) = Hexes(:,[1,5]);
   edge(:,:,10) = Hexes(:,[2,6]);
   edge(:,:,11) = Hexes(:,[3,7]);
   edge(:,:,12) = Hexes(:,[4,8]);

   xedge=reshape(X(edge,1),E,2,12); 
   yedge=reshape(X(edge,2),E,2,12);
   zedge=reshape(X(edge,3),E,2,12);
   for iedge=1:12
     plot3(xedge(:,:,iedge)',yedge(:,:,iedge)',zedge(:,:,iedge)','k-',slw,lw); hold on
   end
%   if strcmp(mode,'label') % label vertex and element id 
%      for i=1:size(X,1);
%         plot3(X(i,1),X(i,2),X(i,3),'ko');hold on;
%         text(X(i,1),X(i,2),X(i,3),num2str(i));
%      end
%
%      xmid = ( X(Hexes(:,1),:)+X(Hexes(:,2),:)+X(Hexes(:,3),:)+X(Hexes(:,4),:)...
%               X(Hexes(:,5),:)+X(Hexes(:,6),:)+X(Hexes(:,7),:)+X(Hexes(:,8),:) )/8;
%      for i=1:size(xmid,1);
%         text(xmid(i,1),xmid(i,2),xmid(i,3),num2str(i),'Color','b');
%      end
%   end

