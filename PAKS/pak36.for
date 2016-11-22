C=======================================================================
C
C        GEOMETRIJSKA NELINEARNOST 3/D ELEMENATA
C
C   SUBROUTINE STRUL3
C              BETL13
C              KNL3
C=======================================================================
      SUBROUTINE STRUL3(BET,NEL,LM,U,STRAIN)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     UKUPNE DEFORMACIJE ZA   U.L.
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /GRADPO/ EL11,EL12,EL13,EL21,EL22,EL23,EL31,EL32,EL33
C
      DIMENSION BET(6,*),NEL(NE,*),LM(*),U(*),STRAIN(*)
C
C....  KOEFICIJENTI L
C
      EL11=0.D0
      EL12=0.D0
      EL13=0.D0
      EL21=0.D0
      EL22=0.D0
      EL23=0.D0
      EL31=0.D0
      EL32=0.D0
      EL33=0.D0
      JJ=-2
      DO 10 J=1,NCVE
      JJ=JJ+3
      IF(NEL(NLM,J).EQ.0) GO TO 10
      J3=J*3
      KU1=LM(J3-2)
      KU2=LM(J3-1)
      KU3=LM(J3)
      IF(KU1.EQ.0.AND.KU2.EQ.0.AND.KU3.EQ.0) GO TO 10
      AHX=BET(1,JJ)
      AHY=BET(4,JJ)
      AHZ=BET(6,JJ)
      IF(KU1.EQ.0) GO TO 15
      EL11=EL11+AHX*U(J3-2)
      EL12=EL12+AHY*U(J3-2)
      EL13=EL13+AHZ*U(J3-2)
C      EL11=EL11+AHX*U(KU1)
C      EL12=EL12+AHY*U(KU1)
C      EL13=EL13+AHZ*U(KU1)
   15 IF(KU2.EQ.0) GO TO 16
      EL21=EL21+AHX*U(J3-1)
      EL22=EL22+AHY*U(J3-1)
      EL23=EL23+AHZ*U(J3-1)
C      EL21=EL21+AHX*U(KU2)
C      EL22=EL22+AHY*U(KU2)
C      EL23=EL23+AHZ*U(KU2)
   16 IF(KU3.EQ.0) GO TO 10
      EL31=EL31+AHX*U(J3)
      EL32=EL32+AHY*U(J3)
      EL33=EL33+AHZ*U(J3)
C      EL31=EL31+AHX*U(KU3)
C      EL32=EL32+AHY*U(KU3)
C      EL33=EL33+AHZ*U(KU3)
   10 CONTINUE
C
C.... DEFORMACIJE UKUPNE
      STRAIN(1)=EL11-(EL11*EL11+EL21*EL21+EL31*EL31)/2.D0
      STRAIN(2)=EL22-(EL12*EL12+EL22*EL22+EL32*EL32)/2.D0
      STRAIN(3)=EL33-(EL13*EL13+EL23*EL23+EL33*EL33)/2.D0
      STRAIN(4)=EL12+EL21-EL11*EL12-EL21*EL22-EL31*EL32
      STRAIN(5)=EL23+EL32-EL12*EL13-EL22*EL23-EL32*EL33
      STRAIN(6)=EL13+EL31-EL11*EL13-EL21*EL23-EL31*EL33
C
      RETURN
      END
