warning off;clear all; close all; format compact; profile off; diary off; restoredefaultpath;warning on;
pause(.1);hdr;

% In this script, it reads a 2D plot3D mesh with both .p3d and .nmf file.
% The output will ne Nek's .rea file and .con file

%% Controls
%fname = 'naca0012_f0';
fname = 'naca0012';
%fname = 'naca0012_sharp';
verbose = 2; % 0=minimal, 1=default, 2=everything
ifplot = 2;  % 0=no plot, 1=plot mesh, 2=plot mesh + BC
ifco2 = 0;   % 0=ascii .con file, 1=binary .co2 file


gen_logfile(fname,1);

%% Step 1: read files
disp_step(1,'Read files');
% files are stored under the directory: input/
fdri= 'inputs'; ext1 = '.p3d'; ext2 = '.nmf';
dat_p3d = read_dat_p3d([fdri '/' fname ext1], verbose);
dat_nmf = read_dat_nmf([fdri '/' fname ext2], verbose);


%% Step 2: generate mesh block-by-block
disp_step(2,'Generate mesh');
% X: (npts,dim), Hexes: (E, 2^dim)
[X, Hexes, iHtoiB] = gen_mesh(dat_p3d, verbose);


%% Step 3: generate connectivity
disp_step(3,'Generate connectivity');
% chk if .nmf matches .p3d
[dim, ierr_nmf] = chk_input(dat_p3d, dat_nmf); % mainly checking nmf

% First pass: nmf should give a water-tight mesh
status1=-1;
if ierr_nmf==0
   [Hexes, status1]  = gen_con_from_nmf(Hexes, iHtoiB, dat_nmf, verbose);
end
[X, Hexes] = remove_unused_X(X, Hexes, verbose);

% Second pass: gencon with uniquetol
mesh_quality = chk_hex_metric(X, Hexes, '', 0);
X0=X; Hexes0=Hexes; tol=0.1*mesh_quality.dxmin(1);
[X, Hexes, status2]=unique_Vpts_v2(X, Hexes, tol, verbose);

con_source_s=''; con_source_i=0;
if (status1>=0); con_source_s=[con_source_s 'NMF '];    con_source_i=con_source_i+1; end 
if (status2>0);  con_source_s=[con_source_s 'UniqTol']; con_source_i=con_source_i+2; end 
if (isempty(con_source_s)); con_source_s='none'; end


%% Step 4: boundary conditions
disp_step(4,'Generate boundary conditions');
nface = 2*dim; E = size(Hexes,1);
CBC = zeros(E,nface); BC_map=cell(0);

% first fill CBC based on the info from nmf
if (ierr_nmf==0)
   [CBC, BC_map, status3] = fill_CBC_from_nmf(CBC, dat_nmf, verbose);
end
nBCid = length(BC_map);

if (con_source_i>0); % meshing connectivity is established.
   % water tight mesh has connectivity
   con_table=connect_hex(Hexes);

   % fill the rest with dummy BC 
   [CBC, BC_map] = fill_dummy_BC(CBC, con_table, BC_map, verbose);
end


%% DUMP Nek file(s)
disp_step(5,'Dump output');
fdro = 'outputs'; fout=[fdro '/' fname];
dump_nek_rea(fout,X,Hexes,CBC,verbose); 
dump_nek_con(fout,Hexes,ifco2,verbose);


%% Summary
disp_step(5,'Summary');

% plotting
if(ifplot>0); ifig=1;plot_mesh(ifig,X,Hexes); end           % mesh
if(ifplot>1); ifig=2;plot_CBC(ifig,X,Hexes,CBC,BC_map); end % mesh + CBC

% print mesh metrics
mesh_quality = chk_hex_metric(X,Hexes,'',verbose);
print_BC_map(CBC,BC_map,verbose);


%% Ending 
fprintf(['Time: ' char(datetime('now','Format','HH:mm:ss MMM/dd/yyyy')) '\n']);
disp_step(100,'End');
fprintf('FINISH, reaching EOF\n');
diary off
