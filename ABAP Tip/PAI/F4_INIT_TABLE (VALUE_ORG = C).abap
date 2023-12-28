DATA: BEGIN OF lt_value OCCURS 0,
  value TYPE c LENGTH 50,
      END OF lt_value.
DATA: lt_field   TYPE TABLE OF dfies.
DATA: lt_return  TYPE TABLE OF ddshretval.
DATA: lt_mapping TYPE TABLE OF dselc.

SELECT
  FROM t052 AS a
    LEFT OUTER JOIN t052u AS b ON  a~zterm = b~zterm
                               AND a~ztagg = b~ztagg
                               AND b~spras = @sy-langu
  FIELDS a~zterm , a~ztagg , b~text1
  INTO TABLE @DATA(lt_t052).

LOOP AT lt_t052 INTO DATA(ls_t052).
  CLEAR: lt_value.
  lt_value-value = ls_t052-zterm.
  APPEND lt_value.

  CLEAR: lt_value.
  lt_value-value = ls_t052-ztagg.
  APPEND lt_value.

  CLEAR: lt_value.
  lt_value-value = ls_t052-text1.
  APPEND lt_value.
ENDLOOP.

lt_field = VALUE #( ( fieldname = 'ZTERM' outputlen = 5  inttype = 'C' intlen = 12  reptext = TEXT-f01 ) " intlen : byte length
                    ( fieldname = 'ZTAGG' outputlen = 3  inttype = 'C' intlen = 8   reptext = TEXT-f02 )
                    ( fieldname = 'TEXT1' outputlen = 50 inttype = 'C' intlen = 100 reptext = TEXT-f03 ) ).

lt_mapping = VALUE #( ( fldname = 'ZTERM' dyfldname = 'ZTERM' )
                      ( fldname = 'ZTAGG' dyfldname = 'ZTAGG' )
                      ( fldname = 'TEXT1' dyfldname = 'TEXT1' ) ).

CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
  EXPORTING
    RETFIELD        = PV_FIELDNAME
    DYNPPROG        = SY-REPID
    DYNPNR          = SY-DYNNR
    VALUE_ORG       = 'C'
  TABLES
    VALUE_TAB       = lt_value[]
    field_tab       = lt_field
    RETURN_TAB      = LT_RETURN
    dynpfld_mapping = lt_mapping
  EXCEPTIONS
    PARAMETER_ERROR = 1
    NO_VALUES_FOUND = 2
    OTHERS          = 3 .
