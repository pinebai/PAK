C=======================================================================
C
C   SUBROUTINE S992GL
C              RD92
C              SIS92
C              ELTE92
C              ALFC
C=======================================================================
      SUBROUTINE S992GL(IND)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     GLAVNI UPRAVLJACKI PROGRAM ZA FORMIRANJE MATRICA I VEKTORA 
CS     2/D KONTAKT ELEMENATA
CE     MAIN PROGRAM FOR CALCULATION OF ELEMENT MATRIX FOR 
CE     2/D CONTACT ELEMENTS
C
      include 'paka.inc'
      
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /ELEMAE/ MXAE,LAE,LMXAE,LHE,LBET,LBED,LRTHE,LSKE,LLM
      COMMON /ELEM99/ MXAU,LAU,LLMEL,LNEL,LNMAT,LAPRS,LIPGC,LIPRC,LISNA,
     1                LBETA
      COMMON /DUPLAP/ IDVA
      COMMON /SRPSKI/ ISRPS
      COMMON /KONTKT/ ICONT,NEQC,NEQ,NWKC,LMAXAC,LRCTDT
      COMMON /CDEBUG/ IDEBUG
      EQUIVALENCE (IETYP,NTSF),(NGAUSX,NTTOT),(LNMAT,LNCVSF),
     &            (LIPRC,LITSRF),(LIPGC,LNELSF),(LLMEL,LIDC)
C
      IF(IDEBUG.GT.0) PRINT *, ' S992GL'
      LAU=LMAX
      CALL RD92(A(LAU),IND)
      IF(MOD(LMAX,2).EQ.0) LMAX=LMAX+1
C
      LAE=LMAX
      MXAE=MAX0(NTTOT*5*IDVA+8,36*IDVA+8)
      LMAX = LAE + MXAE
C
      IF(LMAX.LT.MTOT) GO TO 70
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2009) LMAX,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6009) LMAX,MTOT
      STOP
C
C
C
   70 CALL SIS92(A(LAE),A(LAU),IND)
C
      RETURN
C-----------------------------------------------------------------------
 2009 FORMAT(///' NEDOVOLJNA DIMENZIJA U VEKTORU A ZA MATRICE ELEMENATA'
     1/' POTREBNA DIMENZIJA,    LMAX=',I10
     2/' RASPOLOZIVA DIMENZIJA, MTOT=',I10)
 6009 FORMAT(///' NOT ENOUGH SPACE IN WORKING VECTOR  A'
     1/' REQUESTED DIMENSION , LMAX=',I10
     2/' AVAILABLE DIMENSION , MTOT=',I10)
C-----------------------------------------------------------------------
      END
C=======================================================================
      SUBROUTINE RD92(AU,INA)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     UPRAVLJACKI PROGRAM ZA UCITAVANJE ULAZNIH PODATAKA U AU
CE     MENAGEMENT ROUTINE FOR INPUT DATA IN    AU
C
      include 'paka.inc'
      
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /ELEM99/ MXAU,LAU,LLMEL,LNEL,LNMAT,LAPRS,LIPGC,LIPRC,LISNA,
     1                LBETA
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /DUPLAP/ IDVA
      COMMON /PLASTI/ LPLAST,LPLAS1,LSIGMA
      COMMON /ZAPISI/ LSTAZA(5)
      COMMON /KONTKT/ ICONT,NEQC,NEQ,NWKC,LMAXAC,LRCTDT
      EQUIVALENCE (IETYP,NTSF),(NGAUSX,NTTOT),(LNMAT,LNCVSF),
     &            (LIPRC,LITSRF),(LIPGC,LNELSF),(LLMEL,LIDC),
     &            (LIK,LPLAST),(LIK1,LPLAS1),(LBETA,LFSFD),
     &            (LAPRS,LMASE)
C
      DIMENSION AU(*)
      REAL AU
C
CS     CITANJE SKALARA IZ DIREKT ACCES FILE 
CE     READ SCALARS FROM A DIRECT ACCESS FILE
C
      LSTAZA(1)=LMAX8
      READ(IELEM,REC=LMAX8)
     1 NTSF,NTTOT,NCVE,MXAU,LNCVSF,LITSRF,
     1 LISNA,LNELSF,LNEL,LLMEL,LFSFD,LMASE
      LSTAZA(2)=LMAX8+1
      CALL READDD(AU(LMASE),MXAU/IDVA,IELEM,LMAX8,LDUZI)
      LMAX=LAU+MXAU
      IF(MOD(LMAX,2).EQ.0) LMAX=LMAX+1
CS....  VELICINE SA KRAJU PRETHODNOG KORAKA
CE....  PREVIOUS STEP VALUES
      NPROS=(NE*3+1)/2*2/IDVA+NE
      LIK  =LMAX
      LIK1 =LIK +NE
      IF(MOD(LIK1,2).EQ.0) LIK1=LIK1+1
      LMAX =LIK1+2*NE+NE*IDVA
      IF(LMAX.GT.MTOT) CALL ERROR(1)
