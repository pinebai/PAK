C=======================================================================
C
CE        READING DATA FOR ELEMENTS, TIME FUNCTIONS AND LOADINGS
CS UCITAVANJE PODATAKA O ELEMENTIMA, VREMENSK.FUNKCIJAMA I OPTERECENJIMA
C
C   SUBROUTINE UCELEM
C              ADRESE
C              UCELE
C              PROTYP
C              UCVRFN
C              UCOPT
C              UCGRSS
C              FSPOLJ
C              UCZADP
C              ZADPOM
C              UCPOCT
C              UCTEMP
C
C=======================================================================
C
C     
      SUBROUTINE UCELEM
      use mcm_database
      USE DRAKCE8
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.       TO FORM POINTERS AND CALL ROUTINE FOR READING DATA FOR
CE.       ELEMENT GROUPS
CS.   P R O G R A M
CS.       ZA FORMIRANJE REPERA I POZIVANJE PROGRAMA
CS.       ZA UCITAVANJE PODATAKA O ELEMENTIMA
C .
CE.    P O I N T E R S
CE.       LMHT  -  COLUMN HEIGHTS
CE.       LMAXA -  ADDRESSES OF DIAGONAL ELEMENTS OF SKYLINE STIFFNESS
CE.                MATRIX
CE.       LIGRUP-  USED FOR ARRAY IGRUP(NGELEM,5).
CE.                IGRUP(NGELEM,5) - IS BASIC ARRAY WITH DATA ABOUT 
CE.                ELEMENT GROUP (NETIP,NE,IATYP,NMODM) DEFINED IN /13/
CS.   R E P E R I
CS.       LMHT  -  VISINE STUBOVA
CS.       LMAXA -  DIJAGONALNI CLANOVI
CS.       LIGRUP-  INFORMACIJE O GRUPAMA ELEMENATA
C .
CE.    V A R I A B L E S
CE.       NGELEM- TOTAL NUMBER OF DIFFERENT ELEMENT GROUPS /3/
CE.       JEDN  - NUMBER OF SYSTEM EQUATIONS 
C .
C ......................................................................
C
      CHARACTER*250 ACOZ
      include 'paka.inc'
      
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /REPERI/ LCORD,LID,LMAXA,LMHT
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /DUPLAP/ IDVA
      COMMON /GRUPER/ LIGRUP
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /BROJUK/ KARTIC,INDFOR,NULAZ
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /CVOREL/ ICVEL,LCVEL,LELCV,NPA,NPI,LCEL,LELC,NMA,NMI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /KONTKT/ ICONT,NEQC,NEQ,NWKC,LMAXAC,LRCTDT
      COMMON /NELINE/ NGENN
      COMMON /SUMELE/ ISUMEL,ISUMGR
      COMMON /SRPSKI/ ISRPS
      COMMON /MIXEDM/ MIXED,IOPGS(6),NDS
      COMMON /POSTPR/ LNDTPR,LNDTGR,NBLPR,NBLGR,INDPR,INDGR
      COMMON /NIDEAS/ IDEAS
      COMMON /CDEBUG/ IDEBUG
      COMMON /GEORGE/ TOLG,ALFAG,ICCGG
      COMMON /DRAKCE/ IDRAKCE,NELUK,NZERO,NEED1,NEED2,NEED3,NNZERO
     1                ,IROWS,LAILU,LUCG,LVCG,LWCG,LPCG,LRCG
      COMMON /CRACKS/ CONTE,SINTE,FK123(10,3),NODCR(10,14),NCRACK,LQST,
     1                LNERING,LMIE,LPSI,LQ,N100,IRING,NSEG,MAXRIN,MAXSEG
     1                ,MAXNOD,LXL,LYL,LZL,LSIF1,LXGG,LYGG,LZGG,LNNOD
      COMMON /CRXFEM/ NCXFEM,LNODTIP,LNSSN,LPSIE,LFIE,LHNOD,
     1                LPSIC,LFI,LHZNAK,LNSSE,LKELEM,LID1,LID2
      COMMON /MESLESS/ IGBM,ndif,idif(50),NKI,IKI(10)
CS INDIKATOR ZA KONVERGENCIJU KOD GREDNOG SUPERELEMENTA IKONVP
      COMMON /ENERGP/ ENE91,ENE92,ENEP,IKONVP
      COMMON /smumps/ imumps,ipar
      COMMON /VTKVALUES/ VTKIME,IVTKCOUNTER
C
c     NELUK - broj elemenata za koje je zapisan LM()na disk IDRAKCE
      NELUK=0
      IDRAKCE=39
      OPEN(IDRAKCE,FILE='FDRAK',STATUS='UNKNOWN',
     1      FORM='UNFORMATTED',ACCESS='SEQUENTIAL')
      IKONVP=1
      IF(IDEBUG.GT.0) PRINT *, ' UCELEM'
      IF(NULAZ.EQ.1.OR.NULAZ.EQ.3) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2010)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6010)
      ENDIF
      CALL DELJIV(LMAX,2,INDL)
      IF(INDL.EQ.0) LMAX=LMAX+1
C      
C     REZERVISANJE PROSTORA ZA MEHANIKU LOMA
      IF(NCRACK.GT.0) THEN
         MAXSEG=0
         MAXRIN=0
         DO I=1,NCRACK
            MAXNOD=9
            IF(NODCR(I,1).EQ.3) MAXNOD=21
            IF(NODCR(I,11).GT.MAXSEG) MAXSEG=NODCR(I,11)
            IF(NODCR(I,12).GT.MAXRIN) MAXRIN=NODCR(I,12)
         ENDDO
         IF(MAXSEG.EQ.0) MAXSEG=1
         IF(MAXRIN.EQ.0) MAXRIN=1

         LXGG=LMAX
         LMAX=LXGG+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LYGG=LMAX
         LMAX=LYGG+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LZGG=LMAX
         LMAX=LZGG+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LXL=LMAX
         LMAX=LXL+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LYL=LMAX
         LMAX=LYL+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LZL=LMAX
         LMAX=LZL+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA 
         LSIF1=LMAX
         LMAX=LSIF1+NCRACK*MAXSEG*3*IDVA
         LQST=LMAX
         LMAX=LQST+NCRACK*MAXSEG*MAXRIN*N100*MAXNOD*IDVA
         LQ=LMAX
         LMAX=LQ+NP*MAXRIN*IDVA
         LNERING=LMAX
         LMIE=LNERING+NCRACK*MAXSEG*MAXRIN
         LMAX=LMIE+NCRACK*MAXSEG*MAXRIN*N100
         IF(LMAX.GT.MTOT) CALL ERROR(1)
         CALL CLEAR(A(LXGG),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LYGG),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LZGG),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LXL),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LYL),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LZL),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LSIF1),NCRACK*MAXSEG*3)
         CALL CLEAR(A(LQST),NCRACK*MAXSEG*MAXRIN*N100*MAXNOD)
         CALL CLEAR(A(LQ),NP*MAXRIN)
         CALL ICLEAR(A(LNERING),NCRACK*MAXSEG*MAXRIN*(N100+1))
      ENDIF
C      
C     REZERVISANJE PROSTORA ZA XFEM MEHANIKU LOMA
c     (ako se radi automatski rast prsline ovo mora da se prebaci u pak07.for)
      IF(NCXFEM.GT.0.OR.(NCRACK.GT.0.AND.IGBM.NE.0)) THEN
         CALL DELJIV(LMAX,2,INDL)
         IF(INDL.EQ.0) LMAX=LMAX+1
         LPSIE=LMAX
         LFIE=LPSIE+NP*IDVA
         LHNOD=LFIE+NP*IDVA
         LNODTIP=LHNOD+NP*IDVA
         LNSSN=LNODTIP+NP
         LMAX=LNSSN+NP
         IF(LMAX.GT.MTOT) CALL ERROR(1)
         CALL CLEAR(A(LPSIE),3*NP)
         CALL ICLEAR(A(LNODTIP),2*NP)
      ENDIF
C
      LIGRUP=LMAX
      LMAX8=0
      ITERGL=0
      ISUMEL=0
      ISUMGR=0
      NGENN=0
      DO 10 JPBB=1,JPS
        IF(JPS.GT.1) THEN
           JPBR=JPBB
        ELSE
           JPBR=JPS1
        ENDIF
        IDIREK=1
        NRAD=0
        NEQC=0
        NEQ =JEDN
        NGEL=0
        NGENL=0
        LGEOM=0
        NGEOM=0
        ITERM=0
        CALL UCELP(A(LIPODS),1)
        NPP=NP
        NMM=0
        IF(JPS.GT.1) THEN
          NMM=NGA-NGI+1
          NPP=NP+NPK
          IF(NULAZ.EQ.1.OR.NULAZ.EQ.3) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2070) JPBR
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6070) JPBR
          ENDIF
        ENDIF
C       ZASTO JE UVEDEN NDOD
        NDOD=0
        IF(NCXFEM.GT.0) NDOD=1000
        LMHT=LIGRUP+NGELEM*5
        LMAX=LMHT+2*JEDN+1+NDOD
        NDOD=JEDN+1+NDOD
        IF(LMAX.GT.MTOT) CALL ERROR(1)
        JEDN1=LMAX-LIGRUP
        CALL ICLEAR(A(LIGRUP),JEDN1)
        LID=LMAX
        LMAX=LID+NPP*6
        IF(MIXED.EQ.1) LMAX=LMAX+NPP*6
        IF(ICVEL.EQ.0) THEN
          LCVEL=LMAX
          LELCV=LMAX
          NP6=NP*6
          IF(MIXED.EQ.1) NP6=NP6*2
        ELSE
          NPM=NPA-NPI+1
          LCVEL=LMAX
          LELCV=LCVEL+NPP
          LMAX=LELCV+NPM+NMM
          NP6=NPP*7+NPM+NMM
        ENDIF
        CALL DELJIV(LMAX,2,INDL)
        IF(INDL.EQ.0) LMAX=LMAX+1
        LCORD=LMAX
        LMAX=LCORD+NPP*3*IDVA
        LRAD=LMAX
        LMAX=LRAD+LDUZI/8*IDVA
        IF(LMAX.GT.MTOT) CALL ERROR(1)
        CALL READDD(A(LCORD),NPP*3,IPODS,LMAX13,LDUZI)
        CALL IREADD(A(LID),NP6,IPODS,LMAX13,LDUZI)
        IF(IDEAS.GT.6) THEN
           IF(NBLGR.GE.0.AND.NP.GT.0) THEN
              CALL TGRAFK(A(LCORD),A(LCVEL),ICVEL,NP,IGRAF)
              CALL TGRAFB(A(LID),A(LCVEL),ICVEL,NP,IGRAF)
              CALL TGRAFR(A(LID),A(LCVEL),ICVEL,NP,IGRAF)
           ENDIF
        ENDIF
        IF(NBLGR.GE.0.AND.NP.GT.0) THEN
           CALL TGRAUK(A(LCORD),A(LCVEL),ICVEL,NP,49)
           KOJPAK = mcm_kojpak
        IF((KOJPAK.EQ.4).OR.(KOJPAK.EQ.5)) THEN
           CALL PAKSVTK(A(LCORD),A(LCVEL),ICVEL,NP,49)
! TODO TOPLAOVIC premestiti poziv za vtk u period subrutinu  
        ENDIF   
           CALL TGRAUB(A(LID),A(LCVEL),ICVEL,NP,49)
        ENDIF
        IF(ITEST.GT.0) THEN
          NGEL=1
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2000)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6000)
          CALL ISPITA(ACOZ)
          CALL READTT(A(LMHT),JEDN+1)
        ELSE
          NP=NPP
CE        READING DATA FOR ALL ELEMENT GROUPS
c         WRITE(3,*) ' PRE UCELE LMAX',LMAX

          CALL UCELE(A(LIGRUP))
          LMAXA=LRAD
          LMAX=LMAXA+JEDN+1
          WRITE(3,*) ' POSLE UCELE LMAX',LMAX
         IF(LMAX.GT.MTOT) CALL ERROR(1)
          LMAXM=0
CE        CALCULATING ACTIVE COLUMN HEIGHTS AND ADDRESSES OF DIAGONAL 
CE        ELEMENTS IN SKYLINE STIFFNESS MATRIX
C          CALL IWRR(A(LMHT),JEDN+1,'MHT ')



         ALLOCATE (MAXA8(JEDN+1))
         
         
         
         
          CALL ADRESE(MAXA8,A(LMHT),NWK8,A(LMAXA))
         IF(NWK8.LT.0) STOP 'NWK8.LT.0 - PAK05.FOR'
C          CALL IWRR(A(LMAXA),JEDN+1,'MAXA')
C          write(3,*) 'maxa8',(maxa8(i),i=1,4)
        ENDIF
C
        LMAXA=LMHT

        IF(NEQ.GT.NDOD) STOP 'NEQ.GT.NDOD'
C
        IF(NCXFEM.GT.0.and.JEDN.GT.NEQ) NEQ=JEDN
        LMAXAC=LMAXA +NEQ+1
        LID   =LMAXAC+NEQC+1
c        WRITE(3,*) 'JEDN,NEQ,NDOD,nwk8,nwk',JEDN,NEQ,NDOD,nwk8,nwk
C
        IF(JPS.GT.1) THEN
          CALL UCELP(A(LIPODS),2)
          NP6=NGELEM*5+JEDN+1 
          CALL IWRITD(A(LIGRUP),NP6,IPODS,LMAX13,LDUZI)
          IF(MAX13.LT.LMAX13) MAX13=LMAX13
        ENDIF
        NGENN=NGENN+NGENL
        LMAX=LID
   10 CONTINUE
      
      IF(IABS(ICCGG).EQ.1) THEN
        IF(LMAX.GT.MTOT) CALL ERROR(1)
        
C************************************************
C************************************************
C************************************************

C     NOVO DRAKCETOVO TACKANJE

        
        
C     FLAG ZA NOVO DRAKCETOVO TACKANJE
C     AKO JE 1 RADI NOVO JOS NEDOVOLJNO TESTIRANO 
C     AKO JE BILO STA DRUGO RADI PO STAROM PROVERENOM TACKANJU  
CE       IDINDOT = 0 -> create IROWS with temporary array (quicker)
CE       IDINDOT = 1 -> IROWS created dinamicly due unsifitant memory 
CE                      for temporary array
        IDINDOT = 1
        IF(IDINDOT.NE.1)THEN
            ALLOCATE (ISK(1+NWK8/28), STAT = iAllocateStatus)
            IF (iAllocateStatus /= 0) IDINDOT = 1        
        ENDIF
        
        I2=1
        IF(IMUMPS.EQ.1) I2=2 
        IROWS=LMAX
        
        WRITE(*,*)'IDINDOT = ',IDINDOT
        WRITE(3,*)'IDINDOT = ',IDINDOT
        CALL VREM(5)

        IF(IDINDOT.EQ.1) THEN
            IF(LMAX + JEDN*4.GT.MTOT) CALL ERROR(1)
C            LMAX se povecava za JEDN jer se automatski popunjava 
C            sa dijagonalnim elementima
CE            LMAX automaticly increased for JEDN becaouse of automatic 
CE            population with diagonal elements
            LMAX = LMAX + JEDN
            CALL ISPAKUJ2(A(IROWS), A(LMAXA), MAXA8, NWK8, JEDN)
            NWK = NNZERO
!            IF(IMUMPS.EQ.1) THEN
!                LMAX = LMAX + NWK
!            ENDIF
!            CALL DELJIV(LMAX,2,INDL)
!            IF(INDL.EQ.0) LMAX=LMAX+1
!            IF(LMAX.GT.MTOT) CALL ERROR(1)

C     U ELSE IDE KADA IDE PO STAROM TACKANJU         
          
        ELSE
!          LISK=LMAX
!          LMAX=LISK+1+NWK8/28
c          nwk8=19000000000
            write(3,*) 'pre alociranja isk - LMAX',LMAX
            write(*,*) 'pre alociranja isk'
C            ALLOCATE (ISK(1+NWK8/28), STAT = iAllocateStatus)
            mema=(1+NWK8/28)*4
