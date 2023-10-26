*=======================================================*
* TOP
*=======================================================*

TABLES: TSTCT, RTITL.

DATA: TITLE TYPE C LENGTH 120.

*=======================================================*
* PBO 
*=======================================================*

SELECT SINGLE * FROM TSTCT WHERE SPRSL = SY-LANGU
                           AND   TCODE = SY-TCODE.

RTITL-VAR01 = TSTCT-TTEXT.
CONDENSE RTITL-VAR01.

TITLE(30)    = RTITL-VAR01.
TITLE+30(30) = RTITL-VAR02.
CONDENSE TITLE(60).

SET TITLEBAR '001' WITH TITLE(60). " GUI TITLE '001' = &