CS....  VELICINE ZA TEKUCI KORAK
      LSTAZA(3)=LMAX8+1
      LMA8=LMAX8
      CALL READDD(A(LIK), NPROS,IELEM,LMAX8,LDUZI)
      IF(INA.EQ.4)THEN
        CALL IJEDN1(A(LIK),A(LIK1),NE)
        CALL WRITDD(A(LIK),NPROS,IELEM,LMA8,LDUZI)
      ENDIF
C
      LSIGMA=LMAX
      NPROS =(NE+NTTOT)*2
      LSIGT =LSIGMA+NPROS*IDVA
      LMAX  =LSIGT +NPROS*IDVA
      LSTAZA(5)=LMAX8+1
      NPRO2=2*NPROS
      IF(INA.EQ.2.OR.INA.EQ.3)THEN
        CALL READDD(A(LSIGMA),NPRO2,IELEM,LMAX8,LDUZI)
        CALL CLEAR (A(LSIGMA),NPROS)
      ELSEIF(INA.EQ.4)THEN
        LMA8=LMAX8
        CALL READDD(A(LSIGMA),NPRO2,IELEM,LMAX8,LDUZI)
        CALL JEDNA1(A(LSIGT),A(LSIGMA),NPROS)
        CALL WRITDD(A(LSIGMA),NPRO2,IELEM,LMA8,LDUZI)
      ELSEIF(INA.EQ.7.OR.INA.EQ.8)THEN
        CALL READDD(A(LSIGMA),NPRO2,IELEM,LMAX8,LDUZI)
      ENDIF
      RETURN
      END
C======================================================================
      SUBROUTINE SIS92(AE,AU,IND)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     GLAVNI UPRAVLJACKI PROGRAM  ZA MATRICE ELEMENATA I SISTEMA
CE     MAIN MANAGEMENT  PROGRAM  FOR ELEMENT MATRIX
C
      include 'paka.inc'
      
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /REPERI/ LCORD,LID,LMAXA,LMHT
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /PLASTI/ LPLAST,LPLAS1,LSIGMA
      COMMON /ELEM99/ MXAU,LAU,LLMEL,LNEL,LNMAT,LAPRS,LIPGC,LIPRC,LISNA,
     1                LBETA
      COMMON /ELEMAE/ MXAE,LAE,LMXAE,LHE,LBET,LBED,LRTHE,LSKE,LLM
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /TEMPCV/ LTECV,ITEMP
      COMMON /ZAPISI/ LSTAZA(5)
      COMMON /DUPLAP/ IDVA
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /KONTKT/ ICONT,NEQC,NEQ,NWKC,LMAXAC,LRCTDT
      COMMON /EPUREP/ LPUU,LPUV,LPUA,IPUU,IPUV,IPUA,ISUU,ISUV,ISUA
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
      COMMON /CDEBUG/ IDEBUG
      EQUIVALENCE (IETYP,NTSF),(NGAUSX,NTTOT),(LNMAT,LNCVSF),
     &            (LIPRC,LITSRF),(LIPGC,LNELSF),(LLMEL,LIDC),
     &            (LIK,LPLAST),(LIK1,LPLAS1),(LBETA,LFSFD),
     &            (LAPRS,LMASE)
C
      DIMENSION AE(*),AU(*)
      REAL AE,AU
      IF(IDEBUG.GT.0) PRINT *, ' SIS92'
C  DOPUNSKI REPERI U VEKTORU A
      LIK2 =LIK1 +NE
      LALFK=LIK2 +NE
C
CS            P E T L J A    P O    E L E M N T I M A
CE            L O O P    O V E R    E L E M E N T S
C
      IF(IND.EQ.2.OR.IND.EQ.3)THEN
C       REPERI U VEKTORU ELEMENATA AE
       NWE =36
       LSKE=1
       LLM =LSKE+36*IDVA
       MXAE=LLM +8-1
C
       DO 100 NLM=1,NE
       CALL CLEAR(AE,MXAE/IDVA)
       CALL ELTE92(AE(LSKE),AU(LNCVSF),AU(LITSRF),AU(LNELSF),AE(LLM),
     &             AU(LIDC),AU(LNEL),A(LCORD),A(LID),A(LRTDT),A(LRCTDT),
     &             A(LIK),A(LIK1),A(LALFK),AU(LFSFD),A(LSIGMA),MDIM)
C
CS     RASPOREDJIVANJE MATRICE KRUTOSTI (SKE)
CE     ASSEMBLE STIFFNESS MATRIX
C
       CALL SPAKUJ(A(LSK),A(LMAXA),AE(LSKE),AE(LLM),MDIM)
  100  CONTINUE
C       WRITE(3,*)'NWK,NWKC,NEQC,NEQ',NWK,NWKC,NEQC,NEQ
C       call WRR(A(LSK),NWK,'SKC ')
      ELSEIF(IND.EQ.5)THEN
