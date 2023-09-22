*&---------------------------------------------------------------------*
*& Include
*&---------------------------------------------------------------------*
TYPE-POOLS: ICON, SLIS.
CLASS LCL_ALV DEFINITION DEFERRED.

*TABLES: ZFGLT0003.

*&---------------------------------------------------------------------*
*& TYPES.
*&---------------------------------------------------------------------*
TYPES: gty_err_fld TYPE char40.
TYPES: BEGIN OF gty_s_disp,
  sys_id      TYPE zfglt0003-sys_id,
  sys_nm      TYPE zfglt0002-sys_nm,
  categrp       TYPE zfglt0003-categrp,
  categrp_nm    TYPE zfglt0004-categrp_nm,
  category      TYPE zfglt0003-category,
  category_nm   TYPE zfglt0003-category_nm,
  subs_func     TYPE zfglt0003-subs_func,
  vali_func     TYPE zfglt0003-vali_func,
  post_pgm      TYPE zfglt0003-post_pgm,
  post_pgm_type TYPE zfglt0003-post_pgm_type,
  blart         TYPE zfglt0003-blart,
  real_if_fg  TYPE zfglt0003-real_if_fg,
  edit_flg,
  err_fld     TYPE TABLE OF gty_err_fld WITH DEFAULT KEY,
  style       TYPE lvc_t_styl,
  erdat       TYPE zfglt0003-erdat,
  erzet       TYPE zfglt0003-erzet,
  ernam       TYPE zfglt0003-ernam,
  aedat       TYPE zfglt0003-aedat,
  aezet       TYPE zfglt0003-aezet,
  aenam       TYPE zfglt0003-aenam,
       END OF gty_s_disp,
   gty_t_disp TYPE TABLE OF gty_s_disp WITH DEFAULT KEY.

*&---------------------------------------------------------------------*
*& Objects.
*&---------------------------------------------------------------------*
DATA: GO_GRID_01 TYPE REF TO LCL_ALV.

DATA: gt_disp TYPE gty_t_disp,
      go_disp TYPE REF TO DATA.


*&---------------------------------------------------------------------*
*& Screen.
*&---------------------------------------------------------------------*
DATA: GV_OKCODE TYPE SY-UCOMM,
      GV_OKCOPY TYPE SY-UCOMM.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
PARAMETERS: P_ONE RADIOBUTTON GROUP RB1 USER-COMMAND UCOMM,
            P_TWO RADIOBUTTON GROUP RB1,
            P_MAN RADIOBUTTON GROUP RB1,
            P_TOP RADIOBUTTON GROUP RB1,
            P_STE RADIOBUTTON GROUP RB1,
            P_CTE RADIOBUTTON GROUP RB1.
