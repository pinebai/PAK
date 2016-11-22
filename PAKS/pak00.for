C=======================================================================
C
C=======================================================================
C
C ......................................................................
C .
C .                    - P A K N E L -
C .
CE.        FINITE ELEMENT PROGRAM FOR NONLINEAR ANALYSIS
CE.        PROGRAM MAIN
CS.        PROGRAM ZA NELINEARNU ANALIZU KONSTRUKCIJA
CS.        GLAVNI PROGRAM
C .
C ......................................................................
C
C=======================================================================
C .
CE. LIST OF COMMON STATEMENTS
CS. C O M O N I
C .
C .    COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
CE.       LMAX - CURRENT LENGTH OF VECTOR A
CE.       MTOT - MAXIMUM LENGTH OF VECTOR A
CE.       LMAXM- CURRENT MAXIMUM POINTER IN VECTOR A
CE.       LRAD - CURRENT POINTER IN VECTOR A
CE.       NRAD - CURRENT NUMBER OF ELEMENTS REQUVEST IN VECTOR A
CS.       LMAX - TEKUCA DUZINA VEKTORA A
CS.       MTOT - MAKSIMALNA DUZINA VEKTORA A
C .
C .    COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
CE.      LSK   - LEFT-HAND-SIDE VECTOR IN RESEN POINTER
CE.      LRTDT - RIGHT-HAND-SIDE VECTOR IN RESEN POINTER
CE.      NWK   - LENGTH OF LEFT-HAND-SIDE VECTOR
CE.      JEDN  - LENGTH OF RIGHT-HAND-SIDE VECTOR (NUMBER OF EQUATIONS)
CE.      LFTDT - VECTOR OF INTERNAL FORCES POINTER
CS.      LSK    - VEKTOR LEVE STRANE U RESENU
CS.      LRTDT - VEKTOR DESNE STRANE U RESENU (SILE - RESENJA)
CS.      NWK   - DUZINA VEKTORA LEVE STRANE
CS.      JEDN  - DUZINA VEKTORA DESNE STRANE - BROJ JEDNACINA
CS.      LFTDT - VEKTOR UNUTRASNJIH SILA
C .
C .    COMMON /REPERI/ LCORD,LID,LMAXA,LMHT
CE.      LCORD - COORDINATES OF NODAL POINTS POINTER
CE.      LID   - CONSTRAINS OF NODAL POINTS POINTER
CE.      LMAXA - ADDRESSES OF DIAGONAL ELEMENTS IN LEFT-HAND-SIDE POINTER
CE.      LMHT  - COLUMN HEIGHTS IN LEFT-HAND-SIDE VECTOR POINTER
CS.      LCORD - KOORDINATE CVORNIH TACAKA (X,Y,Z)
CS.      LID   - OGRANICENJA CVORNIH TACAKA (POMERANJA I ROTACIJE)
CS.      LMAXA - ADRESE DIJAGONALNIH CLANOVA VEKTORA LEVE STRANE
CS.      LMHT  - VISINE STUBOVA VEKTORA LEVE STRANE
C .
C .    COMMON /BROJUK/ KARTIC,INDFOR,NULAZ
CE.      KARTIC- NUMBER OF READ CARDS
CE.      INDFOR- FORMAT INDICATOR
CE.      NULAZ - KIND OF PRINTOUT OF THE INPUT DATA
CS.      KARTIC- BROJ UCITANE KARTICE
CS.      INDFOR- NACIN UCITAVANJA ULAZNE DATOTEKE
CS.      NULAZ - NACIN STAMPANJA ULAZNIH PODATAKA
C .
C .    COMMON /FVREME/ NTABFT,MAXTFT,LNTFT,LTABFT
CE.      NTABFT- NUMBER OF DIFFERENT TIME FUNCTION
CE.      MAXTFT- MAXIMUM NUMBER OF POINTS FOR DEFINITION OF TIME FUNCTIONS
CE.      LNTFT - VECTOR NUMBER POINT FOR EACH FUNCTION POINTER
CE.      LTABFT- TIME FUNCTIONS DATA POINTER
CS.      NTABFT- BROJ TABELARNO ZADATIH VREMENSKIH FUNKCIJA
CS.      MAXTFT- MAXIMALNI BROJ TACAKA ZA VREMENSKE FUNKCIJE
CS.      LNTFT - VEKTOR BROJA TACAKA ZA SVAKU FUNKCIJU
CS.      LTABFT- VREMENSKE FUNKCIJE
C .
C .    COMMON /DUPLAP/ IDVA
CE.      IDVA  - DOUBLE PRECISION CODE
CS.      IDVA  - INDIKATOR DUPLE PRECIZNOSTI
C .
C .    COMMON /TRAKEJ/ IULAZ,IZLAZ,IELEM,ISILE,IRTDT,IFTDT,ILISK,ILISE,
C .   1                ILIMC,ILDLT,IGRAF,IDINA,IPOME,IPRIT,LDUZI
CE.      IULAZ - UNIT FOR INPUT DATA
CE.      IZLAZ - UNIT FOR OUTPUT DATA
CE.      IELEM - UNIT STORING ELEMENT DATA (NOT USED)
CE.      ISILE - UNIT STORING CONCENTRATED FORCES DATA (NOT USED)
CE.      IRTDT - UNIT STORING EXTERNALLY APPLIED LOADS (NOT USED)
CE.      IFTDT - UNIT STORING INTERNALLY FORCE (NOT USED)
CE.      ILISK - UNIT STORING LINEAR STIFFNESS MATRIX (NOT USED)
CE.      ILISE - UNIT STORING EFFECTIVE LINEAR STIFFNESS MATRIX (NOT USED)
CE.      ILIMC - UNIT STORING MASS MATRIX (NOT USED)
CE.      ILDLT - UNIT STORING FACTORIZE EFFECTIVE STIFFNES MATRIX (NOT USED)
CE.      IGRAF - UNIT FOR GRAPHICS
CE.      IDINA - UNIT FOR DYNAMIC ANALYSIS (NOT USED)
CE.      IPOME - UNIT STORING DISPLACEMENTS, VELOCITY AND ACCELERATION (NOT USED)
CE.      IPRIT - UNIT STORING PRESSURE DATA (NOT USED)
CE.      LDUZI - RECORD LENGTH OF A DIRECT ACCESS FILE
CS.      IULAZ - JEDINICA ULAZNIH PODATAKA
CS.      IZLAZ - JEDINICA ZA STAMPANJE
CS.      IELEM - JEDINICA ZA PODATKE O ELEMENTIMA
CS.      ISILE - JEDINICA ZA PODATKE O KONCENTRISANIM SILAMA
CS.      IRTDT - JEDINICA ZA SPOLJASNJE SILE
CS.      IFTDT - JEDINICA ZA UNUTRASNJE SILE
CS.      ILISK - JEDINICA ZA LINEARNU MATRICU KRUTOSTI
CS.      ILISE - JEDINICA ZA LINEARNU EFEKTIVNU MATRICU KRUTOSTI
CS.      ILIMC - JEDINICA ZA MATRICU MASA I PRIGUSENJA
CS.      ILDLT - JEDINICA ZA FAKTORIZOVANU EFEKTIVNU MATRICU KRUTOSTI
CS.      IGRAF - JEDINICA ZA GRAFIKU
CS.      IDINA - JEDINICA ZA DINAMIKU
CS.      IPOME - JEDINICA ZA POMERANJA, BRZINE I UBRZANJA
CS.      IPRIT - JEDINICA ZA PODATKE O PRITISCIMA
CS.      IPRIR - JEDINICA ZA PRIRASTAJE POMERANJA
CS.      LDUZI - DUZINA STAZE KOD JEDINICE SA DIREKTNIM PRISTUPOM
C .
C .    COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
C .   1                IOPGL(6),KOSI,NDIN,ITEST
CE.      NP    - TOTAL NUMBER OF NODAL POINTS
CE.      NGELEM- NUMBER OF ELEMENT GROUPS
CE.      NMATM - NUMBER OF MATERIAL MODELS
CE.      NPER  - NUMBER OF PERIODS WITH CONSTANT TIME STEP
CE.      IOPGL - GLOBAL CONSTRAINTS ARRAY
CE.      KOSI  - NUMBER OF SKEW COORDINATE SYSTEMS (NOT USED)
CE.      NDIN  - TYPE OF ANALYSIS (STATIC/DYNAMIC/EIGEN)
CE.      ITEST - INDICATOR FOR PROGRAM TESTING
CS.      NP    - BROJ CVORNIH TACAKA
CS.      NGELEM- BROJ GRUPA ELEMENATA
CS.      NMATM - BROJ MATERIJALNIH MODELA
CS.      NPER  - BROJ VREMENSKIH PERIODA SA KONSTANTNIM KORAKOM
CS.      IOPGL - VEKTOR GLOBALNIH OGRANICENJA POMERANJA I ROTACIJA
CS.      KOSI  - BROJ KOSIH KOORDINATNIH SISTEMA
CS.      NDIN  - INDIKATOR DINAMIKE
CS.      ITEST - INDIKATOR RADA PROGRAMA SA UCITANIM MATRICAMA
C .
C .    COMMON /POSTPR/ LNDTPR,LNDTGR,NBLPR,NBLGR,INDPR,INDGR
CE.      LNDTPR- CONTROL DATA FOR RESULTS PRINTOUT POINTER
CE.      LNDTGR- CONTROL DATA FOR RESULTS PLOTING POINTER
CE.      NBLPR - NUMBER OF BLOCKS FOR RESULTS PRINTOUT
CE.      NBLGR - NUMBER OF BLOCKS FOR GRAFICAL RESULTS PRINTOUT
CE.      INDPR - PRINTOUT CODE
CE.      INDGR - GRAFICAL DATA PRINTOUT CODE
CS.      LNDTPR- INFORMACIJE O STAMPANJU REZULTATA PO KORACIMA
CS.      LNDTGR- INFORMACIJE O CRTANJU REZULTATA PO KORACIMA
CS.      NBLPR - BROJ BLOKOVA ZA STAMPANJE REZULTATA
CS.      NBLGR - BROJ BLOKOVA ZA CRTANJE REZULTATA
CS.      INDPR - INDIKATOR STAMPANJA
CS.      INDGR - INDIKATOR CRTANJA
C .
C .    COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
CE.      LNKDT - NUMBER OF STEPS IN PERIODS VECTOR POINTER
CE.      LDTDT - TIME INCREMENT IN PERIODS VECTOR POINTER
CE.      NDT   - TOTAL NUMBER OF TIME STEPS
CE.      DT    - TIME INCREMENT IN STEP
CE.      VREME - TIME VALUE IN CURENT STEP
CE.      KOR   - CURENT STEP
CS.      LNKDT - VEKTOR BROJA KORAKA U PERIODU
CS.      LDTDT - VEKTOR VREMENKOG PRIRASTAJA U PERIODU
CS.      NDT   - UKUPAN BROJ VREMENSKIH KORAKA
CS.      DT    - VREMENSKI PRIRASTAJ U KORAKU
CS.      VREME - TEKUCE VREME U KORAKU
CS.      KOR   - TEKUCI BROJ KORAKA
C .
C .    COMMON /ITERAC/ METOD,MAXIT,TOLE,TOLS,TOLM,KONVE,KONVS,KONVM
CE.      METOD - INDICATOR FOR ITERATION METHOD EMPLOYED
CE.      MAXIT - MAXIMUM NUMBER OF ITERATIONS
CE.      TOLE  - TOLERANCE FOR CONVERGENCE CRITERIUM - ENERGY
CE.      TOLS  - TOLERANCE FOR CONVERGENCE CRITERIUM - FORCE
CE.      TOLM  - TOLERANCE FOR CONVERGENCE CRITERIUM - MOMENT
CE.      KONVE - INDICATOR FOR CONVERGENCE CRITERIUM - ENERGY
CE.      KONVS - INDICATOR FOR CONVERGENCE CRITERIUM - FORCE
CE.      KONVM - INDICATOR FOR CONVERGENCE CRITERIUM - MOMENT
CS.      METOD - INDIKATOR PRIMENJENOG ITERATIVNOG METODA
CS.      MAXIT - MAXIMALAN BROJ ITERACIJA
CS.      TOLE  - TOLERANCIJA ZA KRITERIJUM KONVERGENCIJE ENERGIJA
CS.      TOLS  - TOLERANCIJA ZA KRITERIJUM KONVERGENCIJE SILA
CS.      TOLM  - TOLERANCIJA ZA KRITERIJUM KONVERGENCIJE MOMENT
CS.      KONVE - INDIKATOR ZA KRITERIJUM KONVERGENCIJE ENERGIJA
CS.      KONVS - INDIKATOR ZA KRITERIJUM KONVERGENCIJE SILA
CS.      KONVM - INDIKATOR ZA KRITERIJUM KONVERGENCIJE MOMENT
C .
C .    COMMON /RESTAR/ TSTART,IREST
CE.      TSTART- TIME OF SOLUTION RESTART
CE.      IREST - INDICATOR FOR RESTART
CS.      TSTART- VREME POCETKA RESAVANJA
CS.      IREST - INDIKATOR RESTARTOVANJA
C .
C .    COMMON /MODELI/ LMODEL
CE.      LMODEL- DATA FOR MATERIALS POINTER
CS.      LMODEL- INFORMACIJE ZA MATERIJALE
C .
C .    COMMON /OPTERE/ NCF,NPP2,NPP3,NPGR,NPGRI,NPLJ,NTEMP,NZADP
CE.      NCF   - NUMBER OF CONCENTRACED FORCES
CE.      NPP2  - NUMBER OF 2/D SURFACE LOADING
CE.      NPP3  - NUMBER OF 3/D SURFACE LOADING
CE.      NPGR  - NUMBER OF BEAMS LOADED BY CONTINUAL LOADING
CE.      NPGRI - NUMBER OF ISOPARAMETRIC BEAMS LOADED BY CONTINUAL LOADING
CE.      NPLJ  - NUMBER OF SHELL SURFACE LOADING
CE.      NTEMP - NUMBER OF TEMPERATUE LOADED NODES
CE.      NZADP - NUMBER OF NODES WITH PRESCRIBED DISPLACEMENTS
CS.      NCF   - BROJ KARTICA ZA UCITAVANJE CVORNIH SILA
CS.      NPP2  - BROJ POVRSINA 2/D ELEMENATA POD PRITISKOM
CS.      NPP3  - BROJ POVRSINA 3/D ELEMENATA POD PRITISKOM
CS.      NPGR  - BROJ GREDA POD PRITISKOM
CS.      NPGRI - BROJ IZOPARAMETARSKIH GREDA POD PRITISKOM
CS.      NPLJ  - BROJ LJUSKI POD PRITISKOM
CS.      NTEMP - BROJ KARTICA ZA UCITAVANJE TEMPERATURA
CS.      NZADP - BROJ KARTICA ZA UCITAVANJE ZADATIH POMERANJA
C .
C .    COMMON /DINAMI/ IMASS,IDAMP,PIP,DIP,MDVI
CE.      IMASS - MASS MATRIX CODE
CE.      IDAMP - DAMPING MATRIX CODE
CE.      PIP   - FIRST INTEGRATION PARAMETER
CE.      DIP   - SECOND INTEGRATION PARAMETER
CE.      MDVI  - TIME INTEGRATION CODE
CS.      IMASS - INDIKATOR VRSTE MATRICE MASA
CS.      IDAMP - INDIKATOR VRSTE MATRICE PRIGUSENJA
CS.      PIP   - PRVI INTEGRACIONI PARAMETAR
CS.      DIP   - DRUGI INTEGRACIONI PARAMETAR
CS.      MDVI  - METOD DIREKTNE VREMENSKE INTEGRACIJE
C .
C .    COMMON /EDPCON/ A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10
CE.      DYNAMIC CONSTANTS
CS.      DINAMICKE KONSTANTE
C .
C .    COMMON /EPUREP/ LPUU,LPUV,LPUA,IPUU,IPUV,IPUA,ISUU,ISUV,ISUA
CE.      LPUU  - INITIAL DISPLACEMENTS POINTER
CE.      LPUV  - INITIAL VELOCITIES POINTER
CE.      LPUA  - INITIAL ACELERATIONS POINTER
CE.      IPUU  - INITIAL DISPLACEMENT FLAG
CE.      IPUV  - INITIAL VELOCITY FLAG
CE.      IPUA  - INITIAL ACCELERATIONS FLAG
CS.      LPUU  - POCETNA POMERANJA
CS.      LPUV  - POCETNE BRZINE
CS.      LPUA  - POCETNA UBRZANJA
CS.      IPUU  - INDIKATOR POCETNIH POMERANJA
CS.      IPUV  - INDIKATOR POCETNIH BRZINA
CS.      IPUA  - INDIKATOR POCETNIH UBRZANJA
C .
C ......................................................................
C=======================================================================
C
C=======================================================================
C
C    SUBROUTINE UPAKS
C               ZAGLAV
C               ELEME
C               STAINF
C
C=======================================================================
      SUBROUTINE UPAKS(IMAJOS,NTOT,NKDT,DTDT,NPE,LIPOD,LMAXS,LSKS,LMM,
     +                 NGENLS,LKAKOS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
CE.    MAIN ROUTINE FOR INPUT DATA
C
CE.    P O I N T E R S                                                  
CE.        LIPODS- IS POINTER FOR ARRAY NPODS(JPS+1,100). 
CE.                NPODS()- IS BASIC ARRAY WITH GENERAL PROGRAM CONTROL
CE.                         PARAMETERS, POINTERS AND RECORD NUMBERS. 
CE.                JPS    - IS NUMBER OF SUBSTRUCTURES.
CE.                         (JPS=1 - SUBSTRUCTURES ARE NOT USED)
CE.        LMAX  - LAST USED ELEMENT IN WORKING ARRAY A(*) FOR CURRENT
CE.                EXECUTION PHASE OF THE PROGRAM. 
CE.                LMAX=1 - AT BEGINING OF THE PROGRAM EXECUTION.
CE.                DURING PROGRAM EXECUTION MUST BE (LMAX.LE.NTOT).
CE.                FOR (LMAX.GT.NTOT) PROGRAM STOPS.
CE.        LMM   - IS LAST USED ELEMENT IN WORKING ARRAY A(*) 
CE.    V A R I A B L E S
CE.        LMAX13- IS RECORD NUMBER OF DIRECT ACCESS FILE (ZIPODS) 
C
      CHARACTER*250 ACOZ
      CHARACTER*4 KRAJ
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /DUZINA/ LMAX,MTOT,LMAXM,LRAD,NRAD
      COMMON /SISTEM/ LSK,LRTDT,NWK,JEDN,LFTDT
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
      COMMON /SOPSVR/ ISOPS,ISTYP,NSOPV,ISTSV,IPROV,IPROL
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /MAXREZ/ PMALL,BMALL,AMALL,SMKOR,SMALL,
     +                NPMALL,NBMALL,NAMALL,KPMALL,KBMALL,KAMALL,
     +                NSMKOR,NSMALL,NGRKOR,NGRALL,KSMALL
      COMMON /BEAMAX/ FZATM,FSMICM,FTORM,FSAVM,NEB1KOR,NPB1KOR,NEB2KOR,
     1                NPB2KOR,NEB4KOR,NPB4KOR,NEB5KOR,NPB5KOR,
     1                NMB1KOR,NMB2KOR,NMB4KOR,NMB5KOR,IMAGREDA 
      COMMON /GRUPEE/ NGEL,NGENL,LGEOM,NGEOM,ITERM
      COMMON /KAKO6O/ LLJUS,LKAKO6
      COMMON /CDEBUG/ IDEBUG
      COMMON /VTKVALUES/ VTKIME,IVTKCOUNTER,KOJPAKVTK
C
      include 'paka.inc'
      
      DIMENSION NKDT(*),DTDT(*)
C
      MTOT=NTOT
      LMAX=LMAXS
      KOJPAK = KOJPAKVTK
C
      IF(IMAJOS.GT.0) GO TO 9999
C
CE    SETTING OF PROGRAM PARAMETERS
C
      CALL PAKPAR
C
      IF(IDEBUG.GT.0) PRINT *, ' UPAKS'
CZxxx
      CALL ZASTIT0
CZxxxx
C
CE    O P E N   I N P U T   F I L E
CS    O T V A R A N J E   U L A Z N E    D A T O T E K E
C     -----------
      CALL OTVORI
C     -----------
C
CE    R E A D I N G    G E N E R A L    I N P U T    D A T A
CS    F A Z A   U C I T A V A N J A   U L A Z N I H   P O D A T A K A
C
C
 9999 CALL VREM(1)
C
CE    B A S I C   D A T A  F O R   T H E   P R O B L E M
CS    O S N O V N I   P O D A C I   O   P R O B L E M U
CE    /1/-/9/ USER MANUAL
C     -----------
      CALL UCDATA
C     -----------
CE    OPEN OTHER FILES
CS    OTVARANJE OSTAGIH FAJLOVA
C     -----------
      CALL OTVSCR
C     -----------
CE    N O D A L   P O I N T    D A T A
CS    P O D A C I   O   C V O R N I M   T A C K A M A
CE    /10/ USER MANUAL
C     -----------
      CALL UCKORD
C     -----------
CE    I N I T I A L   C O N D I T I O N S   D A T A
CS    P O D A C I   Z A   P O C E T N E   U S L O V E
CE    /10-1/-/10-4/ USER MANUAL
CE    (NDIN, ISOPS)  SEE CARD /4/ USER MANUAL
C                                  -----------
      IF(NDIN.GT.0.AND.ISOPS.EQ.0) CALL UCPUVA(A(LIPODS))
C                                  -----------
CE    I N P U T   D A T A   F O R   M A T E R I A L   M O D E L S 
CS    U L A Z N I   P O D A C I   O   M A T E R I J A L I M A
CE    /11/-/12/ USER MANUAL
C                    -----------
      IF(ITEST.NE.1) CALL UCMATE
C                    -----------
CE    I N P U T   D A T A   F O R   E L E M E N T S
CS    U L A Z N I   P O D A C I   Z A   E L E M E N T E
CE    /13/ USER MANUAL
C     -----------
      KOJPAKVTK = KOJPAK
      CALL UCELEM
C     -----------
CE    R E A D   D A T A   A B O U T   T I M E   F U N C T I O N S
CS    U C I T A V A NJ E   V R E M E N S K I H    F U N K C I J A
CE    /14/ USER MANUAL
C     -----------
      CALL UCVRFN
C     -----------
CE    I N P U T   D A T A   F O R   L O A D S
CS    U L A Z N I   P O D A C I   Z A    O P T E R E C E NJ A
CE    /15/ USER MANUAL
C     ----------
      CALL UCOPT
C     ----------
CE    READ CARD "STOP" /16/
CS    UCITAVANJE ZAVRSNE KARTICE
C
      CALL ISPITA(ACOZ)
      READ(ACOZ,5000) KRAJ
      IMAJOS=IMAJOS+1
      IF(KRAJ.EQ.'STOP') THEN
         IMAJOS=0
         CALL ZATVOR(1)
      ENDIF
C
CE    FORM POINTERS FOR SYSTEM MATRICES AND VECTORS
CS    FORMIRANJE REPERA ZA MATRICE I VEKTORE SISTEMA
C     -----------
      CALL FORMRE(A(LIPODS),LMM)
C     -----------
      PMALL=0.
      BMALL=0.
      AMALL=0.
      SMALL=0.
      NPMALL=0
      NBMALL=0
      NAMALL=0
      KPMALL=0
      KBMALL=0
      KAMALL=0
      NSMALL=0
      NGRALL=0
      KSMALL=0
C
C      COMMON /BEAMAX/ FZATM,FSMICM,FTORM,FSAVM,NEB1KOR,NPB1KOR,NEB2KOR,
C     1                NPB2KOR,NEB4KOR,NPB4KOR,NEB5KOR,NPB5KOR,
C     1                NMB1KOR,NMB2KOR,NMB4KOR,NMB5KOR,IMAGREDA 
      IMAGREDA=0
	FZATM=0.
	FSMICM=0.
	FTORM=0.
	FSAVM=0.
C
C
      IPROL=0
      NPE=NPER
      LIPOD=LIPODS
      LMAXS=LMAX
      LSKS=LSK
      NGENLS=NGENL
      LKAKOS=LKAKO6
C
      IF(NPER.GT.100) STOP ' NPER.GT.100'
      CALL IJEDN1(NKDT,A(LNKDT),NPER)
      CALL JEDNA1(DTDT,A(LDTDT),NPER)
C
      RETURN
 5000 FORMAT(A4)
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE SPAKS(IMAJOS)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      include 'paka.inc'
      
      COMMON /SOPSVR/ ISOPS,ISTYP,NSOPV,ISTSV,IPROV,IPROL
      COMMON /OPSTIP/ JPS,JPBR,NPG,JIDG,JCORG,JCVEL,JELCV,NGA,NGI,NPK,
     1                NPUP,LIPODS,IPODS,LMAX13,MAX13,JEDNG,JMAXA,JEDNP,
     1                NWP,NWG,IDF,JPS1
      COMMON /CDEBUG/ IDEBUG
      INCLUDE 'mpif.h'
      integer ierr, myid
C
CE    E I G E N    V A L U E S  -  S T A B I L I T Y    A N A L Y S I S
CS    S O P S T V E N E    V R E D N O S T I  -  S T A B I L N O S T
C
      CALL MPI_COMM_RANK(MPI_COMM_WORLD,myid,ierr)
      CALL EPAKS(A(LIPODS))
C
      CALL MPI_BARRIER(MPI_COMM_WORLD,ierr)
      CALL MPI_BCAST(ISOPS,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
      CALL MPI_BCAST(JPS,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
      IF(ISOPS.GT.0) THEN
         IF(JPS.GT.1) THEN
            CALL MIKA(A(LIPODS))
         ELSE
            write(*,*)'pre call rsopvr iz pak00 iz procesa',myid
            if (myid.eq.0) CALL RSOPVR(1)
         ENDIF
      ENDIF
      write(*,*)'pre barijere iz pak00 iz procesa',myid
      CALL MPI_BARRIER(MPI_COMM_WORLD,ierr)
C           -----------
      IF (myid.eq.0) THEN
         CALL VREM(4)
C
CE       READ NEXT DATA CASE OR PROGRAM STOP
CS       AKO NA KRAJU DATOTEKE NE STOJI STOP UCITAVA SE SLEDECI PRIMER
C
         IF(IMAJOS.GT.0) RETURN
C
CE       CLOSE FILES
CS       ZATVARANJE DATOTEKA
C        -----------
         CALL ZATVOR(2)
C        -----------
      ENDIF

      RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE ELEME(NETIP,IND)
C
C ......................................................................
C .
CE.    P R O G R A M
CE.        TO CALL ELEMENT ROUTINES
CS.    P R O G R A M
CS.        ZA POZIVANJE TIPOVA ELEMENATA
C .
CE.       IND = 1   - READING OF INPUT DATA FOR ELEMENT
CE.       IND = 2   - CALCULATION OF STIFFNESS MATRICES
CE.       IND = 3   - CALCULATION OF STRESSES AND INTERNAL FORCES
CE.       IND = 4   - PRINTING OF STRESSES
CE.       IND = 5   - CALCULATION OF MASS MATRICES
CE.       IND = 6   - CALCULATION OF DAMP MATRICES
CE.       IND = 7   - CALCULATION OF ACCELERATION FOR CONTACT PROBLEMS
CE.       IND = 8   - CALCULATION OF VELOCITY FOR CONTACT PROBLEMS
CE.       IND = 9   - CALCULATION OF FORCES FOR CONTACT PROBLEMS
CS.       IND = 1   - ULAZNI PODACI ZA ELEMENTE
CS.       IND = 2   - RACUNANJE MATRICA KRUTOSTI
CS.       IND = 3   - RACUNANJE NAPONA I UNUTRASNJIH SILA
CS.       IND = 4   - STAMPANJE NAPONA
CS.       IND = 5   - RACUNANJE MATRICA MASA
CS.       IND = 6   - RACUNANJE MATRICA PRIGUSENJA
CS.       IND = 7   - KOREKCIJA UBRZANJA ZA KONTAKTNI PROBLEM
CS.       IND = 8   - KOREKCIJA BRZINA ZA KONTAKTNI PROBLEM
CS.       IND = 9   - AZURIRANJE SILA ZA KONTAKTNI PROBLEM
C .
C ......................................................................
C
      COMMON /RADIZA/ INDBG
      COMMON /CDEBUG/ IDEBUG
      common /elejob/ indjob
C
      IF(IDEBUG.GT.0) PRINT *, ' ELEME'
      indjob=ind
      IF(INDBG.EQ.0)
     1CALL STAINF(IND)
C
C
CE    IND=1  - INPUT DATA FOR ELEMENTS
CS    IND=1  - ULAZNI PODACI ZA ELEMENTE
C
C
      GO TO (100,200,300,400,500,600,200,200,200),IND
C
CE    INPUT DATA FOR ELEMENTS
CS    ULAZNI PODACI ZA ELEMENTE
C
  100 GO TO (110,120,130,140,150,160,170,180,190,129,
     1       139,111,112,114),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
  110 CALL UL1EGL
C  110 CONTINUE
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
  120 CALL UL2EGL
C  120 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT K21
CE    /13-3/ USER MANUAL
C
  130 CALL UL3EGL
C  130 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
  140 CALL UL4EGL
C  140 CONTINUE
      RETURN
C
CE    PLATE DKT
CS    ELEMENT PLOCE DKT
C
  150 CALL UPL3M
C 150 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  160 CALL ULTPG
C  160 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  170 CALL UL7EGL
C 170 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
  180 CALL ULJ4B
C 180 CONTINUE
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
  190 CALL ULJ9B
C 190 CONTINUE
      RETURN
C
CE    CONTACT 2-D ELEMENTS
CS    KONTAKTNI 2-D ELEMENTI
C
  129 CALL UL92GL
      RETURN
C
CE    CONTACT 3-D ELEMENTS
CS    KONTAKTNI 3-D ELEMENTI
C
  139 CALL UL93GL
      RETURN
C
CE    OSLONCI
CS    SUPPORTS
C
  111 CALL UL11EG
      RETURN
C
CE    EFG 2/D
CS    EFG 2/D
C
  112 CALL U22EGL
C  112 CONTINUE
      RETURN
C
CE    GAP
CS    GAP
C
  114 CALL UL14EG
      RETURN
C
CE    INTEGRATION OF THE ELEMENT STIFFNESS MATRIX AND ADD TO GLOBAL
CE    SYSTEM MATRIX
CS    FORMIRANJE MATRICA KRUTOSTI I VEKTORA SISTEMA
C
  200 GO TO (210,220,230,240,250,260,270,280,290,229,
     1       239,211,212,214),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
  210 CALL S02EGL
C  210 CONTINUE
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
  220 CALL K09EGL
C 220 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT  K21
C
  230 CALL K21EGL
C 230 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
  240 CALL S04EGL
C  240 CONTINUE
      RETURN
C
CE    PLATE
CS    ELEMENT PLOCE
C
  250 CALL PLGL3M
C 250 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  260 CALL KTPG
C  260 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  270 CALL L04EGL
C 270 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
  280 CALL IZLJ4B
C 280 CONTINUE
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
  290 CALL IZLJ9B(IND)
C 290 CONTINUE
      RETURN
C
CE    CONTACT 2-D ELEMENTS
CS    KONTAKTNI 2-D ELEMENTI
C
  229 CALL S992GL(IND)
      RETURN
C
CE    CONTACT 3-D ELEMENTS
CS    KONTAKTNI 3-D ELEMENTI
C
  239 CALL S993GL(IND)
      RETURN
C
CE    OSLONCI
CS    SUPPORTS
C
  211 CALL S11EGL
      RETURN
C
CE    EFG 2/D
CS    EFG 2/D
C
  212 CALL K29EGL
C  212 CONTINUE
      RETURN
C
CE    GAP
CS    GAP
C
  214 CALL S14EGL
      RETURN
C
C
CE    CALCULATE STRESS IN GAUSS POINT AND INTERNAL FORCE
CS    RACUNANJE NAPONA  U GAUS TACKAMA I UNUTRASNJIH SILA
C
  300 GO TO (310,320,330,340,350,360,370,380,390,329,
     1       339,311,312,314),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
  310 CALL S02EGL
C  310 CONTINUE
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
  320 CALL K09EGL
C 320 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT  K21
C
  330 CALL K21EGL
C 330 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
  340 CALL S04EGL
C  340 CONTINUE
      RETURN
C
CE    PLATE
CS    ELEMENT PLOCE
C
  350 CALL PLGL3M
C 350 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  360 CALL KTPG
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  370 CALL L04EGL
C 370 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
  380 CALL IZLJ4B
C 380 CONTINUE
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
  390 CALL IZLJ9B(IND)
C 390 CONTINUE
      RETURN
C
CE    CONTACT 2-D ELEMENTS
CS    KONTAKTNI 2-D ELEMENTI
C
  329 CALL S992GL(IND)
      RETURN
C
CE    CONTACT 3-D ELEMENTS
CS    KONTAKTNI 3-D ELEMENTI
C
  339 CALL S993GL(IND)
      RETURN
C
CE    OSLONCI
CS    SUPPORTS
C
  311 CALL S11EGL
      RETURN
C
CE    EFG 2/D
CS    EFG 2/D
C
  312 CALL K29EGL
C  312 CONTINUE
      RETURN
C
CE    GAP
CS    GAP
C
  314 CALL S14EGL
      RETURN
C
CE    PRINT STRESS IN GAUSS POINT
CS    STAMPANJE NAPONA U GAUSS TACKAMA
C
  400 GO TO (410,420,430,440,450,460,470,480,490,429,
     1       439,411,412,414),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
  410 CALL S02NAP
C  410 CONTINUE
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
  420 CALL K09NAP
C 420 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT  K21
C
  430 CALL K21NAP
C 430 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
  440 CALL PRINKN
C  440 CONTINUE
      RETURN
C
CE    PLATE
CS    ELEMENT PLOCE
C
  450 CALL PL5NAP
C 450 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  460 CALL KTPGNA
C 460 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  470 CALL L04NAP
C 470 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
  480 CALL LU8NAP
C 480 CONTINUE
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
  490 CALL LU9NAP
C 490 CONTINUE
      RETURN
C
CE    CONTACT 2-D ELEMENTS
CS    KONTAKTNI 2-D ELEMENTI
C
  429 CALL S92NAP
      RETURN
C
CE    CONTACT 3-D ELEMENTS
CS    KONTAKTNI 3-D ELEMENTI
C
  439 CALL S93NAP
      RETURN
C
CE    OSLONCI
CS    SUPPORTS
C
  411 CALL S11NAP
      RETURN
C
CE    EFG 2/D
CS    EFG K09
C
  412 CALL K29NAP
C 412 CONTINUE
      RETURN
C
CE    GAP
CS    GAP
C
  414 CALL S14NAP
      RETURN
C
CE    CALCULATE MASS MATRIX
CS    RACUNANJE MATRICE MASA
C
  500 GO TO (510,520,530,540,550,560,570,580,590,529,
     1       539,999,999,999),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
  510 CALL S02MAS
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
  520 CALL K09MAS
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT  K21
C
  530 CALL K21MAS
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
  540 CALL IGMAS
      RETURN
C
CE    PLATE
CS    ELEMENT PLOCE
C
C 550 CALL PLMAS
  550 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  560 CALL TPGMAS
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  570 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
  580 CALL K81MAS
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
  590 CALL IZLJ9B(IND)
C 590 CONTINUE
      RETURN
C
CE    CONTACT 2-D ELEMENTS
CS    KONTAKTNI 2-D ELEMENTI
C
  529 CALL S992GL(IND)
      RETURN
C
CE    CONTACT 3-D ELEMENTS
CS    KONTAKTNI 3-D ELEMENTI
C
  539 CALL S993GL(IND)
      RETURN
C
CE    CALCULATE DAMP MATRIX
CS    RACUNANJE MATRICE PRIGUSENJA
C
  600 GO TO (610,620,630,640,650,660,670,680,690,629,
     1       629,999,999,999),NETIP
C
CE    TRUSS
CS    STAPNI ELEMENT
C
C  610 CALL S02DMP
  610 CONTINUE
      RETURN
C
CE    ISOPARAMETRIC 2/D
CS    IZOPARAMETARSKI RAVANSKI ELEMENT K09
C
C  620 CALL K09DMP
  620 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC 3/D
CS    IZOPARAMETARSKI PROSTORNI ELEMENT  K21
C
C 630 CALL K21DMP
  630 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC BEAM
CS    IZOPARAMETARSKI GREDNI ELEMENT
C
C 640 CALL IGDMP
  640 CONTINUE
      RETURN
C
CE    PLATE
CS    ELEMENT PLOCE
C
C 650 CALL PLDMP
  650 CONTINUE
      RETURN
C
CE    THIN WALLED BEAM
CS    TANKOZIDNI GREDNI ELEMENT
C
  660 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC AXISYMMETRIC SHELL
CS    IZOPARAMETARSKA OSNOSIMETRICNA LJUSKA
C
  670 CONTINUE
      RETURN
C
CE    IZOPARAMETRIC SHELL
CS    IZOPARAMETARSKI ELEMENT LJUSKE
C
C 680 CALL K21DMP
  680 CONTINUE
      RETURN
C
CE    BEAM SUPERELEMENT
CS    GREDNI SUPERELEMENT
C
C  690 CALL L9DMP
  690 CONTINUE
C
CE    CONTACT ELEMENTS
CS    KONTAKTNI ELEMENTI
C
  629 RETURN
C
CE    POVRATAK
CS    EXIT
C
  999 RETURN
      END
C=======================================================================
C
C=======================================================================
      SUBROUTINE STAINF(IND)
C
C ......................................................................
C .
CE.   P R O G R A M
CE.      TO PRINT INFORMATION ABOUT SOLUTION
CS.   P R O G R A M
CS.      ZA STAMPANJE INFORMACIJA O TOKU RESAVANJA
C .
C ......................................................................
C
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /GLAVNI/ NP,NGELEM,NMATM,NPER,
     1                IOPGL(6),KOSI,NDIN,ITEST
      COMMON /ELEALL/ NETIP,NE,IATYP,NMODM,NGE,ISKNP,LMAX8
      COMMON /DIREKT/ LSTAZZ(9),LDRV0,LDRV1,LDRV,IDIREK
      COMMON /SRPSKI/ ISRPS
      COMMON /PERKOR/ LNKDT,LDTDT,LVDT,NDT,DT,VREME,KOR
      COMMON /LINSBR/ LIN,KORBR
      COMMON /ITERBR/ ITER
      COMMON /INDKON/ IKONV
      COMMON /INDNAP/ NAPON
      COMMON /CDEBUG/ IDEBUG
C
      IF(IDEBUG.GT.0) PRINT *, ' STAINF'
      IF(IND.EQ.1) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2010) NGE,NGELEM
      IF(ISRPS.EQ.1)
     1WRITE(*,6010) NGE,NGELEM
      ENDIF
      IF(IND.EQ.2.AND.IDIREK.NE.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2020) NGE,NGELEM,KORBR,NDT,ITER,LIN
      IF(ISRPS.EQ.1)
     1WRITE(*,6020) NGE,NGELEM,KORBR,NDT,ITER,LIN
      ENDIF
      IF(IND.EQ.2.AND.IDIREK.EQ.0) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2025) NGE,NGELEM
      IF(ISRPS.EQ.1)
     1WRITE(*,6025) NGE,NGELEM
      ENDIF
      IF(IND.EQ.3) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2030) NGE,NGELEM,KORBR,NDT,ITER,LIN
      IF(ISRPS.EQ.1)
     1WRITE(*,6030) NGE,NGELEM,KORBR,NDT,ITER,LIN
      ENDIF
      IF(IND.EQ.4) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2040) NGE,NGELEM,KORBR,NDT
      IF(ISRPS.EQ.1)
     1WRITE(*,6040) NGE,NGELEM,KORBR,NDT
      ENDIF
      IF(IND.EQ.5) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2050) NGE,NGELEM,KORBR,NDT,ITER,LIN
      IF(ISRPS.EQ.1)
     1WRITE(*,6050) NGE,NGELEM,KORBR,NDT,ITER,LIN
      ENDIF
      IF(IND.EQ.6) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2060) NGE,NGELEM,KORBR,NDT,ITER,LIN
      IF(ISRPS.EQ.1)
     1WRITE(*,6060) NGE,NGELEM,KORBR,NDT,ITER,LIN
      ENDIF
      IF(IND.EQ.7) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2070) NGE,NGELEM,KORBR,NDT
      IF(ISRPS.EQ.1)
     1WRITE(*,6070) NGE,NGELEM,KORBR,NDT
      ENDIF
      IF(IND.EQ.8) THEN
      IF(ISRPS.EQ.0)
     1WRITE(*,2080) NGE,NGELEM,KORBR,NDT
      IF(ISRPS.EQ.1)
     1WRITE(*,6080) NGE,NGELEM,KORBR,NDT
      ENDIF
      RETURN