C            IF (iAllocateStatus /= 0) write(3,*)'*** Not enough memory **'
c            IF (iAllocateStatus /= 0) STOP '*** Not enough memory ***'
            write(3,*) 'alocirao isk - LMAX',LMAX
            write(*,*) 'alocirao isk'
c            WRITE(*,*) ' Potreban prostor LMAX',LMAX
c            WRITE(3,*) ' Potreban prostor LMAX',LMAX
C	       CALL IWRR(A(LMAXA),JEDN+1,'MAX0')
c            WRITE(3,*) 'pre JEDN,NEQ,NDOD,nwk8,nwk',JEDN,NEQ,NDOD,nwk8,nwk
            CALL ISPAKUJ(A(IROWS),ISK,MAXA8,NWK8,JEDN)
c            WRITE(3,*) 'pos JEDN,NEQ,NDOD,nwk8,nwk',JEDN,NEQ,NDOD,nwk8,nwk
            LMAX=IROWS+NNZERO*I2
c            WRITE(*,*) ' IROWS,NNZERO,I2,LMAX',IROWS,NNZERO,I2,LMAX
c            WRITE(3,*) ' IROWS,NNZERO,I2,LMAX',IROWS,NNZERO,I2,LMAX
            IF(NNZERO.LT.0) STOP 'NNZERO.LT.0 - PAK05.FOR'
            IF(LMAX.GT.MTOT) CALL ERROR(1)

c            WRITE(3,*) ' IROWS,LMAXA,LMAX',IROWS,LMAXA,LMAX
            IF(ICCGG.EQ.1)THEN
                CALL FORM(A(IROWS),ISK,A(LMAXA),MAXA8,JEDN,NNZERO,NWK8)
            ELSE
                CALL FORM0(A(IROWS),ISK,A(LMAXA),MAXA8,JEDN,NNZERO,NWK8)
            ENDIF
         
!          NWKOLD=NWK
            NWK=NNZERO
            DEALLOCATE (ISK)

        ENDIF
        
        LMAX=IROWS+NWK*I2
        CALL DELJIV(LMAX,2,INDL)
        IF(INDL.EQ.0) LMAX=LMAX+1
c        WRITE(3,*) 'DeA  JEDN,NEQ,NDOD,nwk8,nwk',JEDN,NEQ,NDOD,nwk8,nwk
        IF(LMAX.GT.MTOT) CALL ERROR(1)
c       kraj if uslova novo/staro tackanje, odavde se nastavlja zajednicki kod    
        IF(I2.EQ.2)THEN   
            CALL FORMCOL(A(IROWS+NWK),A(LMAXA),JEDN)
        END IF
        
        CALL VREM(6)
        
C       stampa za proveru radnih vektora        
c        CALL STIROW(A(IROWS), A(LMAXA), JEDN, IDINDOT, ICCGG, IMUMPS)
      else
c   drugi deo if uslova   IF(IABS(ICCGG).EQ.1) THEN (iccgg <> 1, -1)
        CALL IJEDNA8(A(LMAXA),MAXA8,JEDN+1)
        NWK=NWK8
         
         
         
         
      ENDIF
c   kraj if uslova   IF(IABS(ICCGG).EQ.1) THEN        
      
      
      
      
      
      
      IF(JPS.GT.1) LMAX=LIGRUP
      CALL DELJIV(LMAX,2,INDL)
      IF(INDL.EQ.0) LMAX=LMAX+1
      LRAD=LMAX
      DEALLOCATE (MAXA8)
      CLOSE(IDRAKCE,STATUS='DELETE')
C		CALL IWRR(A(LMAXA),JEDN+1,'MAXa')
C        WRITE(3,*) 'izl1 JEDN,NEQ,NDOD,nwk8,nwk',JEDN,NEQ,NDOD,nwk8,nwk
      RETURN
C-----------------------------------------------------------------------
 2000 FORMAT(///' V E K T O R   M A X A')
 2010 FORMAT(///'1'/6X,'U L A Z N I    P O D A C I    O    G R U P A M A
     1     E L E M E N A T A'/6X,70('-'))
 2070 FORMAT(//////6X,
     1    'P  O  D  S  T  R  U  K  T  U  R  A     B  R  O  J .... JPBR =
     1',I5/6X,66('-'))
C-----------------------------------------------------------------------
 6000 FORMAT(///' V E C T O R   M A X A')
 6010 FORMAT(///'1'/6X,'I N P U T    D A T A    F O R    E L E M E N T
     1  G R O U P S'/6X,61('-'))
 6070 FORMAT(//////6X,
     1    'S  U  B  S  T  R  U  C  T  U  R  E     N  U  M  B  E  R .... 
     1JPBR =',I5/6X,72('-'))
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE ADRESE(MAXA,MHT,NWK8,MAXA4)
!      USE DRAKCE8
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO CALCULATE ADDRESSES OF DIAGONAL ELEMENTS IN SKYLINE MATRIX
CS.   P R O G R A M
CS.      ZA FORMIRANJE VEKTORA MAXA
C .
CE.    V E C T O R S
CE.      MHT  - ACTIVE COLUMN HEIGHTS
CE.      MAXA - ADDRESES OF DIAGONAL ELEMENTS
CS.      MHT  - VISINE STUBOVA
CS.      MAXA - ADRESE DIJAGONALNIH CLANOVA
C .
C ......................................................................
C
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /GEORGE/ TOLG,ALFAG,ICCGG
      COMMON /CDEBUG/ IDEBUG
      INTEGER*8 MAXA,NWK8
      DIMENSION MAXA(*),MHT(*),ioffset(10),MAXA4(*)

C
CE    VECTOR MAXA
CS    VEKTOR MAXA
C
      IF(IDEBUG.GT.0) PRINT *, ' ADRESE'
      IF(JEDN.EQ.0) RETURN
      MAXA(1)=1
      MAXA(2)=2
      MK=0
      IF(JEDN.EQ.1) GO TO 100
c      ioff=0
c      nnwk=0
      DO 10 I=2,JEDN
      IF(MHT(I).GT.MK) MK=MHT(I)
c      if (ioff.gt.0) then
c            MAXA(I+1)=-MAXA(ioffset(ioff))+MAXA(I)+MHT(I)+1
c      else
            MAXA(I+1)=MAXA(I)+MHT(I)+1
c      endif
c      if (MAXA(I+1).gt.(AI32-jedn)) then
c         ioff=ioff+1
c         ioffset(ioff)=I+1
c         nnwk=nnwk+maxa(I+1)/28+1
c         write (*,*) 'I=',I,'I32=',AI32,'MAXA(I+1)=',MAXA(I+1)
c      endif
   10 continue
  100 MK=MK+1
      NWK8=(MAXA(JEDN+1)-1)
c      if (ioff.gt.0) NWK=NWK/28+1+nnwk
      IF(JPS.GT.1.AND.JPBR.LT.JPS1) NWP=MAXA(JEDNP+1)-1
      LMAXM=MK
CN OBRNUTA NUMERACIJA U MATRICI SISTEMA KOD NESIMETRICNOG
      IF(ICCGG.EQ.2) THEN
         DO 300 I=2,JEDN
            MAXA(I)=MAXA(I-1)+MAXA(I+1)-MAXA(I)
  300    CONTINUE
      ENDIF
CN
!      DO 201 I=1,JEDN+1
!  201 MAXA4(I)=MAXA(I)
!      DO 200 I=1,JEDN+1
!  200 MHT(I)=MAXA4(I)
      RETURN
      END
C=======================================================================
C
C
C=======================================================================
      SUBROUTINE ADRESEP(MAXA,MHT)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO CALCULATE ADDRESSES OF DIAGONAL ELEMENTS IN SKYLINE MATRIX
CS.   P R O G R A M
CS.      ZA FORMIRANJE VEKTORA MAXA
C .
CE.    V E C T O R S
CE.      MHT  - ACTIVE COLUMN HEIGHTS
CE.      MAXA - ADDRESES OF DIAGONAL ELEMENTS
CS.      MHT  - VISINE STUBOVA
CS.      MAXA - ADRESE DIJAGONALNIH CLANOVA
C .
C ......................................................................
C
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /GEORGE/ TOLG,ALFAG,ICCGG
      COMMON /CDEBUG/ IDEBUG
  
      DIMENSION MAXA(*),MHT(*),ioffset(10)
C
CE    VECTOR MAXA
CS    VEKTOR MAXA
C
      IF(IDEBUG.GT.0) PRINT *, ' ADRESE'
      IF(JEDN.EQ.0) RETURN
      MAXA(1)=1
      MAXA(2)=2
      MK=0
      IF(JEDN.EQ.1) GO TO 100
c      ioff=0
c      nnwk=0
      DO 10 I=2,JEDN
      IF(MHT(I).GT.MK) MK=MHT(I)
c      if (ioff.gt.0) then
c            MAXA(I+1)=-MAXA(ioffset(ioff))+MAXA(I)+MHT(I)+1
c      else
            MAXA(I+1)=MAXA(I)+MHT(I)+1
c      endif
c      if (MAXA(I+1).gt.(AI32-jedn)) then
c         ioff=ioff+1
c         ioffset(ioff)=I+1
c         nnwk=nnwk+maxa(I+1)/28+1
c         write (*,*) 'I=',I,'I32=',AI32,'MAXA(I+1)=',MAXA(I+1)
c      endif
   10 continue
  100 MK=MK+1
      NWK=(MAXA(JEDN+1)-1)
c      if (ioff.gt.0) NWK=NWK/28+1+nnwk
      IF(JPS.GT.1.AND.JPBR.LT.JPS1) NWP=MAXA(JEDNP+1)-1
      LMAXM=MK
CN OBRNUTA NUMERACIJA U MATRICI SISTEMA KOD NESIMETRICNOG
      IF(ICCGG.EQ.2) THEN
         DO 300 I=2,JEDN
            MAXA(I)=MAXA(I-1)+MAXA(I+1)-MAXA(I)
  300    CONTINUE
      ENDIF
CN
      DO 200 I=1,JEDN+1
  200 MHT(I)=MAXA(I)
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE UCELP(NPODS,IND)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .                                                                     
CE.    P R O G R A M                                                    
CE.        TO BACK READ BASIC DATA ABOUT SUBSTRUCTURES
CS.    P R O G R A M                                                    
CS.        ZA VRACANJE UCITANIH OPSTIH PODATAKA O PODSTRUKTURAMA        
C .                                                                     
CE.    V E C T O R
CE.      I=1,JPS1   (JPS - TOTAL SUBSTRUCTURE NUMBER)                  
CE.        NPODS(I,*) - BASIC DATA ABOUT SUBSTRUCTURE
CS.    V E K T O R                                                     
CS.      I=1,JPS1   (JPS - BROJ PODSTRUKTURA)                          
CS.        NPODS(I,*) - OPSTI PODACI O PODSTRUKTURAMA I BROJEVI STAZA   
C .                                                                     
C ......................................................................
C
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /OPTERE/ NCF,NPP2,NPP3,NPGR,NPGRI,NPLJ,NTEMP
      COMMON /ZADATA/ LNZADJ,LNZADF,LZADFM,NZADP
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /CVOREL/ ICVEL,LCVEL,LELCV,NPA,NPI,LCEL,LELC,NMA,NMI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      DIMENSION NPODS(JPS1,*)
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' UCELP'
      GO TO (1,2,3,4,5,6,7,8,9,10,11,12),IND
C
    1 IF(JPS.EQ.1) THEN
        LMAX13=NPODS(JPS1,1)-1
      ELSE 
        LMAX13=NPODS(JPBR,1)-1
        NP    =NPODS(JPBR,3)
        NPA   =NPODS(JPBR,4)
        NPI   =NPODS(JPBR,5)
        JEDN  =NPODS(JPBR,6)
        NPK   =NPODS(JPBR,7)
        NGA   =NPODS(JPBR,8)
        NGI   =NPODS(JPBR,9)
        NGELEM=NPODS(JPBR,11)
        JEDNP =NPODS(JPBR,23)
        NRAD  =NPODS(JPBR,33)
        ITERG=ITERGL 
      ENDIF
      RETURN
C
    2 LMAX13=MAX13
      NPODS(JPBR,12)=LMAX13+1
      ITERG=ITERGL-ITERG
      NPODS(JPBR,13)=ITERG
      NPODS(JPBR,24)=NWP
      NPODS(JPBR,25)=NWK
      NPODS(JPBR,26)=LMAXM
      NPODS(JPBR,28)=NGEL
      NPODS(JPBR,29)=NGENL
      NPODS(JPBR,30)=LGEOM
      NPODS(JPBR,31)=NGEOM
      NPODS(JPBR,32)=ITERM
      NPODS(JPBR,33)=NRAD
      NPODS(JPBR,69)=IDIREK
      RETURN
C
    3 NPODS(JPBR,15)=NCF
      NPODS(JPBR,16)=NPP2  
      NPODS(JPBR,17)=NPP3  
      NPODS(JPBR,18)=NPGR  
      NPODS(JPBR,19)=NPGRI 
      NPODS(JPBR,20)=NPLJ  
      NPODS(JPBR,21)=NTEMP 
      NPODS(JPBR,22)=NZADP
      RETURN
C 
    4 NPODS(JPS1,15)=NCF
      NPODS(JPS1,21)=NTEMP 
      NPODS(JPS1,22)=NZADP
      RETURN
C
    5 LMAX13=NPODS(JPS1,1)-1
      NPG   =NPODS(JPS1,3)
      NGA   =NPODS(JPS1,4)
      NGI   =NPODS(JPS1,5)
      JEDNG =NPODS(JPS1,6)
      NRAD  =NPODS(JPS1,33)
      RETURN
C
    6 LMAX13=MAX13
      NPODS(JPBR,34)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
    7 LMAX13=MAX13
      NPODS(JPBR,62)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
    8 LMAX13=MAX13
      NPODS(JPBR,63)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
    9 LMAX13=MAX13
      NPODS(JPBR,64)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
   10 LMAX13=MAX13
      NPODS(JPBR,65)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
   11 LMAX13=MAX13
      NPODS(JPBR,36)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
C
   12 LMAX13=MAX13
      NPODS(JPBR,89)=LMAX13+1
      NPODS(JPBR,33)=NRAD
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE UCELE(IGRUP)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.       TO READ DATA FOR ELEMENT GROUP
CS.   P R O G R A M
CS.       ZA UCITAVANJE PODATAKA O ELEMENTIMA
C .
CE.    P O I N T E R S
CE.       LRAD  - FREE SPACE IN WORKING ARRAY A(*) USED FOR ELEMENT 
CE.               GROUP INTEGRATION
CE.    V A R I A B L E S
CE.     NGE=1,NGELEM (NGELEM - TOTAL NUMBER OF DIFFERENT ELEMENT GROUPS)
CE.      /13/ USER MANUAL
CE.       NETIP - ELEMENT TYPE    
CE.                        =1; TRUSS (2 NODES)
CE.                        =2; ISOPARAMETRIC 2D (4-9 NODES)
CE.                        =3; ISOPARAMETRIC 3D (8-21 NODES)
CE.                       ETC
CE.       NE    - NUMBER OF ELEMENTS IN THE ELEMENT GROUP
CE.       IATYP - INDICATOR FOR TYPE OF ANALYSIS
CE.                        =0; LINEAR ANALISYS
CE.                        =1; MATERIALLY NONLINEAR ONLY (MNO) 
CE.                        ETC
CE.       NMODM - MATERIAL MODEL TYPE (SEE /11/)
CE.                        =1; ELASTIC ISOTROPIC
CE.                        =2; ELASTIC ANISOTROPIC
CE.                        ETC
CE.       LMAX8 - RECORD NUMBER OF DIRECT ACCESS FILE (ZIELEM), FOR 
CE.               ELEMENT GROUP DATA
CE.       NRAD  - MAXIMUM SPACE USED FOR ELEMENT GROUP INTEGRATION
CE.               DEFINED DURING ELEMENT GROUP READING DATA
C .
C ......................................................................
C
      CHARACTER*250 ACOZ
      include 'paka.inc'
      
      CHARACTER*6 IMD
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ELEIND/ NGAUSX,NGAUSY,NGAUSZ,NCVE,ITERME,MAT,IETYP
      COMMON /BROJUK/ KARTIC,INDFOR,NULAZ
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /POSTPR/ LNDTPR,LNDTGR,NBLPR,NBLGR,INDPR,INDGR
      COMMON /BTHDTH/ INDBTH,INDDTH,LTBTH,LTDTH
      COMMON /MATERM/ LMODEL,LGUSM
      COMMON /UPDLAG/ LUL,LCORUL
      COMMON /KONTK2/ NPROCK
      COMMON /SRPSKI/ ISRPS
      COMMON /COEFSM/ COEF(3),ICOEF
      COMMON /IKOVAR/ INDKOV
      COMMON /CEPMAT/ INDCEP
      COMMON /LEVDES/ ILEDE,NLD,ICPM1
      COMMON /RESTAR/ TSTART,IREST
      COMMON /DEFNAP/ NAPDEF
      common /krutot/ nlnc,nkrt,mxvez,lnkt,llncvz,lnbv,lncgl,lnvez,
     1                lncvez,lac,limpc,ljmpc,livez,mxvc,mxrac,lxmass
      COMMON /BOBAN3/ IBOB,IC69
      COMMON /ODUZMI/ INDOD
C
      DIMENSION IGRUP(NGELEM,*)
      COMMON /CDEBUG/ IDEBUG
      COMMON /ISTRES/ ISTRESS
C
      IF(IDEBUG.GT.0) PRINT *, ' UCELE'
C INDIKATOR ODUZIMANJA POMERANJA IZ PRVOG KORAKA
      INDOD=0
C...  REASTART
C CERNI
      IF(IREST.EQ.1) THEN
C        PREPISIVANJE DISKA ZA ELEMENTE POSLE RESTARTA ZBOG ALFI
         IDUM=28
         IMD='ZBELEM'
         OPEN (IDUM,FILE=IMD,STATUS='OLD',
     1         FORM='UNFORMATTED',ACCESS='DIRECT',RECL=LDUZI)
         CALL PREPEL(A(LRAD),IDUM,IELEM,LDUZI)
         CLOSE(IDUM,STATUS='KEEP')
      ENDIF
C CERNI
C
      NPROCK=0
CS    INDIKATOR KORISCENJA CP MATRICE: 0-KORISTI, 1-NE KORISITI
      INDCEP=0
CS    INDIKATOR ZA GLAVNE VREDNOSTI: 0-NAPONI, 1-DEFORMACIJE
      NAPDEF=0
CE    LOOP OVER ELEMENT GROUPS
      DO 100 NGE=1,NGELEM
         CALL ISPITA(ACOZ)
      IF(INDFOR.EQ.1)
     1READ(IULAZ,*) NETIP,NE,IATYP,NMODM,INDBTH,INDDTH,
     1              INDKOV,ISTRESS,(COEF(I),I=1,3)
C     1              INDKOV,ICOEF,(COEF(I),I=1,3)
      IF(INDFOR.EQ.2.and.ind56.eq.0)
     1READ(ACOZ,1000) NETIP,NE,IATYP,NMODM,INDBTH,INDDTH,
     1                INDKOV,ISTRESS,(COEF(I),I=1,3)
      IF(INDFOR.EQ.2.and.ind56.eq.1)
     1READ(ACOZ,4000) NETIP,NE,IATYP,NMODM,INDBTH,INDDTH,
     1                INDKOV,ISTRESS,(COEF(I),I=1,3)
C     1                INDKOV,ICOEF,(COEF(I),I=1,3)  
C INDIKATOR ODUZIMANJA POMERANJA IZ PRVOG KORAKA

      IF(NMODM.EQ.9) INDOD=1
C     INDIKATOR ZA BOBANOV 3D
      IBOB=0
      IF(NETIP.EQ.26) THEN
         NETIP=2
         IBOB=1
         IC69=0
      ENDIF
      IF(NETIP.EQ.27) THEN
         NETIP=2
         IBOB=1
         IC69=1
      ENDIF
      IF(NETIP.EQ.36) THEN
         NETIP=3
         IBOB=1
         IC69=0
      ENDIF
      IF(NETIP.EQ.37) THEN
         NETIP=3
         IBOB=1
         IC69=1
      ENDIF
      ICOEF=0
CE    ILEDE: INDICATOR FOR LEFT-HAND OR RIGHT-HAND BASIS FOR LARGE STRAINS
CE    (=0-LEFT-HAND;=1-RIGHT-HAND)
CS    ILEDE: INDIKATOR ZA LEVU I DESNU BAZU ZA VELIKE DEFORMACIJE
CS    (=0-LEVA,=1-DESNA)
      ILEDE=0
CE    ICPM1: INDICATOR FOR STORAGE OF MATRIX FOR LARGE STRAINS
CS    ICPM1: INDIKATOR ZA CUVANJE MATRICA ZA VELIKE DEFORMACIJE
C     [Be (ICPM1=0); Cp**-1 (ICPM1=1); Fp (ICPM1=2)]
      ICPM1=0
CE    NLD: DIMENSION OF MATRIX FOR STORAGE: 6=(Be, Cp**-1); 9=(Fp)
CS    NLD: BROJ PODATAKA KOJI SE CUVA: 6=(Be, Cp**-1); 9=(Fp)
      IF(NETIP.EQ.2.OR.NETIP.EQ.21) THEN
         NLD=4
         IF(ICPM1.EQ.2.AND.IATYP.GE.4) NLD=9
      ELSE
         NLD=6
         IF(ICPM1.EQ.2.AND.IATYP.GE.4) NLD=9
      ENDIF
      IF(IATYP.LT.0) THEN
         IATYP=-IATYP
         ILEDE=1
         NLD=9
C         IF(NETIP.EQ.2.OR.NETIP.EQ.21) NLD=5
      ENDIF
      IF(NMODM.LT.0) THEN
         NMODM=-NMODM
         INDCEP=1
      ENDIF
      IF(DABS(COEF(1)).LT.1.D-10) COEF(1)=5.D0/6.D0
      IF(DABS(COEF(2)).LT.1.D-10) COEF(2)=5.D0/6.D0
      IF(DABS(COEF(3)).LT.1.D-10) COEF(3)=1.D0
         NNTIP=NETIP
         CALL PODTYP(NETIP)
         CALL PROTYP
C EFG
         IF(NETIP.EQ.20) THEN
            NETIP=13
         ENDIF
CS GAP
         IF(NETIP.EQ.12) THEN
            LUL  =1
            NETIP=14
            NMODM=1
            IATYP=2
         ENDIF
CS ELASTICNI OSLONAC
         IF(NETIP.EQ.11) THEN
            LUL  =1
            NETIP=12
            NMODM=1
         ENDIF
CS KONTAKT
         IF(NETIP.EQ.92) THEN
            LUL  =1
            NETIP=10
            NMODM=1
         ENDIF
         IF(NETIP.EQ.93) THEN
            LUL  =1
            NETIP=11
            NMODM=1
         ENDIF
C
         IGRUP(NGE,1)=NETIP
         IGRUP(NGE,2)=NE
         IGRUP(NGE,3)=IATYP
         IF(NMODM.EQ.0) NMODM=1
         IGRUP(NGE,4)=NMODM
         IGRUP(NGE,5)=LMAX8+1
         IF(IATYP.EQ.0) NGEL=NGEL+1
         IF(IATYP.GE.3) LUL=1
         IF(IATYP.GT.0) NGENL=NGENL+1
         IF(IATYP.LE.1) LGEOM=LGEOM+1
         IF(IATYP.GE.2) NGEOM=NGEOM+1
         IF(NMODM.GE.5.OR.IATYP.GE.2) ITERGL=ITERGL+1
         IF(MODTMP(NMODM).EQ.1) ITERM=ITERM+1
         IF(NULAZ.EQ.1.OR.NULAZ.EQ.3) THEN
            CALL WBROJK(KARTIC,0)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2020) NGE,NNTIP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6020) NGE,NNTIP
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2030) NGE,NE,NGE,IATYP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6030) NGE,NE,NGE,IATYP
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2040) NGE,NMODM
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6040) NGE,NMODM
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2041)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6041)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2042)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6042)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2050) INDBTH,INDDTH
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6050) INDBTH,INDDTH
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2060) INDKOV,ISTRESS,(COEF(I),I=1,3)
C     1WRITE(IZLAZ,2060) INDKOV,ICOEF,(COEF(I),I=1,3)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6060) INDKOV,ISTRESS,(COEF(I),I=1,3)
C     1WRITE(IZLAZ,6060) INDKOV,ICOEF,(COEF(I),I=1,3)
         ENDIF
