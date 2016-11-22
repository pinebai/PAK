C=======================================================================
C
C   BIOLOGICAL STRESS-STRETCH MODEL FOR ACTIVE STATE
C
C=======================================================================
C
C
C    SUBROUTINE D8M34
C               TI834
C
      SUBROUTINE D8M34(TAU,DEF,IRAC,LPOCG,LPOC1)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
CE  SPACE IN WORKING VECTOR 
C
      include 'paka.inc'
      
C
      COMMON /REPERM/ MREPER(4)
      COMMON /DUPLAP/ IDVA
C
      LFUN=MREPER(1)
C      LNTA=MREPER(2)
C      LTEM=MREPER(3)
      MATE=MREPER(4)
C
      LTAU=LPOCG
      LDEFT=LTAU + 6*IDVA
      LTAUAT=LDEFT + 6*IDVA
      LDALXT=LTAUAT + 6*IDVA
      LDALYT=LDALXT + 1*IDVA
      LDALZT=LDALYT + 1*IDVA
      LDYT=LDALZT + 1*IDVA
      LAKT=LDYT + 1*IDVA
      LBRZ=LAKT + 1*IDVA
      LTHI=LBRZ + 1*IDVA
C
      LTAU1=LPOC1
      LDEF1=LTAU1 + 6*IDVA
      LTAUA1=LDEF1 + 6*IDVA
      LDALX1=LTAUA1 + 6*IDVA
      LDALY1=LDALX1 + 1*IDVA
      LDALZ1=LDALY1 + 1*IDVA
      LDY1=LDALZ1 + 1*IDVA
      LAKT1=LDY1 + 1*IDVA
      LBRZ1=LAKT1 + 1*IDVA
      LTHI1=LBRZ1 + 1*IDVA
C
      CALL TI834(A(LTAU),A(LDEFT),A(LTAUAT),A(LDALXT),A(LDALYT),
     & A(LDALZT),A(LDYT),A(LAKT),A(LBRZ),A(LTAU1),A(LDEF1),A(LTAUA1),
     & A(LDALX1),A(LDALY1),A(LDALZ1),A(LDY1),A(LAKT1),A(LBRZ1),A(LTHI1),
     & A(LFUN),MATE,TAU,DEF,IRAC,A(LTHI))
C
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE TI834(TAUT,DEFT,TAUAT,DALMXT,DALMYT,DALMZT,DYT,AKTIVT,
     1    BRZINT,TAU1,DEF1,TAUA1,DALMX1,DALMY1,DALMZ1,DY1,AKTIV1,BRZIN1,
     1            THI1,FUN,MATE,TAU,DEF,IRAC,THI)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
C
      COMMON /ORIENT/ CPP(3,3),XJJ(3,3),TSG(6,6),BETA,LBET0,IBB0
      COMMON /UGAOV3/ TE(6,6)
      COMMON /COEFSM/ COEF(3),ICOEF
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON/PLASTI/LPLAST,LPLAS1,LSIGMA
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /IZLE4B/ H(9,3),GM(3,9),BLT(6,54),BE(9,54),ETP(6,6),UEL(54)
      COMMON /DEBLJG/ THICK,THICT,THIC0,NNSL
      COMMON/ITERBR/ ITER
      COMMON /CDEBUG/ IDEBUG
      COMMON /RMIS3/ VMS(3,3),VMS1(3,3),RACGR(3,3),TBET,GRAD1R(3,3)
      COMMON /AKTIV/ COEFIC(10,3),FAKTIV(10,2),NAKTIV,IAKTIV,IMAX
C
      DIMENSION TAU(*),DEF(*),TAU1(*),DEF1(*),TAUT(*),DEFT(*),
     &          TAUAT(*),TAUA1(*),THI1(*),THI(*)
      DIMENSION FUN(5,MATE),FUNT(9),COEFE(3),TBETA(6,6),TBET(3,3)
      DIMENSION SIGMPR(3,3),DELR(3)
      DIMENSION TAUAKT(6),SIGMAK(2,2)
C
C
      IF(IDEBUG.EQ.1) PRINT *, 'TI834'
C
CE     THICKNESS IN INTEGRATED POINT
      IF(IATYP.GE.3) THEN
         IF(ITER.EQ.0) THEN
            IF(KOR.EQ.1) THI1(1)=THIC0
            THI1(2)=THI1(1)
         ENDIF
CE        THICKNESS FROM PREVIOUS ITERATION
         THICK=THI1(1)
CE        THICKNESS FROM PREVIOUS STEP
         THICT=THI1(2)
      ENDIF
C
      COEFE(1)=1.D0
      COEFE(2)=1.D0
      COEFE(3)=1.D0
