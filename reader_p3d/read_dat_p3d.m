function dat = read_dat_p3d(fname, verbose);

if (verbose>=1); fprintf('Reading %s ... ',fname); end; t0=tic;

fid = fopen(fname,'r');

% header
tline = fgets(fid); vec=sscanf(tline,'%d');
if (length(vec)==1); % if having block structure
  nblock = vec(1);
  tline = fgets(fid);
else % if only 1 block, it can ignore nblock line
  nblock = 1;
end

% read dim of block(s)
idims = zeros(nblock,1);
jdims = zeros(nblock,1);
kdims = zeros(nblock,1);
if3d = 0;
for i=1:nblock
  if i>1; tline = fgets(fid); end
  vec=sscanf(tline,'%d'); nv=length(vec); assert(nv>=2 && nv<=3,'error reading bock size');

  idims(i) = vec(1); 
  jdims(i) = vec(2); 
  kdims(i) = 1; if (nv==3 && vec(3)>1); kdims(i) = vec(3); if3d = 1; end
end
dim=2; if(if3d); dim=3; end

% read coordinates
coord = {};
for i=1:nblock; idim = idims(i); jdim = jdims(i); kdim = kdims(i);
   x = fscanf(fid,'%f',[idim*jdim*kdim]); x = reshape(x,[idim,jdim,kdim]);
   y = fscanf(fid,'%f',[idim*jdim*kdim]); y = reshape(y,[idim,jdim,kdim]);
   z = fscanf(fid,'%f',[idim*jdim*kdim]); z = reshape(z,[idim,jdim,kdim]);

   coord(i).x = x;
   coord(i).y = y;
   coord(i).z = z;
end

fclose(fid);

% pack output
dat=[];
dat.nblock= nblock;
dat.dim   = dim;
dat.idims = idims;
dat.jdims = jdims;
dat.kdims = kdims;
dat.coord = coord;

% summary
if (verbose==2)
  fprintf('\n');
  fprintf('   nblock   = %d \n',nblock);
  fprintf('   dim      = %d \n',dim);
  fprintf('   total pt = %d \n',sum(idims.*jdims.*kdims));
end
if (verbose>=1)
  [osize,otype]=comp_fsize(fname);
  fprintf('   done! (%3.1f %s %2.4e sec)\n',osize,otype,toc(t0));
end
