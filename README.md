## plot3d2nek

A Matlab script to convert plot3d format to Nek format.       

plot3d is a multi-blocks mesh. Each block is a 2D/3D grid that has the same topology to box mesh. 
The coordinates are stored in `fname.p3d`.
On the top of that, the connectivity between (or within) blocks is defined in `fname.nmf` file. 
The NMF file also includes boundary conditions.


### Usage:

1. Copy the files `<fname>.p3d` and `<fname>.nmf` into the folder `inputs/`.     
   The nmf file is not required. See water-tight section below) 
2. Set the `<fname>` into variable `fname`.     
3. Execute the main driver via MATLAB or Octave.      
   - MATLAB       
     Run `driver.m`
     
   - Octave    
     ```
     octave-cli --persist driver.m
     ```

4. The outputs files will be generated under the folder `outputs/`. 
   - `<fname>.out`: This is the mesh + boundary condition section of the Ascii rea file.
   - `<fname>.con`: This is the Ascii connectivity file. 
   - `<fname>.log`: The stdout from terminal is redirected to this logfile. A previous one is backup to `.log1`

5. Complete rea file    
   One can use the script. For example, this will read `naca0012_f0.out` and generate `naca0012_f0.rea`  
   ```
   cd outputs/;
   ../scripts/mkrea.sh naca0012_f0.out
   ```
  


### Watertight    
Watertightness is not a requirement but it be useful to inspect the meshes and detect potential error before running the simulations.
A complete Neutral Map File (NMF) should give you a water tight mesh with connectivity and also specifying all of the boundary condition.
This code will first try to use the NMF file to setup the connectivity and boundary conditions.

We also have a second pass to patch the connectivity with our own tolerance-based (chosen by the minimum spacing of the elements) method that should fix most of the cases. 

It's also same for boundary conditions. 
First, we fill CBC with the information store in NMF. Then, all of the un-set faces (detected by connectivity) will be assigned a dummy boundary id so user can determine it at a later stage.
      
Our converter is able to generate watertight mesh for all three examples under `inputs/`. 
This can be checked by visualizing the boundary conditions and counting the faces and indices. 

If the code fails to get the correct connectivity, it can still be fixed by Nek5000 (gencon might also have a hard time but I expect gencon will be more robust than my algorithm). The user only have to use their prior knowledge to setup the boundary condition and discard the incorrect .con/.co2 file.


### Notes

| Features | 2D | 3D |
|:---|:---:|:---:|
| Octave | Yes | Yes but slow |
| Second order mesh | Yes (`iforder2=1`) | Not yet |
| Plotting | MATLAB plots | Not yet |
| rea | Yes | Yes not slow |
| re2 | Yes but not tested | Yes but no curved side |

- (Feature): Octave supports
- (Feature): auto-gen logfiles
- (Feature): second order /octave
- (Feature): 3D supported (limited)    
  - plotting is not
- (TODO): multi-block is not tested at all
- (TODO): new version v04 rea and v02 co2
- (TODO): Support quadratic elements (Hex20)    
  2D is ok, 3D is not.  
  chk rea, chk jac, unify new points via `one_to_one`    
- (TODO): save plots into vtk. MATLAB/OCTAVE is slow.
- (TODO): More tests needed.
- (TODO): complete ascii rea file inside `writer_rea.m`
- (TODO): improve connectivity control. 

### References

- [PLOT3D Files](https://turbmodels.larc.nasa.gov/naca0012_grids.html)
- [Neutral Map File](https://turbmodels.larc.nasa.gov/nmf_documentation.html)
- [p3d2gmsh.py](https://github.com/mrklein/p3d2gmsh/blob/master/p3d2gmsh.py)

