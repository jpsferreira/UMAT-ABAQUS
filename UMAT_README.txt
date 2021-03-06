C********************************************************************
C Record of revisions:                                              |
C        Date        Programmer        Description of change        |
C        ====        ==========        =====================        |
C     14/03/2016    Joao Ferreira      guidelines added             |
C-------------------------------------------------------------------|
---------------------------------------------------------------------
              UMAT - USER-DEFINED MATERIALS IN ABAQUS
---------------------------------------------------------------------
-When none of the existing material models included in the ABAQUS
material library accurately represents the behavior of the material
to be modeled.
-can be used with any abaqus structural element type
-requires proper definition of stress and stress rate in corotational
framework
-allows the description  of dependence on time, temperature, or field
variables
-internal state variables (or their rate form) can be defined to
include the historical dependencies of the material behavior
- follow FORTRAN 77 or C conventions
- all variables must be initialized properly
- also, you can use the abaqus utility routines (amazing :))
       *SINV - first and second invariants of a tensor
       *SPRINC - principal values of a tensor
       *SPRIND - principal values and directions of a tensor
       *ROTSIG - rotate a tensor with an orientation matrix
       *XIT - will terminate an analysis and close all files
                   associated with the analysis properly
- use .inc files to define your parameters (basically, constants);
The PARAMETER assignments yield accurate floating point constant
definitions on any platform.
- verify if your machine precision does not influence the UMAT outputs;
use IMPLICIT NONE to make sure all variables are correctly declared
- if you use multiple cpus in your analysis dont try to access files
inside the UMAT; use UEXTERNALDB for that purpose;
---------------------------------------------------------------------
           MAKE SURE ABAQUS CAN READ YOUR CODE PROPERLY
---------------------------------------------------------------------
                **********************************
                           .INP file
                **********************************
*USER MATERIAL, CONSTANTS=NPROPS
<PROPS(NPROPS) list>
*DEPVAR
NSTATEV,
*USER DEFINED FIELD (if USDFLD is used)
...
*ELEMENT OUTPUT, elset=...
 SDV
 ∗EL PRINT, ∗EL FILE, and *ELEMENT OUTPUT options
 FV (if USDFLD is used)
                **********************************
                        .FORTRAN. COMPILER
                **********************************
intel fortran composer XE; or gfortran
edit the abaqus .env file to activate the compilation options
(natively or on the job path)
                **********************************
                        ABAQUS COMMANDS
                **********************************
abaqus job=job.inp user=umat.for cpus=NCPUS -interactive

                **********************************

---------------------------------------------------------------------
                 VARIABLES PASSED IN FOR INFORMATION
---------------------------------------------------------------------
NTENS - total stress components
         NTENS=NDI+NSHR
NDI - direct stress components
NSHR - shear stress components
NSTATEV - number of state variables
NPROPS - number of material properties
STRAN(NTENS) - total strains array; rotate before UMAT is called;
aproximations to log strain in finite-strain problems
DSTRAN(NTENS) - strain increments array; total strain increments
without thermal effects
TIME(1) - step time at the beginning of the current increment
TIME(2) - total time at the beginning of the current increment
TEMP,DTEMP - temperature and increment of temperature
PREDEF - array of predefined field variables GP, interpolated by
nodal values
DPRED - increments of PREDEF
CMNAME - user-defined material name: 'ABQ-[..]'
PROPS(NPROPS) - material constants of user-specified array
COORDS - coordinates of GP; current coordinates for geometric
non-linearities
DROT(3,3) - rotation increment matrix; provided vectors and tensor
valued state variables ca be rotated properly
CELENT - characteristic element length
DFGRD0(3,3) - deformation gradient at the beginning of the increment
DFGRD1(3,3) - deformation gradient at the end of the increment
NOEL - element number
NPT - integration point number
KSPT - sections point number in the current layer
KSTEP - step number
KINC - increment number
LAYER - composite layer number
---------------------------------------------------------------------
                     VARIABLES TO BE DEFINED
---------------------------------------------------------------------
STRESS(NTENS) - stress tensor to update during UMAT; previous stress
tensor is rotated before UMAT is called; only the corrotational part
of the stress should be done; 'true' cauchy stress;
DDSDDE(NTENS,NTENS)
STATEV(NSTATEV)
SSE - specific elastic strain energy; to updated during UMAT;used for
energy outputs only
SPE - plastic dissipation energy; to updated during UMAT;used for
energy outputs only
SLD - creep dissipation energy; to updated during UMAT;used for
energy outputs only
RPL,DDSDDT,DRPLDE,DRPLDT - for coupled thermal-stress analysis
---------------------------------------------------------------------
                     VARIABLES THAT MAY BE DEFINED
