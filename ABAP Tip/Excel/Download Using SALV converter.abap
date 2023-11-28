  DATA: lo_salv      TYPE REF TO cl_salv_table.
  DATA: lo_worksheet TYPE REF TO zcl_excel_worksheet.
  DATA: lo_columns   TYPE REF TO cl_salv_columns_table.
  DATA: lo_column    TYPE REF TO cl_salv_column_table.
  DATA: lo_converter TYPE REF TO zcl_excel_converter.
  DATA: lt_file      TYPE solix_tab,
        lv_bytecount TYPE i,
        lv_file      TYPE xstring.
  DATA: ls_seoclass  TYPE seoclass.
  DATA: lo_excel_writer TYPE REF TO zif_excel_writer.

...

  "=== Excel Download할 데이터로 SALV 객체 생성.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_salv
        CHANGING
          t_table      = lt_excel_data ).
          
  CATCH cx_salv_msg .
  ENDTRY.
  
  "=== SALV의 column tex 설정.
  lo_columns = lo_salv->get_columns( ).
  lo_columns->set_optimize( 'X' ).
  LOOP AT lt_column INTO DATA(ls_coltext). " lt_column : excel column명 저장된 itab.
    TRY.
      lo_column ?= lo_columns->get_column( CONV #( ls_coltext-name ) ).
    CATCH CX_SALV_NOT_FOUND.
    ENDTRY.
    lo_column->set_long_text( CONV #( ls_coltext-display_name ) ).
    lo_column->set_medium_text( CONV #( ls_coltext-display_name ) ).
    lo_column->set_short_text( CONV #( ls_coltext-display_name ) ).
  ENDLOOP.

  "=== SALV -> EXCEL 변환.
  DATA(lo_excel) = NEW zcl_excel( ).
  CREATE OBJECT lo_converter.
  TRY.
    lo_converter->convert(
      EXPORTING
        io_alv        = lo_salv
        it_table      = lt_excel_data
        i_row_int     = 1
        i_column_int  = 1
      CHANGING
        co_excel = lo_excel ).
  CATCH ZCX_EXCEL.
    sy-subrc = 4.
  ENDTRY.

  "=== column 열 너비 설정.
  DATA(lo_sheet) = lo_excel->get_active_worksheet( ).
  TRY.
    lo_sheet->calculate_column_widths( ).
    lo_sheet->set_column_width(
      ip_column         = 'D'
      ip_width_fix      = 13
      ip_width_autosize = ''
    ).
    lo_sheet->set_column_width(
      ip_column         = 'I'
      ip_width_fix      = 16
      ip_width_autosize = ''
    ).
  CATCH ZCX_EXCEL.
  ENDTRY.

  "=== Export Excel file.
  CREATE OBJECT lo_excel_writer TYPE zcl_excel_writer_2007.
  TRY.
    lv_file = lo_excel_writer->write_file( lo_excel ).
  CATCH ZCX_EXCEL.
  ENDTRY.

  SELECT SINGLE * INTO ls_seoclass
    FROM seoclass
    WHERE clsname = 'CL_BCS_CONVERT'.

  IF sy-subrc = 0.
    CALL METHOD (ls_seoclass-clsname)=>xstring_to_solix
      EXPORTING
        iv_xstring = lv_file
      RECEIVING
        et_solix   = lt_file.

    lv_bytecount = xstrlen( lv_file ).
  ELSE.
  
    "--- Convert to binary
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_file
      IMPORTING
        output_length = lv_bytecount
      TABLES
        binary_tab    = lt_file.
  ENDIF.

  cl_gui_frontend_services=>gui_download( EXPORTING bin_filesize = lv_bytecount
                                                    filename     = lv_fullpath
                                                    filetype     = 'BIN'
                                           CHANGING data_tab     = lt_file ).