CE       READING POINTERS FOR MATERIAL MODEL
CS       UCITAVANJE REPERA ZA MODEL MATERIJALA
         IF(NBLGR.GE.0) CALL UCITAM(A(LMODEL),NMODM)
         ITERME=MODTMP(NMODM)
         LMAX=LRAD
CE       READING DATA FOR ELEMENT TYPE (=NETIP) OF ELEMENT GROUP (=NGE)
         CALL ELEME(NETIP,1)
         NPROS=LMAX-LRAD
         IF(NETIP.EQ.10.AND.NPROCK.LT.NPROS) NPROCK=NPROS
         IF(NRAD.LT.NPROS) NRAD=NPROS
         IF(NULAZ.EQ.1.OR.NULAZ.EQ.3) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2100) NGE,NPROS
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6100) NGE,NPROS
         ENDIF
  100 CONTINUE
      if(nkrt.gt.0) then
            CALL TGRAFKT(A(LNCGL),A(LNVEZ),A(LNCVEZ))
      endif
      RETURN
C
 1000 FORMAT(8I5,3F10.0)
 1001 FORMAT(7I5,5X,3F10.0)     
 4000 FORMAT(I5,I10,6I5,3F10.0)
C-----------------------------------------------------------------------
 2020 FORMAT(
     111X,'TIP KONACNOG ELEMENTA GRUPE ELEMENATA ',I6,' ... NETIP =',I5/
     116X,'EQ.1 ; STAP                             (2    CVORA)'/
     116X,'EQ.11; ELASTICNI OSLONAC                (1    CVOR )'/
     116X,'EQ.12; GAP                              (2    CVORA)'/
     116X,'EQ.20; GALERKIN BEZ MREZE 2/D                       '/
     116X,'EQ.2 ; IZOPARAMETARSKI 2/D              (4-9  CVORA)'/
     116X,'EQ.21; IZOPARAMETARSKI TROUGAONI 2/D    (3-6  CVORA)'/
     116X,'EQ.3 ; IZOPARAMETARSKI 3/D              (8-21 CVORA)'/
     116X,'EQ.31; IZOPARAMETARSKA PRIZMA           (6-15 CVORA)'/
     116X,'EQ.32; IZOPARAMETARSKA PIRAMIDA         (5-13 CVORA)'/
     116X,'EQ.33; IZOPARAMETARSKI TETRAEDAR        (4-10 CVORA)'/
     116X,'EQ.5 ; TROUGAONA PLOCA - D K T          (3    CVORA)'/
     116X,'EQ.6 ; TANKOZIDNA GREDA                 (2    CVORA)'/
     116X,'EQ.7 ; OSNOSIMETRICNA LJUSKA            (2-4  CVORA)'/
     116X,'EQ.8 ; IZOPARAMETARSKA LJUSKA           (4-9  CVORA)'/
     116X,'EQ.81; IZOPARAMETARSKA TROUGAONA LJUSKA (3-6  CVORA)'/
     116X,'EQ.82; LJUSKA - A C S PINSKY & JANG     (9    CVORA)'/
     116X,'EQ.83; LJUSKA - GELIN & BOISSE          (3    CVORA)'/
     116X,'EQ.84; LJUSKA - BATHE & DVORKIN         (4    CVORA)'/
     116X,'EQ.85; PLOCA - SELEKTIVANA INTEGRACIJA  (4-9  CVORA)'/
     116X,'EQ.9 ; GREDNI SUPER ELEMENT             (2-3  CVORA)'/
     116X,'EQ.92; KONTAKTNI 2/D                    (2    CVORA)'/
     116X,'EQ.93; KONTAKTNI 3/D                    (4    CVORA)')
 2030 FORMAT(//
     211X,'BROJ KONACNIH ELEMENATA GRUPE ELEMENATA ',I6,' .... NE =',I5/
     216X,'GT.0;'///
     311X,'INDIKATOR ANALIZE GRUPE ELEMENATA ',I6,' ....... IATYP =',I5/
     316X,'EQ. 0; LINEARNA ANALIZA'/
     316X,'EQ. 1; MATERIJALNO NELINEARAN PROBLEM'/
     316X,'EQ. 2; TOTAL LAGRANZ'/
     316X,'EQ. 3; UPDATE LAGRANZ'/
     316X,'EQ.-4; VELIKE DEFORMACIJE - GREEN LAGRANZ'/
     316X,'EQ. 4; VELIKE DEFORMACIJE - ROTIRANA GREEN LAGRANZ'/
     316X,'EQ.-5; VELIKE DEFORMACIJE - LOGARITAMSKA'/
     316X,'EQ. 5; VELIKE DEFORMACIJE - ROTIRANA LOGARITAMSKA')
 2040 FORMAT(//
     211X,'BROJ MODELA MATERIJALA GRUPE ',I6,' ...........  NMODM =',I5/
     216X,'EQ.0; NMODM=1'/
     216X,'EQ.1; ELASTICAN IZOTROPAN'/
     216X,'EQ.2; ELASTICAN ANIZOTROPAN'/
     216X,'EQ.3; TERMO-ELASTICAN IZOTROPAN'/
     216X,'EQ.4; TERMO-ELASTICAN ANIZOTROPAN'/
     216X,'EQ.5; MIZESOV ELASTO-PLASTICAN SA IZOTROPNIM OJACANJEM'/
     216X,'EQ.6; MIZESOV ELASTO-PLASTICAN SA MESOVITIM OJACANJEM'/
     216X,'EQ.7; TLO PLASTICNOST - GENERALISANI MODEL SA KAPOM'/
     216X,'EQ.8; TLO ANIZOTROPNA PLASTICNOST (CAM-CLAY)'/
     216X,'EQ.9; TLO PLASTICNOST CAM-CLAY (GLINA)'/
     215X,'EQ.10; ELASTO-PLASTICAN ANIZOTROPAN'/
     215X,'EQ.11; ZAZOR SA ZADATIM NAPONOM'/
     215X,'EQ.12; ZAZOR SA ZADATOM SILOM')
 2041 FORMAT(
     215X,'EQ.13; GENERALNI ANIZOTROPAN ELASTO-PLASTICAN'/15X,
     2'EQ.14; MIZESOV TERMO-ELASTO-PLASTICAN SA MESOVITIM OJACANJEM'/
     215X,'EQ.15; TERMO-ELASTICAN SA PUZANJEM'/15X,
     2'EQ.16; MIZESOV TERMO-ELASTO-PLASTICAN (SA MESOVITIM OJACANJEM)'/
     215X,'       I PUZANJE'/15X,
     2'EQ.17; MIZESOV TERMO-ELASTO-PLASTICAN SA MESOVITIM OJACANJEM'/
     215X,'       (ORTOTROPAN)'/
     215X,'EQ.18; TERMO-ELASTICAN SA PUZANJEM (ORTOTROPAN)'/15X,
     2'EQ.19; MIZESOV TERMO-ELASTO-PLASTICAN SA MESOVITIM OJACANJEM'/
     215X,'       I PUZANJEM (ORTOTROPAN)'/
     215X,'EQ.20; MIZESOV IZOTROPAN VISKO-PLASTICAN SA MESOVITIM OJACANJ
     2EM'/
     215X,'EQ.21; MIZESOV ORTOTROPAN VISKO-PLASTICAN SA MESOVITIM OJACAN
     2JEM'/
     215X,'EQ.22; VISKOPLASTICAN CAM-CLAY'/
     215X,'EQ.23; VISKOPLASTICAN CAP'/
     215X,'EQ.24; LINEARAN VISKOELASTICAN'/
     215X,'EQ.25; STENA-CST / PRSLINA'/
     215X,'EQ.27; BETON')
 2042 FORMAT(
     215X,'EQ.28; GUMA'/
     215X,'EQ.29; ANAND-OV PLASTICAN IZOTROPAN'/
     215X,'EQ.30; ELASTICAN SA UNUTRASNJIM TRENJEM'/
     215X,'EQ.31; HILOV MODEL MISICA'/ 
     215X,'EQ.32; BIOLOSKI NAPON-STREC MODEL ZA PASIVNO STANJE'/ 
     215X,'EQ.33; BIOLOSKI MODEL PUZANJA'/ 
     215X,'EQ.34; BIOLOSKI NAPON-STREC MODEL ZA AKTIVNO STANJE'/
     215X,'EQ.40; GURSON'/
     215X,'EQ.61; IZOTROPAN MODEL OSTECENJA (Oliver)'/)
 2050 FORMAT(//
     211X,'INDIKATOR OPCIJE NASTAJANJA ELEMENATA ......... INDBTH =',I5/
     216X,'EQ.0; NE KORISTI SE'/
     216X,'EQ.1; KORISTI SE'///
     211X,'INDIKATOR OPCIJE NESTAJANJA ELEMENATA ......... INDDTH =',I5/
     216X,'EQ.0; NE KORISTI SE'/
     216X,'EQ.1; KORISTI SE')
 2060 FORMAT(//
     611X,'INDIKATOR KOORDINATNOG SISTEMA ZA MATRICU B ... INDKOV =',I5/
     616X,'EQ.-1; KOVARIJANTNI SISTEM'/  
     616X,'EQ.-2; KOVARIJANTNI SISTEM I BEZ BNL'/  
     616X,'EQ. 0; NE KORISTI SE'/
     616X,'EQ. 1; DEKARTOV SISTEM'/  
     616X,'EQ. 2; DEKARTOV SISTEM I BEZ BNL'//  
     611X,'RACUNANJA POCETNIH NAPONA I POMERANJA ........ ISTRESS =',I5/
     616X,'EQ-1; PRORACUN POCETNIH NAPONA I POMERANJA'/
     616X,'EQ.0; NE KORISTI SE'/
     616X,'EQ.1; KORISTE SE POCETNI NAPONI (GEOMETRIJA IZ *.LST)'//  
     611X,'KOEFICIJENT KOREKCIJE MODULA SMICANJA GYZ - COEF1 =',1PD10.3/
     216X,'EQ.0.; COEF1=5./6'//
     611X,'KOEFICIJENT KOREKCIJE MODULA SMICANJA GZX - COEF2 =',1PD10.3/
     216X,'EQ.0.; COEF2=5./6'//
     611X,'KOEFICIJENT KOREKCIJE MODULA SMICANJA GXY - COEF3 =',1PD10.3/
     216X,'EQ.0.; COEF3=1. ')
 2100 FORMAT(///                                        
     111X,'GRUPA ELEMENATA',I5,'  ZAUZIMA PROSTOR ........ NPROS =',I9/)
