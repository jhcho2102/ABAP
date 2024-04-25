*&---------------------------------------------------------------------*
*& 호출부
*&---------------------------------------------------------------------*
PERFORM get_user_param USING 'BUK' CHANGING p_bukrs.


*&---------------------------------------------------------------------*
*& Form get_user_param
*&---------------------------------------------------------------------*
FORM get_user_param  USING    VALUE(p_name)
                     CHANGING p_param.
  CLEAR: p_param.
  GET PARAMETER ID p_name FIELD p_param.
  IF p_param IS INITIAL.
    SELECT SINGLE
      FROM usr05
      FIELDS parva
      WHERE bname = @sy-uname
      AND   parid = @p_name
      INTO @p_param.
  ENDIF.
ENDFORM.
