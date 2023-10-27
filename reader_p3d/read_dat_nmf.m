function dat = read_dat_nmf(fname, verbose);

if (verbose>=1); fprintf('Reading %s ... ',fname); end; t0=tic;

fid = fopen(fname,'r'); 
if (fid==-1); 
   fprintf('   Abort! file not found\n');
   dat=[];dat.dim=0;
   return
end

% nblock
tline = skip_comments(fid); 
vec=sscanf(tline,'%d'); nv=length(vec); assert(nv==1,'error reading nbock');
nblock = vec(1);

% read dim of block(s)
idims = zeros(nblock,1);
jdims = zeros(nblock,1);
kdims = zeros(nblock,1);
if3d = 0;
for i=1:nblock
  tline = skip_comments(fid);
  vec=sscanf(tline,'%d'); nv=length(vec); assert(nv==4,['error reading bock ' num2str(i) ' size']);

  idims(i) = vec(2);
  jdims(i) = vec(3);
  kdims(i) = vec(4); if (vec(4)>1); if3d = 1; end
end
dim=2; if(if3d); dim=3; end

% read connectivity / boundary condition
isok = 0;
tline = skip_comments(fid); if tline==-1; isok=1; end
BC={};ibc=0;
while isok==0; ibc=ibc+1;
  
  % bc type
  bctype = sscanf(tline,'%[a-zA-Z_-]'); nt=length(bctype);
  tline0 = tline; tline = tline(nt+1:end);

  % bc loc and connection
  nd = 6; if strcmp(bctype,'ONE_TO_ONE'); nd = 12; end
  bc_info = zeros(1,nd); 
  [vec,~,~,id] = sscanf(tline,'%d'); nv=length(vec);
  assert(nv==nd,['error reading BC from ' num2str(ibc) '-th line:' tline0])
  bc_info(:)=vec(:);

  % swap (T/F/None)
  tline=tline(id:end); stmp = strtrim(sscanf(tline,'%c'));
  swap = '';
  if (strcmp(stmp,'TRUE')) swap = 'T'; end
  if (strcmp(stmp,'FALSE')) swap = 'F'; end
  
  BC(ibc).type = bctype;
  BC(ibc).vec  = bc_info;
  BC(ibc).swap = swap;

  tline = skip_comments(fid); if tline==-1; isok=1; end;
end; nbc = ibc;

% pack data
dat=[];
dat.nblock = nblock;
dat.dim = dim;
dat.idims = idims;
dat.jdims = jdims;
dat.kdims = kdims;
dat.nbc = nbc;
dat.BC = BC;


% summary
if (verbose==2)
  fprintf('\n');
  fprintf('   nblock   = %d \n',nblock);
  fprintf('   dim      = %d \n',dim);
  fprintf('   nbc      = %d \n',nbc);
end
if (verbose>=1)
  [osize,otype]=comp_fsize(fname);
  fprintf('   done! (%3.1f %s %2.4e sec)\n',osize,otype,toc(t0));
end


function tline = skip_comments(fid);
% ignore lines startwith # or empty line

tline = fgets(fid); if (tline==-1); return; end

isok = 0;
while isok==0
  if strcmp(tline(1),'#') || sum(isspace(tline))==length(tline) || strcmp(tline(1),newline)
    tline = fgets(fid);
  else 
    isok = 1;
  end
end

