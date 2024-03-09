         MACRO
OPLABEL  DLB       A
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         W.*
         VWD       39/0,22/W.(A),3/0
DLB      ENDM

         MACRO
OPLABEL  ILB       A
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         W.*
         CON       P.(A)
ILB      ENDM

         MACRO
OPLABEL  LC        R,N
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
ISVAL    IFA       VAL,N
ISPOS    IFE       N,GE,0
         IFE       N,LE,O'7777777,1
         R         N
         IFE       N,GT,O'7777777,1
         R         =N,
ISPOS    ELSE
         IFE       N,GE,-O'10000000,1
         R         N
         IFE       N,LT,-O'10000000,1
         R         =N,
ISPOS    ENDIF
ISVAL    ELSE
ISCODE   IFA       CODE,N
         R         P.N
ISCODE   ELSE
         R         W.N
ISCODE   ENDIF
ISVAL    ENDIF
LC       ENDM

         MACRO
OPLABEL  LBA       R,A
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
RE       IFC       'A',RE,'\i\w*[+-]\d*'
USES2    IFC       'R',EQ,'S1'
         -1,A7     S2
         R         W.A{(\i\w*)[+-]\d*}
         R         R<3
         S2        A{\i\w*([+-]\d*)}
         R         R+S2
         S2        -1,A7
USES2    ELSE
USES1    IFC       'R',NE,'s1'
         -1,A7     S1
         R         W.A{(\i\w*)[+-]\d*}
         R         R<3
         S1        A{\i\w*([+-]\d*)}
         R         R+S1
         S1        -1,A7
USES1    ELSE
         -1,A7     S2
         R         W.A{(\i\w*)[+-]\d*}
         R         R<3
         S2        A{\i\w*([+-]\d*)}
         R         R+S2
         S2        -1,A7
USES1    ENDIF
USES2    ENDIF
RE       ELSE
         R         W.A
         R         R<3
RE       ENDIF
LBA      ENDM

         MACRO
OPLABEL  TR        R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         IFC       'R1',NE,'R2',1
         R1        R2
TR       ENDM

         MACRO
OPLABEL  LD        R1,L,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        W.L,R2
LD       ENDM

         MACRO
OPLABEL  ST        L,R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         W.L,R1      R2
ST       ENDM

         MACRO
OPLABEL  LDL       R,L
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         (L)/8,A6
LDL      ENDM

         MACRO
OPLABEL  STL       L,R
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         (L)/8,A6    R
STL      ENDM

         MACRO
OPLABEL  PUSH      R
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         A7        A7-1
         ,A7       R
PUSH     ENDM

         MACRO
OPLABEL  POP       R
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         ,A7
         A7        A7+1
POP      ENDM

         MACRO
OPLABEL  INRA      R
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         R+1
INRA     ENDM

         MACRO
OPLABEL  DCRA      R
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         R-1
DCRA     ENDM

         MACRO
OPLABEL  IADD      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2+R3
IADD     ENDM

         MACRO
OPLABEL  ISUB      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2-R3
ISUB     ENDM

         MACRO
OPLABEL  INEG      R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        -R2
INEG     ENDM

         MACRO
OPLABEL  FADD      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2+F_R3
FADD     ENDM

         MACRO
OPLABEL  FSUB      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2-F_R3
FSUB     ENDM

         MACRO
OPLABEL  FNEG      R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        -F_R2
FNEG     ENDM

         MACRO
OPLABEL  FMUL      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2*F_R3
FMUL     ENDM
* 
* /* Floating point arithmetic on S registers */
* fdiv SREG:rw, SREG:rw, SREG:rw .
* 

         MACRO
OPLABEL  ANDS      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2&R3
ANDS     ENDM

         MACRO
OPLABEL  ANDSC     R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        #R3&R2
ANDSC    ENDM

         MACRO
OPLABEL  IORS      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2!R3
IORS     ENDM

         MACRO
OPLABEL  XORS      R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        R2\R3
XORS     ENDM

         MACRO
OPLABEL  NOTS      R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1        #R2
NOTS     ENDM

         MACRO
OPLABEL  LMASK     R,N
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         >N
LMASK    ENDM

         MACRO
OPLABEL  RMASK     R,N
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         <N
RMASK    ENDM

         MACRO
OPLABEL  LSHC      R,N
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         R<N
LSHC     ENDM

         MACRO
OPLABEL  LSHA      R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1         R1<R2
LSHA     ENDM

         MACRO
OPLABEL  LSHAW     R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1         R1,R2<R3
LSHAW    ENDM

         MACRO
OPLABEL  RSHC      R,N
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R         R>N
RSHC     ENDM

         MACRO
OPLABEL  RSHA      R1,R2
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1         R1>R2
RSHA     ENDM

         MACRO
OPLABEL  RSHAW     R1,R2,R3
         IFC       'OPLABEL',NE,'',1
OPLABEL  =         *
         R1         R2,R1<R3
RSHAW    ENDM
