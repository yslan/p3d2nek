%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_nek_rea(fname,X,Hexes,CBC,verbose)

t0=tic; 
ext='.out'; fname=[fname ext]; if (verbose>0); fprintf('Dump rea: %s ... ',fname); end

if size(X,2) == 2
  dump_rea_2d(fname,X,Hexes,CBC,verbose);
else
  dump_rea_3d(fname,X,Hexes,CBC,verbose);
end

[osize,otype]=comp_fsize(fname);
if(verbose>0); fprintf(['   done! (%3.1f %s %2.4e sec)\n'],osize,otype,toc(t0)); end


function dump_rea_2d(fname,X,Hexes,CBC,verbose);

   E=size(Hexes,1); lgeom=length(unique(abs(CBC(:)))); 
   assert(lgeom<=100,'Too many BC');
   
   cbc_dmy{1}='W  ';
   for ig=2:lgeom
     cbc_dmy{ig}=['W' sprintf('%02d',ig-1)];
   end
   
   fid=fopen(fname,'w');
   fprintf(fid,'%8i   %8i   %8i NEL NDIM NEL\n',E,2,E);
   for e=1:E;
      fprintf(fid,'            ELEMENT%12i [    1A]    GROUP     0\n',e);
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,1:4),1));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,1:4),2));
   end;
   
   fprintf(fid,' ***** CURVED SIDE DATA ***** \n'); % For sphere
   fprintf(fid,'   %d Curved sides follow \n',0);
   
   fprintf(fid,' ***** BOUNDARY CONDITIONS ***** \n');
   fprintf(fid,' ***** FLUID   BOUNDARY CONDITIONS ***** \n');
   o=0; nbc=zeros(1,lgeom);nbc0=0;nbce=0;
   
   if (E<1E3)
   %    write (11,20) cbc(k,ie),ie,k,(bc(j,k,ie),j=1,5)
   %   20 FORMAT(1x,A3,2I3,5G14.6)
     fmt='%3d%3d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   elseif(E<1E5) 
   %    write (11,21) cbc(k,ie),ie,k,(bc(j,k,ie),j=1,5)
   %   21 FORMAT(1x,A3,i5,i1,5G14.6)
     fmt='%5d%1d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   elseif(E<1E6) 
   %    write (11,22) cbc(k,ie),ie,(bc(j,k,ie),j=1,5)
   %   22 FORMAT(1x,A3,i6,5G14.7)
     fmt='%6d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   else
     warning('Need to add fmt for rE>1M !');
     warning('Need to comsider re2 as well');
     fmt='%12d %17.9e %17.9e %17.9e %17.9e %17.9e\n';
   %    write (11,23) cbc(k,ie),ie,(bc(j,k,ie),j=1,5)
   %   23 FORMAT(1x,A3,i12,5G18.11)
   %  fmt='%5d%1d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   end
   
   for e=1:E 
     for f=1:4
       cbc=CBC(e,f);
       o1=o;o2=o;o3=o;o4=o;
   
       igeom=max(cbc,0);
       if igeom==0
         bcf='E  '; nbc0=nbc0+1;
       elseif (igeom>0 && igeom<=lgeom)
         bcf=cbc_dmy{igeom}; nbc(igeom)=nbc(igeom)+1;
       else
         bcf='v  '; nbce=nbce+1; warning('bc id missing, put inflow %d %d',e,f);
       end
   
       o1=o; o2=o; o3=o; o4=o; o5=o;
   
       if(E<1E5)
         fprintf(fid,[' ' bcf fmt],e,f,o1,o2,o3,o4,o5);
       elseif(E<1E6)
         fprintf(fid,[' ' bcf fmt],e,o1,o2,o3,o4,o5);
       else
         fprintf(fid,[' ' bcf fmt],e,o1,o2,o3,o4,o5);
       end
     end
   end;
   fclose(fid);
   
   if (verbose>1);
      fprintf('\n   #Elements=%d  #Curves=%d  #BCs',E,0);
      fprintf(' %d',[nbc0,nbc,nbce]);fprintf('\n'); 
   end


