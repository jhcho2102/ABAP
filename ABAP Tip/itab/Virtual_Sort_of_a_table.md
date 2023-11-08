# Virtual Sort of a Table
## Prepare Data
```abap
TYPES: BEGIN OF gty_s_data,
  col1 TYPE char01,
  col2 TYPE char01,
       END OF gty_s_data,
  gty_t_data TYPE TABLE OF gty_s_data.

DATA: lt_itab       TYPE gty_t_data.
DATA: lt_sorted_tab TYPE gty_t_data.

START-OF-SELECTION.
lt_itab = VALUE #( ( col1 = 'C' col2 ='4' )
                   ( col1 = 'A' col2 ='2' )
                   ( col1 = 'D' col2 ='5' )
                   ( col1 = 'A' col2 ='3' )
                   ( col1 = 'B' col2 ='1' ) ).
```

## Virtual Sorting
```abap
DATA(lt_index) =
cl_abap_itab_utilities=>virtual_sort(
    im_virtual_source = VALUE #( ( source = REF #( lt_itab )
                                   components = VALUE #( ( name = 'col1' descending = ''  astext = '' )
                                                         ( name = 'col2' descending = 'X' astext = '' ) ) ) )
).
```

## Build Sorted Table
```abap
lt_sorted_tab = VALUE #( FOR lv_idx IN lt_index
                         ( lt_itab[ lv_idx ] ) ).
```
