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
  method SET_RANGE_WITH_ICON.
    DATA lv_cls_eq.
    DATA lv_idx TYPE i.
    DATA ld_ranges TYPE REF TO DATA.
    DATA ld_range  TYPE REF TO DATA.
    FIELD-SYMBOLS <l_ranges> TYPE ANY TABLE.
    FIELD-SYMBOLS <l_range>  TYPE ANY.
    FIELD-SYMBOLS <l_sign>   TYPE ANY.
    FIELD-SYMBOLS <l_option> TYPE ANY.
    FIELD-SYMBOLS <l_low>    TYPE ANY.
    FIELD-SYMBOLS <l_high>   TYPE ANY.
    DATA lv_more_name TYPE icons-text.
    DATA lv_stat_name TYPE icons-text.

    "---[S] initialization.
    DATA(lv_lines)     = lines( ct_range ).
    DATA(lv_input_l)   = cv_low.
    DATA(lv_input_h)   = cv_high.
    DATA(lv_option) = cv_stat+2(1).

    GET REFERENCE OF ct_range INTO ld_ranges.
    ASSIGN ld_ranges->* TO <l_ranges>.
    "---[E] initialization.

    "---[S] set ranges in PAI.
    IF iv_pbo <> 'X'.

      IF lv_lines < 1.
        IF lv_input_l IS INITIAL AND lv_input_h IS INITIAL.
        ELSE.
          INSERT INITIAL LINE INTO TABLE <l_ranges> ASSIGNING <l_range>.
          ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <l_range> TO <l_sign>.
          ASSIGN COMPONENT 'OPTION' OF STRUCTURE <l_range> TO <l_option>.
          ASSIGN COMPONENT 'LOW'    OF STRUCTURE <l_range> TO <l_low>.
          ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <l_range> TO <l_high>.

          <l_sign> = CONV #( 'I' ).
          <l_low>  = CONV #( lv_input_l ).
          <l_high> = CONV #( lv_input_h ).

          IF <l_high> IS INITIAL.
            IF <l_low> CA '*'.
              <l_option> = 'CP'.
            ELSE.
              <l_option> = 'EQ'.
            ENDIF.
          ELSE.
              <l_option> = 'BT'.
          ENDIF.
        ENDIF.

      ELSEIF lv_lines >= 1.
        CLEAR: lv_idx.
        lv_idx = 1.
        LOOP AT <l_ranges> ASSIGNING <l_range>.
          IF lv_idx > 1.
            EXIT.
          ENDIF.

          ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <l_range> TO <l_sign>.
          ASSIGN COMPONENT 'OPTION' OF STRUCTURE <l_range> TO <l_option>.
          ASSIGN COMPONENT 'LOW'    OF STRUCTURE <l_range> TO <l_low>.
          ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <l_range> TO <l_high>.

          IF lv_input_l IS INITIAL AND lv_input_h IS INITIAL.
            IF <l_option> = 'BT' OR <l_option> = 'NB'.
              DELETE ct_range INDEX 1.
            ELSE.
              IF lv_option IS INITIAL.
                DELETE ct_range INDEX 1.
              ELSEIF lv_option <> '0' AND <l_low> IS NOT INITIAL.
                DELETE ct_range INDEX 1.
              ENDIF.
            ENDIF.

          ELSE.
            IF lv_input_h IS INITIAL.
              IF lv_input_l CA '*'.
                <l_option> = 'CP'.
              ELSE.
                IF <l_option> = 'BT' OR <l_option> = 'NB'.
                  <l_option> = 'EQ'.
                ENDIF.
              ENDIF.
              IF lv_option = '0'.
                lv_cls_eq = 'X'.
              ENDIF.

            ELSE.
              IF <l_option> = 'NB'.
                <l_option> = 'NB'.
              ELSE.
                <l_option> = 'BT'.
              ENDIF.
            ENDIF.

            <l_low>  = CONV #( lv_input_l ).
            <l_high> = CONV #( lv_input_h ).

          ENDIF.

          lv_idx += 1.
        ENDLOOP.
      ENDIF.

      IF <l_range> IS ASSIGNED.
        UNASSIGN: <l_range>.
      ENDIF.

      IF <l_sign> IS ASSIGNED.
        UNASSIGN: <l_sign>.
      ENDIF.

      IF <l_option> IS ASSIGNED.
        UNASSIGN: <l_option>.
      ENDIF.

      IF <l_low> IS ASSIGNED.
        UNASSIGN: <l_low>.
      ENDIF.

      IF <l_high> IS ASSIGNED.
        UNASSIGN: <l_high>.
      ENDIF.
    ENDIF.
    "---[E] set ranges in PAI.

    "---[S] set screen field & icons.
    CLEAR: lv_lines.
    lv_lines = lines( ct_range ).
    IF lv_lines <= 1.
      lv_more_name = '@1F@'."ICON_ENTER_MORE.
    ELSE.
      lv_more_name = '@1E@'."ICON_DISPLAY_MORE.
    ENDIF.

    CLEAR: lv_idx.
    lv_idx = 1.
    LOOP AT <l_ranges> ASSIGNING <l_range>.
      IF lv_idx > 1.
        EXIT.
      ENDIF.
      ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <l_range> TO <l_sign>.
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <l_range> TO <l_option>.
      ASSIGN COMPONENT 'LOW'    OF STRUCTURE <l_range> TO <l_low>.
      ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <l_range> TO <l_high>.

      IF <l_option> IS NOT INITIAL.
        IF <l_sign> = 'I'.
          CASE <l_option>.
            WHEN 'EQ'. lv_stat_name = '0'.
            WHEN 'NE'. lv_stat_name = '1'.
            WHEN 'GT'. lv_stat_name = '2'.
            WHEN 'LT'. lv_stat_name = '3'.
            WHEN 'GE'. lv_stat_name = '4'.
            WHEN 'LE'. lv_stat_name = '5'.
            WHEN 'BT'. lv_stat_name = '6'.
            WHEN 'NB'. lv_stat_name = '7'.
            WHEN 'CP'. lv_stat_name = '8'.
            WHEN 'NP'. lv_stat_name = '9'.
          ENDCASE.
        ELSE.
          CASE <l_option>.
            WHEN 'EQ'. lv_stat_name = 'A'.
            WHEN 'NE'. lv_stat_name = 'B'.
            WHEN 'GT'. lv_stat_name = 'C'.
            WHEN 'LT'. lv_stat_name = 'D'.
            WHEN 'GE'. lv_stat_name = 'E'.
            WHEN 'LE'. lv_stat_name = 'F'.
            WHEN 'BT'. lv_stat_name = 'G'.
            WHEN 'NB'. lv_stat_name = 'H'.
            WHEN 'CP'. lv_stat_name = 'I'.
            WHEN 'NP'. lv_stat_name = 'J'.
          ENDCASE.
        ENDIF.
      ENDIF.
      lv_stat_name = '@2' && lv_stat_name && '@'.

      " clear status icon.
      IF lv_input_l IS NOT INITIAL AND lv_stat_name = '@20@'.
        CLEAR: lv_stat_name.
      ENDIF.

      IF lv_option = '0' AND lv_input_l IS NOT INITIAL.
        CLEAR: lv_stat_name.
      ENDIF.

      IF lv_cls_eq = 'X'.
        CLEAR: lv_stat_name.
      ENDIF.

      IF lv_stat_name = '@26@'.
        CLEAR: lv_stat_name.
      ENDIF.


      cv_low  = CONV #( <l_low> ).
      cv_high = CONV #( <l_high> ).
      lv_idx += 1.
    ENDLOOP.
    "---[E] set screen field & icons.

    "---[S] create icons.
    CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                        = lv_more_name
        IMPORTING
          RESULT                      = cv_more
       EXCEPTIONS
         ICON_NOT_FOUND              = 1
         OUTPUTFIELD_TOO_SHORT       = 2
         OTHERS                      = 3 .

    IF lv_stat_name IS INITIAL.
      CLEAR: cv_stat.
    ELSE.
      CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                        = lv_stat_name
          IMPORTING
            RESULT                      = cv_stat
         EXCEPTIONS
           ICON_NOT_FOUND              = 1
           OUTPUTFIELD_TOO_SHORT       = 2
           OTHERS                      = 3 .
      IF strlen( cv_stat ) > 4.
        cv_stat = cv_stat+0(3) && '@'.
      ENDIF.
    ENDIF.
    "---[E] create icons
  endmethod.