C======================================================================
      SUBROUTINE BETL13(BET,NEL,LM,U,STRAIN,IEPS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     MATRICE BETL1 (BEL1 TRANSPONOVANO ZA T.L.)
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /GRADPO/ EL11,EL12,EL13,EL21,EL22,EL23,EL31,EL32,EL33
C
      DIMENSION BET(6,*),NEL(NE,*),LM(*),U(*),STRAIN(*)
C.... DEFORMACIJE UKUPNE
      IF(IEPS.EQ.1)THEN
        STRAIN(1)=EL11+(EL11*EL11+EL21*EL21+EL31*EL31)/2.D0
        STRAIN(2)=EL22+(EL12*EL12+EL22*EL22+EL32*EL32)/2.D0
        STRAIN(3)=EL33+(EL13*EL13+EL23*EL23+EL33*EL33)/2.D0
        STRAIN(4)=EL12+EL21+EL11*EL12+EL21*EL22+EL31*EL32
        STRAIN(5)=EL23+EL32+EL12*EL13+EL22*EL23+EL32*EL33
        STRAIN(6)=EL13+EL31+EL11*EL13+EL21*EL23+EL31*EL33
C     WRITE(3,*)'STRAIN ',(STRAIN(I),I=1,6)
C
      RETURN
      ENDIF
C
C....  KOEFICIJENTI L
C
      EL11=0.D0
      EL12=0.D0
      EL13=0.D0
      EL21=0.D0
      EL22=0.D0
      EL23=0.D0
      EL31=0.D0
      EL32=0.D0
      EL33=0.D0
      JJ=-2
      DO 10 J=1,NCVE
      JJ=JJ+3
      IF(NEL(NLM,J).EQ.0) GO TO 10
      J3=J*3
      KU1=LM(J3-2)
      KU2=LM(J3-1)
      KU3=LM(J3)
      IF(KU1.EQ.0.AND.KU2.EQ.0.AND.KU3.EQ.0) GO TO 10
      AHX=BET(1,JJ)
      AHY=BET(4,JJ)
      AHZ=BET(6,JJ)
      IF(KU1.EQ.0) GO TO 15
      EL11=EL11+AHX*U(J3-2)
      EL12=EL12+AHY*U(J3-2)
      EL13=EL13+AHZ*U(J3-2)
C      EL11=EL11+AHX*U(KU1)
C      EL12=EL12+AHY*U(KU1)
C      EL13=EL13+AHZ*U(KU1)
   15 IF(KU2.EQ.0) GO TO 16
      EL21=EL21+AHX*U(J3-1)
      EL22=EL22+AHY*U(J3-1)
      EL23=EL23+AHZ*U(J3-1)
C      EL21=EL21+AHX*U(KU2)
C      EL22=EL22+AHY*U(KU2)
C      EL23=EL23+AHZ*U(KU2)
   16 IF(KU3.EQ.0) GO TO 10
      EL31=EL31+AHX*U(J3)
      EL32=EL32+AHY*U(J3)
      EL33=EL33+AHZ*U(J3)
C      EL31=EL31+AHX*U(KU3)
C      EL32=EL32+AHY*U(KU3)
C      EL33=EL33+AHZ*U(KU3)
   10 CONTINUE
C
      JJ=-2
      DO 40 I=1,NCVE
      JJ=JJ+3
      J1=JJ+1
      J2=JJ+2
      IF(NEL(NLM,I).EQ.0) GO TO 40
      AHX=BET(1,JJ)
      AHY=BET(4,JJ)
      AHZ=BET(6,JJ)
C
      BET(1,JJ)=BET(1,JJ)+EL11*AHX
      BET(2,JJ)=EL12*AHY
      BET(3,JJ)=EL13*AHZ
      BET(4,JJ)=BET(4,JJ)+EL11*AHY+EL12*AHX
      BET(5,JJ)=EL12*AHZ+EL13*AHY
      BET(6,JJ)=BET(6,JJ)+EL11*AHZ+EL13*AHX
C
      BET(1,J1)=EL21*AHX
      BET(2,J1)=BET(2,J1)+EL22*AHY
      BET(3,J1)=EL23*AHZ
      BET(4,J1)=BET(4,J1)+EL21*AHY+EL22*AHX
      BET(5,J1)=BET(5,J1)+EL22*AHZ+EL23*AHY
      BET(6,J1)=EL21*AHZ+EL23*AHX
C
      BET(1,J2)=EL31*AHX
      BET(2,J2)=EL32*AHY
      BET(3,J2)=BET(3,J2)+EL33*AHZ
      BET(4,J2)=EL31*AHY+EL32*AHX
      BET(5,J2)=BET(5,J2)+EL32*AHZ+EL33*AHY
      BET(6,J2)=BET(6,J2)+EL31*AHZ+EL33*AHX
C
   40 CONTINUE
      RETURN
      END
C======================================================================
      SUBROUTINE KNL3(SKE,H,NEL,LM,STRESS,WD,NCVE3)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C     NELINEARNI DEO MATRICE KRUTOSTI
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
C
      DIMENSION SKE(*),H(NCVE,*),NEL(NE,*),LM(*),STRESS(*)
C
      DO 40 I=1,NCVE
      IF(NEL(NLM,I).EQ.0)GO TO 40
      I3=3*I
      I2=I3-1
      I1=I3-2
      AHXI=XJ(1,1)*H(I,2)+XJ(1,2)*H(I,3)+XJ(1,3)*H(I,4)
      AHYI=XJ(2,1)*H(I,2)+XJ(2,2)*H(I,3)+XJ(2,3)*H(I,4)
      AHZI=XJ(3,1)*H(I,2)+XJ(3,2)*H(I,3)+XJ(3,3)*H(I,4)
      IJ11=(I1-1)*NCVE3-(I1-1)*I1/2
      IJ22=(I2-1)*NCVE3-(I2-1)*I2/2
      IJ33=(I3-1)*NCVE3-(I3-1)*I3/2
      DO 30 J=I,NCVE
      IF(NEL(NLM,J).EQ.0) GO TO 30
C
      J3=3*J
      J2=J3-1
      J1=J3-2
      AHXJ=XJ(1,1)*H(J,2)+XJ(1,2)*H(J,3)+XJ(1,3)*H(J,4)
      AHYJ=XJ(2,1)*H(J,2)+XJ(2,2)*H(J,3)+XJ(2,3)*H(J,4)
      AHZJ=XJ(3,1)*H(J,2)+XJ(3,2)*H(J,3)+XJ(3,3)*H(J,4)
C
      XX=((AHXI*STRESS(1)+AHYI*STRESS(4)+AHZI*STRESS(6))*AHXJ+
     +    (AHXI*STRESS(4)+AHYI*STRESS(2)+AHZI*STRESS(5))*AHYJ+
     +    (AHXI*STRESS(6)+AHYI*STRESS(5)+AHZI*STRESS(3))*AHZJ)*WD
C
      IF(LM(I1).EQ.0.OR.LM(J1).EQ.0) GO TO 10
      IJ1=IJ11+J1
      SKE(IJ1)=SKE(IJ1)+XX
C
   10 IF(LM(I2).EQ.0.OR.LM(J2).EQ.0) GO TO 20
      IJ2=IJ22+J2
      SKE(IJ2)=SKE(IJ2)+XX
C
   20 IF(LM(I3).EQ.0.OR.LM(J3).EQ.0) GO TO 30
      IJ3=IJ33+J3
      SKE(IJ3)=SKE(IJ3)+XX
C
   30 CONTINUE
   40 CONTINUE
C
      RETURN
      END