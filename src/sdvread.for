      SUBROUTINE SDVREAD(STATEV)
C>    VISCOUS DISSIPATION: READ STATE VARS
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      DOUBLE PRECISION STATEV(NSDV)
C        read your sdvs here. they should be allocated. 
C          after the viscous terms (only if you use viscosity check hvread)
!        POS1=9*VV
!        DO I1=1,NCH
!         POS2=POS1+I1
!         FRAC(I1)=STATEV(POS2)
!        ENDDO
C

C
      RETURN
C
      END SUBROUTINE SDVREAD
