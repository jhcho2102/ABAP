*=========================================*
* TOP            
*=========================================*

DATA: STATUS(4) TYPE C.

DATA: BEGIN OF EXCTAB OCCURS 10,
  OKCOD(4) TYPE C,
      END   OF EXCTAB.

*=========================================*
* PBO            
*=========================================*
EXCTAB = VALUE #( ( OKCODE = '...' ) (...) ).

UNPACK SY-DYNNR TO STATUS.
SET PF-STATUS STATUS (EXCLUDING EXCTAB).