C-----------------------------------------------------------------------
 6020 FORMAT(
     111X,'ELEMENT TYPE FOR GROUP ',I6,' .................. NETIP =',I5/
     116X,'EQ.1 ; TRUSS                            (2    NODES)'/
     116X,'EQ.11; ELASTIC SUPPORT                  (1    NODES)'/
     116X,'EQ.12; GAP                              (2    NODES)'/
     116X,'EQ.20; ELEMENT FREE GALERKIN 2/D                    '/
     116X,'EQ.2 ; ISOPARAMETRIC 2/D                (4-9  NODES)'/
     116X,'EQ.21; ISOPARAMETRIC TRIANGULAR 2/D     (3-6  NODES)'/
     116X,'EQ.3 ; ISOPARAMETRIC 3/D                (8-21 NODES)'/
     116X,'EQ.31; ISOPARAMETRIC PRISMATIC          (6-15 NODES)'/
     116X,'EQ.32; ISOPARAMETRIC PYRAMIDAL          (5-13 NODES)'/
     116X,'EQ.33; ISOPARAMETRIC TETRAHEDRONAL      (4-10 NODES)'/
     116X,'EQ.5 ; TRIANGULAR PLATE - D K T         (3    NODES)'/
     116X,'EQ.6 ; THIN-WALLED BEAM                 (2    NODES)'/
     116X,'EQ.7 ; AXISYMMETRIC SHELL               (2-4  NODES)'/
     116X,'EQ.8 ; ISOPARAMETRIC SHELL              (4-9  NODES)'/
     116X,'EQ.81; ISOPARAMETRIC TRIANGULAR SHELL   (3-6  NODES)'/
     116X,'EQ.82; SHELL - A C S PINSKY & JANG      (9    NODES)'/
     116X,'EQ.83; SHELL - GELIN & BOISSE           (3    NODES)'/
     116X,'EQ.84; SHELL - BATHE & DVORKIN          (4    NODES)'/
     116X,'EQ.85; PLATE - SELECTIVE INTEGRATION    (4-9  NODES)'/
     116X,'EQ.9 ; BEAM SUPERELEMENT                (2-3  NODES)'/
     116X,'EQ.92; CONTACT 2/D                      (2    NODES)'/
     116X,'EQ.93; CONTACT 3/D                      (4    NODES)')
 6030 FORMAT(//
     211X,'NUMBER OF ELEMENTS IN THE GROUP ',I6,' ............ NE =',I5/
     216X,'GT.0;'///
     311X,'INDICATOR FOR TYPE OF ANALYSIS FOR GROUP',I6,' . IATYP =',I5/
     316X,'EQ. 0; LINEAR ANALYSIS'/
     316X,'EQ. 1; MATERIALLY NONLINEAR ANALYSIS'/
     316X,'EQ. 2; TOTAL LAGRANGIAN'/
     316X,'EQ. 3; UPDATED LAGRANGIAN'/
     316X,'EQ.-4; LARGE STRAIN - GREEN LAGRANGE'/
     316X,'EQ. 4; LARGE STRAIN - ROTATED GREEN LAGRANGE'/
     316X,'EQ.-5; LARGE STRAIN - LOGARITHMIC STRAIN'/
     316X,'EQ. 5; LARGE STRAIN - ROTATED LOGARITHMIC STRAIN')
 6040 FORMAT(//
     211X,'NUMBER OF MATERIAL MODELS FOR GROUP ',I6,' ....  NMODM =',I5/
     216X,'EQ.0; NMODM=1'/
     216X,'EQ.1; ELASTIC ISOTROPIC'/
     216X,'EQ.2; ELASTIC ANISOTROPIC'/
     216X,'EQ.3; THERMO-ELASTIC ISOTROPIC'/
     216X,'EQ.4; THERMO-ELASTIC ORTHOTROPIC'/
     216X,'EQ.5; VON MISES ELASTIC-PLASTIC WITH ISOTROPIC HARDENING'/
     216X,'EQ.6; VON MISES ELASTIC-PLASTIC WITH MIXED HARDENING'/
     216X,'EQ.7; SOIL PLASTICITY - GENERAL CAP'/
     216X,'EQ.8; SOIL ANISOTROPIC PLASTICITY (CAM-CLAY)'/
     216X,'EQ.9; SOIL ISOTROPIC PLASTICITY (CAM-CLAY)'/
     215X,'EQ.10; ELASTIC-PLASTIC ORTHOTROPIC'/
     215X,'EQ.11; GAP - STRESS'/
     215X,'EQ.12; GAP - FORCE')
 6041 FORMAT(
     215X,'EQ.13; GENERAL ANISOTROPIC ELASTIC-PLASTIC'/15X,
     2'EQ.14; VON MISES THERMO-ELASTIC-PLASTIC WITH MIXED HARDENING'/
     215X,'EQ.15; THERMO-ELASTIC WITH CREEP'/15X,
     2'EQ.16; VON MISES THERMO-ELASTIC-PLASTIC (WITH MIXED HARDENING)'/
     215X,'       AND CREEP'/15X,
     2'EQ.17; VON MISES THERMO-ELASTIC-PLASTIC (WITH MIXED HARDENING)'/
     215X,'       (ORTHOTROPIC)'/
     215X,'EQ.18; THERMO-ELASTIC WITH CREEP (ORTHOTROPIC)'/15X,
     2'EQ.19; VON MISES THERMO-ELASTIC-PLASTIC (WITH MIXED HARDENING)'/
     215X,'       AND CREEP (ORTHOTROPIC)'/
     215X,'EQ.20; VON MISES VISCO-PLASTIC ISOTROPIC WITH MIXED HARDENING
     2'/
     215X,'EQ.21; VON MISES VISCO-PLASTIC ORTHOTROPIC WITH MIXED HARDENI
     2NG'/
     215X,'EQ.22; CAM-CLAY VISCOPLASTICITY'/
     215X,'EQ.23; SOIL CAP MODEL - VISCOPLASTICITY'/
     215X,'EQ.24; LINEAR VISCOELASTIC'/
     215X,'EQ.25; ROCKS-CST / JOINT'/
     215X,'EQ.27; CONCRETE')
 6042 FORMAT(
     215X,'EQ.28; RUBBER'/
     215X,'EQ.29; ANAND`S PLASTIC ISOTROPIC'/
     215X,'EQ.30; ELASTIC MATERIAL WITH INTERNAL FRICTION'/
     215X,'EQ.31; HILLS MUSCLE MODEL'/
     215X,'EQ.32; BIOLOGICAL STRESS-STRETCH MODEL FOR PASSIVE STATE'/
     215X,'EQ.33; BIOLOGICAL STRESS-STRETCH MODEL FOR PASSIVE STATE'/
     215X,'       WITH CREEP'/
     215X,'EQ.34; BIOLOGICAL STRESS-STRETCH MODEL FOR ACTIVE STATE'/
     215X,'EQ.40; GURSON'/
     215X,'EQ.61; ISOTROPIC DAMAGE MODEL (OLIVER)'/)
 6050 FORMAT(//
     211X,'ELEMENT BIRTH OPTION INDICATOR ................ INDBTH =',I5/
     216X,'EQ.0; OPTION NOT USED'/
     216X,'EQ.1; OPTION USED'///
     211X,'ELEMENT DEATH OPTION INDICATOR ................ INDDTH =',I5/
     216X,'EQ.0; OPTION NOT USED'/
     216X,'EQ.1; OPTION USED')
 6060 FORMAT(//
     611X,'COORDINATE SYSTEM INDICATOR FOR MATRIX B ...... INDKOV =',I5/
     616X,'EQ.-1; COVARIANT SYSTEM'/  
     616X,'EQ.-2; COVARIANT SYSTEM, WITHOUT BNL'/  
     616X,'EQ. 0; NOT USED'/
     616X,'EQ. 1; CARTESIAN SYSTEM'/  
     616X,'EQ. 2; CARTESIAN SYSTEM, WITHOUT BNL'//  
     611X,'INDICATOR FOR INITIAL STRESS ................. ISTRESS =',I5/
     616X,'EQ.-1; CALCULATION OF INITIAL STRESS AND DISPLACEMENT'//  
     616X,'EQ. 0; OPTION NOT USED'/  
     616X,'EQ. 1; INITIAL STRESS USED (COPY CONFIGURATION FROM LST)'//  
     611X,'CORECTION COEFFICIENT FOR SHEAR MODULUS GYZ-COEF1 =',1PD10.3/
     216X,'EQ.0.; COEF1=5./6'//
     611X,'CORECTION COEFFICIENT FOR SHEAR MODULUS GZX-COEF2 =',1PD10.3/
     216X,'EQ.0.; COEF2=5./6'//
     611X,'CORECTION COEFFICIENT FOR SHEAR MODULUS GXY-COEF3 =',1PD10.3/
     216X,'EQ.0.; COEF3=1. ')
 6100 FORMAT(///                                        
     111X,'GROUP NUMBER',I5,'  SPACE IN WORKING VECTOR ... NPROS =',I9/)
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE PODTYP(NETIP)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.       TO CHECK ELEMENT TYPE
CS.   P R O G R A M
CS.       ZA PROVERU TIPA ELEMENTA
C .
C ......................................................................
C
      COMMON /PODTIP/ IPODT
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' PODTYP'
      IPODT=0
      IF(NETIP.EQ.31) THEN
         IPODT=1
         NETIP=3
      ENDIF
      IF(NETIP.EQ.32) THEN
         IPODT=2
         NETIP=3
      ENDIF
      IF(NETIP.EQ.33) THEN
         IPODT=3
         NETIP=3
      ENDIF
      IF(NETIP.EQ.21) THEN
         IPODT=1
         NETIP=2
      ENDIF
      IF(NETIP.EQ.81) THEN
         IPODT=1
         NETIP=8
      ENDIF
      IF(NETIP.EQ.82) THEN
         IPODT=2
         NETIP=8
      ENDIF
      IF(NETIP.EQ.83) THEN
         IPODT=3
         NETIP=8
      ENDIF
      IF(NETIP.EQ.84) THEN
         IPODT=4
         NETIP=8
      ENDIF
      IF(NETIP.EQ.85) THEN
         IPODT=5
         NETIP=8
      ENDIF
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE PROTYP
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.       TO CHECK DATA FOR ELEMENTS
CS.   P R O G R A M
CS.       ZA PROVERU PODATAKA O ELEMENTIMA
C .
C ......................................................................
C
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /SOPSVR/ ISOPS,ISTYP,NSOPV,ISTSV,IPROV,IPROL
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /SRPSKI/ ISRPS
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' PROTYP'
      IF(NETIP.LT.1.OR.NETIP.GT.12.AND.NETIP.NE.92.AND.NETIP.NE.93.AND.
     1   NETIP.NE.20) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2030) NGE,NETIP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6030) NGE,NETIP
      STOP
      ENDIF
C
      IF(NE.LE.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2040) NGE,NE
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6040) NGE,NE
      STOP
      ENDIF
C
      IF(IATYP.LT.0.OR.IATYP.GT.5) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2050) NGE,IATYP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6050) NGE,IATYP
      STOP
      ENDIF
C
      IF(NMODM.LT.0.OR.NMODM.GT.100) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2060) NGE,NMODM
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6060) NGE,NMODM
      STOP
      ENDIF
C
      IF((NMODM.GE.3.AND.IATYP.EQ.0).OR.
     1   (NMODM.LE.2.AND.IATYP.EQ.1).OR.
     1   (NMODM.LE.4.AND.IATYP.GE.4)) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2070) NGE,NMODM,IATYP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6070) NGE,NMODM,IATYP
      STOP
      ENDIF
C
      IF(NMODM.GE.5.AND.LINEAR.EQ.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2080) NGE,NMODM
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6080) NGE,NMODM
      STOP
      ENDIF
C
      IF(IATYP.GE.2.AND.LINEAR.EQ.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2090) NGE,IATYP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6090) NGE,IATYP
      STOP
      ENDIF
C
      IF(NDIN.GT.0.AND.ISOPS.GT.0.AND.IATYP.GT.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2100) NGE,IATYP
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6100) NGE,IATYP
      STOP
      ENDIF
      RETURN
C-----------------------------------------------------------------------
 2030 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ELEMENT
     1A NE ODGOVARA KONACNIM ELEMENTIMA UGRADJENIM U PROGRAM NETIP=',I3)
 2040 FORMAT(///' ZA GRUPU ELEMENATA',I3/' UCITANI BROJ KONACNIH ELEMENA
     1TA MORA BITI VECI OD NULE NE=',I5)
 2050 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ANALIZE
     1 NE ODGOVARA ONIM KOJE SU UGRADJENE U PROGRAM IATYP=',I3)
 2060 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O MODELU MATER
     1IJALA NE ODGOVARA ONIM KOJI SU UGRADJENI U PROGRAM NMODM=',I3)
 2070 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O MODELU MATER
     1IJALA NMODM=',I3/' NIJE U SAGLASNOSTI SA TIPOM ANALIZE IATYP=',I3)
 2080 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O MODELU MATER
     1IJALA NMODM=',I3/' NIJE U SAGLASNOSTI SA MOGUCNOSTIMA PROGRAMA'/
     1' OVA VERZIJA PROGRAMA JE ZA LINEARNU TERMOELASTICNU ANALIZU')
 2090 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ANALIZE
     1 IATYP=',I3/' NIJE U SAGLASNOSTI SA MOGUCNOSTIMA PROGRAMA'/
     1' OVA VERZIJA PROGRAMA JE ZA LINEARNU TERMOELASTICNU ANALIZU')
 2100 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ANALIZE
     1 JE IATYP=',I3/' A MORA BITI NULA ZA RACUNANJE SOPSTVENIH FREKVENC
     2IJA')