C
CE  INITIAL DATA
C
      TOLF=1.0D-8
      ANI  = FUN(1,MAT)
      DO 108 I = 1,6
  108 TAUAKT(I) = 0.D0
      FAKT1=0.D0
      BRZINA=0.D0
C
CE  LONGITUDINAL SEGMENTS
C
        AAK  = FUN(2,MAT)
        BBK  = FUN(3,MAT)
C
CE  CIRCUMFERENTIAL SEGEMENTS
C
       AAKP  = FUN(4,MAT)
       BBKP  = FUN(5,MAT)
C
        IF(KOR.EQ.1) THEN 
           DALMXT=1.D0
           DALMYT=1.D0
           DALMZT=1.D0
           DYT=1.D0
        ENDIF
C
      IF (ITER.EQ.0.AND.IRAC.EQ.2.AND.KOR.EQ.1) THEN
        DLAMDX=1.D0
        DLAMDY=1.D0
        DLAMDZ=1.D0
        GO TO 199
      ENDIF
C
C
CS   LAMDAP U TRENUTKU T+DT, U PRAVCU OSE R
C
      DO 124 I=1,3
      DELR(I)=0.D0
      DO 124 K=1,3
 124  DELR(I)=DELR(I)+GRAD1R(I,K)*VMS1(1,K)
C
      VINTEZ = DSQRT(DELR(1)*DELR(1)+DELR(2)*DELR(2)+DELR(3)*DELR(3))
C
CS  VEKTOR Gr U TRENUTKU T=0 
C
      VNTEZ1 = DSQRT(VMS1(1,1)*VMS1(1,1)+VMS1(1,2)*VMS1(1,2)+
     &               VMS1(1,3)*VMS1(1,3))
C
      DLAMDX =  VINTEZ/VNTEZ1
C
CS  LAMDA NA DRUGI NACIN PREKO KOSI-GRINOVOG TENZORA DEFORMACIJE
C
C      CALL MNOZM2(CGRAD,GRAD1R,GRAD1R,3,3,3)  
C      DKOJIC=0.D0
C
C      DO 109 KK=1,3
C        VMS1(1,KK)=VMS1(1,KK)/VNTEZ1
C 109  CONTINUE
C
C      DO 112 K=1,3       
C      DO 112 M=1,3       
C 112  DKOJIC=DKOJIC+CGRAD(K,M)*VMS1(1,K)*VMS1(1,M)
C      DKOJIC=DSQRT(DKOJIC)
C      WRITE(3,*) 'DKOJIC=',DKOJIC 
C
CS  LAMDA NA DRUGI NACIN PREKO KOSI-GRINOVOG TENZORA DEFORMACIJE
C
 199  CONTINUE
C
      DRACA=DLAMDX
      IF(DLAMDX.LT.1D0) THEN
       DLAMDX=1.D0-DLAMDX+1.D0
      ENDIF
C
      IF (ITER.EQ.0) DLAMDY=DALMYT  
      IF (ITER.EQ.0.AND.KOR.EQ.1) THEN
        DLAMDY=1.D0
      ENDIF
C
CS   LAMDAP U TRENUTKU T+DT, U PRAVCU OSE Y, UPRAVNO NA R
C
      IF (ITER.GE.1) THEN
        TEZ=DSQRT(TBET(1,1)*TBET(1,1)+TBET(1,2)*TBET(1,2)
     &            +TBET(1,3)*TBET(1,3))
        GYX=TBET(2,1)
        GYY=TBET(2,2)
        GYZ=TBET(2,3)
        FGX=RACGR(1,1)*GYX+RACGR(1,2)*GYY+RACGR(1,3)*GYZ
        FGY=RACGR(2,1)*GYX+RACGR(2,2)*GYY+RACGR(2,3)*GYZ
        FGZ=RACGR(3,1)*GYX+RACGR(3,2)*GYY+RACGR(3,3)*GYZ
        FGINTZ=DSQRT(FGX*FGX+FGY*FGY+FGZ*FGZ)
        DLAMDY=TEZ/FGINTZ
      ENDIF
C
CS  STREC U PRAVCU DEBLJINE
C
      DLAMDZ=1.D0/(DLAMDX*DLAMDY)
C
      DRAC1=DLAMDY
      DY1=DLAMDY
      IF(DLAMDY.LT.1D0) THEN
         DLAMDY=1.D0-DLAMDY+1.D0
      ENDIF
C
CS  TRAZENJE IZVODA NAPONA PO DEFORMACIJI PREKO STRETCHA
C
      DO 137 II=1,3
      DO 137 JJ=1,3
  137 SIGMPR(II,JJ)=0.D0
C
C
CS   NAPON U PRAVCU R (POPRECNE KARAKTERISTIKE)
C
       	  TAU(1) = AAK/BBK*((DLAMDX**BBK)-1.D0)
          SIGMPR(1,1)=AAK*(DLAMDX**(BBK-1.D0))