---------------------------------------------------------------------
PNEWDT - ratio off suggested new time increment to the time increment
being used DTIME
---------------------------------------------------------------------
            'MY UMAT DOENST WORK AND I DON'T KNOW WHY' :(
---------------------------------------------------------------------
- sorry, you can't avoid the exhausting try and error procedure, but
don't worry, I'll try to expose all the major drawbacks regarding the
UMAT implementation and give guidelines for your bugs
- read the abaqus documentation before starting. You'll find it helpful!
- Understand the role of your UMAT in the balance equation. In some
materials the balance equation is preferably written in the rate form,
which influence the way you define your DDSDDE.
- DDSDDE is used in the Newton-Raphson incremental solution
 to solve the FE equilibrium and is often called as the consistent
 tangent matrix
- If you use STRAN or DSTRAN in your UMAT look at the strain measures
recommended by abaqus for each element type
- The UMAT can't be used for all element structural element types.
Distinguish between shell, plane stress, 3D, or thermal analysis.
Coupled multi-field problems are usually coded using UEL.
- start with a simple material behavior and verify if it's working.
Then, add a new complexity, verify again.
After, add that fancy material feature, but don't forget, you need to
verify the results again. And then consider that...
well, you got the idea...Basically, the routine should be  written
in incremental form, which allows generalization to more complex
dependences of  the material behavior. Whenever a “new” feature is added
to the model in a user subroutine, test it before adding an additional
feature.
- debug by printing to the fortran(if multiple cpus the prints replicate!)
    * write(*,*) print to terminal
    * write(6,*) print to .dat file
    * write(7,*) print to .msg file
    * other option: open a channel not linking with ABAQUS
and write to a external text file
---------------------------------------------------------------------
                VERIFY IF YOUR CODE WORKS (TRICKY PART)
---------------------------------------------------------------------
                   **********************************
                   Integration (material) point level
                   **********************************
- as a first approach to the verification procedure, you should test
your code making a comparison with an analytical solution
- for a given deformation gradient at an arbitrary material point,
verify if the code outputs the same STRESS and DDSDDE of the analytical
solution (use Maple or Mathematica to compute the analytical solution)
- change the deformation gradient to include several possible cases:
volumetric changes, uniaxial, biaxial, finite shear, ...
- usually, the imcompressibility constraint in the analytical solution
is assumed. however, in the numerical schemes this contraint is often
imposed  using  lagrange multipliers or the penalty method. make sure
both solutions (analytical and numerical) arise from the same deformation
state.
                   **********************************
                              Element level
                   **********************************
- if the above verification is successful, use the UMAT with a small
(one element only) input file.
- run tests with all displacements prescribed to verify the integration
algorithm for stresses and state variables: uniaxial, uniaxial in oblique
direction, uniaxial with finite rotation, finite shear...
- after, run similar tests with prescribed loads to very the accuracy of
the material jacobian (convergence rates)
- at this level, you can still compare with analytical solutions or with standard
abaqus material models
                   **********************************
                              Model level
                   **********************************
- once again, if the above verifications were successful, apply to more
complicated problems. Preferentially, run examples available in the
literature. After that, run your own problems and, finally, publish it! :)
---------------------------------------------------------------------
                     SOME IMPORTANT TIPS...
---------------------------------------------------------------------
- take a pencil or use a symbolic programming software (maple or mathematica)
to write/deduce the necessary mathematical expressions; find a way to compute
explicitly all the necessary variables;
- use the programming tools of FORTRAN77 or C to compute the variables; some
compilers can read more advanced functions, like those available in FORTRAN95
and C++, to build the object file (.o)
- If the *ORIENTATION option is used in conjunction with UMAT,
stress and strain components will be in the local material system. If the
 *orientation is not used there is no rotations of the physical quantities.
 As a result both solutions can be compared only in the principal axis system.
- The characteristic element length can be used to define softening behavior
- UMAT is called twice for the first iteration of each increment:
once for assembly and once for recovery. After, is called just once.
- If user subroutines call other subroutines or use COMMON blocks to pass
information, such subroutines or COMMON blocks should begin with the letter
K since this letter is never used to start the name of any subroutine or COMMON
block in ABAQUS
- It is the user’s responsibility to calculate the evolution of the SDVs within
 the subroutine; ABAQUS just stores the variables for the user subroutine.
- UEXTERNALDB - can be called at the beginning of the analysis and at the end
of each increment. This routine read external databases of information.
this information is allocated in common blocks that can be used inside the UMAT
- USDFLD - called at the end of each increment.
The values defined by USDFLD are not stored by ABAQUS, they should be
allocated in SDVs or in COMMON blocks. The values are captured using GETVRM
- GETVRM - The variables provided to GETVRM are the output variable key,VAR,
for the desired solution data, and JMAC, JMATYP, MATLAYO, LACCFLA
