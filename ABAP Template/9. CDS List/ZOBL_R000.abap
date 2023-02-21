*&---------------------------------------------------------------------*
*& Report ZOBL_R000
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZOBL_R000.
************************************************************************
* TOP.
************************************************************************
TABLES: zobl_t001, zobl_t002.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA: ok_code    TYPE sy-ucomm,
      gv_copy    TYPE sy-ucomm.

DATA: go_docking        TYPE REF TO cl_gui_docking_container,
      go_splitter       TYPE REF TO cl_gui_splitter_container,
      go_cont_top       TYPE REF TO cl_gui_container,
      go_cont_body      TYPE REF TO cl_gui_container,
      go_grid           TYPE REF TO cl_gui_alv_grid,
      go_grid_2         TYPE REF TO cl_gui_alv_grid,
      go_event_receiver TYPE REF TO lcl_event_receiver.

DATA: gs_fieldcat TYPE lvc_s_fcat,
      gt_fieldcat TYPE lvc_t_fcat,
      gs_layout   TYPE lvc_s_layo,
      gt_exclude  TYPE ui_functions,
      gs_exclude  TYPE ui_func,
      gt_sort     TYPE lvc_t_sort,
      gs_sort     TYPE lvc_s_sort,
      gs_variant  TYPE disvariant,
      gs_stable   TYPE lvc_s_stbl.

DATA: gs_fieldcat_i TYPE lvc_s_fcat,
      gt_fieldcat_i TYPE lvc_t_fcat.

TYPES: BEGIN OF ty_s_disp_h,
  obj_name                  TYPE zobl_t001-obj_name,
  entityname                TYPE zobl_t001-entityname,
  ddtext                    TYPE zobl_t001-ddtext,
  release_state             TYPE zobl_t001-release_state,
  compatibility_contract    TYPE zobl_t001-compatibility_contract,
  use_in_sap_cloud_platform TYPE zobl_t001-use_in_sap_cloud_platform,
  is_extended               TYPE zobl_t001-is_extended,
  has_source                TYPE zobl_t001-has_source,
  pack_name                 TYPE zobl_t001-pack_name,
       END OF ty_s_disp_h,
       ty_t_disp_h TYPE TABLE OF ty_s_disp_h.

TYPES: BEGIN OF ty_s_disp_i,
  entity_name   TYPE zobl_t002-entity_name,
  element_name  TYPE zobl_t002-element_name,
  base_object   TYPE zobl_t002-base_object,
  base_field    TYPE zobl_t002-base_field,
  is_calculated TYPE zobl_t002-is_calculated,
       END OF ty_s_disp_i,
       ty_t_disp_i TYPE TABLE OF ty_s_disp_i.

DATA: gs_disp TYPE ty_s_disp_h,
      gt_disp TYPE ty_t_disp_h,

      gs_item TYPE ty_s_disp_i,
      gt_item TYPE ty_t_disp_i,

      gs_item_tmp TYPE ty_s_disp_i,
      gt_item_tmp TYPE ty_t_disp_i.

************************************************************************
* Selection Screen.
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS: p_ddl RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND ucom, " From Data Definition.
              p_src RADIOBUTTON GROUP rb1. " From Source table.
  SELECTION-SCREEN ULINE.

  PARAMETERS: p_c1   AS CHECKBOX DEFAULT 'X', " C1 contract API.
              p_rel  AS CHECKBOX DEFAULT 'X'. " Released API.

  SELECT-OPTIONS: s_ddtext FOR zobl_t001-ddtext NO INTERVALS.

  SELECT-OPTIONS: s_con FOR zobl_t001-compatibility_contract NO-DISPLAY,
                  s_rel FOR zobl_t001-release_state NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
  SELECT-OPTIONS: s_objnam FOR zobl_t001-obj_name NO INTERVALS MODIF ID b2,
                  s_elemnt FOR zobl_t002-element_name NO INTERVALS MODIF ID b2.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
  SELECT-OPTIONS: s_srctab FOR zobl_t002-base_object NO INTERVALS MODIF ID b3,
                  s_srcfld FOR zobl_t002-base_field NO INTERVALS MODIF ID b3.
SELECTION-SCREEN END OF BLOCK b3.

************************************************************************
* INITIALIZATION.
************************************************************************
INITIALIZATION.
  gs_stable-row = 'X'.
  gs_stable-col = 'X'.

************************************************************************
* AT SELECTION-SCREEN.
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM set_selection_screen.

AT SELECTION-SCREEN.

************************************************************************
* START-OF-SELECTION.
************************************************************************
START-OF-SELECTION.
  PERFORM set_select_range.

  PERFORM get_data_ddl.

  PERFORM get_data_src.

************************************************************************
* END-OF-SELECTION.
************************************************************************
END-OF-SELECTION.
  CALL SCREEN 100.