C
CS   NAPON U PRAVCU UPRAVNO NA R (UZDUZNE KARAKTERISTIKE)
C
      	  TAU(2) = AAKP/BBKP*((DLAMDY**BBKP)-1.D0)
          SIGMPR(2,2)=AAKP*(DLAMDY**(BBKP-1.D0))
C
CS  RACUNANJE PRIRASTAJA NAPONA U KORAKU
C
        ANIN=1.D0/(1.D0-ANI*ANI)
        DAL1=0.5D0*(DALMXT+DLAMDX)
        DAL2=0.5D0*(DALMYT+DLAMDY)
        ET1SR=AAK*(DAL1**(BBK-1.D0))
        ET2SR=AAKP*(DAL2**(BBKP-1.D0))
C
        C11T=AAK/BBK*((DALMXT**BBK)-1.D0)
        C11TDT=AAK/BBK*((DLAMDX**BBK)-1.D0)
        C11=ANIN*(C11TDT-C11T)
      	IF(DRACA.LT.1.D0) C11 = -C11
C
        C22T=AAKP/BBKP*((DALMYT**BBKP)-1.D0)
        C22TDT=AAKP/BBKP*((DLAMDY**BBKP)-1.D0)
        C22=ANIN*(C22TDT-C22T)
      	IF(DRAC1.LT.1.D0) C22 = -C22
C
        C12T=ANI*(DAL1*ET1SR)*DLOG(DALMYT)
        C12TDT=ANI*(DAL1*ET1SR)*DLOG(DLAMDY)
        IF(DRAC1.LT.1.D0) THEN 
           C12T=ANI*(DAL1*ET1SR)*DLOG(DYT)
           C12TDT=ANI*(DAL1*ET1SR)*DLOG(DRAC1)
        ENDIF
        C12=ANIN*(C12TDT-C12T)
C
        C21T=ANI*(DAL2*ET2SR)*DLOG(DALMXT)
        C21TDT=ANI*(DAL2*ET2SR)*DLOG(DLAMDX)
        IF(DRACA.LT.1.D0) THEN 
           C21T=ANI*(DAL2*ET2SR)*DLOG(2.D0-DALMXT)
           C21TDT=ANI*(DAL2*ET2SR)*DLOG(DRACA)
        ENDIF
        C21=ANIN*(C21TDT-C21T)
C
CS  ODREDIVANJE PRIRASTAJA NAPONA I UKUPNIH NAPONA
C
        DLSIG1=C11+C12
        DLSIG2=C21+C22
        TAU(1)=TAUT(1)+DLSIG1
        TAU(2)=TAUT(2)+DLSIG2
C
CS  !!!!   AKTIVNO STANJE   !!!!
C
      IF(KOR.GE.IAKTIV.AND.ITER.GE.1) THEN
C
CS  ODREDIVANJE TEKUCE BRZINE
C
        BRZINA=DABS((DLAMDX-DALMXT)/DT)
        IF (BRZINA.LE.0.01) BRZINA=0.0100001D0
