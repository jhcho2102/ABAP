*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  < --  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL .
  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA                   = GS_DOC_DATA
     PUT_IN_OUTBOX                    = GV_OUTBOX
*     SENDER_ADDRESS                   = GV_SENDER
*     SENDER_ADDRESS_TYPE              = GV_SENDER_TYPE
     COMMIT_WORK                      = GV_COMMIT_FLG
*   IMPORTING
*     SENT_TO_ALL                      =
*     NEW_OBJECT_ID                    =
*     SENDER_ID                        =
    TABLES
      PACKING_LIST                     = GT_PACKLIST
*     OBJECT_HEADER                    =
*     CONTENTS_BIN                     =
      CONTENTS_TXT                     = GT_CONT_TXT
*     CONTENTS_HEX                     =
*     OBJECT_PARA                      =
*     OBJECT_PARB                      =
      RECEIVERS                        = GT_RECEIVER
*     ET_VSI_ERROR                     =
   EXCEPTIONS
     TOO_MANY_RECEIVERS               = 1
     DOCUMENT_NOT_SENT                = 2
     DOCUMENT_TYPE_NOT_EXIST          = 3
     OPERATION_NO_AUTHORIZATION       = 4
     PARAMETER_ERROR                  = 5
     X_ERROR                          = 6
     ENQUEUE_ERROR                    = 7
     OTHERS                           = 8
            .
  IF SY-SUBRC < > 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  SET_DOC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  < --  p2        text
*----------------------------------------------------------------------*
FORM SET_DOC_DATA .
  CLEAR: GS_DOC_DATA, GV_OUTBOX, GV_COMMIT_FLG,
         GV_SENDER, GV_SENDER_TYPE.

  GV_OUTBOX = 'X'.
  GV_COMMIT_FLG = 'X'.
*  GV_SENDER = ''.
*  GV_SENDER_TYPE = 'INT'.

  GS_DOC_DATA-OBJ_NAME   = '[TEST]'.
  GS_DOC_DATA-OBJ_DESCR  = 'TEST_MAIL'.
  GS_DOC_DATA-OBJ_LANGU  = '3'.
  GS_DOC_DATA-SENSITIVTY = '0'.
  GS_DOC_DATA-OBJ_PRIO   = '1'.
  GS_DOC_DATA-NO_CHANGE  = 'X'.
  GS_DOC_DATA-PRIORITY   = '1'.
ENDFORM.                    " SET_DOC_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_CONTENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  < --  p2        text
*----------------------------------------------------------------------*
FORM SET_CONTENTS .
  DATA: LV_LINES TYPE SO_BD_NUM.

  DATA: BEGIN OF LS_MAILL_ADDR,
    MAIL_ADDR TYPE CHAR255,
        END OF LS_MAILL_ADDR,
  LT_MAILL_ADDR LIKE TABLE OF LS_MAILL_ADDR.

  CLEAR: GS_PACKLIST, GT_PACKLIST, GS_RECEIVER, GT_RECEIVER, LV_LINES.

  "*** Set contents lines text .
  PERFORM SET_CONT_TXT. " 메일 내용 입력

  DESCRIBE TABLE GT_CONT_TXT LINES LV_LINES.
*  gt_pack_list-transf_bin  = 'X'.
  GS_PACKLIST-HEAD_START  = 1.
  GS_PACKLIST-HEAD_NUM    = 1.
  GS_PACKLIST-BODY_START  = 1.
  GS_PACKLIST-BODY_NUM    = LV_LINES.
  GS_PACKLIST-OBJ_LANGU   = '3'.
  GS_PACKLIST-DOC_TYPE    = 'HTM'.
  GS_PACKLIST-DOC_SIZE    = LV_LINES * 255.
  APPEND GS_PACKLIST TO GT_PACKLIST.

  SPLIT GV_RECEIVER AT ';' INTO TABLE LT_MAILL_ADDR.
  IF LT_MAILL_ADDR IS NOT INITIAL.
    LOOP AT LT_MAILL_ADDR INTO LS_MAILL_ADDR.
      CLEAR: GS_RECEIVER.
      GS_RECEIVER-RECEIVER = LS_MAILL_ADDR-MAIL_ADDR.
      GS_RECEIVER-REC_TYPE = 'U'.
      GS_RECEIVER-EXPRESS = 'X'.
      APPEND GS_RECEIVER TO GT_RECEIVER.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " SET_CONTENTS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_CONT_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  < --  p2        text
*----------------------------------------------------------------------*
FORM SET_CONT_TXT .
  DATA: LV_CHAR(255) TYPE C.
  CLEAR: LV_CHAR, GS_CONT_TXT, GT_CONT_TXT.

 " HTML 입력은 tag기준으로... 라인 관계 없음.
  GS_CONT_TXT-LINE = '< html>< head>< /head>< body>< h2>< /h2>< br>< br>'.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ...  ... < /p> .
  CLEAR: LV_CHAR, GS_CONT_TXT.
  LV_CHAR = TEXT-C01.
  REPLACE '&1' WITH P_DATE INTO LV_CHAR.
  CONCATENATE TEXT-TPS
              LV_CHAR
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ...  ... < /p> .
  CLEAR: LV_CHAR, GS_CONT_TXT.
  CONCATENATE TEXT-TPS
              TEXT-C02
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ... &nbsp; ... < /p> .
  CLEAR: LV_CHAR, GS_CONT_TXT.
  CONCATENATE TEXT-TPS
              '&nbsp;'
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.


  "*********************** Set Table HTML .
  PERFORM SET_TABLE_TXT.
  "****************************************

  CLEAR: GS_CONT_TXT.
  GS_CONT_TXT-LINE = '< br>'.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ...  ... < /p> .
  CLEAR: LV_CHAR, GS_CONT_TXT.
  CONCATENATE TEXT-C03 '< br>'
              TEXT-TBL
              TEXT-C04 INTO LV_CHAR.
  CONCATENATE TEXT-TPS
              LV_CHAR
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ...  ... < /p> .
  CLEAR: GS_CONT_TXT.
  CONCATENATE TEXT-TPS
              TEXT-C05
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  "< p> ...  ... < /p> .
  CLEAR: GS_CONT_TXT.
  CONCATENATE TEXT-TPS
              TEXT-TBL
              TEXT-C06
              '< /p>' INTO GS_CONT_TXT-LINE.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.

  CLEAR: GS_CONT_TXT.
  GS_CONT_TXT-LINE = '< /body>< /html>'.
  APPEND GS_CONT_TXT TO GT_CONT_TXT.
ENDFORM.                    " SET_CONT_TXT