C-----------------------------------------------------------------------
 6030 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ELEMENT
     1A NE ODGOVARA KONACNIM ELEMENTIMA UGRADJENIM U PROGRAM NETIP=',I3)
 6040 FORMAT(///' FOR ELEMENTS GROUP',I3,' NUMBER OF ELEMENTS MUST BE GR
     1EATHER THAN ZERO NE=',I5)
 6050 FORMAT(//' ZA GRUPU ELEMENATA',I3,' UCITANI PODATAK O TIPU ANALIZE
     1 NE ODGOVARA ONIM KOJE SU UGRADJENE U PROGRAM IATYP=',I3)
 6060 FORMAT(//' ZA GRUPU ELEMENATA',I3,' UCITANI PODATAK O MODELU MATER
     1IJALA NE ODGOVARA ONIM KOJI SU UGRADJENI U PROGRAM NMODM=',I3)
 6070 FORMAT(//' ZA GRUPU ELEMENATA',I3,' UCITANI PODATAK O MODELU MATER
     1IJALA NMODM=',I3,' NIJE U SAGLASNOSTI SA TIPOM ANALIZE IATYP=',I3)
 6080 FORMAT(//' ZA GRUPU ELEMENATA',I3,' UCITANI PODATAK O MODELU MATER
     1IJALA NMODM=',I3,' NIJE U SAGLASNOSTI SA MOGUCNOSTIMA PROGRAMA'/
     1' OVA VERZIJA PROGRAMA JE ZA LINEARNU TERMOELASTICNU ANALIZU')
 6090 FORMAT(//' ZA GRUPU ELEMENATA',I3,' UCITANI PODATAK O TIPU ANALIZE
     1 IATYP=',I3,' NIJE U SAGLASNOSTI SA MOGUCNOSTIMA PROGRAMA'/
     1' OVA VERZIJA PROGRAMA JE ZA LINEARNU TERMOELASTICNU ANALIZU')
 6100 FORMAT(//' ZA GRUPU ELEMENATA',I3/' UCITANI PODATAK O TIPU ANALIZE
     1 JE IATYP=',I3/' A MORA BITI NULA ZA RACUNANJE SOPSTVENIH FREKVENC
     2IJA')
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE FORMGR(NPODS,LMM)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.    P R O G R A M
CE.        TO FORM POINTERS FOR MATRICES AND VECTORS OF THE SYSTEM
CS.    P R O G R A M
CS.        ZA FORMIRANJE REPERA ZA MATRICE I VEKTORE SISTEMA
C .
CE.    P O I N T E R S
CE.        LZAPS - VECTOR OF BODY FORCE
CE.        LTECV - VECTOR OF NODAL TEMPERATURES
CE.        LCORUL- MATRIX OF UPDATED COORDINATES (U.L.), 
CE.                CURRENT CONFIGURATION
CE.        LFTDT - VECTOR OF INTERNAL FORCES
CE.        LUPRI - VECTOR OF DISPLACEMENT INCREMENTS
CE.        LRTDT - VECTOR OF EXTERNAL FORCES OR 
CE.                SOLUTION RESULTS FROM SOLVER
CE.        LRCTDT- VECTOR OF CONTACT FORCES
CE.        LSK   - STIFFNESS MATRIX OF THE SYSTEM
CE.        LRAD  - FREE SPACE IN WORKING ARRAY A(*) USED FOR ELEMENT 
CE.                GROUP INTEGRATION
CE.        LMM   - IS LAST USED ELEMENT IN WORKING ARRAY A(*) 
CS.    R E P E R I
CS.        LSK - MATRICA SISTEMA
CS.        LRTDT - VEKTOR SPOLJASNJIH SILA
CS.        LFTDT - VEKTOR UNUTRASNJIH SILA
CS.        LTECV - VEKTOR CVORNIH TEMPERATURA
CS.        LCORUL- MATRICA KORIGOVANIH KOORDINATA (U.L.)
C .
CE.    V A R I A B L E S
CE.        NP    - TOTAL NUMBER OF NODAL POINTS, SEE CARD /3/
CE.        LUL   - INDICATOR FOR GEOMETRICAL NONLINEAR ELEMENT GROUPS,
CE.                (LUL.GT.0) FOR (IATYP.GE.3), SEE CARD /13/
CE.        ITERM - INDICATOR FOR THERMAL PROBLEMS 
CE.        ICONT - INDICATOR FOR CONTACT PROBLEMS
CE.        ITERGL- INDICATOR FOR ITERATION METHODS
CE.                (ITERGL.GT.0) - ITERATION METHODS ARE USED
CE.        NBLOCK- NUMER OF BLOCKS FOR SOLUTION OF THE SYSTEM EQUATIONS
CE.                (NBLOCK.GT.1) - BLOCKS ARE USED BECAUSE AVAILABLE
CE.                MEMORY IN ARRAY VECTOR A(NTOT) IS LESS THEN REQUIRED
CE.        NRAD  - MAXIMUM SPACE USED FOR ELEMENT GROUP INTEGRATION
CE.                DEFINED DURING ELEMENT GROUP READING DATA
CE.        JEDN  - NUMBER OF SYSTEM EQUATIONS
CE.        NWK*I2- TOTAL SPACE IN WORKING ARRAY A(*) USED FOR SYSTEM
CE.                STIFFNES MATRIX
CE.                I2=1 - SYMMETRIC SOLVER
CE.                I2=2 - UNSYMMETRIC SOLVER FOR (ICCGG=2), SEE CARD /7/
CE.        NWM   - TOTAL SPACE IN WORKING ARRAY A(*) USED FOR SYSTEM
CE.                MASS MATRIX (NDIN.GT.0.OR.ISOPS.GT.0), SEE CARD /4/.
CE.                NWM=NWK - FOR CONSISTENT MASS MATRIX
CE.                NWM=JEDN - FOR LUMPED (DIAGONAL) MASS MATRIX
C .
C ......................................................................
C
      include 'paka.inc'
      
      CHARACTER*6    FILDLT
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /DINAMI/ IMASS,IDAMP,PIP,DIP,MDVI
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /REPERI/ LCORD,LID,LMAXA,LMHT
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /BROJUK/ KARTIC,INDFOR,NULAZ
      COMMON /OPTERE/ NCF,NPP2,NPP3,NPGR,NPGRI,NPLJ,NTEMP
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /POSTPR/ LNDTPR,LNDTGR,NBLPR,NBLGR,INDPR,INDGR
      COMMON /RESTAR/ TSTART,IREST
      COMMON /NEBACK/ INDBACK
      COMMON /TEMPCV/ LTECV,ITEMP
      COMMON /ANALIZ/ LINEAR,ITERGL,INDDIN
      COMMON /BLOCKS/ NBMAX,IBLK,NBLOCK,LMNQ,LICPL,LLREC,KC,LR
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /SOPSVR/ ISOPS,ISTYP,NSOPV,ISTSV,IPROV,IPROL
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /KONTKT/ ICONT,NEQC,NEQ,NWKC,LMAXAC,LRCTDT
      COMMON /KONTK2/ NPROCK
      COMMON /UPDLAG/ LUL,LCORUL
      COMMON /GRUPER/ LIGRUP
      COMMON /NELINE/ NGENN
      COMMON /UPRIRI/ LUPRI
      COMMON /DUPLAP/ IDVA
      COMMON /SRPSKI/ ISRPS
      COMMON /CDEBUG/ IDEBUG
      COMMON /ZAPSIL/ UBXYZ(3,10),NVFUB(10),INDZS,LZAPS,LNPRZ
      COMMON /KAKO6O/ LLJUS,LKAKO6
      COMMON /CVOREL/ ICVEL,LCVEL,LELCV,NPA,NPI,LCEL,LELC,NMA,NMI
      COMMON /JCERNI/ LKOLKO,ICERNI
      COMMON /PRITGR/ LPRCV
      COMMON /GEORGE/ TOLG,ALFAG,ICCGG
      COMMON /DRAKCE/ IDRAKCE,NELUK,NZERO,NEED1,NEED2,NEED3,NNZERO
     1                ,IROWS,LAILU,LUCG,LVCG,LWCG,LPCG,LRCG
      COMMON /FORSPA/ Lr1,Lz1,Lp1,LM0,LMaxM1,LColM
      COMMON/VERSION/ IVER
      COMMON /ODUZMI/ INDOD
      COMMON /ODUZPOM/ KODUZ
      COMMON /EXPLICITNA/ INDEXPL
      COMMON /EXPLALOK/ IUBRZ,IBRZINA,IBRZINAIPO,IPOMAK,IMASA,IPRIGUSEN
      COMMON /SKDISK/ ISKDSK
      DIMENSION NPODS(JPS1,*)
C
      IF(IDEBUG.GT.0) PRINT *, ' FORMGR'
C
      NPP=NP
      LMAX13=MAX13
C CERNI
      IF(NRAD.LT.LDUZI/4.AND.NGENN.GT.0) NRAD=LDUZI/4
C CERNI
      IF(NRAD.LT.JEDN*IDVA) NRAD=JEDN*IDVA
CSKDISK      IF(NRAD.LT.(NWK+2*JEDN)*IDVA.AND.NDIN.GT.0.AND.ISOPS.EQ.0)
CSKDISK     1 NRAD=(NWK+2*JEDN)*IDVA
CZILESK      IF(NRAD.LT.2*JEDN*IDVA.AND.NDIN.GT.0.AND.ISOPS.EQ.0)
CZILESK     1 NRAD=2*JEDN*IDVA
      IF(NRAD.LT.(4*JEDN)*IDVA+NPROCK.AND.NDIN.GT.0.AND.ISOPS.EQ.0)
     1 NRAD=(4*JEDN)*IDVA+NPROCK
      LMAX=LRAD
C PRIVREMENO ZBOG VAGONA
      LKAKO6=LMAX
      IF(IREST.EQ.2.AND.IOPGL(6).EQ.1) LMAX=LKAKO6+NP
C
      LNPRZ=LMAX
      IF(INDZS.NE.0) THEN
         LMAX=LNPRZ+JEDN
         NPODS(JPBR,84)=LMAX13+1
         NPODS(JPBR,83)=LNPRZ
         CALL ICLEAR(A(LNPRZ),JEDN)
         CALL IWRITD(A(LNPRZ),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
C
C CERNI
CS    PROSTOR ZA PODATKE VEZANE ZA ZONE NESTABILNOSTI (0-NE,1-DA)
      ICERNI=0
      IF(NGENN.GT.0.AND.INDBACK.EQ.0) ICERNI=1
      LKOLKO=LMAX
      IF(ICERNI.EQ.1) THEN
         LMAX=LKOLKO+NP
         CALL ICLEAR(A(LKOLKO),NP)
      ENDIF
C CERNI
C
      CALL DELJIV(LMAX,2,INDL)
      IF(INDL.EQ.0) LMAX=LMAX+1
C
      LZAPS=LMAX
      IF(INDZS.NE.0) THEN
         LMAX=LZAPS+JEDN*IDVA
         NPODS(JPBR,86)=LMAX13+1
         NPODS(JPBR,85)=LZAPS
         CALL CLEAR(A(LZAPS),JEDN)
         CALL WRITDD(A(LZAPS),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
      
      IF(INDEXPL.EQ.1) then
C
C       Alokacija vektora ubrzanja
C
         IUBRZ=LMAX
         LMAX=IUBRZ+JEDN*IDVA
         CALL CLEAR(A(IUBRZ),JEDN)
C
C     Alokacija vektora brzine u n
C
         IBRZINA=LMAX
         LMAX=IBRZINA+JEDN*IDVA
         CALL CLEAR(A(IBRZINA),JEDN)
C
C     Alokacija vektora brzine u n+1/2
C
         IBRZINAIPO=LMAX
         LMAX=IBRZINAIPO+JEDN*IDVA
         CALL CLEAR(A(IBRZINAIPO),JEDN)
C
C     Alokacija vektora pomeranja
C
         IPOMAK=LMAX
         LMAX=IPOMAK+JEDN*IDVA
         CALL CLEAR(A(IPOMAK),JEDN)
C
C
C     Alokacija vektora masa
C
         IMASA=LMAX
         LMAX=IMASA+JEDN*IDVA
         CALL CLEAR(A(IMASA),JEDN)
C
C     Alokacija vektora prigusenja
C
         IPRIGUSEN=LMAX
         LMAX=IPRIGUSEN+JEDN*IDVA
         CALL CLEAR(A(IPRIGUSEN),JEDN)
C
      ENDIF
      
      LTECV=LMAX
      IF(ITERM.NE.0.OR.NTEMP.NE.0) THEN
         IF(JPS.GT.1.AND.JPBR.EQ.JPS1) THEN
         ELSE
            LMAX=LTECV+NPP*IDVA
            NPODS(JPBR,40)=LTECV
            NPODS(JPBR,41)=LMAX13+1
            CALL CLEAR(A(LTECV),NPP)
            CALL WRITDD(A(LTECV),NPP,IPODS,LMAX13,LDUZI)
         ENDIF
      ENDIF
C
      LPRCV=LMAX
      IF(NPGR.GT.0) THEN
         IF(JPS.GT.1.AND.JPBR.EQ.JPS1) THEN
         ELSE
            LMAX=LPRCV+NPP*IDVA
            NPODS(JPBR,90)=LPRCV
            NPODS(JPBR,91)=LMAX13+1
            CALL CLEAR(A(LPRCV),NPP)
            CALL WRITDD(A(LPRCV),NPP,IPODS,LMAX13,LDUZI)
         ENDIF
      ENDIF
C
      LCORUL=LMAX
      IF(LUL.NE.0) THEN
         IF(JPS.GT.1.AND.JPBR.EQ.JPS1) THEN
         ELSE
            LMAX=LCORUL+3*NPP*IDVA
            NPODS(JPBR,42)=LCORUL
            NPODS(JPBR,43)=LMAX13+1
            CALL JEDNA1(A(LCORUL),A(LCORD),NPP*3)
            CALL WRITDD(A(LCORUL),NPP*3,IPODS,LMAX13,LDUZI)
         ENDIF
      ENDIF
C
      LFTDT=LMAX
C     IF(NGENN.NE.0) THEN
         LMAX=LFTDT+JEDN*IDVA
         NPODS(JPBR,45)=LMAX13+1
         NPODS(JPBR,44)=LFTDT
         CALL CLEAR(A(LFTDT),JEDN)
C         WRITE(3,*) '45,LFTDT',LFTDT
         CALL WRITDD(A(LFTDT),JEDN,IPODS,LMAX13,LDUZI)
C     ENDIF
C
      LUPRI=LMAX
C      IF(NGENN.NE.0) THEN
         LMAX=LUPRI+JEDN*IDVA
         NPODS(JPBR,47)=LMAX13+1
         NPODS(JPBR,46)=LUPRI
         CALL CLEAR(A(LUPRI),JEDN)
         CALL WRITDD(A(LUPRI),JEDN,IPODS,LMAX13,LDUZI)
C      ENDIF
C
      LRTDT=LMAX
      LMAX=LRTDT+JEDN*IDVA
C zbog oduzimanja pomeranja
      IF(INDOD.EQ.1) LMAX=LMAX+JEDN*IDVA
      NPODS(JPBR,48)=LRTDT
      NPODS(JPBR,38)=LMAX13+1
      CALL CLEAR(A(LRTDT),JEDN)
C         WRITE(3,*) '38,LRTDT',LRTDT
      CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
      NPODS(JPBR,39)=LMAX13+1
C         WRITE(3,*) '39,LRTDT',LRTDT
      CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
CZILESK
      NPODS(JPBR,87)=LMAX13+1
C         WRITE(3,*) '87,LRTDT',LRTDT
      CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
CR
CR    Kreiranje staze za zapisivanje pomeranja u koraku 
CR    za oduzimanje! (rakic)
C      KODUZ=0
      IF (KODUZ.GT.0) THEN
        NPODS(JPBR,92)=LMAX13+1
        CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
CZILESK
      IF(JPS.GT.1.AND.ISOPS.GT.0) THEN
C         IF(JPBR.LT.JPS1.AND.NSOPV.GT.1) THEN
         IF(NSOPV.GT.1) THEN
            DO 10 IX=1,NSOPV-1
               CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
   10       CONTINUE
         ENDIF
         NSTAZ=(LMAX13-NPODS(JPBR,39)+1)/NSOPV
         NPODS(JPBR,83)=NSTAZ
      ENDIF
      NPODS(JPBR,52)=LMAX13+1
C         WRITE(3,*) '52,LRTDT',LRTDT
      CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
      IF(JPS.GT.1.AND.ISOPS.GT.0) THEN
C         IF(JPBR.LT.JPS1.AND.NSOPV.GT.1) THEN
         IF(NSOPV.GT.1) THEN
            DO 20 IX=1,NSOPV-1
               CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
   20       CONTINUE
         ENDIF
      ENDIF

      
      IF((NDIN.GT.0.AND.MDVI.NE.2).OR.ISOPS.GT.0) THEN
         NPODS(JPBR,53)=LMAX13+1
         CALL WRITDD(A(LRTDT),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
CE    SPACE FOR CONTACT FORCES
C--- PROSTOR ZA KONTAKTNE SILE
      LRCTDT=LMAX
      IF(ICONT.NE.0) THEN
         LMAX=LRCTDT+JEDN*IDVA
         IF(IABS(ICCGG).EQ.1) STOP 'ICCGG.EQ.1.AND.ICONT.NE.0'
         IF(JPS.GT.1) STOP 'JPS.GT.1.AND.ICONT.NE.0'
C  NIJE PREDVIDJENO ZA RAD PO PODSTRUKTURAMA
CC         IF(JPS.GT.1) THEN
CC            NPODS(JPBR,46)=LUPRI
CC            CALL CLEAR(A(LUPRI),JEDN)
CC            NPODS(JPBR,47)=LMAX13+1
CC            CALL WRITDD(A(LUPRI),JEDN,IPODS,LMAX13,LDUZI)
CC         ENDIF
      ENDIF
C
CE    ALLOCATE SPACES FOR UNIT VECTORS FOR NODES AND ITS INITIALISATION
CS    PROSTOR ZA JEDINICNE VEKTORE U CVOROVIMA I INICIJALIZACIJA
C
      IF(JPS.GT.1.AND.JPBR.EQ.JPS1) THEN
      ELSE
         CALL INIDRV(A(LIPODS))
      ENDIF
C
CE    ALLOCATE SPACES FOR ITERATIONS
CS    REZERVISANJE PROSTORA ZA ITERACIJE
C
      IF(JPS.GT.1.AND.JPBR.LT.JPS1) THEN
      ELSE
         IF(ITERGL.GT.0) CALL MEMIT(A(LIPODS))
      ENDIF
      CALL DELJIV(LMAX,2,INDL)
      IF(INDL.EQ.0) LMAX=LMAX+1
      IMEM=LMAX+2*JEDN*IDVA+NRAD+3
      IF(IMEM.GT.MTOT) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2100) IMEM
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6100) IMEM
      STOP
      ENDIF
C
CE    CHECK FOR WORK WITH BLOCKS
CS    PROVERA ZA RAD PO BLOKOVIMA
C
CZILESK
      IF(ISOPS.GT.0) THEN
         LMAXX=LMAX
         CALL RSOPVR(0)
         IF(NRAD.LT.(LMAX-LMAXX)) NRAD=LMAX-LMAXX
         LMAX=LMAXX
      ENDIF
      NWM=0
      IF(NDIN.GT.0.OR.ISOPS.GT.0) THEN
         IF(IMASS.EQ.1) NWM=NWK
         IF(IMASS.EQ.2) NWM=JEDN
      ENDIF
      IF(NDIN.EQ.0.AND.ISOPS.GT.0) NWM=NWK
CZILESK
      I2=1
      IF(ICCGG.EQ.2) I2=2
      IF((LMAX+(NWM+NWK*I2)*IDVA).LT.(MTOT-NRAD-1)) THEN
        NBLOCK=1
        LMNQ=LMAX
        LICPL=LMAX
        LLREC=LMAX
        LR=LDUZI/8
      ELSE
        LAMAX=LMAX+(NWM+NWK)*IDVA+NRAD
c      if(IVER.EQ.1.AND.nblock.gt.1) STOP 
c     1 'PROGRAM STOP-STUDENTSKA VERZIJA PROGRAMA, NE RADI SA BLOKOVIMA'
        IF(JPS.GT.1) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2200)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6200)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2001) JEDN,NWK,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6001) JEDN,NWK,MTOT
        STOP
        ENDIF
        IF(NDIN.GT.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2300)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6300)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2001) JEDN,NWK,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6001) JEDN,NWK,MTOT
        STOP
        ENDIF
        IF(ISOPS.GT.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2400)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6400)
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2001) JEDN,NWK,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6001) JEDN,NWK,MTOT
        STOP
        ENDIF
        LMNQ=LMAX
        LICPL=LMNQ+NBMAX+1
        LLREC=LICPL+NBMAX
        LMAX=LLREC+NBMAX+1
        CALL DELJIV(LMAX,2,INDL)
        IF(INDL.EQ.0) LMAX=LMAX+1
