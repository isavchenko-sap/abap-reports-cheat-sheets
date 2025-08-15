*&---------------------------------------------------------------------*
*& Include          Z_PERNR_PERSONAL_DATA_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK main_block WITH FRAME TITLE TEXT-sbl.
  SELECT-OPTIONS: so_pernr FOR gv_pernr OBLIGATORY NO INTERVALS MATCHCODE OBJECT prem.
SELECTION-SCREEN END OF BLOCK main_block.