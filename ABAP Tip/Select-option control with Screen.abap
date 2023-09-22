************************************************************************
*     DATE        DESCRIPTION                                          *
* ---------------------------------------------------------------------*
*  2023/05/19    Set select-option with screen field.                  *
* **********************************************************************
* IV_PBO   IMPORTING CHAR01 OPTIONAL     | Indicator Flow logic        *
* CT_RANGE CHANGING  STANDARD TABLE      | Range Itab                  *
* CV_LOW   CHANGING  TVARV_VAL OPTIONAL  | Screen Field - Low          *
* CV_HIGH  CHANGING  TVARV_VAL OPTIONAL  | Screen Field - High         *
* CV_MORE  CHANGING  ICONS-TEXT OPTIONAL | More/Enter Icon             *
* CV_STAT  CHANGING  ICONS-TEXT OPTIONAL | Option Icon                 *
* **********************************************************************
  METHOD SET_RANGE_WITH_ICON.
    DATA LV_CLS_EQ.
    DATA LV_IDX TYPE I.
    DATA LD_RANGES TYPE REF TO DATA.
    DATA LD_RANGE  TYPE REF TO DATA.
    FIELD-SYMBOLS <L_RANGES> TYPE ANY TABLE.
    FIELD-SYMBOLS <L_RANGE>  TYPE ANY.
    FIELD-SYMBOLS <L_SIGN>   TYPE ANY.
    FIELD-SYMBOLS <L_OPTION> TYPE ANY.
    FIELD-SYMBOLS <L_LOW>    TYPE ANY.
    FIELD-SYMBOLS <L_HIGH>   TYPE ANY.
    DATA LV_MORE_NAME TYPE ICONS-TEXT.
    DATA LV_STAT_NAME TYPE ICONS-TEXT.

    "---[S] initialization.
    DATA(LV_LINES)     = LINES( CT_RANGE ).
    DATA(LV_INPUT_L)   = CV_LOW.
    DATA(LV_INPUT_H)   = CV_HIGH.
    DATA(LV_OPTION) = CV_STAT+2(1).

    GET REFERENCE OF CT_RANGE INTO LD_RANGES.
    ASSIGN LD_RANGES->* TO <L_RANGES>.
    "---[E] initialization.

    FIELD-SYMBOLS <LS_WA> TYPE ANY.
    DATA LD_STRUC TYPE REF TO DATA.
    DATA: LV_FIELD.
    CREATE DATA LD_STRUC LIKE LINE OF <L_RANGES>.
    ASSIGN LD_STRUC->* TO <LS_WA>.
    ASSIGN COMPONENT 'LOW'    OF STRUCTURE <LS_WA> TO FIELD-SYMBOL(<L_VALUE>).
    DESCRIBE FIELD <L_VALUE> TYPE LV_FIELD.
    IF LV_FIELD = 'N'.
      SHIFT LV_INPUT_L LEFT DELETING LEADING '0'.
      CONDENSE LV_INPUT_L.
      SHIFT LV_INPUT_H LEFT DELETING LEADING '0'.
      CONDENSE LV_INPUT_H.
    ENDIF.

    "---[S] set ranges in PAI.
    IF IV_PBO <> 'X'.

      IF LV_LINES < 1.
        IF LV_INPUT_L IS INITIAL AND LV_INPUT_H IS INITIAL.
        ELSE.
          INSERT INITIAL LINE INTO TABLE <L_RANGES> ASSIGNING <L_RANGE>.
          ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <L_RANGE> TO <L_SIGN>.
          ASSIGN COMPONENT 'OPTION' OF STRUCTURE <L_RANGE> TO <L_OPTION>.
          ASSIGN COMPONENT 'LOW'    OF STRUCTURE <L_RANGE> TO <L_LOW>.
          ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <L_RANGE> TO <L_HIGH>.

          <L_SIGN> = CONV #( 'I' ).
          <L_LOW>  = COND #( WHEN LV_INPUT_L IS NOT INITIAL THEN LV_INPUT_L ).
          <L_HIGH> = COND #( WHEN LV_INPUT_H IS NOT INITIAL THEN LV_INPUT_H ).

          IF <L_HIGH> IS INITIAL.
            IF <L_LOW> CA '*'.
              <L_OPTION> = 'CP'.
            ELSE.
              <L_OPTION> = 'EQ'.
            ENDIF.
          ELSE.
            <L_OPTION> = 'BT'.
          ENDIF.
        ENDIF.

      ELSEIF LV_LINES >= 1.
        CLEAR: LV_IDX.
        LV_IDX = 1.
        LOOP AT <L_RANGES> ASSIGNING <L_RANGE>.
          IF LV_IDX > 1.
            EXIT.
          ENDIF.

          ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <L_RANGE> TO <L_SIGN>.
          ASSIGN COMPONENT 'OPTION' OF STRUCTURE <L_RANGE> TO <L_OPTION>.
          ASSIGN COMPONENT 'LOW'    OF STRUCTURE <L_RANGE> TO <L_LOW>.
          ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <L_RANGE> TO <L_HIGH>.

          IF LV_INPUT_L IS INITIAL AND LV_INPUT_H IS INITIAL.
            IF <L_OPTION> = 'BT' OR <L_OPTION> = 'NB'.
              DELETE CT_RANGE INDEX 1.
            ELSE.
              IF LV_OPTION IS INITIAL.
                DELETE CT_RANGE INDEX 1.
              ELSEIF LV_OPTION <> '0' AND <L_LOW> IS NOT INITIAL.
                DELETE CT_RANGE INDEX 1.
              ENDIF.
            ENDIF.

          ELSE.
            IF LV_INPUT_H IS INITIAL.
              IF LV_INPUT_L CA '*'.
                <L_OPTION> = 'CP'.
              ELSE.
                IF <L_OPTION> = 'BT' OR <L_OPTION> = 'NB'.
                  <L_OPTION> = 'EQ'.
                ENDIF.
              ENDIF.
              IF LV_OPTION = '0'.
                LV_CLS_EQ = 'X'.
              ENDIF.

            ELSE.
              IF <L_OPTION> = 'NB'.
                <L_OPTION> = 'NB'.
              ELSE.
                <L_OPTION> = 'BT'.
              ENDIF.
            ENDIF.

            <L_LOW>  = CONV #( LV_INPUT_L ).
            <L_HIGH> = CONV #( LV_INPUT_H ).

          ENDIF.

          LV_IDX += 1.
        ENDLOOP.
      ENDIF.

      IF <L_RANGE> IS ASSIGNED.
        UNASSIGN: <L_RANGE>.
      ENDIF.

      IF <L_SIGN> IS ASSIGNED.
        UNASSIGN: <L_SIGN>.
      ENDIF.

      IF <L_OPTION> IS ASSIGNED.
        UNASSIGN: <L_OPTION>.
      ENDIF.

      IF <L_LOW> IS ASSIGNED.
        UNASSIGN: <L_LOW>.
      ENDIF.

      IF <L_HIGH> IS ASSIGNED.
        UNASSIGN: <L_HIGH>.
      ENDIF.
    ENDIF.
    "---[E] set ranges in PAI.

    "---[S] set screen field & icons.
    CLEAR: LV_LINES.
    LV_LINES = LINES( CT_RANGE ).
    IF LV_LINES <= 1.
      LV_MORE_NAME = '@1F@'."ICON_ENTER_MORE.
    ELSE.
      LV_MORE_NAME = '@1E@'."ICON_DISPLAY_MORE.
    ENDIF.

    CLEAR: LV_IDX.
    LV_IDX = 1.
    LOOP AT <L_RANGES> ASSIGNING <L_RANGE>.
      IF LV_IDX > 1.
        EXIT.
      ENDIF.
      ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <L_RANGE> TO <L_SIGN>.
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <L_RANGE> TO <L_OPTION>.
      ASSIGN COMPONENT 'LOW'    OF STRUCTURE <L_RANGE> TO <L_LOW>.
      ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <L_RANGE> TO <L_HIGH>.

      IF <L_OPTION> IS NOT INITIAL.
        IF <L_SIGN> = 'I'.
          CASE <L_OPTION>.
            WHEN 'EQ'. LV_STAT_NAME = '0'.
            WHEN 'NE'. LV_STAT_NAME = '1'.
            WHEN 'GT'. LV_STAT_NAME = '2'.
            WHEN 'LT'. LV_STAT_NAME = '3'.
            WHEN 'GE'. LV_STAT_NAME = '4'.
            WHEN 'LE'. LV_STAT_NAME = '5'.
            WHEN 'BT'. LV_STAT_NAME = '6'.
            WHEN 'NB'. LV_STAT_NAME = '7'.
            WHEN 'CP'. LV_STAT_NAME = '8'.
            WHEN 'NP'. LV_STAT_NAME = '9'.
          ENDCASE.
        ELSE.
          CASE <L_OPTION>.
            WHEN 'EQ'. LV_STAT_NAME = 'A'.
            WHEN 'NE'. LV_STAT_NAME = 'B'.
            WHEN 'GT'. LV_STAT_NAME = 'C'.
            WHEN 'LT'. LV_STAT_NAME = 'D'.
            WHEN 'GE'. LV_STAT_NAME = 'E'.
            WHEN 'LE'. LV_STAT_NAME = 'F'.
            WHEN 'BT'. LV_STAT_NAME = 'G'.
            WHEN 'NB'. LV_STAT_NAME = 'H'.
            WHEN 'CP'. LV_STAT_NAME = 'I'.
            WHEN 'NP'. LV_STAT_NAME = 'J'.
          ENDCASE.
        ENDIF.
      ENDIF.
      LV_STAT_NAME = '@2' && LV_STAT_NAME && '@'.

      " clear status icon.
      IF LV_INPUT_L IS NOT INITIAL AND LV_STAT_NAME = '@20@'.
        CLEAR: LV_STAT_NAME.
      ENDIF.

      IF LV_OPTION = '0' AND LV_INPUT_L IS NOT INITIAL.
        CLEAR: LV_STAT_NAME.
      ENDIF.

      IF LV_CLS_EQ = 'X'.
        CLEAR: LV_STAT_NAME.
      ENDIF.

      IF LV_STAT_NAME = '@26@'.
        CLEAR: LV_STAT_NAME.
      ENDIF.


      CV_LOW  = CONV #( <L_LOW> ).
      CV_HIGH = CONV #( <L_HIGH> ).
      LV_IDX += 1.
    ENDLOOP.
    "---[E] set screen field & icons.

    "---[S] create icons.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        NAME                  = LV_MORE_NAME
      IMPORTING
        RESULT                = CV_MORE
      EXCEPTIONS
        ICON_NOT_FOUND        = 1
        OUTPUTFIELD_TOO_SHORT = 2
        OTHERS                = 3.

    IF LV_STAT_NAME IS INITIAL.
      CLEAR: CV_STAT.
    ELSE.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          NAME                  = LV_STAT_NAME
        IMPORTING
          RESULT                = CV_STAT
        EXCEPTIONS
          ICON_NOT_FOUND        = 1
          OUTPUTFIELD_TOO_SHORT = 2
          OTHERS                = 3.
      IF STRLEN( CV_STAT ) > 4.
        CV_STAT = CV_STAT+0(3) && '@'.
      ENDIF.
    ENDIF.
    "---[E] create icons
  ENDMETHOD.
