      SUBROUTINE SPECTRAL(A,D,V)
C>    EIGENVALUES AND EIGENVECTOR OF A 3X3 MATRIX
C     THIS SUBROUTINE CALCULATES THE EIGENVALUES AND EIGENVECTORS OF
C     A SYMMETRIC 3X3 MATRIX A.
C
C     THE OUTPUT CONSISTS OF A VECTOR D CONTAINING THE THREE
C     EIGENVALUES IN ASCENDING ORDER, AND A MATRIX V WHOSE
C     COLUMNS CONTAIN THE CORRESPONDING EIGENVECTORS.
C
      IMPLICIT NONE
C
      INTEGER NP,NROT
      PARAMETER(NP=3)
C
      DOUBLE PRECISION D(3),V(3,3),A(3,3),E(3,3)
C
      E = A
C
      CALL JACOBI(E,3,NP,D,V,NROT)
      CALL EIGSRT(D,V,3,NP)
C
      RETURN
      END SUBROUTINE SPECTRAL

C***********************************************************************

      SUBROUTINE JACOBI(A,N,NP,D,V,NROT)
C
C COMPUTES ALL EIGENVALUES AND EIGENVECTORS OF A REAL SYMMETRIC
C  MATRIX A, WHICH IS OF SIZE N BY N, STORED IN A PHYSICAL
C  NP BY NP ARRAY.  ON OUTPUT, ELEMENTS OF A ABOVE THE DIAGONAL
C  ARE DESTROYED, BUT THE DIAGONAL AND SUB-DIAGONAL ARE UNCHANGED
C  AND GIVE FULL INFORMATION ABOUT THE ORIGINAL SYMMETRIC MATRIX.
C  VECTOR D RETURNS THE EIGENVALUES OF A IN ITS FIRST N ELEMENTS.
C  V IS A MATRIX WITH THE SAME LOGICAL AND PHYSICAL DIMENSIONS AS
C  A WHOSE COLUMNS CONTAIN, UPON OUTPUT, THE NORMALIZED
C  EIGENVECTORS OF A.  NROT RETURNS THE NUMBER OF JACOBI ROTATION
C  WHICH WERE REQUIRED.
C
C THIS SUBROUTINE IS TAKEN FROM 'NUMERICAL RECIPES.'
C
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER IP,IQ,N,NMAX,NP,NROT,I,J
      PARAMETER (NMAX=100)
C
      DOUBLE PRECISION A(NP,NP),D(NP),V(NP,NP),B(NMAX),Z(NMAX),
     +  SM,TRESH,G,T,H,THETA,S,C,TAU


C INITIALIZE V TO THE IDENTITY MATRIX
      DO I=1,3
          V(I,I)=ONE
        DO J=1,3
          IF (I.NE.J)THEN
           V(I,J)=ZERO
         ENDIF
       END DO
      END DO
C INITIALIZE B AND D TO THE DIAGONAL OF A, AND Z TO ZERO.
C  THE VECTOR Z WILL ACCUMULATE TERMS OF THE FORM T*A_PQ AS
C  IN EQUATION (11.1.14)
C
      DO IP = 1,N
        B(IP) = A(IP,IP)
        D(IP) = B(IP)
        Z(IP) = 0.D0
      END DO


C BEGIN ITERATION
C
      NROT = 0
      DO I=1,50
C
C         SUM OFF-DIAGONAL ELEMENTS
C
          SM = 0.D0
          DO IP=1,N-1
            DO IQ=IP+1,N
              SM = SM + DABS(A(IP,IQ))
            END DO
          END DO
C
C          IF SM = 0., THEN RETURN.  THIS IS THE NORMAL RETURN,
C          WHICH RELIES ON QUADRATIC CONVERGENCE TO MACHINE
C          UNDERFLOW.
C
          IF (SM.EQ.0.D0) RETURN
C
C          IN THE FIRST THREE SWEEPS CARRY OUT THE PQ ROTATION ONLY IF
C           |A_PQ| > TRESH, WHERE TRESH IS SOME THRESHOLD VALUE,
C           SEE EQUATION (11.1.25).  THEREAFTER TRESH = 0.
C
          IF (I.LT.4) THEN
            TRESH = 0.2D0*SM/N**2
          ELSE
            TRESH = 0.D0
          END IF
C
          DO IP=1,N-1
            DO IQ=IP+1,N
              G = 100.D0*DABS(A(IP,IQ))