C
CS     PRIPADAJUCE MASE CVOROVA
CE     NODES MASSES
C
       CALL MASE92(A(LSK),A(LMAXA),A(LID),AU(LMASE),AU(LNCVSF),
     &             AU(LITSRF),AU(LNELSF),AU(LNEL),NP,NE,NTSF)
C
       LMA8=LSTAZA(2)-1
       CALL WRITDD(AU(LMASE),MXAU/IDVA,IELEM,LMA8,LDUZI)
      ELSEIF(IND.EQ.7.OR.IND.EQ.8)THEN
C       REPERI U VEKTORU ELEMENATA AE
       LA  =1
       LB  =LA+NTTOT*3*IDVA
       LLM =LB+NTTOT*2*IDVA
       MXAE=LLM+8-1
       MCLR=(LLM-LA)/IDVA
       CALL CLEAR(AE,MCLR)
C
CS     KOREKCIJA UBRZANJA I BRZINA PRI UDARU
CE     UPDATE ACCELERATION AND VELOCITY AFFTER IMPACT
C
C   LPUU --> UBRZANJE ITERACIJA (I-1), BRZINA TRENUTAK (T)
C   LRR  --> ( LPUU ) + KOREKCIJE
       LRR =LPUU
       LSIG=LSIGMA
       LII =LIK2
       IF(IND.EQ.8)THEN
C*
         LPUU =LPUV
C*
         LRR =LPUV
         LSIG=LSIGMA+(NE+NTTOT)*2*IDVA
         LII =LIK
       ENDIF
       CALL VAUPDT(A(LRR),A(LPUU),A(LID),A(LRCTDT),AU(LMASE),AE(LA),
     &             AE(LB),A(LII),A(LIK1),A(LALFK),AU(LNELSF),AU(LITSRF),
     &             AU(LIDC),AU(LNEL),AU(LNCVSF),A(LSIG),AE(LLM),
     &             A(LRTDT),NP,NE,NTTOT,NTSF,DT,IND,A(LIK))
       CALL IJEDN1(A(LIK2),A(LIK1),NE)
      ENDIF
C
      NPROS=(NE*3+1)/2*2/IDVA+NE
      LMA8=LSTAZA(3)-1
      CALL WRITDD(A(LIK),NPROS,IELEM,LMA8,LDUZI)
C
      NPROS =(NE+NTTOT)*4
      LMA8=LSTAZA(5)-1
      CALL WRITDD(A(LSIGMA),NPROS,IELEM,LMA8,LDUZI)
C
      RETURN
      END
C=======================================================================
      SUBROUTINE ELTE92(SKE,NCVSF,ITSRF,NELSF,LM,IDC,
     &                  NEL,CORD,ID,U,RC,IK,IK1,ALFK,FSFD,SILE,MDIM)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     FORMIRANJE MATRICA ELEMENATA I SISTEMA
CE     FORM ELEMENT MATRIX
C
C  IK     INDIKATOR KONTAKTA U TRENUTKU (T)
C  IK1    INDIKATOR KONTAKTA U TRENUTKU (T+DT) (U ITERACIJI)
      include 'paka.inc'
      
C*      REAL DUM4
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /PLASTI/ LPLAST,LPLAS1,LSIGMA
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /ELEMEN/ ELAST(6,6),XJ(3,3),ALFA(6),TEMP0,DET,NLM,KK
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /SRPSKI/ ISRPS
C
      DIMENSION SKE(*),NCVSF(*),ITSRF(*),NELSF(*),LM(*),NEL(NE,*),
     1          CORD(NP,*),U(*),RC(*),IDC(NE,*),ID(NP,*),FSFD(NE,*),
     2          IK(*),IK1(*),ALFK(*),SILE(2,*)
      DIMENSION D(4),DC(2),TAUS(4),TAUN(4),TAU1(4),TAU2(4)
      DATA IT1/1000000/
C
C  CVOR KONTAKTOR
C
      NCK=NEL(NLM,1)
C
C  KOEFICIJENTI TRENJA
C
      FS=FSFD(NLM,1)
      FD=FSFD(NLM,2)
C
CS...... PETLJA PO CILJNIM TACKAMA 
CE...... LOOP OVER TARGET POINTS
C
C  ISRF - CILJNI SEGMENT, NNC - BROJ CVOROVA SEGMENTA
      ISRF=NEL(NLM,2)
      NNC =NCVSF(ISRF)
      LL  =IABS(ITSRF(ISRF))-1
      NELL=NE+LL
C  PROVERA STANJA U PRETHODNOJ ITERACIJI
      IND =IK1(NLM)/IT1
      IF(IND.GT.0) THEN
        NCAA=IK1(NLM)-IND*IT1
        NCBB=NCAA+1
        NCA =NELSF(LL+NCAA)
        NCB =NELSF(LL+NCBB)
        CALL ALFC(ALF,NCK,NCA,NCB,CC,SS,DC,CORD,U,ID,NP,NDUM)
