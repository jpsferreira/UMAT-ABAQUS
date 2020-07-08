      SUBROUTINE SDVWRITE(DET,STATEV,VV)
C>    VISCOUS DISSIPATION: WRITE STATE VARS
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER VV,POS1,POS2,POS3,I1
      DOUBLE PRECISION STATEV(NSDV),DET
C        write your sdvs here. they should be allocated 
C                after the viscous terms (check hvwrite)
!        POS1=9*VV
!        DO I1=1,NCH
!         POS2=POS1+I1
!         STATEV(POS2)=FRAC(I1)
!        ENDDO
!C
!        DO I1=1,NWP
!          POS3=POS2+I1
!          STATEV(POS3)=RU0(I1)
!        ENDDO
!        STATEV(POS3+1)=DET
!        STATEV(POS3+2)=VARACT 
!        STATEV(POS3+3)=DIRMAX(1)
!        STATEV(POS3+4)=DIRMAX(2)
!        STATEV(POS3+5)=DIRMAX(3)
      RETURN
C
      END SUBROUTINE SDVWRITE
