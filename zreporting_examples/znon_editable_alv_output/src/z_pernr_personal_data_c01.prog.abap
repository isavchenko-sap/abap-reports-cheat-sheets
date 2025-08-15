*&---------------------------------------------------------------------*
*& Include          Z_PERNR_PERSONAL_DATA_C01
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION FINAL.
  PUBLIC SECTION.
    DATA:
      mt_pernrs TYPE RANGE OF pernr_d.

    METHODS:
      constructor
        IMPORTING it_pernrs TYPE ANY TABLE,
      read_data,
      show_alv.

    DATA:
      mt_personal_data TYPE p0002_tab.

ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    mt_pernrs = it_pernrs.
  ENDMETHOD.

  METHOD read_data.

    SELECT * FROM pa0002 INTO CORRESPONDING FIELDS OF TABLE @mt_personal_data
      WHERE pernr IN @mt_pernrs.

  ENDMETHOD.

  METHOD show_alv.

    DATA(lo_alv) =
      NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen ).

    DATA(lv_structure_name) =
      CONV dd02l-tabname(
        cl_abap_tabledescr=>describe_by_data( mt_personal_data )->get_ddic_header( )-refname ).

    lo_alv->set_table_for_first_display(
      EXPORTING
        i_structure_name = lv_structure_name
      CHANGING
        it_outtab        = mt_personal_data ).

    WRITE space.

  ENDMETHOD.
ENDCLASS.