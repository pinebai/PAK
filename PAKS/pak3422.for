C     Cam-clay model - 2-D   viscoplasticity
C     With equilibrium iterations
C
C     Main notation :
C
C    SUBROUTINE D3M22
C               TI322
C               MVP3    
C
      SUBROUTINE D3M22(TAU,DEF,IRAC,LPOCG,LPOC1)
      USE PLAST3D
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C     PROGRAM ZA ODREDIVANJE LOKACIJA VELICINA KOJE SE CUVAJU
C     NA NIVOU INTEGRACIONE TACKE

      include 'paka.inc'
      
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
C
      COMMON /REPERM/ MREPER(4)
      COMMON /DUPLAP/ IDVA
      COMMON /CDEBUG/ IDEBUG
C
      DIMENSION TAU(6),DEF(6)
C
      IF(IDEBUG.GT.0) PRINT *, ' D2M22'
C
      LFUN=MREPER(1)
      MATE=MREPER(4)
C
      LTAU=LPOCG
      LDEFT=LTAU + 6
      LOCR=LDEFT + 6
      LDEFPP=LOCR + 6
      LPOT=LDEFPP + 6
      LEMP=LPOT + 1
      LD=LEMP + 1
C
      LTAU1=LPOC1
      LDEFT1=LTAU1 + 6
      LOCR1=LDEFT1+ 6
      LDEFP1=LOCR1 + 6
      LPOT1=LDEFP1 + 6
      LEMP1=LPOT1 + 1
      LD1=LEMP1 + 1
C
      CALL TI322(PLAST(LTAU),PLAST(LDEFT),PLAST(LOCR),
     1           PLAST(LDEFPP),PLAST(LPOT),PLAST(LEMP),PLAST(LD),
     1           PLAS1(LTAU1),PLAS1(LDEFT1),PLAS1(LOCR1),PLAS1(LDEFP1),
     1           PLAS1(LPOT1),PLAS1(LEMP1),PLAS1(LD1),
     1           A(LFUN),MATE,TAU,DEF,IRAC)
C
      RETURN
      END
C
C  =====================================================================
C
      SUBROUTINE TI322(STREST,STRAIT,EVP,SZVEZT,PT,SIGMST,EPSVPM,
     1                  STRES1,STRAI1,EVP1,SZVEZ1,PT1,SIGMS1,EPVPM1,
     1                  FUN,MATE,STRESS,STRAIN,IRAC)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C     PODPROGRAM ZA INTEGRACIJU KONSTITUTIVNIH RELACIJA ZA 
C     CAM-CLAY MATERIJALNI MMODEL
C
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
C
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
C
      COMMON /TAUD3/ TAUD(6),DEFDPR(6),DEFDS(6),DDEFP(6),
     1               DETAU(6),STRAID(6)
      COMMON /MAT2D/ EE,ANI,ET,TEQY0
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
C
      COMMON/PLASTI/LPLAST,LPLAS1,LSIGMA
C
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
C
      COMMON/ITERBR/ITER
C
      COMMON /CONMAT/ AE,EP,DVT
      COMMON /CDEBUG/ IDEBUG
C
      DIMENSION STREST(*),STRAIT(*),EVP(*),STRAIN(*),STRESS(*),DEVP(6),
     1          STRES1(*),STRAI1(*),EVP1(*),SS(6),SE(6),
     1          SZVEZT(*),SZVEZ1(*)
      DIMENSION FUN(10,MATE),FUN2(6)
C
C
      IF(IDEBUG.EQ.1) PRINT *, 'TI322'
C
C     OSNOVNE KONSTANTE
C
C
      TOLBIS=1.0D-8
      IVP=0
      ISH = 0
      MAXBIS=200
      TOL=1.0D-10
      TOLO=1.0D-9
      TOLDX=1.0D-10
      TOLF=1.0D-10
      TOLSH=1.0D-3
      FACTP=1.D-3
C
      DVT=2.0D0/3.0D0
      SQ2=DSQRT(2.0D0)
      DJP=DSQRT(1.5D0)
C
C     INICIJALIZACIJA OSNOVNIH VELICINA
C     MATERIAL CONSTANTS
      EE=FUN(1,MAT)
      ANI=FUN(2,MAT)
      AT=FUN(3,MAT)
      IEL=FUN(4,MAT)
      EM=FUN(5,MAT)
      ALAMDA=FUN(6,MAT)
      ETAS=FUN(7,MAT)
      P0=FUN(8,MAT)
      E0=FUN(9,MAT)
      ETA=FUN(10,MAT)
