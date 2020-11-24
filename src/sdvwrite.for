      SUBROUTINE SDVWRITE(DET,LAMBDA,STATEV)
C>    VISCOUS DISSIPATION: WRITE STATE VARS
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      DOUBLE PRECISION STATEV(NSDV),DET,LAMBDA
C        write your sdvs here. they should be allocated 
C                after the viscous terms (check hvwrite)
       STATEV(1)=DET
       STATEV(2)=LAMBDA 

      RETURN
C
      END SUBROUTINE SDVWRITE