C...  KONTAKTOR VAN CILJNOG PODSEGMENTA -  OSLOBADJANJE 
        IF(ALF.LT.0.D0.OR.ALF.GT.1.D0) IND=0
        IOVR=0
C      WRITE(3,*)'***ALF,NCK,NCA,NCB,DC,IND',ALF,NCK,NCA,NCB,DC,IND
      ENDIF
C
C   NA KRAJU PRETHODNE ITERACIJE NIJE BILO KONTAKTA
C
      IF(IND.EQ.0) THEN
C  NALAZENJE NAJBLIZEG CVORA   (NCA)
      XL2M=1.D15
      DO 10 NC=1,NNC
       NC2=NELSF(LL+NC)
       XL2=0.D0
       DO 5 L=1,2
    5  D(L)=CORD(NCK,L)-CORD(NC2,L)
C
        XL2=0.D0
        DO 504 L=1,2
        I=ID(NCK,L)
        IF(I.LE.0) GO TO 502
        D(L)=D(L)+U(I)
  502   J=ID(NC2,L)
        IF(J.LE.0) GO TO 503
        D(L)=D(L)-U(J)
  503   XL2=XL2+D(L)*D(L)
  504   CONTINUE
C
       IF(XL2.LT.XL2M)THEN
        XL2M=XL2
        NCA =NC2
        NCAA=NC
       ENDIF
   10 CONTINUE
C  NALAZENJE DRUGOG CVORA CILJA   (NCB)
      IF(NCAA.GT.1.AND.NCAA.LT.NNC)THEN
       NCBB=NCAA+1
       NCB =NELSF(LL+NCBB)
       CALL ALFC(ALF,NCK,NCA,NCB,CC,SS,DC,CORD,U,ID,NP,IND)
       IF(IND.EQ.0)THEN
        NCBB=NCAA-1
        NCB =NELSF(LL+NCBB)
        CALL ALFC(ALF,NCK,NCB,NCA,CC,SS,DC,CORD,U,ID,NP,IND)
       ENDIF
        ELSEIF(NCAA.EQ.1)THEN
         NCBB=2
         NCB=NELSF(LL+2)
         CALL ALFC(ALF,NCK,NCA,NCB,CC,SS,DC,CORD,U,ID,NP,IND)
        ELSEIF(NCAA.EQ.NNC)THEN
         NCBB=NNC-1
         NCB=NELSF(LL+NCBB)
         CALL ALFC(ALF,NCK,NCB,NCA,CC,SS,DC,CORD,U,ID,NP,IND)
      ENDIF
      IF(IND.EQ.1.AND.NCAA.GT.NCBB)THEN
        NDUM=NCAA
        NCAA=NCBB
        NCBB=NDUM
        NDUM=NCA
        NCA =NCB
        NCB =NDUM
      ENDIF
      IOVR=IND
C
      ENDIF
C      WRITE(3,*)'nlm,ALF,NCK,NCA,NCB,DC,IND',NLM,ALF,NCK,NCA,NCB,DC,IND
C
C  RAZLICITI KONTAKTNI USLOVI
C
C
C-----    (1)   NEMA KONTAKTA
C
      MDIM=8
   20 IF(IND.EQ.0)THEN
       MDIM=2
       LM(1)  =IDC(NLM,1)
       LM(2)  =IDC(NLM,2)
       SKE(1) =-1.D0
       SKE(3) =-1.D0
       DO 30 J=1,2
   30  SILE(J,NLM)=0.D0
       IK1(NLM)=0
       RETURN
      ENDIF
C
C-----    (2)   KONTAKT SA ILI BEZ KLIZANJA
C
      DO 35 J=1,4
       TAU1(J)=0.D0
   35  TAU2(J)=0.D0
      ALF1=1.D0-ALF
      LM(1) =ID(NCK,1)
      LM(2) =IDC(NLM,1)
      LM(3) =ID(NCA,1)
      LM(4) =ID(NCB,1)
      LM(5) =ID(NCK,2)
      LM(6) =IDC(NLM,2)
      LM(7) =ID(NCA,2)
      LM(8) =ID(NCB,2)
C
C
      IF(LM(2).NE.0) THEN
C           KONTAKTNE SILE  - PRAVAC X
        TAU1(2)=0.D0
C*        DUM4   =SNGL(U(LM(2)))
C*        TAU1(1)=DBLE(DUM4)
        TAU1(1)=U(LM(2))
        TAU1(3)=SILE(1,NELL+NCAA)-ALF1*TAU1(1)
        TAU1(4)=SILE(1,NELL+NCBB)-ALF *TAU1(1)
        SILE(1,NLM)      =TAU1(1)
        SILE(1,NELL+NCAA)=TAU1(3)
        SILE(1,NELL+NCBB)=TAU1(4)
      ENDIF
      IF(LM(6).NE.0) THEN