C
C ???
      IF (KOR.EQ.1) THEN
      SIGMST=0.D0
C        ELSE
C         SIGMST=(STREST(1)+STREST(2)+STREST(4))/3.D0+SIGMS0
      ENDIF
C????
C
      IF (IEL.EQ.0) THEN
      ET=(STRAIT(1)+STRAIT(2)+STRAIT(3))/3.D0
      ET=(1.D0+E0)*DEXP(3.*ET)-1.D0
      SIGMSA=DABS(SIGMST)
      AMS=(1.0D0+ET)*SIGMSA/ETAS
      EE=3.D0*AMS*(1.D0+2.D0*ANI)
      ENDIF
C
C???
C      IF (KOR.GT.1) SIGMS0=0.D0
      FUN2(1)=EE
      FUN2(2)=ANI
      IF (KOR.EQ.1) THEN
      PT=P0
C      SIGMST=SIGMS0
      ENDIF
C      PT1=PT
C????
C
      SIGMS = SIGMST
      AE = (1.+ANI)/EE
      AEM1 = 1./AE
      AKS = ALAMDA - ETAS
      AM3 = 3./(EM*EM)
      CECON = EE*(1.-ANI)/((1.+ANI)*(1.-2.*ANI))
      ANIC = ANI/(1.-ANI)
      CM = EE/(1.-2.*ANI)
      EM3 = 3./(EM*EM)
C
      CALL MEL31(FUN2)
      IF (IRAC.EQ.2) RETURN
C
      ETADT = ETA/DT
      ETADT3  = 3.*ETADT
      BETA = EM3*(1. + AEM1/ETADT)
C
C    ESTIMACIJA
C
      IF (ITER.EQ.0) THEN
         IF (KOR.EQ.1) THEN
            DO 166 I=1,6
  166       STRESS(I)=STREST(I)
            RETURN
         ENDIF 
         DO 167 I = 1,6  
  167    DEVP(I)=(STRESS(I)-SZVEZT(I))/ETADT
         DO 169 I=1,6
         STRESS(I) = 0.D0
         DO 169 J = 1,6
         STRESS(I)=ELAST(I,J)*(STRAIN(J)-EVP(J)-DEVP(J))
  169    CONTINUE
         RETURN
      ENDIF
C
C
C???? ne treba
C      DO 10 I=1,4
C      STRESS(I)=0.D0
C      STRAID(I)=STRAIN(I)-EVP(I)
C      IF (I.EQ.3) STRAID(I)=STRAIN(I)-2.*EVP(I)
C   10 CONTINUE
C????
C
      EPSV = STRAIN(1) + STRAIN(2) + STRAIN(3)
      EPSM = EPSV/3.
      EPSVPV = EVP(1) + EVP(2) + EVP(3)
      EPSVPM = EPSVPV/3.
      EPRM = EPSM - EPSVPM
      DEFDS(1) = STRAIN(1) - EVP(1) - EPRM
      DEFDS(2) = STRAIN(2) - EVP(2) - EPRM
      DEFDS(3) = STRAIN(3) - EVP(3) - EPRM
      DEFDS(4) = 0.5*(STRAIN(4) - EVP(4))
      DEFDS(5) = 0.5*(STRAIN(5) - EVP(5))
      DEFDS(6) = 0.5*(STRAIN(6) - EVP(6))
C
      POROZ = (1.+E0)*EXP(EPSV) - 1.
      BV = AKS/(3.*(1.+POROZ))
      DEPM = 0.D0
      DO 13 I = 1,6
   13 DEVP(I) = 0.D0
C
C     ELASTIC STRESSES
C
      PT2 = 0.5*PT
      SIGME = CM*EPRM
      SIGM = SIGME
      AJ2DE = 0.D0
      DO 12 I = 1,6
      TAUD(I) = DEFDS(I)/AE
      DAJ = TAUD(I)*TAUD(I)
      IF (I.GT.3) DAJ = DAJ + DAJ
      AJ2DE = AJ2DE + DAJ
   12 CONTINUE
      IF (SIGME.GT.PT2) GO TO 200
      AJ2DE = 0.5*AJ2DE
C
      F = SIGME*SIGME - PT*SIGME + EM3*AJ2DE
      IF (F.LT.0.D0) GO TO 200
C
C     VISCOPLASTIC DEFORMATION
C
      IVP = 1
      P0B = 2.*SIGME - PT
      IF  (DABS(P0B/PT).GT.TOLSH) GO TO 30
