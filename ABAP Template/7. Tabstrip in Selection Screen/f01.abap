*&---------------------------------------------------------------------*
*& Include          ZFLR001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_1000 .
  tab1 = 'Tab 1'.
  tab2 = 'Tab 2'.
  tab3 = 'Tab 3'.

  push1 = 'Push_Button1'.
  mytab-prog = sy-repid.
  mytab-dynnr = 1100.
  mytab-activetab = 'TAB1'.

  CLEAR: gs_dyntxt.
  gs_dyntxt-text = 'IMG'.
  gs_dyntxt-icon_id = icon_display.
  gs_dyntxt-icon_text = 'func1'.
  sscrfields-functxt_01 = gs_dyntxt.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modif_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modif_1000 .
  LOOP AT SCREEN.
    IF screen-name EQ 'P_UNAM'.
      screen-input = 0.
    ENDIF.

    IF p_rb1 EQ 'X'.
      CASE screen-group1.
        WHEN 'TB1'.
          screen-active = 1.
        WHEN 'TB2'.
          screen-active = 1.
        WHEN 'TB3'.
          screen-active = 0.
      ENDCASE.
    ELSE.
      CASE screen-group1.
        WHEN 'TB1'.
          screen-active = 1.
        WHEN 'TB2'.
          screen-active = 0.
        WHEN 'TB3'.
          screen-active = 1.
      ENDCASE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_tab .
  CASE sy-dynnr.
    WHEN 1000.
      CASE sscrfields-ucomm.
        WHEN 'TAB1'.
          mytab-dynnr = 1100.
        WHEN 'TAB2'.
          mytab-dynnr = 1200.
        WHEN 'TAB3'.
          mytab-dynnr = 1300.
      ENDCASE.
  ENDCASE.
ENDFORM.
