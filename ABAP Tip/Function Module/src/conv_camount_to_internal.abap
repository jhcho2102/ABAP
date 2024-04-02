FORM convert_internal_amount  USING    VALUE(p_waers)
                                       VALUE(p_curr)
                              CHANGING p_amt.
  DATA: l_compos TYPE i,
        l_comlen TYPE i,
        l_dotpos TYPE i.

  CONDENSE p_curr NO-GAPS.
  FIND FIRST OCCURRENCE OF '.' IN p_curr MATCH OFFSET l_dotpos.
  FIND FIRST OCCURRENCE OF ',' IN p_curr MATCH OFFSET l_compos MATCH LENGTH l_comlen.

  IF l_dotpos LT l_compos.
    REPLACE ALL OCCURRENCES OF ',' IN p_curr WITH ''.

  ELSE.
    REPLACE ALL OCCURRENCES OF ',' IN p_curr WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN p_curr WITH ','.
    REPLACE ALL OCCURRENCES OF '/' IN p_curr WITH '.'.

  ENDIF.

  CONDENSE p_curr NO-GAPS.
  CLEAR: l_dotpos, l_compos, l_comlen.


  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      currency                   = CONV waers_curc( p_waers )
      amount_external            = CONV bapicurr_d( p_curr )
      max_number_of_digits       = 15
    IMPORTING
      amount_internal            = p_amt.
ENDFORM.
