" 숫자를 3자리 단위로 끊어 ','를 삽입.

CALL FUNCTION 'RRBA_CONVERT_PACKED_NUMBER'
    EXPORTING
      i_char                     = gv_data
   IMPORTING
     E_VALUE_WRITE               = gv_data.
