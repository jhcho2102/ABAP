REPORT ZTMPR1091 NO STANDARD PAGE HEADING.

*&---------------------------------------------------------------------*
*& INCLUDE                                                             *
*&---------------------------------------------------------------------*
INCLUDE ZTMP1091T01.
INCLUDE ZTMP1091C00.
INCLUDE ZTMP1091C01.
INCLUDE ZTMP1091O01.
INCLUDE ZTMP1091I01.
INCLUDE ZTMP1091F00.
INCLUDE ZTMP1091F01.

*&---------------------------------------------------------------------*
*& INITIALIZATION                                                      *
*&---------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION                                                  *
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  SELECT
    FROM ZFGLT0003
    FIELDS *
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

*&---------------------------------------------------------------------*
*& END-OF-SELECTION                                                    *
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  CASE 'X'.
    WHEN P_ONE. " One Grid - Custom Cnt.
      CALL SCREEN '0100'.
    WHEN P_TWO. " Two Grid - Docking Cnt/Split.
      CALL SCREEN '0200'.
    WHEN P_MAN. " Three Grid - Docking Cnt/Split.
      CALL SCREEN '0300'.
    WHEN P_TOP. " Top of Page.
      CALL SCREEN '0400'.
    WHEN P_STE. " Simple Tree.
      CALL SCREEN '0500'.
    WHEN P_CTE. " Column Tree.
      CALL SCREEN '0600'.
  ENDCASE.
