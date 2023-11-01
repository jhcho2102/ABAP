*===================================================*
* TOP
*===================================================*
PARAMETERS: p_layout TYPE alv_vari.

*===================================================*
* AT SELECTION-SCREEN
*===================================================*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYOUT.
  PERFORM F4_LAYOUT CHANGING P_LAYOUT.

*===================================================*
* PBO
*===================================================*
...
IS_VARIANT-VARIANT = P_LAYOUT. " ALV Display시 IS-VARIANT-VARIANT에 LAYOUT을 입력함.
...


*****************************************************
******************** END ****************************
*****************************************************


*===================================================*
* _FXX.
*===================================================*
FORM f4_layout  CHANGING pv_layout.
  DATA: ls_variant TYPE disvariant,
        lv_exit    TYPE char1.

  ls_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ls_variant
      i_save     = 'A'
    IMPORTING
      e_exit     = lv_exit
      es_variant = ls_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF lv_exit EQ space.
      pv_layout = ls_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.
