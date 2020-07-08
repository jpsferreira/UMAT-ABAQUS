      SUBROUTINE FSLIP(F,FBAR,DET,NDI)
C>     DISTORTION GRADIENT
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER NDI,I1,J1
      DOUBLE PRECISION F(NDI,NDI),FBAR(NDI,NDI)
      DOUBLE PRECISION DET,SCALE1
C     
C     JACOBIAN DETERMINANT
      DET = F(1,1) * F(2,2) * F(3,3)
     1    - F(1,2) * F(2,1) * F(3,3)
C
      IF (NDI .EQ. 3) THEN
          DET = DET + F(1,2) * F(2,3) * F(3,1)
     1              + F(1,3) * F(3,2) * F(2,1)
     2              - F(1,3) * F(3,1) * F(2,2)
     3              - F(2,3) * F(3,2) * F(1,1)
      END IF 
C
      SCALE1=DET**(-ONE /THREE)
C      
      DO I1=1,NDI
        DO J1=1,NDI
          FBAR(I1,J1)=SCALE1*F(I1,J1)
        END DO
      END DO
C
      RETURN      
      END SUBROUTINE FSLIP
