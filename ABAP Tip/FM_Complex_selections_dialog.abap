    CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
      EXPORTING
*       title             = space
        TEXT              = IS_INPUT-TEXT
*       signed            = 'X'
*       lower_case        = space
*       no_interval_check = space
*       just_display      = space
*       just_incl         = space
       excluded_options  = IS_INPUT-EXCLUDED_OPTIONS
*       description       =
*       help_field        =
*       search_help       =
        TAB_AND_FIELD     = IS_INPUT-TAB_AND_FIELD
      TABLES
        RANGE             = ET_RESULT
      EXCEPTIONS
        NO_RANGE_TAB      = 1
        CANCELLED         = 2
        INTERNAL_ERROR    = 3
        INVALID_FIELDNAME = 4
        OTHERS            = 5.
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
