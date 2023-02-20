*&---------------------------------------------------------------------*
*& Report zobl_r001
*&---------------------------------------------------------------------*
*& DDLS
*& BDEF
*&
*&---------------------------------------------------------------------*
REPORT zobl_r001.

TABLES:tadir, zobl_t001, zobl_t002.

PARAMETERS: p_object TYPE string DEFAULT 'DDLS'.
SELECT-OPTIONS: s_objnam FOR tadir-obj_name.
" I_PurchaseOrderHistoryAPI01
" I_SALESDOCUMENTBASIC
PARAMETERS: p_save AS CHECKBOX.

************************************************************************
* TOP                                                                  *
************************************************************************
DATA: ls_0001 TYPE zobl_t001,
      lt_0001 TYPE TABLE OF zobl_t001,
      ls_0002 TYPE zobl_t002,
      lt_0002 TYPE TABLe OF zobl_t002.

DATA: lt_ddlinfo TYPE cl_dd_ddl_analyze=>ty_t_ddlsinfo,
      lt_ddlname TYPE cl_dd_ddl_analyze=>ty_t_ddlnames,
      ls_ddlname LIKE LINE OF lt_ddlname.

DATA: lv_ptn TYPE string.

CLEAR: ls_0001, lt_0001, ls_0002, lt_0002.
************************************************************************
* INITIALIZATION                                                       *
************************************************************************
INITIALIZATION.
  s_objnam[] = VALUE #( ( sign = 'I' option = 'CP' low = 'I_*'  )
                        ( sign = 'I' option = 'CP' low = 'C_*'  )
                        ( sign = 'I' option = 'CP' low = 'R_*'  ) ).

************************************************************************
* START-OF-SELECTION                                                   *
************************************************************************
START-OF-SELECTION.
  SELECT
    FROM tadir AS obj
      LEFT OUTER JOIN ddddlsrc  AS src ON  src~ddlname = obj~obj_name
                                       AND src~as4local = 'A'
      LEFT OUTER JOIN ddddlsrct AS txt ON  txt~ddlname = src~ddlname
                                       AND txt~ddlanguage = @sy-langu
                                       AND txt~as4local = src~as4local
      LEFT OUTER JOIN ars_w_api_state AS api
                                       ON api~object_id = obj~obj_name
                                       AND compatibility_contract = 'C1'
    FIELDS obj~obj_name, src~as4date, txt~ddtext, src~source,
           api~compatibility_contract, api~release_state,
           api~use_in_key_user_apps, api~use_in_sap_cloud_platform
    WHERE pgmid    = 'R3TR'
      AND object   = @p_object
      AND obj_name IN @s_objnam
    ORDER BY obj~obj_name
    INTO TABLE @DATA(lt_obj).

  SELECT
    FROM zobl_t001
    FIELDS *
    INTO TABLE @DATA(lt_saved_01).

  DELETE ADJACENT DUPLICATES FROM lt_obj COMPARING obj_name.
  "--------------------------------------------------------------------"
  " Get info. about CDS view.
  LOOP AT lt_obj INTO DATA(ls_obj).
    "Check the data already exits in ZOBL_T0001.
    READ TABLE lt_saved_01 WITH KEY obj_name = ls_obj-obj_name
                           TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.

    " Get DDLS info. method.
    CLEAR: lt_ddlinfo, lt_ddlname, ls_ddlname, ls_0001.

    APPEND ls_obj-obj_name TO lt_ddlname.
    cl_dd_ddl_analyze=>get_ddlsinfo(
                                EXPORTING ddlnames = lt_ddlname
                                          state    = 'A'
                                IMPORTING ddlsinfo = lt_ddlinfo ).

    CLEAR: ls_0001.
    ls_0001-object        = p_object.
    ls_0001-obj_name      = ls_obj-obj_name.
    ls_0001-as4date       = ls_obj-as4date.
    ls_0001-ddtext        = ls_obj-ddtext.
    ls_0001-release_state = ls_obj-release_state.
    ls_0001-compatibility_contract    = ls_obj-compatibility_contract.
    ls_0001-use_in_key_user_apps      = ls_obj-use_in_key_user_apps.
    ls_0001-use_in_sap_cloud_platform = ls_obj-use_in_sap_cloud_platform.
    IF lt_ddlinfo IS NOT INITIAL.
      ls_0001-entityname    = lt_ddlinfo[ 1 ]-entityname.
      ls_0001-is_extended   = lt_ddlinfo[ 1 ]-is_extended.
      ls_0001-pack_name     = lt_ddlinfo[ 1 ]-package.
    ENDIF.

    TRANSLATE ls_0001-ddtext TO LOWER CASE.

    " Get DDLS info. about...
    "-- association.
    "-- composition.
    "-- associatin to parent.
    "-- where, groupby.
    "-- parameters.
    "-- table function.

    " Get Data source and fields.
    TRY.
      DATA(lt_tracker) = NEW cl_dd_ddl_field_tracker( ls_obj-obj_name
                             )->get_base_field_information( ).

      lt_0002 = CORRESPONDING #( BASE ( lt_0002 )
                                      lt_tracker ).

      ls_0001-has_source = 'X'.

    CATCH cx_dd_ddl_read.
      cl_dd_ddl_analyze=>get_descriptions(
        EXPORTING
          ddlnames    = lt_ddlname
          state       = 'A' " Activation State of Repository Object
          langu       = 'E' " Language Keys
        IMPORTING
          fielddescr  = DATA(lt_fdescr)
          pardescr    = DATA(lt_pdescr) ).

      LOOP AT lt_fdescr INTO DATA(ls_fields).
        CLEAR: ls_0002.
        ls_0002-entity_name  = ls_fields-entityname.
        ls_0002-element_name = ls_fields-fieldname.
        APPEND ls_0002 TO lt_0002.
      ENDLOOP.
    ENDTRY.

    APPEND ls_0001 TO lt_0001.
  ENDLOOP.

*  BREAK-POINT.

  IF p_save EQ 'X'.
    INSERT zobl_t001 FROM TABLE lt_0001 ACCEPTING DUPLICATE KEYS.
    IF sy-subrc EQ 0.
      INSERT zobl_t002 FROM TABLE lt_0002 ACCEPTING DUPLICATE KEYS.
      IF sy-subrc EQ 0.
        COMMIT WORK.
        MESSAGE 'Save Success!' TYPE 'S'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE 'Save Failed!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
