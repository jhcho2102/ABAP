*&---------------------------------------------------------------------*
*& Include          ZFLR001_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS: p_unam TYPE sy-uname DEFAULT sy-uname.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_rb1 RADIOBUTTON GROUP rbg1 DEFAULT 'X' USER-COMMAND ucomm.
    SELECTION-SCREEN: COMMENT 2(8) TEXT-R01 FOR FIELD p_rb1.
    PARAMETERS: p_rb2 RADIOBUTTON GROUP rbg1.
    SELECTION-SCREEN: COMMENT 12(20) TEXT-002 FOR FIELD p_rb2.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

************************************************************************
* Define Subscreen.
************************************************************************
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK sb1 WITH FRAME.
    PARAMETERS: p_sb TYPE char05.
  SELECTION-SCREEN END OF BLOCK sb1.
  SELECTION-SCREEN: PUSHBUTTON /1(80) push1 USER-COMMAND push1.
SELECTION-SCREEN END OF SCREEN 1100.

SELECTION-SCREEN BEGIN OF SCREEN 1200 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK sb2 WITH FRAME.
    PARAMETERS: p_sb2 TYPE char05.
  SELECTION-SCREEN END OF BLOCK sb2.
SELECTION-SCREEN END OF SCREEN 1200.

SELECTION-SCREEN BEGIN OF SCREEN 1300 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK sb3 WITH FRAME.
    PARAMETERS: p_sb3 TYPE char05.
  SELECTION-SCREEN END OF BLOCK sb3.
SELECTION-SCREEN END OF SCREEN 1300.

************************************************************************
* Define Tabstrip.
************************************************************************
SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 20 LINES,
  tab (20) TAB1 USER-COMMAND tab1 MODIF ID tb1,
  tab (20) TAB2 USER-COMMAND tab2 MODIF ID tb2,
  tab (20) TAB3 USER-COMMAND tab3 MODIF ID tb3.
SELECTION-SCREEN: END OF BLOCK mytab.

************************************************************************
* Function Key.
************************************************************************
SELECTION-SCREEN: FUNCTION KEY 1.