C           KONTAKTNE SILE  - PRAVAC Y
        TAU2(2)=0.D0
C*        DUM4   =SNGL(U(LM(6)))
C*        TAU2(1)=DBLE(DUM4)
        TAU2(1)=U(LM(6))
        TAU2(3)=SILE(2,NELL+NCAA)-ALF1*TAU2(1)
        TAU2(4)=SILE(2,NELL+NCBB)-ALF *TAU2(1)
        SILE(2,NLM)      =TAU2(1)
        SILE(2,NELL+NCAA)=TAU2(3)
        SILE(2,NELL+NCBB)=TAU2(4)
      ENDIF
C           TRANSFORMACIJA U LOKALNI SISTEM I UVODJENJE USLOVA KLIZANJA
      DO 50 I=1,4
      TAUS(I)= CC*TAU1(I)+SS*TAU2(I)
   50 TAUN(I)=-SS*TAU1(I)+CC*TAU2(I)
C
C  PROVERA ZA OSLOBADJANJE IZ KONTAKTA
C
      IF(IOVR.NE.1.AND.TAUN(1).LT.-1.D-10)THEN
        IND=0
        GO TO 20
      ENDIF
C
C           PROVERA TIPA KONTAKTA
C 
      IND=1
      IF(DABS(TAUS(1)).GE.FS*TAUN(1)) IND=2
C
C  KONTAKT BEZ KLIZANJA
C
      IF(IND.EQ.1) THEN
C          KONTAKTNA KRUTOST 
       SKE(2) =-1.D0
       SKE(10)= ALF1
       SKE(11)= ALF
       SKE(28)=-1.D0
       SKE(32)= ALF1
       SKE(33)= ALF
      ENDIF
C
C   KONTAKT SA KLIZANJEM
C
      IF(IND.EQ.2) THEN
C   SPECIJALNI SLUCAJ: POKLAPA SE GLOBALNI I LOKLANI SISTEM
       IF(DABS(SS).LT.1.D-10)THEN
         SS=0.D0
         CC=DSIGN(1.D0,CC)
         SKE(9)=CC
       ENDIF
C   SPECIJALNI SLUCAJ: IZMEDJU GLOBALNOG I LOKLANOG SISTEMA UGAO PI/2
       IF(DABS(CC).LT.1.D-10)THEN
         SS=DSIGN(1.D0,SS)
         CC=0.D0
         SKE(31)=SS
       ENDIF
       C2=CC*CC
       S2=SS*SS
       CS=CC*SS
C          KONTAKTNA KRUTOST 
       SKE(2) =-S2
       SKE(6) = CS
       SKE(10)= S2*ALF1
       SKE(11)= S2*ALF
       SKE(12)= CS
       SKE(14)=-CS*ALF1
       SKE(15)=-CS*ALF
       SKE(19)= SKE(14) 
       SKE(24)= SKE(15) 
       SKE(28)=-C2
       SKE(32)= C2*ALF1
       SKE(33)= C2*ALF
C          KONTAKTNE SILE PRI KLIZANJU
       DO 55 I=1,4
   55  TAUS(I)= FD*DSIGN(DABS(TAUN(I)),TAUS(I))
       XS= 0.D0
       XN=-SS*DC(1)+CC*DC(2)
C           TRANSFORMACIJA U GLOBALNI SISTEM
       DO 60 I=1,4
       TAU1(I)= CC*TAUS(I)-SS*TAUN(I)
   60  TAU2(I)= SS*TAUS(I)+CC*TAUN(I)
       DC(1)=-SS*XN
       DC(2)= CC*XN
      IF(LM(2).NE.0) THEN
       SILE(1,NLM)      =TAU1(1)
       SILE(1,NELL+NCAA)=TAU1(3)
       SILE(1,NELL+NCBB)=TAU1(4)
      ENDIF
      IF(LM(6).NE.0) THEN
       SILE(2,NLM)      =TAU2(1)
       SILE(2,NELL+NCAA)=TAU2(3)
       SILE(2,NELL+NCBB)=TAU2(4)
      ENDIF
      ENDIF
C
C  RASPOREDJIVANJE KONTAKTNIH SILA
C
C           PRAVAC X
      IF(LM(2).NE.0) THEN
        IF(LM(1).NE.0) RC(LM(1))=TAU1(1)
        IF(LM(3).NE.0) RC(LM(3))=TAU1(3)
        IF(LM(4).NE.0) RC(LM(4))=TAU1(4)
C           KONTAKTNO PRODIRANJE - PRAVAC X
        RC(LM(2))=DC(1)
      ENDIF
C           PRAVAC Y
      IF(LM(6).NE.0) THEN
        IF(LM(5).NE.0) RC(LM(5))=TAU2(1)
        IF(LM(7).NE.0) RC(LM(7))=TAU2(3)
        IF(LM(8).NE.0) RC(LM(8))=TAU2(4)
