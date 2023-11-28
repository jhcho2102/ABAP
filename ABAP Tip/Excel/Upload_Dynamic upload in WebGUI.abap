*&---------------------------- Main -----------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_excel_data .
  DATA: lv_headerxstring  TYPE xstring.
  DATA: lt_excel          TYPE gty_t_excel_data.
  DATA: lo_data_ref       TYPE REF TO DATA.
  DATA: lo_cx_excel       TYPE REF TO cx_fdt_excel_core.
  DATA: lo_type_structure TYPE REF TO cl_abap_structdescr.

  CLEAR: lv_headerxstring, lt_excel.
  CLEAR: lo_data_ref, lo_type_structure.

  IF p_path IS INITIAL.
    MESSAGE s000(zfar01) WITH TEXT-m02 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM get_binary_data CHANGING lv_headerxstring.     "--- File -> Binary Data.
  IF lv_headerxstring IS NOT INITIAL.
    PERFORM get_excel_ref_data USING    lv_headerxstring "--- Binary Data -> Excel Ref Data.
                               CHANGING lo_data_ref
                                        lo_cx_excel.
    IF lo_cx_excel IS NOT INITIAL.
      DATA(lv_msg) = lo_cx_excel->get_text( ).
      MESSAGE s000(zfar01) WITH lv_msg DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    IF lo_data_ref IS INITIAL.
      RETURN.
    ENDIF.

    PERFORM get_types_from_ref_data USING    lo_data_ref "--- Excel Ref Data -> Excel Itab Data.
                                    CHANGING lt_excel.

    PERFORM convert_excel_to_inner_data USING lt_excel.  "--- Excel Itab Data -> Display Itab Data.
  ENDIF.
ENDFORM.





*&---------------------------------------------------------------------*
*& Form get_binary_data
*&---------------------------------------------------------------------*
FORM get_binary_data  CHANGING pv_headerxstring.
  DATA: lv_extension     TYPE string.
  DATA: lt_records       TYPE solix_tab.
  DATA: lv_filelength    TYPE i.
  DATA: lv_headerxstring TYPE xstring.

  " Check File Extension
  CALL FUNCTION 'CRM_IC_WZ_SPLIT_FILE_EXTENSION'
    EXPORTING
      iv_filename_with_ext = p_path
    IMPORTING
      ev_extension         = lv_extension.
  TRANSLATE lv_extension TO UPPER CASE.

  CASE lv_extension.
    WHEN 'XLS' OR 'XLSX'.
      PERFORM gui_upload TABLES   lt_records[]
                         USING    p_path
                                  'BIN'
                                  lv_extension
                         CHANGING lv_filelength.
  ENDCASE.

  IF sy-subrc = 0.
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filelength
      IMPORTING
        buffer       = lv_headerxstring
      TABLES
        binary_tab   = lt_records
      EXCEPTIONS
        FAILED       = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.
*      EXIT.
    ENDIF.

    pv_headerxstring = lv_headerxstring.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_excel_ref_data
*&---------------------------------------------------------------------*
FORM get_excel_ref_data  USING    pv_headerxstring
                         CHANGING po_data_ref
                                  po_cx_excel TYPE REF TO cx_fdt_excel_core.