C-----------------------------------------------------------------------
 2010 FORMAT(' *** ULAZNI PODACI GRUPE ELEMENATA',I4,' /',I3,' ***')
 2020 FORMAT(' *** MATRICA KRUTOSTI GRUPE',I4,' /',I3,', KORAK',
     1I4,' /',I4,', ITERACIJA',I3,' /',I2,' ***')
 2025 FORMAT(' *** FORMIRANJE VEKTORA NORMALE GRUPE',
     1I4,' /',I3,' ***')
 2030 FORMAT(' *** NAPONI I SILE GRUPE',I4,' /',I3,', KORAK',
     1I4,' /',I4,', ITERACIJA',I3,' /',I2,' ***')
 2040 FORMAT(' *** STAMPANJE NAPONA GRUPE',I4,' /',I3,', KORAK',
     1I4,' /',I4,' ***')
 2050 FORMAT(' *** MATRICA MASA GRUPE',I4,' /',I3,', KORAK',
     1I4,' /',I4,', ITERACIJA',I3,' /',I2,' ***')
 2060 FORMAT(' *** MATRICA PRIGUSENJA GRUPE',I4,' /',I3,', KORAK',
     1I4,' /',I4,', ITERACIJA',I3,' /',I2,' ***')
 2070 FORMAT(' *** KOREKCIJA UBRZANJA KONTAKTNE GRUPE',I4,' /',I3,
     1', KORAK',I4,' /',I4,' ***')
 2080 FORMAT(' *** KOREKCIJA BRZINA KONTAKTNE GRUPE',I4,' /',I3,
     1', KORAK',I4,' /',I4,' ***')
