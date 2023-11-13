# Declare TYPES
```abap
TYPES: BEGIN OF ts_data,
    field_01 TYPE char10,
    field_02 TYPE char10,
    field_03 TYPE char10,
    field_04 TYPE char10,
        END OF ts_data,
tt_data TYPE TABLE OF ts_data WITH KEY PRIMARY_KEY AS PKEY COMPONENTS field_01 field_02.
```

# Handle Table
```abap
DATA: gt_data TYPE tt_data.

...

READ TABLE gt_data FROM ls_data USING KEY PRIMARY_KEY.

DELETE TABLE gt_data FROM ls_data USING KEY PRIMARY_KEY.

MODIFY TABLE gt_data FROM ls_data USING KEY PRIMARY_KEY.
```
