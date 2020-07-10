UMAT-ABAQUS | A general framework to develop material models (UMAT) in ABAQUS (Dassault Systèmes)

# Brief description

This library provides subroutines for 3D implementation of large deformation constitutive behavior using continuum mechanics. The code is written in either fixed-form or modern Fortran. You can use it as a primary subroutine interface for ABAQUS (Dassault Systèmes) as a UMAT or an interface for your finite element code. I have used this code to model many specific material laws of biological soft tissues and cells. Take a look at the reference list. 

You are highly welcome to use these open-resource codes for your non-commercial usage; please cite the below papers.

## Subroutine interface

The core routines for the subroutine interface are:

```Fortran

!main program - subroutines caller

program main


!uexternaldb subroutine - read databases of microstructure 
!            information, passes in as common data blocks

      SUBROUTINE UEXTERNALDB(LOP,LRESTART,TIME,DTIME,KSTEP,KINC)


!main subroutine - calculates stress and material tangent

      SUBROUTINE UMAT(STRESS,STATEV,DDSDDE,SSE,SPD,SCD,
     1 RPL,DDSDDT,DRPLDE,DRPLDT,
     2 STRAN,DSTRAN,TIME,DTIME,TEMP,DTEMP,PREDEF,DPRED,CMNAME,
     3 NDI,NSHR,NTENS,NSTATEV,PROPS,NPROPS,COORDS,DROT,PNEWDT,
     4 CELENT,DFGRD0,DFGRD1,NOEL,NPT,LAYER,KSPT,KSTEP,KINC)


`"
# Examples

This library does not run any specific example. See my other repositories for more models. 

3 directories:
*src - files to build UMAT
*sym - examples of analytical derivations of the constitutive relations
*test_in_abaqus - example to test the UMAT file in abaqus environment


# Compiling

Simple bash scripts are provided for building UMAT-ABAQUS with gfortran. The code can also be compiled with the Intel Fortran Compiler (and presumably any other Fortran compiler that supports modern standards).

- ```build.sh``` - compiles the program
- ```run_code.sh``` simple input-output test for an arbitrary deformation gradient
- ```cat_umat_files.sh``` since you can interact with abaqus using only one fortran file, this script concatenates fortran files into one umat file.

# Documentation

[jpsferreira.github.io/UMAT-ABAQUS/](https://jpsferreira.github.io/UMAT-ABAQUS/)

### Authors:
  * João P S Ferreira 
  
### Release:
  * 2020/09/07.

### License:
  * GNU GPL 3.0.  


# References

J P S Ferreira et al. "On the mechanical response of the actomyosin cortex during cell indentations". English. In: Biomechanics and Modeling in Mechanobiology 130.10 (Apr. 2020), pp. 202–19. doi: [(10.1007/s10237-020-01324-5)](https://link.springer.com/article/10.1007%2Fs10237-020-01324-5).

J P S Ferreira et al. "Altered mechanics of vaginal smooth muscle cells due to the lysyl oxidase-like1 knockout." English. In: Acta Biomaterialia (Apr. 2020). doi: [(10.1016/j.actbio.2020.03.046)](https://doi.org/10.1016/j.actbio.2020.03.046).

J A López-Campos et al. "Characterization of hyperelastic and damage behavior of tendons." English. In: Computer Methods in Biomechanics and Biomedical Engineering 81.2 (Jan. 2020), pp. 1–11. doi: [(10.1080/10255842.2019.1710742)](https://doi.org/10.1080/10255842.2019.1710742).

M C P Vila Pouca et al. "Viscous effects in pelvic floor muscles during childbirth: A numerical study." English. In: International Journal for Numerical Methods in Biomedical Engineering 34.3 (Mar. 2018), e2927. doi: [(10.1002/cnm.2927)](https://doi.org/10.1002/cnm.2927). 

J P S Ferreira, M P L Parente, and R M Natal Jorge. "Continuum mechanical model for cross-linked actin networks with contractile bundles". English. In: Journal of the Mechanics and Physics of Solids (2017). doi: [(10.1016/j.jmps.2017.09.009)](https://doi.org/10.1016/j.jmps.2017.09.009).

J P S Ferreira et al. "A general framework for the numerical implementation of anisotropic hyperelastic material models including non-local damage". In: Biomechanics and Modeling in Mechanobiology 44.18–19 (2017), pp. 5894–1140. doi: [(10.1007/s10237-017- 0875-9)](https://link.springer.com/article/10.1007/s10237-017-0875-9).