C
C              AFTER FOUR SWEEPS, SKIP THE ROTATION IF THE
C               OFF-DIAGONAL ELEMENT IS SMALL.
C
              IF ((I.GT.4).AND.(DABS(D(IP))+G.EQ.DABS(D(IP)))
     +            .AND.(DABS(D(IQ))+G.EQ.DABS(D(IQ)))) THEN
                A(IP,IQ) = 0.D0
              ELSE IF (DABS(A(IP,IQ)).GT.TRESH) THEN
                H = D(IQ) - D(IP)
                IF (DABS(H)+G.EQ.DABS(H)) THEN
C
C                  T = 1./(2.*THETA), EQUATION (11.1.10)
C
                  T =A(IP,IQ)/H
                ELSE
                  THETA = 0.5D0*H/A(IP,IQ)
                  T =1.D0/(DABS(THETA)+DSQRT(1.D0+THETA**2.D0))
                  IF (THETA.LT.0.D0) T = -T
                END IF
                C = 1.D0/DSQRT(1.D0 + T**2.D0)
                S = T*C
                TAU = S/(1.D0 + C)
                H = T*A(IP,IQ)
                Z(IP) = Z(IP) - H
                Z(IQ) = Z(IQ) + H
                D(IP) = D(IP) - H
                D(IQ) = D(IQ) + H
                A(IP,IQ) = 0.D0
C
C               CASE OF ROTATIONS 1 <= J < P
C
                DO J=1,IP-1
                  G = A(J,IP)
                  H = A(J,IQ)
                  A(J,IP) = G - S*(H + G*TAU)
                  A(J,IQ) = H + S*(G - H*TAU)
                END DO
C
C                CASE OF ROTATIONS P < J < Q
C
                DO J=IP+1,IQ-1
                  G = A(IP,J)
                  H = A(J,IQ)
                  A(IP,J) = G - S*(H + G*TAU)
                  A(J,IQ) = H + S*(G - H*TAU)
                END DO
C
C                 CASE OF ROTATIONS Q < J <= N
C
                DO J=IQ+1,N
                  G = A(IP,J)
                  H = A(IQ,J)
                  A(IP,J) = G - S*(H + G*TAU)
                  A(IQ,J) = H + S*(G - H*TAU)
                END DO
                DO J = 1,N
                  G = V(J,IP)
                  H = V(J,IQ)
                  V(J,IP) = G - S*(H + G*TAU)
                  V(J,IQ) = H + S*(G - H*TAU)
                END DO
                NROT = NROT + 1
             END IF
               END DO
             END DO
C
C          UPDATE D WITH THE SUM OF T*A_PQ, AND REINITIALIZE Z
C
       DO IP=1,N
         B(IP) = B(IP) + Z(IP)
         D(IP) = B(IP)
         Z(IP) = 0.D0
       END DO
      END DO
C
C IF THE ALGORITHM HAS REACHED THIS STAGE, THEN THERE
C  ARE TOO MANY SWEEPS.  PRINT A DIAGNOSTIC AND CUT THE
C  TIME INCREMENT.
C
      WRITE (*,'(/1X,A/)') '50 ITERATIONS IN JACOBI SHOULD NEVER HAPPEN'
C
      RETURN
      END SUBROUTINE JACOBI

C**********************************************************************
      SUBROUTINE EIGSRT(D,V,N,NP)
C
C     GIVEN THE EIGENVALUES D AND EIGENVECTORS V AS OUTPUT FROM
C     JACOBI, THIS SUBROUTINE SORTS THE EIGENVALUES INTO ASCENDING
C     ORDER AND REARRANGES THE COLMNS OF V ACCORDINGLY.
C
C     THE SUBROUTINE WAS TAKEN FROM 'NUMERICAL RECIPES.'
C
      IMPLICIT NONE
C
      INTEGER N,NP,I,J,K
C
      DOUBLE PRECISION D(NP),V(NP,NP),P
C
      DO I=1,N-1
              K = I
              P = D(I)
              DO J=I+1,N
               IF (D(J).GE.P) THEN
                K = J
                P = D(J)
               END IF
              END DO
              IF (K.NE.I) THEN
               D(K) = D(I)
               D(I) = P
               DO J=1,N
                P = V(J,I)
                V(J,I) = V(J,K)
                V(J,K) = P
               END DO
              END IF
      END DO
C
      RETURN
      END SUBROUTINE EIGSRT