*  DATA: ls_worksheets TYPE string.

  TRY.
    DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet( document_name = CONV #( p_path )
                                                     xdocument    = pv_headerxstring ).

  CATCH CX_FDT_EXCEL_CORE INTO po_cx_excel. EXIT.
  ENDTRY .

  " Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  READ TABLE lt_worksheets INTO DATA(ls_worksheets) INDEX 1.
  po_data_ref = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet( ls_worksheets ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_types_from_ref_data
*&---------------------------------------------------------------------*
FORM get_types_from_ref_data  USING    po_data_ref
                              CHANGING pt_excel TYPE gty_t_excel_data.

  DATA: lo_type   TYPE REF TO cl_abap_typedescr,
        lo_table  TYPE REF TO cl_abap_tabledescr,
        lo_struct TYPE REF TO cl_abap_structdescr.
  DATA: lo_ref_line TYPE REF TO DATA.

  DATA: lv_index        TYPE i,
        lv_total_comp   TYPE i,
        lv_index_assign TYPE sy-index.

  DATA: ls_excel_components   TYPE abap_componentdescr,
        lt_excel_components   TYPE abap_component_tab.

  DATA: ls_excel TYPE gty_s_excel_data,
        lt_excel TYPE gty_t_excel_data.


  DATA(lo_typedescr) = cl_abap_typedescr=>describe_by_data_ref( po_data_ref ).
  lo_table  ?= lo_typedescr.
  lo_struct ?= lo_table->get_table_line_type( ).
  DATA(lt_im_comps) = lo_struct->get_components( ).

  ASSIGN po_data_ref->* TO FIELD-SYMBOL(<lt_itab>).

  LOOP AT <lt_itab> ASSIGNING FIELD-SYMBOL(<l_itab>).
    IF sy-tabix = C_HEADERLINE.
      LOOP AT lt_im_comps INTO DATA(ls_im_comp).
       lv_total_comp += 1.
       FIND ls_im_comp-name IN sy-abcde MATCH OFFSET lv_index.
       lv_index += 1.
       ASSIGN COMPONENT lv_index OF STRUCTURE <l_itab> TO FIELD-SYMBOL(<l_fieldname>).
       IF <l_fieldname> IS ASSIGNED AND <l_fieldname> IS NOT INITIAL.
         TRANSLATE <l_fieldname> TO UPPER CASE.
         CONDENSE <l_fieldname> NO-GAPS.
         READ TABLE gt_components INTO DATA(ls_component) WITH KEY cfield = <l_fieldname> BINARY SEARCH.
         IF sy-subrc = 0.
           ls_excel_components = CORRESPONDING #( ls_component ).
           APPEND ls_excel_components TO lt_excel_components.
         ENDIF.
       ENDIF.
     ENDLOOP.
    ENDIF.
  ENDLOOP.
  UNASSIGN: <l_itab>.

  DATA(lo_structure) = cl_abap_structdescr=>get( lt_excel_components ).
  CREATE DATA lo_ref_line TYPE HANDLE lo_structure.
  ASSIGN lo_ref_line->* TO FIELD-SYMBOL(<l_line>).

  LOOP AT <lt_itab> ASSIGNING <l_itab>.
    CLEAR: lv_index_assign.
    IF sy-tabix >= p_srow.
      IF p_erow IS NOT INITIAL AND sy-tabix > p_erow.
        EXIT.
      ENDIF.

      DO lv_total_comp TIMES.
        IF sy-index = 1. "= 구분자 제외.
          CONTINUE.
        ENDIF.
        lv_index_assign = sy-index - 1.
        ASSIGN COMPONENT sy-index OF STRUCTURE <l_itab> TO FIELD-SYMBOL(<l_field>).
        IF <l_field> IS ASSIGNED.
          ASSIGN COMPONENT lv_index_assign OF STRUCTURE <l_line> TO FIELD-SYMBOL(<l_line_field>).
          IF <l_line_field> IS ASSIGNED.
            <l_line_field> = CONV #( <l_field> ).
          ENDIF.
        ENDIF.
      ENDDO.

      CLEAR: ls_excel.
      ls_excel = CORRESPONDING #( <l_line> ).
      APPEND ls_excel TO pt_excel.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_excel_to_inner_data
*&---------------------------------------------------------------------*
FORM convert_excel_to_inner_data  USING pt_excel TYPE gty_t_excel_data.
  DATA: lv_fieldname TYPE fieldname.

  CLEAR: gt_disp_200.
  LOOP AT pt_excel INTO DATA(ls_excel).
    CLEAR: gs_disp_200.
    gs_disp_200 = CORRESPONDING #( ls_excel ).
    ASSIGN COMPONENT 'STATUS'  OF STRUCTURE gs_disp_200 TO FIELD-SYMBOL(<l_status>).
    ASSIGN COMPONENT 'ERR_MSG' OF STRUCTURE gs_disp_200 TO FIELD-SYMBOL(<l_msg>).
    CHECK <l_status> IS ASSIGNED AND <l_msg> IS ASSIGNED.

    LOOP AT gt_components INTO DATA(ls_comp).
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE ls_excel TO FIELD-SYMBOL(<l_value_x>).
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE gs_disp TO FIELD-SYMBOL(<l_value>).
      CHECK <l_value_x> IS ASSIGNED AND <l_value> IS ASSIGNED.

      CASE ls_comp-name.
        WHEN 'BUKRS'.

        WHEN 'WAERS'.

        WHEN OTHERS.
      ENDCASE.

      <l_value> = <l_value_x>.
    ENDLOOP.
*    IF <l_value> IS INITIAL.
*      <l_value> = <l_value_x>.
*    ENDIF.
    UNASSIGN: <l_value>, <l_value_x>.

    IF gs_disp-status <> C_ICON_RED.
      <l_status> = C_ICON_YELLOW.
    ENDIF.
    APPEND gs_disp TO gt_disp.
  ENDLOOP.
ENDFORM.