function dump_rea_3d(fname,X,Hexes,CBC,verbose);
% original dump_nek_mesh5
% TODO fix output following dump_nek_re2  DD3

   E=size(Hexes,1); lgeom=length(unique(abs(CBC(:)))); 
   
   cbc_dmy{1}='W  ';
   for ig=2:lgeom
     cbc_dmy{ig}=['W' sprintf('%02d',ig-1)];
   end
   
   fid=fopen(fname,'w');
   fprintf(fid,'%8i   %8i   %8i NEL NDIM NEL\n',E,3,E);
   for e=1:E;
      fprintf(fid,'            ELEMENT%12i [    1A]    GROUP     0\n',e);
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,1:4),1));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,1:4),2));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,1:4),3));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,5:8),1));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,5:8),2));
      fprintf(fid,'%15.7g  %15.7g  %15.7g  %15.7g\n',X(Hexes(e,5:8),3));
   end;
   
   fprintf(fid,' ***** CURVED SIDE DATA ***** \n'); % For sphere
   fprintf(fid,'   %d Curved sides follow \n',0);
   
   fprintf(fid,' ***** BOUNDARY CONDITIONS ***** \n');
   fprintf(fid,' ***** FLUID   BOUNDARY CONDITIONS ***** \n');
   o=0; nbc=zeros(1,lgeom);nbc0=0;nbce=0;
   
   if (E<1E3)
   %    write (11,20) cbc(k,ie),ie,k,(bc(j,k,ie),j=1,5)
   %   20 FORMAT(1x,A3,2I3,5G14.6)
     fmt='%3d%3d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   elseif(E<1E5) 
   %    write (11,21) cbc(k,ie),ie,k,(bc(j,k,ie),j=1,5)
   %   21 FORMAT(1x,A3,i5,i1,5G14.6)
     fmt='%5d%1d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   elseif(E<1E6) 
   %    write (11,22) cbc(k,ie),ie,(bc(j,k,ie),j=1,5)
   %   22 FORMAT(1x,A3,i6,5G14.7)
     fmt='%6d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   else
     warning('Need to add fmt for rE>1M !');
     warning('Need to comsider re2 as well');
     fmt='%12d %17.9e %17.9e %17.9e %17.9e %17.9e\n';
   %    write (11,23) cbc(k,ie),ie,(bc(j,k,ie),j=1,5)
   %   23 FORMAT(1x,A3,i12,5G18.11)
   %  fmt='%5d%1d %13.5e %13.5e %13.5e %13.5e %13.5e\n';
   end
   
   for e=1:E 
     for f=1:6
       cbc=CBC(e,f);
       o1=o;o2=o;o3=o;o4=o;
   
       igeom=max(cbc,0);
       if igeom==0
         bcf='E  '; nbc0=nbc0+1;
       elseif (igeom>0 && igeom<=lgeom)
         bcf=cbc_dmy{igeom}; nbc(igeom)=nbc(igeom)+1;
       else
         bcf='v  '; nbce=nbce+1; warning('bc id missing, put inflow %d %d',e,f);
       end
   
       o1=o; o2=o; o3=o; o4=o; o5=o;
   
       if(E<1E5)
         fprintf(fid,[' ' bcf fmt],e,f,o1,o2,o3,o4,o5);
       elseif(E<1E6)
         fprintf(fid,[' ' bcf fmt],e,o1,o2,o3,o4,o5);
       else
         fprintf(fid,[' ' bcf fmt],e,o1,o2,o3,o4,o5);
       end
     end
   end;
   fclose(fid);
   
   if (verbose>1);
      fprintf('\n   #Elements=%d  #Curves=%d  #BCs',E,0);
      fprintf(' %d',[nbc0,nbc,nbce]);fprintf('\n');
   end