C           KONTAKTNO PRODIRANJE - PRAVAC Y
        RC(LM(6))=DC(2)
      ENDIF
C..  KONTAKTOR KOD GOVORI O TIPU KONTAKTA I PRVOM CVORU CILJNOG PODSEG.
      IK1(NLM)=IND*IT1+NCAA
      ALFK(NLM)=ALF
      RETURN
      END
C=======================================================================
      SUBROUTINE ALFC(ALF,NK,NA,NB,CC,SS,DC,CORD,U,ID,NP,IND)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     NALAZENJE POLOZAJA KONTAKTA
CE     FIND CONTACT LOCATION
C
      DIMENSION CORD(NP,*),U(*),ID(NP,*),DC(2),D(4)
      EQUIVALENCE (XAK,D(1)),(YAK,D(2)),(XAB,D(3)),(YAB,D(4))
      DATA EPSIL/1.D-8/
      SQRT(X)=DSQRT(X)
C
      XAK=CORD(NK,1)-CORD(NA,1)
      YAK=CORD(NK,2)-CORD(NA,2)
      XAB=CORD(NB,1)-CORD(NA,1)
      YAB=CORD(NB,2)-CORD(NA,2)
CC
      AB2=0.D0
      DO 504 L=1,2
        L2=L+2
        I=ID(NK,L)
        IF(I.LE.0) GO TO 501
        D(L)=D(L)+U(I)
  501   II=ID(NB,L)
        IF(II.LE.0) GO TO 502
        D(L2)=D(L2)+U(II)
  502   J=ID(NA,L)
        IF(J.LE.0) GO TO 503
        D(L)=D(L)-U(J)
        D(L2)=D(L2)-U(J)
  503   AB2=AB2+D(L2)*D(L2)
  504 CONTINUE
CS.....  PRAVAC LOKALNIH OSA S,N  (COS=CC, SIN=SS)
      AB2=SQRT(AB2)
      CC=D(3)/AB2
      SS=D(4)/AB2  
C
      EPS=EPSIL*AB2
      ALF=(XAB*XAK+YAB*YAK)/(XAB*XAB+YAB*YAB)
      IF(DABS(ALF)     .LT.EPSIL) ALF=0.D0
      IF(DABS(ALF-1.D0).LT.EPSIL) ALF=1.D0
      IND=0
      DC(1)=0.D0
      DC(2)=0.D0
C  PROVERA DA LI JE DOSLO DO PRODORA
      IF((ALF.LT.0.D0.OR.ALF.GT.1.D0).OR.(XAB*YAK-YAB*XAK.GT.EPS))
     &  RETURN
C  VELICINA PRODORA
      IND=1
      DC(1)=XAK-ALF*XAB
      DC(2)=YAK-ALF*YAB
      RETURN
      END      
C=======================================================================
      SUBROUTINE MASE92(AM,MAXA,ID,EMAS,NCVSF,ITSRF,
     &                  NELSF,NEL,NP,NE,NTSF)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     PRIPADAJUCE MASE CVOROVA
CE     NODES MASSES
C
      DIMENSION AM(*),MAXA(*),EMAS(*),ID(NP,*),
     &          NCVSF(*),ITSRF(*),NELSF(*),NEL(NE,*)
      DO 10 NLM=1,NE
        NCK=NEL(NLM,1)
        IEQ=ID(NCK,1)
        IF(IEQ.LE.0) IEQ=ID(NCK,2)
        IF(IEQ.GT.0)THEN
          EMAS(NLM)=AM(MAXA(IEQ))
        ELSE
          EMAS(NLM)=0.D0
        ENDIF
   10 CONTINUE
C
      DO 30 ITS=1,NTSF
C  ITS - CILJNI SEGMENT, NNC - BROJ CVOROVA SEGMENTA
      NNC =NCVSF(ITS)
      LL  =IABS(ITSRF(ITS))-1
      NELL=NE+LL
      DO 28 NC=1,NNC
      IC=NELSF(LL+NC)
        IEQ=ID(IC,1)
        IF(IEQ.LE.0) IEQ=ID(IC,2)
        IF(IEQ.GT.0)THEN
          EMAS(NELL+NC)=AM(MAXA(IEQ))
        ELSE
          EMAS(NELL+NC)=0.D0
        ENDIF
   28 CONTINUE
   30 CONTINUE
      RETURN
      END
C=======================================================================
      SUBROUTINE VAUPDT(VA,VA0,ID,RC,EMAS,AA,BB,IK,IK1,ALFK,
     &                  NELSF,ITSRF,IDC,NEL,NCVSF,SIL,LM,U,
     &                  NP,NE,NTTOT,NTSF,DT,IVA,IKV)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     KOREKCIJA UBRZANJA I BRZINA PRI UDARU
