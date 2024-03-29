*&---------------------------------------------------------------------*
*& TOP                                                                 *
*&---------------------------------------------------------------------*
TYPE-POOLS: VRM.

PARAMETERS: P_LIST TYPE XXX AS LISTBOX VISIBLE LENGTH 15.

*&---------------------------------------------------------------------*
*& INITIALIZATION                                                      *
*&---------------------------------------------------------------------*
INITIALIZATION.

  DATA(lt_list) = VALUE vrm_values( ( key = 'A' text = 'All' )
                                    ( key = 'H' text = 'Header' )
                                    ( key = 'L' text = 'Line Item' ) ).
  
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id                    = 'P_LIST'
        values                = lt_list
      EXCEPTIONS
        ID_ILLEGAL_NAME       = 1
        OTHERS                = 2 .
  
    IF sy-subrc <> 0.
  *    EXIT.
    ENDIF.