C----------------------------------------------------------------------
 6010 FORMAT(' *** INPUT DATA FOR ELEMENTS GROUP',I4,' /',I3,' ***')
 6020 FORMAT(' *** STIFFNESS MATRIX FOR GROUP',I4,' /',I3,', STEP',
     1I4,' /',I4,', ITERATION',I3,' /',I2,' ***')
 6025 FORMAT(' *** FORM NORMAL VECTORS FOR GROUP',
     1 I4,' /',I3,' ***')
 6030 FORMAT(' *** STRESSES AND FORCES FOR GROUP',I4,' /',I3,', STEP',
     1I4,' /',I4,', ITERATION',I3,' /',I2,' *')
 6040 FORMAT(' *** PRINT STRESSES FOR GROUP',I4,' /',I3,', STEP',
     1I4,' /',I4,' ***')
 6050 FORMAT(' *** MASS MATRIX FOR GROUP',I4,' /',I3,', STEP',
     1I4,' /',I4,', ITERATION',I3,' /',I2,' ***')
 6060 FORMAT(' *** DAMP MATRIX FOR GROUP',I4,' /',I3,', STEP',
     1I4,' /',I4,', ITERATION',I3,' /',I2,' ***')
 6070 FORMAT(' *** ACCELERATION CORECTION FOR CONTACT GROUP',
     1I4,' /',I3,', STEP',I4,' /',I4,' ***')
 6080 FORMAT(' *** VELOCITY CORECTION FOR CONTACT GROUP',
     1I4,' /',I3,', STEP',I4,' /',I4,' ***')
C----------------------------------------------------------------------
      END