C
CS  PROVERA DA LI JE TEKUCA BRZINA U ZADATOM OPSEGU KRIVE
C  
      	IF (BRZINA.LT.COEFIC(1,1).OR.BRZINA.GT.COEFIC(NAKTIV,1)) THEN
          WRITE(3,2160) BRZINA
 2160     FORMAT(/' ','KRIVA AKTIVNI NAPON-BRZINA NIJE DEFINISANA ZA OVU
     & VREDNOST BRZINE'/,' BRZINA =',E12.5)
          STOP
        ENDIF
C
       DO 311 I = 1,NAKTIV
C
CS   KOEFICIJENTI ZA AKTIVNI NAPON SA KRIVE NAPON-STREC-BRZINA DEFORMACIJE
C
      IF (BRZINA.GE.COEFIC(I,1).AND.BRZINA.LE.COEFIC(I+1,1)) THEN
        PR1 = (BRZINA-COEFIC(I,1))/(COEFIC(I+1,1)-COEFIC(I,1))
        PR2 = (COEFIC(I+1,1)-BRZINA)/(COEFIC(I+1,1)-COEFIC(I,1))
C
        AY2A=PR2 * COEFIC(I,2) + PR1 * COEFIC(I+1,2)
        BY2A=PR2 * COEFIC(I,3) + PR1 * COEFIC(I+1,3)
C
        AX2A=PR2 * COEFIC(I,2) + PR1 * COEFIC(I+1,2)
        BX2A=PR2 * COEFIC(I,3) + PR1 * COEFIC(I+1,3)
C
        GO TO 319
      ENDIF
  311 CONTINUE
C
  319 CONTINUE
C
CS RACUNANJE NAPONA ZA POPRECNI PRAVAC
C
       	  TAUAKT(1) = AX2A/BX2A*((DLAMDX**BX2A)-1.D0)
          SIGMAK(1,1)=AX2A*(DLAMDX**(BX2A-1.D0))
C
C
CS RACUNANJE NAPONA ZA UZDUZNI PRAVAC
C
        TAUAKT(2)=0.D0
        IF (DRAC1.GT.1.D0) THEN
       	  TAUAKT(2) = AY2A/BY2A*((DLAMDY**BY2A)-1.D0)
          SIGMAK(2,2)=AY2A*(DLAMDY**(BY2A-1.D0))
        ENDIF
C
CS ODREDIVANJE VREDNOSTI FUNKCIJE AKTIVACIJE
C
CS PROVERA DA LI JE TEKUCE VREME U ZADATOM OPSEGU KRIVE
C
      	IF (VREME.GT.FAKTIV(IMAX,1)) THEN
          WRITE(3,2190) VREME
 2190     FORMAT(/' ','KRIVA AKTIVACIJA-VREME NIJE DEFINISANA ZA OVU VRE
     &DNOST VREMENA'/,' VREME =',E12.5)
          STOP
        ENDIF
C
       DO 511 I = 1,IMAX
C
CS   FUNCIJA AKTIVACIJE
C
      	IF (VREME.GE.FAKTIV(I,1).AND.VREME.LE.FAKTIV(I+1,1)) THEN
      	  FAKT1 = (FAKTIV(I+1,2)-FAKTIV(I,2)) * (VREME-FAKTIV(I,1))/
     &    (FAKTIV(I+1,1)-FAKTIV(I,1)) + FAKTIV(I,2)
C
          GO TO 519
        ENDIF
  511  CONTINUE
C
  519 CONTINUE
C
CS UKUPNI NAPON ZA OBA PRAVCA (ZBIR PASIVNOG I AKTIVNOG NAPONA)
C
      	TAU(1) = TAU(1)+FAKT1*TAUAKT(1)
      	TAU(2) = TAU(2)+FAKT1*TAUAKT(2)
C      	IF(TAU(2).LT.TAUAKT(2)) TAU(2) = TAU(2)+FAKT1*TAUAKT(2)
C
CS KOREKCIJA TANGENTNOG MODULA ZBOG KONTRAKCIJE
C
          SIGMPR(1,1)=SIGMPR(1,1)+SIGMAK(1,1)
C          SIGMPR(2,2)=SIGMPR(2,2)+SIGMAK(2,2)
C
      ENDIF
C
CS  !!!!   AKTIVNO STANJE   !!!!
C
C
C ODREDIVANJE KOEFICIJENATA ZA MATRICU ELAST
C
          EE=ANIN*DLAMDX*SIGMPR(1,1)
          EY=ANIN*DLAMDY*SIGMPR(2,2)
          EZ1=ANIN*ANI*DLAMDX*SIGMPR(1,1)
          EZ2=ANIN*ANI*DLAMDY*SIGMPR(2,2)
          EZ=0.5D0*(EZ1+EZ2)
          GG=(EE+EY)/4.0/(1+ANI)
C
      FUNT(1)=EE
      FUNT(2)=EY
      FUNT(3)=EZ
C
      DO 1 I = 4,9
        IF (I.GT.3.AND.I.LE.6) FUNT(I)=ANI
        IF (I.GT.6.AND.I.LE.9) FUNT(I)=GG
    1 CONTINUE
C
      DO 138 I=1,6 
      DO 138 J=1,6 
 138  TBETA(I,J)=0.D0
      IOPT=1
C
      CALL MEL8R(FUNT,COEFE,ETP,TBETA,BETA,IOPT)
C
      IF(IRAC.EQ.2) RETURN
C
CS  SMICUCI NAPON U LOKALNOM SISTEMU
C
      DO 121 K=4,6
 121  TAU(K)=0.5D0*GG*DEF(K) 
C
      KS=6
C
C     ZA ITER=0 UZIMA TAU=TAUT I VRACA SE
C
      IF (ITER.EQ.0) THEN
         DO 5 I = 1,KS
    5    TAU(I) = TAUT(I)
         RETURN
      ENDIF
C
CS     AZURIRANJE VELICINA ZA SLEDECI KORAK 
CE     UPDATE FROM PREVIOUS STEP
C
      DALMX1 = DLAMDX
      DALMY1 = DLAMDY
      DALMZ1 = DLAMDZ
      AKTIV1 = FAKT1
      BRZIN1 = BRZINA
C
      THI1(1)=DLAMDZ*THIC0
C
      DO 608 I = 1,KS
        TAU1(I) = TAU(I)
        TAUA1(I) = TAUAKT(I)
  608   DEF1(I) = DEF(I)
C
      RETURN
      END
