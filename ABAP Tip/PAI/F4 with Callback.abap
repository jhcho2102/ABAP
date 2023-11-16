*=========================================*
* PAI            
*=========================================*
CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname             = 'T001'
      fieldname           = 'BUKRS'
      dynpprog            = sy-cprog
      dynpnr              = sy-dynnr
      callback_program    = sy-cprog
      callback_form       = 'F4_CALLBACK'
    TABLES
      return_tab          = lt_return
    EXCEPTIONS
      field_not_found     = 1
      no_help_for_field   = 2
      inconsistent_help   = 3
      no_values_found     = 4
      others              = 5 .

*=========================================*
* FORM 
*=========================================*
FORM f4_callback TABLES   pt_recored_tab STRUCTURE seahlpres
                 CHANGING ps_shlp        TYPE shlp_descr_t
                          ps_callcontrol LIKE ddshf4ctrl ##NEEDED ##CALLED.

  ps_callcontrol = VALUE #( MAXRECORDS = '500' ). " Max Hit list number
ENDFORM.
