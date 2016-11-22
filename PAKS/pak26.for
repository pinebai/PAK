C=======================================================================
C
C        GEOMETRIJSKA NELINEARNOST 2/D ELEMENATA
C
C   SUBROUTINE STRUL2
C              BETL12
C              KNL2
C=======================================================================
      SUBROUTINE STRUL2(BLT,NEL,LM,U,X1,STRAIN)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     UKUPNE DEFORMACIJE ZA   U.L.
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /GRADPO/ EL11,EL12,EL13,EL21,EL22,EL23,EL31,EL32,EL33
      DIMENSION BLT(KK,*),NEL(NE,*),LM(*),U(*),STRAIN(*)
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' STRUL2'
C
C....  KOEFICIJENTI L
C
      EL11=0.D0
      EL12=0.D0
      EL21=0.D0
      EL22=0.D0
      EL33=0.D0
C
      JJ=-1
      DO 10 J=1,NCVE
         JJ=JJ+2
         IF(NEL(NLM,J).EQ.0) GO TO 10
         KU1=2*J-1
         KU2=2*J
         AHX=BLT(1,JJ)
         AHY=BLT(3,JJ)
         EL11=EL11+AHX*U(KU1)
         EL12=EL12+AHY*U(KU1)
         EL22=EL22+AHY*U(KU2)
         EL21=EL21+AHX*U(KU2)
         IF(IETYP.NE.1) GO TO 10
         EL33=EL33+BLT(4,JJ)*U(KU1)
   10 CONTINUE
C
C.... DEFORMACIJE UKUPNE
C
      STRAIN(1)=EL11-(EL11*EL11+EL21*EL21)/2.D0
      STRAIN(2)=EL22-(EL12*EL12+EL22*EL22)/2.D0
      STRAIN(3)=EL12+EL21-EL11*EL12-EL21*EL22
      IF(IETYP.NE.1) GO TO 25
      IF(X1.GT.0.00000001) GO TO 20
      STRAIN(4)=STRAIN(1)
      GO TO 25
   20 STRAIN(4)=EL33*(1.D0+EL33/2.D0)
   25 RETURN
      END
C======================================================================
      SUBROUTINE BETL12(BLT,NEL,LM,U,X1,STRAIN,IEPS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     MATRICE BETL1 (BEL1 TRANSPONOVANO ZA T.L.)
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /GRADPO/ EL11,EL12,EL13,EL21,EL22,EL23,EL31,EL32,EL33
      DIMENSION BLT(KK,*),NEL(NE,*),LM(*),U(*),STRAIN(*)
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' BETL12'
C
C.... DEFORMACIJE UKUPNE
C
      IF(IEPS.EQ.1) THEN
         STRAIN(1)=EL11+(EL11*EL11+EL21*EL21)/2.D0
         STRAIN(2)=EL22+(EL12*EL12+EL22*EL22)/2.D0
         STRAIN(3)=EL12+EL21+EL11*EL12+EL21*EL22
         IF(IETYP.NE.1) GO TO 25
         IF(X1.GT.0.00000001) GO TO 20
         STRAIN(4)=STRAIN(1)
         GO TO 25
   20    STRAIN(4)=EL33*(1.D0+EL33/2.D0)
   25    RETURN
      ENDIF
C
C....  KOEFICIJENTI L
C
      EL11=0.D0
      EL12=0.D0
      EL21=0.D0
      EL22=0.D0
      EL33=0.D0
C
      JJ=-1
      DO 10 J=1,NCVE
         JJ=JJ+2
         IF(NEL(NLM,J).EQ.0) GO TO 10
         KU1=2*J-1
         KU2=2*J
         AHX=BLT(1,JJ)
         AHY=BLT(3,JJ)
         EL11=EL11+AHX*U(KU1)
         EL12=EL12+AHY*U(KU1)
         EL22=EL22+AHY*U(KU2)
         EL21=EL21+AHX*U(KU2)
         IF(IETYP.NE.1) GO TO 10
         EL33=EL33+BLT(4,JJ)*U(KU1)
   10 CONTINUE
C
      JJ=-1
      DO 40 I=1,NCVE
         JJ=JJ+2
         J1=JJ+1
         IF(NEL(NLM,I).EQ.0) GO TO 40
         AHX=BLT(1,JJ)
         AHY=BLT(3,JJ)
         BLT(1,JJ)=BLT(1,JJ)+EL11*AHX
         BLT(2,JJ)=EL12*AHY
         BLT(3,JJ)=BLT(3,JJ)+EL11*AHY+EL12*AHX
         BLT(1,J1)=EL21*AHX
         BLT(2,J1)=BLT(2,J1)+EL22*AHY
         BLT(3,J1)=BLT(3,J1)+EL21*AHY+EL22*AHX
         IF(IETYP.NE.1) GO TO 40
         IF(X1.GT.0.00000001) GO TO 30
         BLT(4,JJ)=BLT(1,JJ)
         GO TO 40
   30    BLT(4,JJ)=BLT(4,JJ)*(1.D0+EL33)
   40 CONTINUE
      RETURN
      END
C======================================================================
      SUBROUTINE KNL2(SKE,H,NEL,LM,X1,STRESS,WTU)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     NELINEARNI DEO MATRICE KRUTOSTI
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      DIMENSION SKE(*),H(NCVE,*),NEL(NE,*),LM(*),STRESS(*)
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' KNL2  '
C
      IF(IETYP.EQ.1) X12=X1*X1
      DO 40 I=1,NCVE
         IF(NEL(NLM,I).EQ.0) GO TO 40
         I2=2*I
         I1=I2-1
         AHXI=XJ(1,1)*H(I,2)+XJ(1,2)*H(I,3)
         AHYI=XJ(2,1)*H(I,2)+XJ(2,2)*H(I,3)
         IJ11=(I1-1)*2*NCVE-(I1-1)*I1/2
         IJ22=(I2-1)*2*NCVE-(I2-1)*I2/2
         DO 30 J=I,NCVE
            IF(NEL(NLM,J).EQ.0) GO TO 30
C
            J2=2*J
            J1=J2-1
            AHXJ=XJ(1,1)*H(J,2)+XJ(1,2)*H(J,3)
            AHYJ=XJ(2,1)*H(J,2)+XJ(2,2)*H(J,3)
C
            XX=((AHXI*STRESS(1)+AHYI*STRESS(3))*AHXJ+
     1          (AHXI*STRESS(3)+AHYI*STRESS(2))*AHYJ)*WTU
C
C           IF(LM(I1).EQ.0.OR.LM(J1).EQ.0) GO TO 10
            IJ1=IJ11+J1
            SKE(IJ1)=SKE(IJ1)+XX
            IF(IETYP.EQ.1) SKE(IJ1)=SKE(IJ1)+H(I,1)*H(J,1)/X12*WTU
C
C  10       IF(LM(I2).EQ.0.OR.LM(J2).EQ.0) GO TO 30
            IJ2=IJ22+J2
            SKE(IJ2)=SKE(IJ2)+XX
C
   30    CONTINUE
   40 CONTINUE
      RETURN
      END