************************************************************************
* Local Class.
************************************************************************
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
          IMPORTING e_row
                    e_column.

    METHODS: handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
          IMPORTING e_row_id
                    e_column_id.

    METHODS: handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
          IMPORTING e_object
                    e_interactive.

    METHODS: handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
          IMPORTING e_ucomm.

    METHODS: handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
          IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_double_click.
    PERFORM handle_double_click USING e_row
                                      e_column.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    PERFORM handle_hotspot USING e_row_id
                                 e_column_id.
  ENDMETHOD.

  METHOD handle_toolbar.
    PERFORM handle_toolbar USING e_object.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM handle_ucom USING e_ucomm.
  ENDMETHOD.

  METHOD handle_data_changed.
    PERFORM handle_data_changed USING er_data_changed.
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0100 OUTPUT.
  IF go_grid IS INITIAL.
    PERFORM create_object.
    PERFORM set_fieldcat.
    PERFORM set_layout.
    PERFORM set_sort.
    PERFORM set_exclude.
    PERFORM set_event.
    PERFORM display_alv.
  ELSE.
    PERFORM refresh_alv.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  gv_copy = ok_code.
  CLEAR: ok_code, gs_stable.

*  PERFORM alv_check_changed_data.

  CASE gv_copy.
    WHEN 'PROPG'.
*      PERFORM propagateObject.
  ENDCASE.
ENDMODULE.


************************************************************************
* Subroutines.
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_object .
  CREATE OBJECT go_docking
    EXPORTING
*      parent                      =
*      repid                       =
*      dynnr                       =
      side               = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      extension          = CL_GUI_DOCKING_CONTAINER=>WS_MAXIMIZEBOX
      .

  CREATE OBJECT go_splitter
    EXPORTING
      parent = go_docking
      rows = 2
      columns = 1.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_cont_top.

  CALL METHOD go_splitter->set_row_height
    EXPORTING
      id                = 1
      height            = 15 .

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_cont_body.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_cont_top.

  CREATE OBJECT go_grid_2
    EXPORTING
      i_parent = go_cont_body.
ENDFORM.                    " CREATE_OBJECT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fieldcat .
  PERFORM abap_structdescr.

  FIELD-SYMBOLS <fcat> LIKE gs_fieldcat.
  LOOP AT gt_fieldcat ASSIGNING <fcat>.
    <fcat>-col_opt = 'X'.
    CASE <fcat>-fieldname.
      WHEN ''.
        <fcat>-no_out = 'X'.
      WHEN 'OBJ_NAME'.
        <fcat>-coltext = 'Object Name'.
        <fcat>-key = 'X'.
      WHEN 'ENTITYNAME'.
        <fcat>-coltext = 'Entity Name'.
      WHEN 'IS_EXTENDED'.
        <fcat>-coltext = 'Is Extended'.
      WHEN 'PACK_NAME'.
        <fcat>-coltext = 'Package Name'.
      WHEN 'COMPATIBILITY_CONTRACT'.
        <fcat>-coltext = 'Contract Type'.
      WHEN 'RELEASE_STATE'.
        <fcat>-coltext = 'Rel. State'.
      WHEN 'HAS_SOURCE'.
        <fcat>-coltext = 'Has Source'.
*      WHEN ''.
*        <fcat>-coltext = ''.
    ENDCASE.
  ENDLOOP.

  FIELD-SYMBOLS <fcat_i> LIKE gs_fieldcat_i.
  LOOP AT gt_fieldcat_i ASSIGNING <fcat_i>.
    <fcat_i>-col_opt = 'X'.
    CASE <fcat_i>-fieldname.
      WHEN 'ENTITY_NAME'.
        <fcat_i>-key = 'X'.
        <fcat_i>-coltext = 'CDS Entity Name'.
      WHEN 'ELEMENT_NAME'.
        <fcat_i>-coltext = 'CDS Element Name'.
      WHEN 'BASE_OBJECT'.
        <fcat_i>-coltext = 'Source Table'.
      WHEN 'BASE_FIELD'.
        <fcat_i>-coltext = 'Source Field'.
      WHEN 'IS_CALCULATED'.
        <fcat_i>-coltext = 'Calculated Field'.