CE      LR  JE DUZINA ZAPISA NE U BAJTIMA VEC KAO BROJ CLANOVA
CE      EKVIVALENTNOG VEKTORA U DUPLOJ PRECIZNOSTI
CS      LR  JE DUZINA ZAPISA NE U BAJTIMA VEC KAO BROJ CLANOVA
CS      EKVIVALENTNOG VEKTORA U DUPLOJ PRECIZNOSTI
        LR=LDUZI/8
        MTMM=MTOT-NRAD-1
        CALL BLKDEF(A(LMAXA),A(LMNQ),A(LICPL),A(LLREC),
     1              NBLOCK,KC,NBMAX,LR,JEDN,LMAX,MTMM,IDVA,IZLAZ)
CE      OPEN FILES FOR BLOCKS
CS      OTVARANJE FILE-A ZA BLOKOVE
        CALL BLOKOP(IBLK)
      ENDIF
      NPODS(JPBR,49)=NBLOCK
C
      IF(IABS(ICCGG).EQ.1) THEN
         CALL DELJIV(LMAX,2,INDL)
         IF(INDL.EQ.0) LMAX=LMAX+1
         IF(ICCGG.EQ.1) THEN
            Lz1=LMAX
            LMAX=Lz1+JEDN*IDVA
            Lp1=LMAX
            LMAX=Lp1+JEDN*IDVA
            Lr1=LMAX
            LMAX=Lr1+JEDN*IDVA
            LM0=LMAX
            LMAX=LM0+NNZERO
            if(jedn.gt.10000) LMAX=LM0+NNZERO/4
            LColM=LMAX
            LMAX=LColM+NNZERO
            if(jedn.gt.10000) LMAX=LColM+NNZERO/4
            LMaxM1=LMAX
            LMAX=LMaxM1+JEDN+1
            CALL DELJIV(LMAX,2,INDL)
            IF(INDL.EQ.0) LMAX=LMAX+1
            IF(LMAX.GT.MTOT) CALL ERROR(1)
            LAILU=LMAX
            CALL ICLEAR(A(Lz1),LMAX-Lz1)
         ELSE
            LAILU=LMAX
            LUCG=LAILU+NEED2*IDVA
            LVCG=LUCG+JEDN*IDVA
            LWCG=LVCG+JEDN*IDVA
            LPCG=LWCG+JEDN*IDVA
            LRCG=LPCG+JEDN*IDVA
            LMAX=LRCG+JEDN*IDVA
            IF(LMAX.GT.MTOT) CALL ERROR(1)
            Lz1=LMAX
C            CALL CLEAR(A(LAILU),(LMAX-LAILU)/IDVA)
            CALL ICLEAR(A(LAILU),LMAX-LAILU)
         ENDIF
      ENDIF
      LSK=LMAX
      IF(NBLOCK.EQ.1) THEN
         LRAD=LSK+NWK*I2*IDVA
         CALL CLEAR(A(LSK),NWK*I2)
         NPODS(JPBR,35)=LMAX13+1
         IF(IREST.NE.2)CALL WRITDD(A(LSK),NWK,IPODS,LMAX13,LDUZI)
         IF(NDIN.GT.0.OR.ISOPS.GT.0) THEN
            LRAD=LRAD+NWM*IDVA
            NPODS(JPBR,54)=LMAX13+1
              IF(IREST.NE.2.AND.IMASS.EQ.1)
     +               CALL WRITDD(A(LSK),NWM,IPODS,LMAX13,LDUZI)
C         WRITE(3,*) '54,LSK',LSK
            IF(IMASS.EQ.2) CALL WRITDD(A(LSK),NWM,IPODS,LMAX13,LDUZI)
         ENDIF
         IF(NDIN.GT.0) THEN
            NPODS(JPBR,58)=LMAX13+1
            IF(IREST.NE.2)CALL WRITDD(A(LSK),NWK,IPODS,LMAX13,LDUZI)
            IF(IDAMP.GT.0) THEN
               NPODS(JPBR,56)=LMAX13+1
               IF(IREST.NE.2.AND.IMASS.EQ.1)
     +               CALL WRITDD(A(LSK),NWM,IPODS,LMAX13,LDUZI)
               IF(IMASS.EQ.2) CALL WRITDD(A(LSK),NWM,IPODS,LMAX13,LDUZI)
            ENDIF
         ENDIF
         IF(JPS.GT.1.AND.JPBR.LT.JPS1) THEN
            NPODS(JPBR,37)=LMAX13+1
            JED=JEDN-JEDNP
            NWPK=JED*(JED+1)/2
            IF(IREST.NE.2)CALL WRITDD(A(LSK),NWPK,IPODS,LMAX13,LDUZI)
            NPODS(JPBR,60)=LMAX13+1
            IF(IREST.NE.2)CALL WRITDD(A(LSK),NWP,IPODS,LMAX13,LDUZI)
            LSKG=LSK+NWP*IDVA
            NWKP=NWK-NWP
            NPODS(JPBR,61)=LMAX13+1
            IF(IREST.NE.2)CALL WRITDD(A(LSKG),NWKP,IPODS,LMAX13,LDUZI)
         ELSE 
            NPODS(JPBR,60)=LMAX13+1
C         WRITE(3,*) '60,LSK',LSK
C            IF(IREST.EQ.0.AND.METOD.EQ.-1)
C     +      CALL WRITDD(A(LSK),NWK,IPODS,LMAX13,LDUZI)
C            IF(IREST.EQ.1.AND.METOD.EQ.-1)
C     +      CALL READDD(A(LSK),NWK,IPODS,LMAX13,LDUZI)
             FILDLT='ZILDLT'
             OPEN (ILDLT,FILE=FILDLT,STATUS='UNKNOWN',
     1                   FORM='UNFORMATTED',ACCESS='SEQUENTIAL')
            IF(METOD.GT.-1) CLOSE (ILDLT,STATUS='DELETE')
         ENDIF
      ELSE
         LRAD=MTOT-NRAD-1
         CALL CLEAR(A(LSK),KC)
         NPODS(JPBR,35)=LMAX13+1
C         IF(IREST.NE.2.AND.(IREST.NE.1.OR.METOD.NE.-1))
C     +     CALL BLKZAP(A(LSK),A(LMAXA),A(LMNQ))
         NPODS(JPBR,60)=LMAX13+1
C         IF(IREST.NE.2.AND.(IREST.NE.1.OR.METOD.NE.-1))
C     +     CALL BLKZAP(A(LSK),A(LMAXA),A(LMNQ))
      ENDIF
      CALL DELJIV(LRAD,2,INDL)
      IF(INDL.EQ.0) LRAD=LRAD+1
      NPODS(JPBR,50)=LSK
      NPODS(JPBR,51)=LRAD
      NPODS(JPBR,33)=NRAD
      IF(MAX13.LT.LMAX13) MAX13=LMAX13
CSKDISK....
            LMAX=LRAD
CSKDISK
      LMM=LRAD+NRAD+1
C
C      IF(NULAZ.GE.0.OR.NBLPR.GE.0) THEN
      IF(JPS.EQ.1.OR.(JPS.GT.1.AND.JPBR.EQ.1)) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2050)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6050)
      ENDIF
      IF(JPS.GT.1) THEN
      IF(JPBR.EQ.JPS1) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2070)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6070)
      ELSE
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2060) JPBR
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6060) JPBR
      ENDIF
      ENDIF
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2000) JEDN,NWK,LMAXM,LMM,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6000) JEDN,NWK,LMAXM,LMM,MTOT
C      ENDIF
C
      IF(NBLOCK.GT.1) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2010) LAMAX,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6010) LAMAX,MTOT
      IF(ICCGG.EQ.1) STOP 'ICCGG.EQ.1.AND.NBLOCK.GT.1'
      if(IVER.EQ.1.AND.nblock.gt.1) STOP 
     1 'PROGRAM STOP-STUDENTSKA VERZIJA PROGRAMA, NE RADI SA BLOKOVIMA'
      ENDIF
      IF(IREST.NE.2.AND.LMM.GT.MTOT) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2010) LMM,MTOT
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6010) LMM,MTOT
      STOP ' FORMGR - PAK07'
      ENDIF
C
CE    INITIALISE UNITS VECTORS FOR NODES FOR SHELL AND BEAM ELEMENT
CE    GROUP
CS    INICIJALIZACIJA JEDINICNIH VEKTORA U CVOROVIMA
C
      IF(JPS.GT.1.AND.JPBR.EQ.JPS1) THEN
      ELSE
         CALL DRV000(A(LIGRUP),A(LIPODS),A(LKAKO6),A(LCORD),A(LCVEL),
     1               A(LID))
      ENDIF
      IF(MAX13.LT.LMAX13) MAX13=LMAX13
      IF(JPS.GT.1) LRAD=LID
      RETURN
