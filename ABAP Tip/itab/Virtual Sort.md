# Virtual Sort
## filter index
```
DATA: lt_tab TYPE gty_t_data.
lt_tab = VALUE #( FOR idx IN v_index
        ( itab[ idx ] ) ).
```