C
C     SHEAR VISCOPLASTIC FLOW
C
      ISH = 1
      SQJ2DE =DSQRT(AM3*AJ2DE)
      SIGMH = DSQRT(DABS(SIGM*(SIGM-PT)))
      AK = (SQJ2DE/SIGMH - 1.)/BETA
      BETAK1 = 1. + BETA*AK
      SIGMS = SIGME
      P0 = PT
      IF (AK.GT.TOLO) GO TO 162
      ISH = 0
      IVP = 0
      GO TO 200
C
C
   30 SIGMST = (SZVEZT(1)+SZVEZT(2)+SZVEZT(3))/3.
C
C
  120 I = I + 1
      DEPM1 = DEPM
      IF (I.EQ.1)DEPM=0.0D0
      SIGM = SIGME - CM*DEPM
      SIGMS = SIGM - ETADT*DEPM
C
      P0 = PT*DEXP(-DEPM/BV)
      AK = ETADT3*DEPM/(2. *SIGMS-P0)
C
      BETAK1 = 1.+ BETA*AK
      BETAK2 = BETAK1*BETAK1
      AJ2DS = AJ2DE/BETAK2
C
C  ZA DEFINISANJE PRVOG IZVODA
C
      SMPR=CM+ETADT
      DA1=1/(2.D0*SIGMS-P0)*(ETADT3+AK*(2.D0*SMPR-P0/BV))
      DVT4=DA1*2.D0*AJ2DS*BETA/(1.D0+BETA*AK)
      FPR=-SMPR*(SIGMS-P0)-SIGMS*SMPR+SIGMS*P0/BV-EM3*DVT4
      F = SIGMS*SIGMS - P0*SIGMS + EM3*AJ2DS
C
C
      DEPM=DEPM-F/FPR
      TDEPM=DABS((DEPM-DEPM1)/DEPM)
      IF (TDEPM.LT.TOLBIS)GO TO 162
      IF  (I.GT.MAXBIS) THEN                                                  
      WRITE(3,1030)
 1030 FORMAT(' ','DOSTIGNUT MAKSIMALAN BROJ BISEKCIJA U TI222')
      STOP
      ENDIF
      IF (DABS(F).LT.TOLF)GO TO 162
      GO TO 120
C
C
  162 EM3K = EM3*AK/ETADT
C
      EPVPM1=EPSVPM+DEPM
      DO 165 I = 1,6
      SS(I) = TAUD(I)/BETAK1
      DEVP(I) = EM3K*SS(I)
      SE(I) = TAUD(I)
      TAUD(I) = TAUD(I) - AEM1*DEVP(I)
      IF  (I.LE.3) THEN
      DEVP(I) = DEVP(I) + DEPM
      ENDIF
  165 CONTINUE
C
  200 CONTINUE
C
      EVP1(1)=EVP(1)+DEVP(1)
      EVP1(2)=EVP(2)+DEVP(2)
      EVP1(3)=EVP(3)+DEVP(3)
      EVP1(4)=EVP(4)+2.*DEVP(4)
      EVP1(5)=EVP(5)+2.*DEVP(5)
      EVP1(6)=EVP(6)+2.*DEVP(6)
C
      SIGMST = SIGMS
      SIGMS1=SIGMST
      PT=P0
      PT1=PT
C
      IF  (IVP.EQ.1) THEN
          SZVEZ1(1)=SS(1)+SIGMS
          SZVEZ1(2)=SS(2)+SIGMS
          SZVEZ1(3)=SS(3)+SIGMS
          SZVEZ1(4)=SS(4)
          SZVEZ1(5)=SS(5)
          SZVEZ1(6)=SS(6)
      ENDIF
C
C
      DO 201 I = 1,6
      STRESS(I) = TAUD(I)
      IF (I.LE.3) STRESS(I) = STRESS(I) + SIGM
  201 CONTINUE
C
      IF (IVP.EQ.1) THEN
      IF(ISKNP.NE.2)THEN
      CALL MVP3(AEM1,BETAK1,AM3,EM3,AE,BETA,SQJ2DE,SIGMH,
     1         BETAK2,AK,ETADT,SE,CM,SIGMS,P0,BV,AJ2DS,SS,
     2         ETADT3,ISH)
      ENDIF     
      ENDIF     
C
      DO 233 I=1,6
      SZVEZ1(I)=STRESS(I)-ETADT*DEVP(I)
      STRES1(I)=STRESS(I)
  233 STRAI1(I)=STRAIN(I)
C
      RETURN
      END
C======================================================================
C
C     ELASTIC-VISCOPLASTIC MATRIX :
C
C======================================================================
      SUBROUTINE MVP3(AEM1,BETAK1,AM3,EM3,AE,BETA,SQJ2DE,SIGMH,
     1		     BETAK2,AK,ETADT,SE,CM,SIGMS,P0,BV,AJ2DS,SS,
     2               ETADT3,ISH)