CE     UPDATE ACCELERATION AND VELOCITY AFFTER IMPACT
C
C   IVA = 7  UBRZANJA
C   IVA = 8  BRZINE
      DIMENSION VA(*),ID(NP,*),EMAS(*),AA(*),BB(NTTOT,*),IK(*),IK1(*),
     &          ALFK(*),NELSF(*),ITSRF(*),NEL(NE,*),NCVSF(*),SIL(2,*),
     &          IDC(NE,*),VA0(*),RC(*),LM(*),U(*),DA(2),IKV(*)
      DATA IT1/1000000/
      DT2=-1.D0
      IF(IVA.EQ.7)DT2=DT*.5D0
C
C.. MATRICE   AA   I   BB
C
C.. FORMIRANJE MATRICE AA, BB   BEZ KONTAKTORA
      KK=3*NTTOT-2
      I=1
      DO 10 N=1,KK,3
      EM=EMAS(NE+I)
      IC=NELSF(I)
      AA(N)=EM
       DO 5 II=1,2
        IEQ=ID(IC,II)
        IF(IEQ.GT.0) BB(I,II)=EM*VA0(IEQ)
    5  CONTINUE
   10 I=I+1
C.. DODATAK MATRICAMA  AA, BB   OD KONTAKTORA
      DO 30 NLM=1,NE
       IC=NEL(NLM,1)
       IND0=IK(NLM) /IT1
       IND1=IK1(NLM)/IT1
C
       EM  =EMAS(NLM)
       NCAA=IK1(NLM)-IND1*IT1
       ALFA=ALFK(NLM)
C.. RIGHT
       KLR =0
C.. LEFT
       IF(ALFA.GT.0.5D0)THEN
         NCAA=NCAA+1
         KLR =-1
       ENDIF
C
       ITS =NEL(NLM,2)
       NNC =NCVSF(ITS)
       LL  =IABS(ITSRF(ITS))-1
C.. CILJNI CVOR KOME SE PRIDRUZUJE KONTAKTOR CVOR
       ICT=LL+NCAA
C.. MATRICA   AA
      IF(IND1.GT.0)THEN
       N=3*ICT-2+KLR
       AA(N)=AA(N)+EM*(1.D0-ALFA)
       N=N+1
       AA(N)=AA(N)+EM*ALFA
      ENDIF
C.. MATRICA   BB
       DO 20 II=1,2
        IEQ=ID(IC,II)
        IF(IEQ.GT.0.AND.IND1.GT.0)THEN
C**        IF(IEQ.GT.0.AND.NCAA.GT.0)THEN
C*         IF(IND1.GT.0) BB(ICT,II)=BB(ICT,II)+EM*VA0(IEQ)
         BB(ICT,II)=BB(ICT,II)+EM*VA0(IEQ)
         IF(IVA.EQ.7.OR.(IVA.EQ.8.AND.IND1.EQ.0.AND.IND0.GT.0))
     1   BB(ICT,II)=BB(ICT,II)+DT2*SIL(II,ICT+NE)
        ENDIF
   20  CONTINUE
   30 CONTINUE
C----------------------------------------
C.. NALAZENJE KORIGOVANIH VREDNOSTI
C
      CALL RESTRI(AA,BB,NTTOT)
C----------------------------------------
C.. RASPOREDJIVANJE KORIGOVANIH VREDNOSTI
C
C.. CILJ
      DO 50 ITS=1,NTSF
      NNC =NCVSF(ITS)
      LL  =IABS(ITSRF(ITS))-1
      DO 40 NC=1,NNC
      ICT=LL+NC
      IC =NELSF(ICT)
       DO 35 II=1,2
        IEQ=ID(IC,II)
        IF(IEQ.GT.0)THEN
          VA(IEQ)=BB(ICT,II)
C**          IF(IVA.EQ.7) VA(IEQ)=BB(ICT,II)
        ELSE
          BB(ICT,II)=0.D0
        ENDIF
   35  CONTINUE
   40 CONTINUE
   50 CONTINUE
C.. KONTAKTOR
      DO 80 NLM=1,NE
       NCK=NEL(NLM,1)
       IND0=IK(NLM) /IT1
       IND1=IK1(NLM)/IT1
       INDV=IKV(NLM)/IT1
C.. NO CHANGE OF STATUSS
       IMPC=0
C.. IMPACT
       IF(IND0.EQ.0.AND.IND1.GT.0)IMPC=1
C.. RELEASE
       IF(IND0.GT.0.AND.IND1.EQ.0)IMPC=-1
C
       EM  =EMAS(NLM)
       NCAA=IK1(NLM)-IND1*IT1
       NCBB=NCAA+1
       ALF =ALFK(NLM)
       ALF1=1.D0-ALF
       ITS =NEL(NLM,2)
       NNC =NCVSF(ITS)
       LL  =IABS(ITSRF(ITS))-1
       NELL=NE+LL
       ICT=LL+NCAA
       ICS=ICT+NE
