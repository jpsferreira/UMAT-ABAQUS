      SUBROUTINE ONEM(A,AA,AAS,NDI)
C
C>      THIS SUBROUTINE GIVES:
C>          2ND ORDER IDENTITY TENSORS - A
C>          4TH ORDER IDENTITY TENSOR - AA
C>          4TH ORDER SYMMETRIC IDENTITY TENSOR - AAS
C
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER I,J,K,L,NDI
C
      DOUBLE PRECISION A(NDI,NDI),AA(NDI,NDI,NDI,NDI),
     1                 AAS(NDI,NDI,NDI,NDI)
C
      DO I=1,NDI
         DO J=1,NDI
            IF (I .EQ. J) THEN
              A(I,J) = ONE
            ELSE
              A(I,J) = ZERO
            END IF
         END DO
      END DO
C
      DO I=1,NDI
         DO J=1,NDI
          DO K=1,NDI
             DO L=1,NDI
              AA(I,J,K,L)=A(I,K)*A(J,L)
              AAS(I,J,K,L)=(ONE/TWO)*(A(I,K)*A(J,L)+A(I,L)*A(J,K))
           END DO
          END DO
        END DO
      END DO
C
      RETURN
      END SUBROUTINE ONEM
