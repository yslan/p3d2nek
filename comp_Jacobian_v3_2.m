function JACM3=comp_Jacobian_v3_2(Xl)

persistent ifcalld DD

dim = size(Xl,3); E=size(Xl,1);

if isempty(ifcalld); ifcalld = 1;
  % ordering xmin/xmax ymin/ymax zmin/zmax
  Dh=[-0.5 0.5;-0.5 0.5]; Ih=eye(2);

  if (dim==3)
     Dr=kron(Ih,kron(Ih,Dh));
     Ds=kron(Ih,kron(Dh,Ih));
     Dt=kron(Dh,kron(Ih,Ih));

     DD=[blkdiag(Dr,Dr,Dr);
         blkdiag(Ds,Ds,Ds);
         blkdiag(Dt,Dt,Dt)];
  elseif (dim==2)
     Dr=kron(Ih,Dh);
     Ds=kron(Dh,Ih);
     DD=[blkdiag(Dr,Dr);
         blkdiag(Ds,Ds)];
   end
end;


if (dim==3)
   Xl=Xl(:,[1 2 4 3 5 6 8 7],:); % ordering of coordinates % Ex8x3
   
   Xperm=reshape(permute(Xl,[2,3,1]),24,E,1); % 24xE
   Jac=DD*Xperm;   % Jac: 72 x E
   J1=reshape(Jac,8,9,E);   % J1: 8x9xE
   J2=permute(J1,[2 1 3]);  % J2: 9x8xE
   J3=reshape(J2,9,8*E);
   
   % XR YR ZR   XS YS ZS   XT YT ZT
   %  1  2  3    4  5  6    7  8  9
   % XR XS XT   YR YS YT   ZR ZS ZT
   %  1  4  7    2  5  8    3  6  9
   JACM3=J3(1,:).*J3(5,:).*J3(9,:)... % CALL ADDCOL4 (JACM3,1XRM3,5YSM3,9ZTM3,NTOT3)
        +J3(7,:).*J3(2,:).*J3(6,:)... % CALL ADDCOL4 (JACM3,7XTM3,2YRM3,6ZSM3,NTOT3)
        +J3(4,:).*J3(8,:).*J3(3,:)... % CALL ADDCOL4 (JACM3,4XSM3,8YTM3,3ZRM3,NTOT3)
        -J3(1,:).*J3(8,:).*J3(6,:)... % CALL SUBCOL4 (JACM3,1XRM3,8YTM3,6ZSM3,NTOT3)
        -J3(4,:).*J3(2,:).*J3(9,:)... % CALL SUBCOL4 (JACM3,4XSM3,2YRM3,9ZTM3,NTOT3)
        -J3(7,:).*J3(5,:).*J3(3,:);   % CALL SUBCOL4 (JACM3,7XTM3,5YSM3,3ZRM3,NTOT3)

elseif (dim==2)

   Xl=Xl(:,[1 2 4 3],:); % ordering of coordinates % Ex4x2
   
   Xperm=reshape(permute(Xl,[2,3,1]),8,E,1); % 8xE
   Jac=DD*Xperm;   % Jac: 16 x E
   J1=reshape(Jac,4,4,E);   % J1: 4x4xE
   J2=permute(J1,[2 1 3]);  % J2: 4x4xE
   J3=reshape(J2,4,4*E);
   
   % XR YR   XS YS 
   %  1  2    3  4 
   % XR XS   YR YS
   %  1  3    2  4
   JACM3 = J3(1,:).*J3(4,:)... % CALL ADDCOL3 (JACM3,XRM3,YSM3,NTOT3)
         - J3(3,:).*J3(2,:);   % CALL SUBCOL3 (JACM3,XSM3,YRM3,NTOT3)
end