C.. PODACI O PRIPADAJUCIM JEDNACINAMA
      LM(1) =ID(NCK,1)
      LM(2) =IDC(NLM,1)
      LM(5) =ID(NCK,2)
      LM(6) =IDC(NLM,2)
      IF(NCAA.GT.0)THEN
        NCA=NELSF(LL+NCAA)
        NCB=NELSF(LL+NCBB)
        LM(3) =ID(NCA,1)
        LM(4) =ID(NCB,1)
        LM(7) =ID(NCA,2)
        LM(8) =ID(NCB,2)
      ENDIF
C
      IF(IND1.NE.0)THEN
        DO 60 II=1,2
         IEQ=ID(NCK,II)
         IF(IEQ.GT.0)THEN
           DA(II) =VA(IEQ)
C*          IF((IVA.EQ.7.AND.(IND1.NE.INDV)).OR.
C*          IF( IVA.EQ.7.OR.
C*     &       (IVA.EQ.8.AND.(IND1.NE.IND0)))THEN
      IF(NCAA.GT.0)THEN
            IEQ1=ID(NCA,II)
            IEQ2=ID(NCB,II)
            IF(IEQ1.GT.0) VA(IEQ1)=BB(ICT,II)
            IF(IEQ2.GT.0) VA(IEQ2)=BB(ICT+1,II)
            VA(IEQ)=ALF1*BB(ICT,II)+ALF*BB(ICT+1,II)
      ENDIF
C*          ENDIF
           DA(II) =DA(II)-VA(IEQ)
         ENDIF
   60   CONTINUE
      ENDIF 
      IF(IVA.EQ.7)THEN
        IF(IMPC.EQ.-1)THEN
          IX=-2
          DO 65 II=1,2
           IX =IX+4
           IEQ=ID(NCK,II)
           IF(IEQ.GT.0.AND.LM(IX).GT.0)VA(IEQ)=VA(IEQ)-U(LM(IX))/EM
C           IF(IEQ.GT.0) VA(IEQ)=VA(IEQ)+SIL(II,NLM)/EM
           SIL(II,NLM)=0.D0
   65     CONTINUE
        ELSEIF(IMPC.EQ.1)THEN
          IF(IND1.NE.0)THEN
            DO 70 II=1,2
   70       SIL(II,NLM)=SIL(II,NLM)+EM*DA(II)          
          ENDIF
      IF(NCAA.GT.0)THEN
          DO 75 II=1,2
          SIL(II,NELL+NCAA)=SIL(II,NELL+NCAA)-ALF1*SIL(II,NLM)
   75     SIL(II,NELL+NCBB)=SIL(II,NELL+NCBB)-ALF *SIL(II,NLM)
      ENDIF
C
C  RASPOREDJIVANJE KONTAKTNIH SILA
C
C           PRAVAC X
        IF(LM(2).NE.0) THEN
          IF(LM(1).NE.0) RC(LM(1))=SIL(1,NLM)
          IF(LM(3).NE.0) RC(LM(3))=SIL(1,NELL+NCAA)
          IF(LM(4).NE.0) RC(LM(4))=SIL(1,NELL+NCBB)
        ENDIF
C           PRAVAC Y
        IF(LM(6).NE.0) THEN
          IF(LM(5).NE.0) RC(LM(5))=SIL(2,NLM)
          IF(LM(7).NE.0) RC(LM(7))=SIL(2,NELL+NCAA)
          IF(LM(8).NE.0) RC(LM(8))=SIL(2,NELL+NCBB)
        ENDIF
C.. ENDIF   IVA.EQ.7
        ENDIF
      ENDIF
   80 CONTINUE
      RETURN
      END
C=======================================================================
      SUBROUTINE RESTRI(A,B,NN)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CS     TRIDIJAGONALNI SISTEM
CE     TRIDIAGONAL SOLVER
C
      DIMENSION A(*),B(NN,*)
      KK=3*NN-2
      I=2
C.. FAKTORIZACIJA
      DO 10 N=1,KK,3
       IF(DABS(A(N)).GT.1.D-10)THEN
        AA=A(N+2)/A(N)
        A(N+3)=A(N+3)-A(N+1)*AA
         IF(I.LE.NN)THEN
          B(I,1)=B(I,1)-B(I-1,1)*AA
          B(I,2)=B(I,2)-B(I-1,2)*AA
         ENDIF
       ENDIF
      I=I+1
   10 CONTINUE
C
C.. ZAMENA UNAZAD
C
      I=NN
   20 IF(DABS(A(KK)).GT.1.D-10)THEN
        B(I,1)=B(I,1)/A(KK)
        B(I,2)=B(I,2)/A(KK)
      ENDIF
      I=I-1
      IF(I.EQ.0)RETURN
      KK=KK-3
      B(I,1)=B(I,1)-A(KK+1)*B(I+1,1)
      B(I,2)=B(I,2)-A(KK+1)*B(I+1,2)
      GO TO 20
      END