C
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /CDEBUG/ IDEBUG
C
C
      DIMENSION CP(6,6),DJ(6),SE(6),SS(6),CHPM(6),CBPM(6)
      IF(IDEBUG.EQ.1) PRINT *, 'MVP '
C
      IF (ISH.EQ.0) GO TO 221
C
C     SHEAR VISCOPLASTIC DEFORMATION
C
      A2 = AEM1/BETAK1
      A5 = AM3/(2.*AE*BETA*SQJ2DE*SIGMH)
      A6 = BETA*A5/BETAK1
      DIAG = AEM1*(1. - AM3*AK*A2/ETADT)
      COEFD = AM3*AEM1*(A5-AK*A6)/ETADT
      DO 235 I = 1,6
      CHPM(I) = 0.D0
      CBPM(I) = 0.D0
      DJ(I) = SE(I)
      IF (I.GT.3) DJ(I) = DJ(I) + DJ(I)
  235 CONTINUE
      CMM = CM
      GO TO 238
C
C     WITH VOLUMETRIC VISCOPLASTIC DEFORMATION
C
  221 DEND = BETAK2*AE
      DO 205 I = 1,6
      DJ(I) = SE(I)/DEND
      IF(I.GT.3) DJ(I) = DJ(I) + DJ(I)
  205 CONTINUE
      SIGP0 = 2.*SIGMS - P0
      CMETA = CM + ETADT
      P0B = P0/BV
      A1 = (ETADT3 + AK*(2.*CMETA - P0B))/SIGP0
      A2 = AEM1/BETAK1
      A3 = BETA*A1/BETAK1
      A4 = 2.*A3*AJ2DS
      COEFD = AM3/(CMETA*SIGP0 - SIGMS*P0B + AM3*A4)
C
      A1M = 2.*AK*CM/SIGP0
      A2M = (ETADT3 + AK*(2.*CMETA-P0B))/SIGP0
      ACOEF = 2.*EM3*BETA*AJ2DS/BETAK1
      A3M = CM*SIGP0 + ACOEF*A1M
      A4M = CMETA*SIGP0 - SIGMS*P0B + ACOEF*A2M
      B1M = A3M/A4M
      A5MA = -A1M + A2M*B1M
      A5M = BETA*A5MA/BETAK1
      A6M = -AM3*AEM1*(A5MA - AK*A5M)/ETADT
      CMM = CM*(1. - B1M)
C
      DO 207 I = 1,6
      DJ(I) = COEFD*DJ(I)
      CBPM(I) = - CM*DJ(I)
      CHPM(I) = A6M*SS(I)
  207 CONTINUE
      DIAG = AEM1*(1. - AM3*AK*A2/ETADT)
      COEFD = AM3*AEM1*(A1 - A3*AK)/ETADT
C
  238 DO 210 I = 1,6
      DO 210 J = 1,6
      CP(I,J) = - COEFD*SS(I)*DJ(J) 
      IF (I.LE.3) CP(I,J) = CP(I,J) + CBPM(J)
      IF (I.EQ.J) CP(I,J) = CP(I,J) + DIAG
  210 CONTINUE
C
      DO 225 I = 1,3
      ELAST(I,1) = (2.*CP(I,1)-CP(I,2)-CP(I,3) + CHPM(I) + CMM)/3.
      ELAST(I,2) = (2.*CP(I,2)-CP(I,1)-CP(I,3) + CHPM(I) + CMM)/3.
      ELAST(I,3) = (2.*CP(I,3)-CP(I,1)-CP(I,2) + CHPM(I) + CMM)/3.
  225 CONTINUE
      DO 227 I = 4,6
      ELAST(I,1) = (2.*CP(I,1)-CP(I,2)-CP(I,3) + CHPM(I))/3.
      ELAST(I,2) = (2.*CP(I,2)-CP(I,1)-CP(I,3) + CHPM(I))/3.
      ELAST(I,3) = (2.*CP(I,3)-CP(I,1)-CP(I,2) + CHPM(I))/3.
  227 CONTINUE
      DO 228 I = 1,6
      DO 228 J = 4,6
  228 ELAST(I,J) = 0.5*CP(I,J)
      DO 229 I = 1,6
      DO 229 J = I,6
      ELAST(I,J) = 0.5*(ELAST(I,J)+ELAST(J,I))
      ELAST(J,I) = ELAST(I,J)
  229 CONTINUE
C
      RETURN
      END