*      WHEN ''.
*        <fcat_i>-coltext = ''.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " SET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  ABAP_STRUCTDESCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM abap_structdescr .
  DATA : lo_strdescr TYPE REF TO cl_abap_structdescr,
         lt_dfies    TYPE ddfields,
         ls_dfies    TYPE dfies.

  CLEAR gt_fieldcat.

  lo_strdescr ?= cl_abap_structdescr=>describe_by_data( gs_disp ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lo_strdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    MOVE-CORRESPONDING ls_dfies TO gs_fieldcat.
    APPEND gs_fieldcat TO gt_fieldcat.
    CLEAR gs_fieldcat.
  ENDLOOP.

  CLEAR gt_fieldcat_i.

  lo_strdescr ?= cl_abap_structdescr=>describe_by_data( gs_item ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lo_strdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    MOVE-CORRESPONDING ls_dfies TO gs_fieldcat_i.
    APPEND gs_fieldcat_i TO gt_fieldcat_i.
    CLEAR gs_fieldcat_i.
  ENDLOOP.
ENDFORM.                    " ABAP_STRUCTDESCR
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_layout .
  CLEAR gs_layout.

  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode = 'D'.
*  gs_layout-stlyefieldname = ''.
*  gs_layout-grid_title = ''.
ENDFORM.                    " SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_sort .

ENDFORM.                    " SET_SORT
*&---------------------------------------------------------------------*
*&      Form  SET_EXCLUDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_exclude .
  CLEAR: gs_exclude, gt_exclude.

*  PERFORM append_exclude
*    USING : cl_gui_alv_grid=>mc_fc_excl_all. " 전체 제거
*    USING : cl_gui_alv_grid=>mc_fc_loc_undo. " 실행취소 &LOCAL&UNDO
*            cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*            cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
*            cl_gui_alv_grid=>mc_fc_graph,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
*            cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 행 카피.
*            cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
*            cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
*            cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
*            cl_gui_alv_grid=>mc_fc_loc_move_row,
*            cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
*            cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_loc_paste_new_row, " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all,
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_fc_sum,
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processor.
ENDFORM.                    " SET_EXCLUDE
*&---------------------------------------------------------------------*
*&      Form  APPEND_EXCLUDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CL_GUI_ALV_GRID=>MC_FC_EXCL_AL  text
*----------------------------------------------------------------------*
FORM append_exclude  USING   ps_exclude LIKE gs_exclude.
  APPEND ps_exclude TO gt_exclude.
ENDFORM.                    " APPEND_EXCLUDE
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_event .
  CREATE OBJECT go_event_receiver.

  SET HANDLER: go_event_receiver->handle_double_click  FOR go_grid,
               go_event_receiver->handle_hotspot_click FOR go_grid,
               go_event_receiver->handle_toolbar       FOR go_grid,
               go_event_receiver->handle_user_command  FOR go_grid,
               go_event_receiver->handle_data_changed  FOR go_grid.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = go_grid->mc_evt_modified.
  " mc_evt_modified / mc_evt_enter
ENDFORM.                    " SET_EVENT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .
  CLEAR: gs_variant.
  gs_variant-report = sy-repid.
  gs_variant-username = sy-uname.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
*      i_structure_name              =
      is_variant                    = gs_variant
      i_save                        = 'A' " X(global)/U(user)/A(all)/''
      i_default                     = 'X' " X(enable)/''(disable)
      is_layout                     = gs_layout
*      is_print                      =
*      it_special_groups             =
      it_toolbar_excluding          = gt_exclude
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
    CHANGING
      it_outtab                     = gt_disp
      it_fieldcatalog               = gt_fieldcat
*      it_sort                       = gt_sort
*      it_filter                     =
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      others                        = 4
          .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  CALL METHOD go_grid_2->set_table_for_first_display
    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
*      i_structure_name              =
      is_variant                    = gs_variant
      i_save                        = 'A' " X(global)/U(user)/A(all)/''
      i_default                     = 'X' " X(enable)/''(disable)
      is_layout                     = gs_layout
*      is_print                      =
*      it_special_groups             =
      it_toolbar_excluding          = gt_exclude
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
    CHANGING
      it_outtab                     = gt_item
      it_fieldcatalog               = gt_fieldcat_i
*      it_sort                       = gt_sort
*      it_filter                     =
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      others                        = 4
          .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv .
  CALL METHOD go_grid->refresh_table_display
    EXPORTING
      is_stable      = gs_stable
      i_soft_refresh = 'X'
    EXCEPTIONS
      finished       = 1
      others         = 2
          .

  CALL METHOD go_grid_2->refresh_table_display
    EXPORTING
      is_stable      = gs_stable
      i_soft_refresh = 'X'
    EXCEPTIONS
      finished       = 1
      others         = 2
          .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.                    " REFRESH_ALV
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM handle_double_click  USING    ps_row    TYPE lvc_s_row
                                   ps_column TYPE lvc_s_col.

  DATA(lv_obj) = gt_disp[ ps_row-index ]-obj_name.

  CLEAR: gt_item.
  gt_item = VALUE #( FOR ls_item IN gt_item_tmp
                       WHERE ( entity_name = lv_obj )
                       ( entity_name   = ls_item-entity_name
                         element_name  = ls_item-element_name
                         base_object   = ls_item-base_object
                         base_field    = ls_item-base_field
                         is_calculated = ls_item-is_calculated ) ).

  PERFORM refresh_alv.
ENDFORM.                    " HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM handle_hotspot  USING    ps_row_id    TYPE lvc_s_row
                              ps_column_id TYPE lvc_s_col.

ENDFORM.                    " HANDLE_HOTSPOT
*&---------------------------------------------------------------------*
*&      Form  HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*----------------------------------------------------------------------*
FORM handle_toolbar  USING    po_object
                          TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

ENDFORM.                    " HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*&      Form  HANDLE_UCOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM handle_ucom  USING    pv_ucomm TYPE sy-ucomm.

ENDFORM.                    " HANDLE_UCOM
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM handle_data_changed  USING    po_data_changed
                               TYPE REF TO cl_alv_changed_data_protocol.

ENDFORM.                    " HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  ALV_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_check_changed_data .
  DATA: lv_valid, lv_refresh.

  CALL METHOD go_grid->check_changed_data
*    IMPORTING
*      e_valid   = lv_valid
*    CHANGING
*      c_refresh = 'X'
      .
ENDFORM.                    " ALV_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& Form set_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_screen .
  LOOP AT SCREEN.
    CASE 'X'.
      WHEN p_ddl.
        IF screen-group1 = 'B3'.
          screen-active = 0.
        ENDIF.

      WHEN p_src.
        IF screen-group1 = 'B2'.
          screen-active = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_select_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_select_range .
  IF p_c1 = 'X'.
    s_con-sign = 'I'. s_con-option = 'EQ'.
    s_con-low = 'C1'. APPEND s_con.
  ENDIF.

  IF p_rel = 'X'.
    s_rel-sign = 'I'. s_rel-option = 'EQ'.
    s_rel-low = 'RELEASED'. APPEND s_rel.
*    CLEAR s_rel-low.
*    s_rel-low = 'RELEASED_WITH_FEATURE_TOGGLE'. APPEND s_rel.
*    CLEAR s_rel-low.
*    s_rel-low = 'NOT_TO_BE_RELEASED_STABLE'. APPEND s_rel.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_ddl
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_ddl .
  IF p_ddl = 'X'.
    SELECT
      FROM zobl_t001 AS h
      FIELDS *
      WHERE h~release_state IN @s_rel
        AND h~compatibility_contract IN @s_con
        AND h~obj_name IN @s_objnam
        AND h~ddtext IN @s_ddtext
      INTO CORRESPONDING FIELDS OF TABLE @gt_disp.

    SELECT
      FROM zobl_t002 as i
      FIELDS *
      FOR ALL ENTRIES IN @gt_disp
      WHERE i~entity_name = @gt_disp-obj_name
        AND i~element_name IN @s_elemnt
      INTO CORRESPONDING FIELDS OF TABLE @gt_item_tmp.


    DATA(lv_obj) = gt_disp[ 1 ]-obj_name.
    gt_item = VALUE #( FOR ls_item IN gt_item_tmp
                       WHERE ( entity_name = lv_obj )
                       ( entity_name   = ls_item-entity_name
                         element_name  = ls_item-element_name
                         base_object   = ls_item-base_object
                         base_field    = ls_item-base_field
                         is_calculated = ls_item-is_calculated ) ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_src
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_src .
  IF p_src = 'X'.
    SELECT
      FROM zobl_t002 AS i
      FIELDS *
      WHERE i~base_object IN @s_srctab
        AND i~base_field  IN @s_srcfld
      INTO CORRESPONDING FIELDS OF TABLE @gt_item_tmp.

    DATA(lt_item_adj) = CORRESPONDING ty_t_disp_i( gt_item_tmp ).
    SORT lt_item_adj BY entity_name.
    DELETE ADJACENT DUPLICATES FROM lt_item_adj COMPARING entity_name.

    SELECT
      FROM zobl_t001 AS h
      FIELDS *
      FOR ALL ENTRIES IN @lt_item_adj
      WHERE h~release_state IN @s_rel
        AND h~compatibility_contract IN @s_con
        AND h~ddtext IN @s_ddtext
        AND h~obj_name = @lt_item_adj-entity_name
        AND h~has_source = 'X'
      INTO CORRESPONDING FIELDS OF TABLE @gt_disp.

    DATA(lv_obj) = gt_disp[ 1 ]-obj_name.
    gt_item = VALUE #( FOR ls_item IN gt_item_tmp
                       WHERE ( entity_name = lv_obj )
                       ( entity_name   = ls_item-entity_name
                         element_name  = ls_item-element_name
                         base_object   = ls_item-base_object
                         base_field    = ls_item-base_field
                         is_calculated = ls_item-is_calculated ) ).
  ENDIF.
ENDFORM.