C-----------------------------------------------------------------------
 2050 FORMAT(///'1',///6X,
     1'PODACI O DIMENZIJAMA MATRICA SISTEMA I RADNOG VEKTORA - A'/
     16X,57('-')///)
 2060 FORMAT(//6X,
     1'Z A   P O D S T R U K T U R U   B R O J ..... JPBR =',I5///)
 2070 FORMAT(//6X,'Z A   K O N T U R N E   C V O R O V E'///)
 2000 FORMAT(
     111X,'BROJ JEDNACINA .............................. JEDN =',I10// 
     211X,'BROJ ELEMENATA U MATRICI SISTEMA ............. NWK =',I10// 
     311X,'MAKSIMALNA VISINA STUBCA U MATRICI SISTEMA ... MHC =',I10// 
     311X,'ZAUZET PROSTOR U RADNOM VEKTORU ............. LMAX =',I10// 
     411X,'RASPOLOZIV PROSTOR U RADNOM VEKTORU ......... MTOT =',I10///)
 2001 FORMAT(
     111X,'BROJ JEDNACINA .............................. JEDN =',I10// 
     211X,'BROJ ELEMENATA U MATRICI SISTEMA ............. NWK =',I10// 
     411X,'RASPOLOZIV PROSTOR U RADNOM VEKTORU ......... MTOT =',I10///)
 2010 FORMAT(///' NEDOVOLJNA DIMENZIJA ZA SMESTANJE MATRICA I VEKTORA ',
     1'SISTEMA :'/' POTREBNA DIMENZIJA,    LMAXM=',I10/' RASPOLOZIVA ',
     2'DIMENZIJA, MTOT =',I10//
     3' TREBA POVECATI RADNI VEKTOR A()'/' PROGRAM STOP')
 2100 FORMAT(//' NEDOVOLJNO MEMORIJE ZA RAD PO BLOKOVIMA'/
     1' POVECATI DUZINU RADNOG VEKTORA NA MTOT =',I10)
 2200 FORMAT(//' PROGRAM NE MOZE RADITI SA PODSTRUKTURAMA PO BLOKOVIMA'/
     1' POVECATI DUZINU RADNOG VEKTORA ILI BROJ PODSTRUKTURA')
 2300 FORMAT(//' PROGRAM NE MOZE RADITI DINAMICKU ANALIZU PO BLOKOVIMA')
 2400 FORMAT(//' PROGRAM NE MOZE RACUNATI KRITICNE SILE PO BLOKOVIMA')
C-----------------------------------------------------------------------
 6050 FORMAT(///'1',///6X,
     1'DATA ABOUT DIMENSIONS OF THE SYSTEM MATRIX AND THE WORKING ARRAY 
     1A'/6X,66('-')///)
 6060 FORMAT(//6X,
     1'F O R   S U B S T R U C T U R E   N U M B E R .... JPBR =',I5///)
 6070 FORMAT(//6X,'F O R   C O N T O U R   N O D E S'///)
 6000 FORMAT(
     111X,'NUMBER OF EQUATIONS ......................... JEDN =',I10//
     211X,'NUMBER OF ELEMENTS IN THE SYSTEM MATRIX ...... NWK =',I10//
     211X,'MAXIMUM HEIGHT COLUMN IN THE SYSTEM MATRIX ... MHC =',I10//
     311X,'REQUIRED DIMENSION IN THE WORKING ARRAY ..... LMAX =',I10//
     411X,'MAXIMUM TOTAL STORAGE AVAILABLE ............. MTOT =',I10///)
 6001 FORMAT(
     111X,'NUMBER OF EQUATIONS ......................... JEDN =',I10//
     211X,'NUMBER OF ELEMENTS INTO MATRIX OF SYSTEM ..... NWK =',I10//
     411X,'MAXIMUM TOTAL STORAGE AVAILABLE ............. MTOT =',I10///)
 6010 FORMAT(///' UNSUFFICIENT DIMENSION OF WORKING VECTOR:'/
     1' REQUIRED DIMENSION LMAXM =',I10/
     2' AVAILABLE DIMENSION MTOT =',I10)
 6100 FORMAT(//' UNSUFFICIENT MEMORY FOR WORK PER BLOCKS'/
     1' REQUIRED DIMENSION OF WORKING VECTOR, MTOT =',I10)
 6200 FORMAT(//' PROGRAM CAN NOT BE WORKED WITH SUBSTRUCTURES AND BLOCKS
     1')
 6300 FORMAT(//' PROGRAM CAN NOT BE WORKED DYNAMIC ANALISYS WITH BLOCKS 
     1')
 6400 FORMAT(//' PROGRAM CAN NOT BE SOLVED CRITICAL LOADS WITH BLOCKS')
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE FORMRE(NPODS,LMM)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CE    CALL ROUTINE FOR SET POINTERS FOR MATRICES AND VECTORS OF SYSTEM
C
      include 'paka.inc'
      
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /REPERI/ LCORD,LID,LMAXA,LMHT
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /CVOREL/ ICVEL,LCVEL,LELCV,NPA,NPI,LCEL,LELC,NMA,NMI
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /RESTAR/ TSTART,IREST
      COMMON /SRPSKI/ ISRPS
      COMMON /DUPLAP/ IDVA
      COMMON /CDEBUG/ IDEBUG
      DIMENSION NPODS(JPS1,*)
C
      IF(IDEBUG.GT.0) PRINT *, ' FORMRE'
      JPSS=JPS1
      IF(JPS.EQ.1) JPSS=1
      DO 150 JPBB=1,JPSS
         IF(JPS.GT.1) THEN
            JPBR=JPBB
            CALL PODDAT(NPODS,1)
            CALL PODDAT(NPODS,3)
         ELSE
            JPBR=JPS1
         ENDIF 
C
CE       SET POINTERS FOR MATRICES AND VECTORS OF THE SYSTEM
CS       FORMIRANJE REPERA ZA MATRICE I VEKTORE SISTEMA
C
         CALL FORMGR(NPODS,LMM)
C
  150 CONTINUE
C
      IF(JPS.GT.1) THEN
         NPG=NPODS(JPS1,3)
         NGA=NPODS(JPS1,4)
         NGI=NPODS(JPS1,5)
         NPROS=3*NPG
         LMAX=LRAD
         CALL DELJIV(LMAX,2,INDL)
         IF(INDL.EQ.0) LMAX=LMAX+1
         LDRVG=LMAX
         JIDG=LDRVG+NPROS*IDVA
         JCVEL=JIDG+NPG*6
         JELCV=JCVEL+NPG
         NPM=NGA-NGI+1
         LMAX=JELCV+NPM
         CALL CLEAR(A(LDRVG),NPROS)
         NP6=NPG*7+NPM
         LMAX13=NPODS(JPS1,2)-1
         CALL IREADD(A(JIDG),NP6,IPODS,LMAX13,LDUZI)
         LID=LMAX
         DO 160 JPBR=1,JPS
            IDIREK=NPODS(JPBR,69)
            IF(IDIREK.GT.0) GO TO 160
            NP =NPODS(JPBR,3)
            NPA=NPODS(JPBR,4)
            NPI=NPODS(JPBR,5)
            NPK=NPODS(JPBR,7)
            NAA=NPODS(JPBR,8)
            NII=NPODS(JPBR,9)
            NPP=NP+NPK
            LCVEL=LID+NPP*6
            LELCV=LCVEL+NPP
            NMM=NPA-NPI+NAA-NII+2
            LMAX=LELCV+NMM
            CALL DELJIV(LMAX,2,INDL)
            IF(INDL.EQ.0) LMAX=LMAX+1
            LDRV=LMAX
            LMAX=LDRV+NPP*3*IDVA
            NP6=NPP*7+NMM
            LMAX13=NPODS(JPBR,2)-1
            CALL IREADD(A(LID),NP6,IPODS,LMAX13,LDUZI)
C           VEKTOR  VN  U TRENUTKU  T=TAU  NA DISKU
            NPROS=NPP*3
            LMAX13=NPODS(JPBR,70)
            CALL READDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C
            CALL GLNOR1(A(LDRVG),A(LDRV),A(JELCV),A(LCVEL),NPP)
C
  160    CONTINUE
         DO 170 JPBR=1,JPS
            IDIREK=NPODS(JPBR,69)
            IF(IDIREK.GT.0) GO TO 170
            NP =NPODS(JPBR,3)
            NPA=NPODS(JPBR,4)
            NPI=NPODS(JPBR,5)
            NPK=NPODS(JPBR,7)
            NAA=NPODS(JPBR,8)
            NII=NPODS(JPBR,9)
            NPP=NP+NPK
            LCVEL=LID+NPP*6
            LELCV=LCVEL+NPP
            NMM=NPA-NPI+NAA-NII+2
            LMAX=LELCV+NMM
            CALL DELJIV(LMAX,2,INDL)
            IF(INDL.EQ.0) LMAX=LMAX+1
            NPROS=3*NPP*IDVA
            LDRV =LMAX
            LDRV1=LDRV +NPROS
            LDRV0=LDRV1+NPROS
            LMAX =LDRV0
            IF(NGENL.EQ.0) LDRV0=LDRV
            IF(NGENL.GT.0) LMAX =LDRV0+2*NPROS
C           VEKTOR NORMALE I  V1  U TRENUTKU  T  NA DISKU I U  RAM-U
            NPROS=3*NPP
            CALL CLEAR (A(LDRV1),NPROS)
            IF(NGENL.GT.0) CALL CLEAR(A(LDRV0),2*NPROS)
            NP6=NPP*7+NMM
            LMAX13=NPODS(JPBR,2)-1
            CALL IREADD(A(LID),NP6,IPODS,LMAX13,LDUZI)
C           VEKTOR  VN  U TRENUTKU  T=TAU  NA DISKU
            LMAX13=NPODS(JPBR,70)
            CALL READDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C
            CALL GLNOR2(A(LDRVG),A(LDRV),A(JELCV),A(LCVEL),NPP)
C
            NP=NPP
            DO 180 I=1,9
               LSTAZZ(I)=NPODS(JPBR,69+I)
  180       CONTINUE
C
C           NORMIRANJE JEDINICNIH VEKTORA NORMALE  I  V1    
C
            CALL NOVNV1(A(LDRV),A(LDRV1),NP)
C
C           Z A P I S I V A N J E    N A    D I S K
C
            NPROS=3*NP
C           VEKTOR  VN  U TRENUTKU  T=TAU  NA DISKU
            LMAX13=LSTAZZ(1)
            CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C           VEKTOR  V1  U TRENUTKU  T=TAU  NA DISKU
            LMAX13=LSTAZZ(2)
            CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C
            IF(NGENL.GT.0) THEN
C              VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
               LMAX13=LSTAZZ(3)
               CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C              VEKTOR  V1  U TRENUTKU  T+DT  NA DISKU
               LMAX13=LSTAZZ(4)
               CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C              VEKTOR  VN  U TRENUTKU  0  NA DISKU 
               CALL JEDNA1(A(LDRV0),A(LDRV),2*NPROS)
               LMAX13=LSTAZZ(5)
               CALL WRITDD(A(LDRV),2*NPROS,IPODS,LMAX13,LDUZI)
C              RADNI SEARCH VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
               LMAX13=LSTAZZ(6)
               CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C
C              U SLUCAJU AUTOMATSKOG INKREMENTIRANJA OPTERECENJA
C              CUVAJU SE VREDNOSTI SA KRAJA PRETHODNOG KORAKA
C              ZA SLUCAJ KORIGOVANJA PARAMETARA U KORAKU
C
               IF(METOD.GT.5.AND.METOD.LT.10) THEN
                  LMAX13=LSTAZZ(7)
                  CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
                  LMAX13=LSTAZZ(8)
                  CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
               ENDIF
            ENDIF
            NPODS(JPBR,69)=-1
  170    CONTINUE
      ENDIF
      IF(IREST.EQ.2) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2020)
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6020)
      STOP
      ENDIF
      RETURN
C-----------------------------------------------------------------------
 2020 FORMAT(///' ZAVRSENO JE UCITAVANJE I GENERISANJE ULAZNIH PODATAKA'
     1/' ULAZNI PODACI SU BEZ FORMALNIH GRESAKA'/
     2' ZA IZVRSENJE PROGRAMA UNETI:   IREST = 0'//)
C-----------------------------------------------------------------------
 6020 FORMAT(///' READING AND GENERATING OF INPUT DATA IS OVER'/
     1' INPUT DATA ARE WITHOUT FORMAL ERROR'/
     2' FOR EXECUTION OF PROGRAM ENTER:   IREST = 0'//)
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE GLNOR1(DRVG,DRV,MELCV,NCVEL,NPP)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO DEFINE NORMAL CONTOUR NODES
CS.   P R O G R A M
CS.      ZA ODREDJIVANJE NORMALA KONTURNIH CVOROVA
C .
C ......................................................................
C
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /CDEBUG/ IDEBUG
      DIMENSION DRVG(NPG,*),DRV(NPP,*),MELCV(*),NCVEL(*)
C
      IF(IDEBUG.GT.0) PRINT *, ' GLNOR1'
      DO 10 I=1,NPK
         NC=NCVEL(NP+I)
         NC=NC-NGI+1
         NC=MELCV(NC)
         DO 20 J=1,3
            DRVG(NC,J)=DRVG(NC,J)+DRV(NP+I,J)
   20    CONTINUE
   10 CONTINUE
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE GLNOR2(DRVG,DRV,MELCV,NCVEL,NPP)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO DEFINE NORMAL CONTOUR NODES IN SUBSTRUCTURE
CS.   P R O G R A M
CS.      ZA RASPOREDJIVANJE NORMALA KONTURNIH CVOROVA NA PODSTRUKTURU
C .
C ......................................................................
C
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /CDEBUG/ IDEBUG
      DIMENSION DRVG(NPG,*),DRV(NPP,*),MELCV(*),NCVEL(*)
C
      IF(IDEBUG.GT.0) PRINT *, ' GLNOR1'
      DO 10 I=1,NPK
         NC=NCVEL(NP+I)
         NC=NC-NGI+1
         NC=MELCV(NC)
         DO 20 J=1,3
            DRV(NP+I,J)=DRVG(NC,J)
   20    CONTINUE
   10 CONTINUE
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE INIDRV(NPODS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C.. PROSTOR ZA JEDINICNE VEKTORE U CVOROVIMA
C           ( IDIREK ) SE SETUJE AKO POSTOJE GREDE ILI LJUSKE 
C           REZERVISE SE PROSTOR SAMO KOD PRVE UCITANE GRUPE ELEMENATA
C  
      include 'paka.inc'
      
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /DUPLAP/ IDVA
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /CDEBUG/ IDEBUG
      DIMENSION NPODS(JPS1,*)
C
      IF(IDEBUG.GT.0) PRINT *, ' INIDRV'
      IF(IDIREK.GT.0) RETURN
C
      NPROS=3*NP*IDVA
      LDRV =LMAX
      LDRV1=LDRV +NPROS
      LDRV0=LDRV1+NPROS
      LMAX =LDRV0
      IF(NGENL.EQ.0) LDRV0=LDRV
      IF(NGENL.GT.0) LMAX =LDRV0+2*NPROS
C.......  VEKTOR NORMALE I  V1  U TRENUTKU  T  NA DISKU I U  RAM-U
      NPROS=3*NP
      CALL CLEAR (A(LDRV) ,NPROS)
      CALL CLEAR (A(LDRV1),NPROS)
C----------------------------
      IF(NGENL.GT.0) CALL CLEAR(A(LDRV0),2*NPROS)
      NPODS(JPBR,66)=LDRV0
      NPODS(JPBR,67)=LDRV1
      NPODS(JPBR,68)=LDRV
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE DRV000(IGRUP,NPODS,KAKO6,CORD,NCVEL,ID)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C  JEDINICNI VEKTORI U NULTOM TRENUTKU
C
      include 'paka.inc'
      
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /MATERM/ LMODEL,LGUSM
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /CDEBUG/ IDEBUG
      COMMON /RESTAR/ TSTART,IREST
      COMMON /CVOREL/ ICVEL,LCVEL,LELCV,NPA,NPI,LCEL,LELC,NMA,NMI
      COMMON /SOPSVR/ ISOPS,ISTYP,NSOPV,ISTSV,IPROV,IPROL
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
C
      DIMENSION IGRUP(NGELEM,*),NPODS(JPS1,*),KAKO6(*),CORD(NP,*),
     1          NCVEL(*),ID(NP,*)
      IF(IDEBUG.GT.0) PRINT *, ' DRV000'
C
      IF(IDIREK.GT.0) RETURN
C PRIVREMENO ZBOG VAGONA
      IF(IREST.EQ.2.AND.IOPGL(6).EQ.1) THEN
      DO 1 I=1,NP
    1 KAKO6(I)=1
      ENDIF
C
      IDIREK=0
C...... PETLJA PO GRUPAMA ELEMENATA LJUSKI/GREDA 
C
      DO 100 NGE = 1,NGELEM
        NETIP = IGRUP(NGE,1)
C
        IF(NETIP.EQ.4.OR.NETIP.EQ.5.OR.NETIP.EQ.8.OR.NETIP.EQ.9) THEN
          NE    = IGRUP(NGE,2)
          IATYP = IGRUP(NGE,3)
          NMODM = IGRUP(NGE,4)
          LMAX8 = IGRUP(NGE,5)
          ISKNP=0
          CALL UCITAM(A(LMODEL),NMODM)
          LMAX=LRAD
C
          CALL ELEME(NETIP,2)
        ENDIF
C
  100 CONTINUE
C PRIVREMENO ZBOG VAGONA
      IF(IREST.EQ.2.AND.IOPGL(6).EQ.1) THEN
         WRITE(IZLAZ,1011) 
         DO 2 I=1,NP
            II=I
            IF(ICVEL.EQ.1) II=NCVEL(I)
            DO 3 J=1,5
               IF(ID(I,J).EQ.0) THEN
                  ID(I,J)=1
               ELSE
                  ID(I,J)=0
               ENDIF
    3       CONTINUE
         WRITE(IZLAZ,5000) II,(ID(I,J),J=1,5),KAKO6(I),(CORD(I,J),J=1,3)
    2    CONTINUE
      ENDIF
 1011 FORMAT(///' PROGRAMSKI OGRANICEN STEPEN SLOBODE 6'/)
 5000 FORMAT(I5,1X,6I2,2X,3F10.4)
C
      IF(JPS.EQ.1) THEN
C        NORMIRANJE JEDINICNIH VEKTORA NORMALE  I  V1    
         CALL NOVNV1(A(LDRV),A(LDRV1),NP)
         IF(IREST.EQ.2) THEN
            KOR=1
            CALL STAGVN(A(LDRV),A(LCVEL),ICVEL,NP,IGRAF,1)
            CALL STAGVN(A(LDRV1),A(LCVEL),ICVEL,NP,IGRAF,2)
         ENDIF
C
C        Z A P I S I V A N J E    N A    D I S K
C
         NPROS=3*NP
C        VEKTOR  VN  U TRENUTKU  T=TAU  NA DISKU
         LSTAZZ(1)=LMAX13
         CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C        VEKTOR  V1  U TRENUTKU  T=TAU  NA DISKU
         LSTAZZ(2)=LMAX13
         CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C
         IF(NGENL.GT.0) THEN
C           VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
            LSTAZZ(3)=LMAX13
            CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C           VEKTOR  V1  U TRENUTKU  T+DT  NA DISKU
            LSTAZZ(4)=LMAX13
            CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C           VEKTOR  VN  U TRENUTKU  0  NA DISKU 
            CALL JEDNA1(A(LDRV0),A(LDRV),2*NPROS)
            LSTAZZ(5)=LMAX13
            CALL WRITDD(A(LDRV),2*NPROS,IPODS,LMAX13,LDUZI)
C           RADNI SEARCH VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
            LSTAZZ(6)=LMAX13
            CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C
C           U SLUCAJU AUTOMATSKOG INKREMENTIRANJA OPTERECENJA
C           CUVAJU SE VREDNOSTI SA KRAJA PRETHODNOG KORAKA
C           ZA SLUCAJ KORIGOVANJA PARAMETARA U KORAKU
C
            IF(METOD.GT.5.AND.METOD.LT.10) THEN
               LSTAZZ(7)=LMAX13
               CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
               LSTAZZ(8)=LMAX13
               CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
            ENDIF
         ENDIF
         IDIREK=-1
CZILESK
         IF(NDIN.EQ.0.AND.ISOPS.GT.0) THEN
            NPODS(JPBR,88)=LMAX13+1
            CALL WRITDD(A(LDRV0),2*NPROS,IPODS,LMAX13,LDUZI)
         ENDIF
CZILESK
C
      ELSE
C
C        Z A P I S I V A N J E    N A    D I S K
C
         NPROS=3*NP
C        VEKTOR  VN  U TRENUTKU  T=TAU  NA DISKU
         NPODS(JPBR,70)=LMAX13
         CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C        VEKTOR  V1  U TRENUTKU  T=TAU  NA DISKU
         NPODS(JPBR,71)=LMAX13
         CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C
         IF(NGENL.GT.0) THEN
C           VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
            NPODS(JPBR,72)=LMAX13
            CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C           VEKTOR  V1  U TRENUTKU  T+DT  NA DISKU
            NPODS(JPBR,73)=LMAX13
            CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
C           VEKTOR  VN  U TRENUTKU  0  NA DISKU 
            CALL JEDNA1(A(LDRV0),A(LDRV),2*NPROS)
            NPODS(JPBR,74)=LMAX13
            CALL WRITDD(A(LDRV),2*NPROS,IPODS,LMAX13,LDUZI)
C           RADNI SEARCH VEKTOR  VN  U TRENUTKU  T+DT  NA DISKU
            NPODS(JPBR,75)=LMAX13
            CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
C
C           U SLUCAJU AUTOMATSKOG INKREMENTIRANJA OPTERECENJA
C           CUVAJU SE VREDNOSTI SA KRAJA PRETHODNOG KORAKA
C           ZA SLUCAJ KORIGOVANJA PARAMETARA U KORAKU
C
            IF(METOD.GT.5.AND.METOD.LT.10) THEN
               NPODS(JPBR,76)=LMAX13
               CALL WRITDD(A(LDRV), NPROS,IPODS,LMAX13,LDUZI)
               NPODS(JPBR,77)=LMAX13
               CALL WRITDD(A(LDRV1),NPROS,IPODS,LMAX13,LDUZI)
            ENDIF
         ENDIF
      ENDIF
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE NOVNV1(DRG,DRV1,NP)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C...... NORMIRANJE JEDINICNIH VEKTORA NORMALE  I  V1    
C
      COMMON /CDEBUG/ IDEBUG
      DIMENSION DRG(NP,*),DRV1(NP,*),EF1(3),EF2(3),EF3(3)
      IF(IDEBUG.GT.0) PRINT *, ' NOVNV1'
      DO 43 I=1,NP
      DUS=0.D0
      DO 45 J=1,3
   45 DUS= DRG(I,J)*DRG(I,J)+DUS
      IF(DUS.GT.1.D-10) THEN
        DUS=DSQRT(DUS)
        DO 46 J=1,3
        EF3(J)=DRG(I,J)/DUS
   46   DRG(I,J)=EF3(J)
C
        CALL V1V2(EF1,EF2,EF3,1)
C
        DO 11 J=1,3
   11   DRV1(I,J)=EF1(J)
      ELSE
        DRG(I,1)=0.D0
        DRG(I,2)=0.D0
        DRG(I,3)=1.D0
        DRV1(I,1)=1.D0
        DRV1(I,2)=0.D0
        DRV1(I,3)=0.D0
      ENDIF
   43 CONTINUE
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE BLKDEF( MAXA,MNQ,ICPL,LREC,
     1NBLOCK,KC,NBMAX,LR,NEQ,LMAX,MTOT,IDVA,IZLAZ)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO DEFINE OF WORKS WITH BLOCKS
CS.   P R O G R A M
CS.      ZA DEFINISANJE RADA SA BLOKOVIMA
C .
C ......................................................................
C
      COMMON /SRPSKI/ ISRPS
      COMMON /CDEBUG/ IDEBUG
      DIMENSION MAXA(*),MNQ(*),ICPL(*),LREC(*)
C
      IF(IDEBUG.GT.0) PRINT *, ' BLKDEF'
      KC=(MTOT-LMAX)/2/IDVA
      IF(KC.LT.NEQ) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2000)NEQ,KC
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6000)NEQ,KC
         STOP
      ENDIF
CE    CONNECTION OF BLOCKS WITH EQUATIONS
CS    VEZA BLOKOVA SA JEDNACINAMA
      NB=0
      N=1
      M1=0
    5 NB=NB+1
      IF(NB.GT.NBMAX) THEN
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2010)NBMAX
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6010)NBMAX
         STOP
      ENDIF
      MNQ(NB)=N
      M=0
   10 M=M+MAXA(N+1)-MAXA(N)
      IF(M.GT.KC)GO TO 5
      IF(N.EQ.NEQ)GO TO 30
         IF(M.GT.M1) M1=M
         N=N+1
         IF(M.EQ.KC)GO TO 5
         GO TO 10
   30 NBLOCK=NB
      MNQ(NBLOCK+1)=NEQ+1
CE    VEKTOR OF COUPLED BLOCKS    ICPL
CS    VEKTOR SPREGNUTIH BLOKOVA   ICPL
      DO 50 NB=1,NBLOCK
        K=MNQ(NB)
        DO 40 N=MNQ(NB),MNQ(NB+1)-1
        KH=MAXA(N+1)-MAXA(N)-1
   40   IF(N-KH.LT.K) K=N-KH
      KB=0
   42 KB=KB+1
      IF(K.LT.MNQ(KB+1))GO TO 45
      GO TO 42
   45 ICPL(NB)=KB
   50 CONTINUE
CE    POINTER OF WRITE FOR BLOCK    LREC
CS    POLOZAJ ZAPISA BLOKA    LREC
      LREC(1)=1
      DO 70 NB=1,NBLOCK
      LTH=MAXA(MNQ(NB+1))-MAXA(MNQ(NB))
      L1=LTH/LR
      E=FLOAT(LTH)/FLOAT(LR)
      IF(E.GT.FLOAT(L1)) L1=L1+1
      LREC(NB+1)=LREC(NB)+L1
   70 CONTINUE
C
      IF(ISRPS.EQ.0)
     1WRITE(IZLAZ,2030) NBLOCK,M1
      IF(ISRPS.EQ.1)
     1WRITE(IZLAZ,6030) NBLOCK,M1
      RETURN
C-----------------------------------------------------------------------
 2030 FORMAT('1',///6X,
     1'PODACI O BLOKOVIMA MATRICE KRUTOSTI'/
     16X,35('-')///
     111X,'BROJ BLOKOVA .............................. NBLOCK =',I9///
     211X,'MAKSIMALNA DUZINA BLOKA ....................... M1 =',I9)
 2000 FORMAT(/1X,'NEDOVOLJNA DIMENZIJA BLOKA :'
     1/1X,'MINIMALNA POTREBNA DIMENZIJA, JEDN =',I10
     2/1X,'RASPOLOZIVA DIMENZIJA,          KC =',I10)
 2010 FORMAT(/1X,'NEDOVOLJAN BROJ BLOKOVA :'
     1/1X,'RASPOLOZIVI BROJ BLOKOVA,    NBMAX =',I10)
C-----------------------------------------------------------------------
 6030 FORMAT('1',///6X,
     1'DATA ABOUT BLOCKS OF STIFFNESS MATRIX'/
     16X,37('-')///
     111X,'NUMBER OF BLOCKS .......................... NBLOCK =',I9///
     211X,'MAXIMUM LENGTH OF BLOCKS ...................... M1 =',I9)
 6000 FORMAT(/1X,'UNSUFFICIENT DIMENSION OF BLOCK:'
     1/1X,'MINIMUM REQUIRED DIMENSION  JEDN =',I10
     2/1X,'AVAILABLE DIMENSION ........  KC =',I10)
 6010 FORMAT(/1X,'UNSUFFICINET NUMBER OF BLOCKS :'
     1/1X,'AVAILABLE NUMBER OF BLOCKS  NBMAX =',I10)
C-----------------------------------------------------------------------
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE BLKZAP(SK,MAXA,MNQ)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO WRITE BLOCKS
CS.   P R O G R A M
CS.      ZA ZAPISIVANJE BLOKOVIMA
C .
C ......................................................................
C
      COMMON /BLOCKS/ NBMAX,IBLK,NBLOCK,LMNQ,LICPL,LLREC,KC,LR
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /CDEBUG/ IDEBUG
      DIMENSION SK(*),MAXA(*),MNQ(*)
C
      IF(IDEBUG.GT.0) PRINT *, ' BLKZAP'
      DO 70 NB=1,NBLOCK
         LTH=MAXA(MNQ(NB+1))-MAXA(MNQ(NB))
         CALL WRITDD(SK,LTH,IPODS,LMAX13,LDUZI)
   70 CONTINUE
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE MEMIT(NPODS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C....  REZERVISANJE PROSTORA ZA ITERACIJE
      include 'paka.inc'
      
      COMMON /DIM   / N9,N10,N11,N12,MAXUP
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
      COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
     1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /DUPLAP/ IDVA
      COMMON /BFGSUN/ IFILE
      COMMON /CDEBUG/ IDEBUG
      DIMENSION NPODS(JPS1,*)
C
      IF(IDEBUG.GT.0) PRINT *, ' MEMIT'
      IF(METOD.LT.0) RETURN
      N9=LMAX
      MAXUP=15
      NEIT=JEDN*IDVA
      GO TO (10,20,30,40,50,60,60,60,60,60,60) METOD
C....  MODIFIKOVAN NJUTN-RAPSSON (METOD.EQ.1)  -----------------
   10 RETURN
C....  MODIFIKOVANI NJUTN SA AITKENOVIM UBRZANJEM (METOD.EQ.2) -
   20 LMAX=N9+NEIT
      IF(JPS.GT.1) THEN
         NPODS(JPBR,7)=N9
         NPODS(JPBR,17)=LMAX13+1
         CALL CLEAR(A(N9),JEDN)
         CALL WRITDD(A(N9),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
      RETURN
C....  PUNI NJUTN  (METOD.EQ.3)  --------------------------------
   30 RETURN
C....  PUNI NJUTN  +  LINE SEARCH  (METOD.EQ.3)  ----------------
   40 N10=N9+NEIT
      LMAX=N10+NEIT
      IF(JPS.GT.1) THEN
         NPODS(JPBR,7)=N9
         NPODS(JPBR,17)=LMAX13+1
         CALL CLEAR(A(N9),JEDN)
         CALL WRITDD(A(N9),JEDN,IPODS,LMAX13,LDUZI)
         NPODS(JPBR,8)=N10
         NPODS(JPBR,18)=LMAX13+1
         CALL CLEAR(A(N10),JEDN)
         CALL WRITDD(A(N10),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
      RETURN
C....  BFGS  METOD  ---------------------------------------------
   50 N10=N9+NEIT
      N11=N10+NEIT
      N12=N11+NEIT+IDVA
      LMAX=N12+MAXUP*2
      IF(JPS.GT.1) THEN
         NPODS(JPBR,7)=N9
         NPODS(JPBR,17)=LMAX13+1
         CALL CLEAR(A(N9),JEDN)
         CALL WRITDD(A(N9),JEDN,IPODS,LMAX13,LDUZI)
         NPODS(JPBR,8)=N10
         NPODS(JPBR,18)=LMAX13+1
         CALL CLEAR(A(N10),JEDN)
         CALL WRITDD(A(N10),JEDN,IPODS,LMAX13,LDUZI)
         NPODS(JPBR,9)=N11
         NPODS(JPBR,19)=LMAX13+1
         CALL CLEAR(A(N11),JEDN+1)
         CALL WRITDD(A(N11),JEDN+1,IPODS,LMAX13,LDUZI)
         NPODS(JPBR,10)=N12
         NPODS(JPBR,20)=LMAX13+1
         CALL ICLEAR(A(N12),MAXUP*2)
         CALL IWRITD(A(N12),MAXUP*2,IPODS,LMAX13,LDUZI)
      ENDIF
C     LENGTH=(2*JEDN+1)*4*IDVA
C....  OTVARANJE FILE-A ZA BFGS VEKTORE
      CALL BFGSOP
      RETURN
C....  AUTOMATSKO OPTERECENJE (METOD=6X; METOD=7X) ------------
   60 N10=N9+NEIT
      LMAX=N10+NEIT
      IF(JPS.GT.1) THEN
         NPODS(JPBR,7)=N9
         NPODS(JPBR,17)=LMAX13+1
         CALL CLEAR(A(N9),JEDN)
         CALL WRITDD(A(N9),JEDN,IPODS,LMAX13,LDUZI)
         NPODS(JPBR,8)=N10
         NPODS(JPBR,18)=LMAX13+1
         CALL CLEAR(A(N10),JEDN)
         CALL WRITDD(A(N10),JEDN,IPODS,LMAX13,LDUZI)
      ENDIF
      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE IJEDNA8(IA,IB,N)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
C ......................................................................
C .
CE.    P R O G R A M
CE.       TO EQUALIZING INTEGER VECTORS OF 4 AND 8 BYTES WITH TERM :
CS.    P R O G R A M
CS        ZA IZJEDNACAVANJE CELOBROJNIH VEKTORA OD 4 I 8 BAJTOVA SA IZRAZOM :
C .
C .         IA(I)=IB(I)
C .
C ......................................................................
C
      COMMON /CDEBUG/ IDEBUG
      INTEGER*8 IB
      DIMENSION IA(*),IB(*)
C
      IF(IDEBUG.GT.0) PRINT *, ' JEDNA1'
      DO 10 I=1,N
   10 IA(I)=IB(I)
      RETURN
      END
