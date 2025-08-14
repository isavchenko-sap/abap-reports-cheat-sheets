# zreporting_basics

This section provides **core patterns and detailed explanations** for building classic ABAP reports.  
It covers the full report lifecycle, selection screen patterns, input validation techniques, and modularization approaches.

---

## 1. Report Skeleton & Event Flow

Classic ABAP reports are event-driven. The main events you will use:

| Event | Purpose |
|-------|---------|
| **INITIALIZATION** | Before the selection screen is displayed — set default values. |
| **AT SELECTION-SCREEN OUTPUT** | Manipulate the selection screen before it is rendered (hide/show fields, change attributes). |
| **AT SELECTION-SCREEN [ON …]** | Validate inputs or handle field-specific events (F1/F4). |
| **START-OF-SELECTION** | Main logic execution after inputs have been validated. |
| **END-OF-SELECTION** | Finalize logic; mostly used in logical database reports. |

**Minimal skeleton:**
```abap
REPORT z_demo_report.

INITIALIZATION.
  " Set default values here if it's needed

AT SELECTION-SCREEN OUTPUT.
  " Dynamically modify screen layout if it's needed

AT SELECTION-SCREEN ON p_param.
  " Validate single field if it's needed

START-OF-SELECTION.
  " Main program logic

END-OF-SELECTION.
  " Final output or cleanup if it's needed
```

---

## 2. Selection Screen Patterns

### 2.1 PARAMETERS
Used for single-value input fields.

**Syntax:**
```abap
PARAMETERS p_name  TYPE c LENGTH 10.
PARAMETERS p_pernr TYPE pernr_d.
PARAMETERS p_count TYPE int4.
```

**Options:**
- `LOWER CASE` — enable lowercase input.
- `OBLIGATORY` — mark the field as required.
- `DEFAULT` — set a pre-filled value.
- `AS CHECKBOX` — boolean-style input (`X` if checked, blank otherwise).
- `RADIOBUTTON GROUP grp` — group radio buttons for exclusive selection.

**Examples:**
```abap
PARAMETERS p_flag AS CHECKBOX.
PARAMETERS: p_opt1 RADIOBUTTON GROUP grp1,
            p_opt2 RADIOBUTTON GROUP grp1.
```

---

### 2.2 SELECT-OPTIONS
Ideal for ranges, multiple values, or complex selection logic.

**Syntax:**
```abap
SELECT-OPTIONS s_matnr FOR mara-matnr.
SELECT-OPTIONS s_pernr FOR gv_pernr.
```
Creates an internal table with:
- `SIGN` — Include/Exclude
- `OPTION` — EQ, NE, CP, etc.
- `LOW` / `HIGH` — value range

**Customization options:**
- `NO EXTENSION` — disables the multiple selection popup (F4).
- `NO INTERVALS` — hides the TO field, making it behave like a parameter.

---

### 2.3 Formatting Elements
Organize the layout visually using **SELECTION-SCREEN** statements:

```abap
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS p_bukrs TYPE bukrs.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN COMMENT /1(30) text-002.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP 1.
```

---

## 3. Input Validation Patterns

### 3.1 Using Events

- **INITIALIZATION** — set defaults, prepare dynamic screen values.
- **AT SELECTION-SCREEN** — validate or react to user input after pressing **Execute**.

**Field-specific validation:**
```abap
AT SELECTION-SCREEN ON p_bsart.
  IF p_bsart NE 'NB'.
    MESSAGE e398(00) WITH 'You must input NB for PR Type'.
  ENDIF.
```

**Custom F4 Help:**
```abap
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_matnr.
  lcl_screen_logic=>material_search_help( ).
```

**Custom F1 Help:**
```abap
AT SELECTION-SCREEN ON HELP-REQUEST FOR p_matnr.
  lcl_screen_logic=>material_help( ).
```

**Block-level validation:**
```abap
AT SELECTION-SCREEN ON BLOCK b1.
  " Validate multiple fields at once
```

**Radiobutton group validation:**
```abap
AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  " Ensure one selection is valid
```

---

### 3.2 Select-Options Specific Validation
You can validate ranges or individual entries:
```abap
AT SELECTION-SCREEN ON s_matnr.
  LOOP AT s_matnr ASSIGNING FIELD-SYMBOL(<ls_sel>).
    IF <ls_sel>-low IS INITIAL.
      MESSAGE e398(00) WITH 'Material number cannot be empty'.
    ENDIF.
  ENDLOOP.
```

---

### 3.3 Handling Obligatory Fields Dynamically
Instead of hardcoding `OBLIGATORY`, you can set fields as recommended (yellow) or required (red) dynamically:

```abap
LOOP AT SCREEN.
  IF screen-name = 'P_BUKRS'.
    screen-required = '2'. " 2 = recommended, 1 = required
  ENDIF.
  MODIFY SCREEN.
ENDLOOP.
```

Then enforce validation manually:
```abap
AT SELECTION-SCREEN ON p_bukrs.
  IF p_bukrs IS INITIAL.
    MESSAGE e398(00) WITH 'Company code is required'.
  ENDIF.
```

---

## 4. Modularization (FORMs, Local Classes, Constants/Structures)

### 4.1 FORM Subroutines (Classical)
Procedural “mini-programs” within a report.

**Example:**
```abap
FORM fetch_data.
  SELECT * FROM mara INTO TABLE @DATA(lt_mara) UP TO 100 ROWS.
ENDFORM.

START-OF-SELECTION.
  PERFORM fetch_data.
```

**When to use:**
- Legacy reports
- Very small procedural code
- Not recommended for new development unless minimal

---

### 4.2 Local Classes (Preferred)
Classes defined inside a report; encapsulate logic and keep it near where it’s used.

**Example:**
```abap
CLASS lcl_app DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS fetch_data
      RETURNING VALUE(rt_data) TYPE STANDARD TABLE OF mara.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD fetch_data.
    SELECT * FROM mara INTO TABLE rt_data UP TO 100 ROWS.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA(lt_data) = NEW lcl_app( )->fetch_data( ).
```

**Why use local classes:**
- Encapsulation
- Clear separation of concerns
- Testability
- SAP styleguides recommend OO for maintainability

---

### 4.3 Global Constants and Structures
Keep constants and type definitions at the top of the report.

**Example:**
```abap
TYPES: BEGIN OF ty_item,
         matnr TYPE matnr,
         maktx TYPE maktx,
       END OF ty_item.

CONSTANTS: c_true  TYPE abap_bool VALUE abap_true,
           c_false TYPE abap_bool VALUE abap_false.
```

---

## Summary

- Follow **event flow**: INITIALIZATION → AT SELECTION-SCREEN → START-OF-SELECTION → END-OF-SELECTION.
- Use **PARAMETERS** for single inputs and **SELECT-OPTIONS** for ranges.
- Validate inputs at the right event to avoid runtime errors.
- Prefer **local classes** over FORMs for new development.
- Keep constants and types defined at the top for clarity.
