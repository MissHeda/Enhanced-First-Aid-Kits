#define IDD_POUCH               8800
#define IDC_KIT_SWITCH          8801
#define IDC_LIST_INVENTORY      8802
#define IDC_LIST_KIT            8803
#define IDC_CAPACITY_TEXT       8804
#define IDC_BUTTON_CLOSE        8806
#define IDC_BUTTON_UNPACKALL    8807
#define IDC_BUTTON_TO_KIT       8808
#define IDC_BUTTON_TO_INVENTORY 8809
#define IDC_TAB_INVENTORY       8810
#define IDC_HEADER_KIT          8811
#define IDC_HINT                8812
#define IDC_BACKGROUND          8813
#define IDC_LOAD_TEXT           8815
#define IDC_LIST_GROUND         8816
#define IDC_HEADER_GROUND       8817
#define IDC_TAB_CRATE           8819
#define IDC_BUTTON_PACKALL      8820
#define IDC_BG_SOURCE           8821
#define IDC_BG_KIT              8822
#define IDC_SEARCH              8823
#define IDC_SORT                8824
#define IDC_SORT_DIR            8825
#define IDC_AMOUNT              8826
#define IDC_SHOW_ALL            8827
#define IDC_SHOW_ALL_LABEL      8828
#define IDC_TAKE_INTO           8829
#define IDC_TAKE_INTO_LABEL     8830
// The row along the bottom: the ground and what the player wears. The ground column keeps the ground
// list and its header above.
#define IDC_PREVIEW_HEADER_UNIFORM  8831
#define IDC_PREVIEW_HEADER_VEST     8832
#define IDC_PREVIEW_HEADER_BACKPACK 8833
#define IDC_PREVIEW_LIST_UNIFORM    8837
#define IDC_PREVIEW_LIST_VEST       8838
#define IDC_PREVIEW_LIST_BACKPACK   8839
// How many items the current drag carries, next to the mouse
#define IDC_DRAG_COUNT              8841
// "Search" in the empty search field, the words on the two tabs, the icons that change
#define IDC_SEARCH_PLACEHOLDER      8842
#define IDC_TAB_INVENTORY_LABEL     8843
#define IDC_TAB_CRATE_LABEL         8844
#define IDC_SORT_DIR_ICON           8845
#define IDC_SHOW_ALL_ICON           8846
#define IDC_HEADER_KIT_COUNT        8847
// The kit's picture in the switcher and over the kit list, the amounts next to the two meters
#define IDC_KIT_SWITCH_PICTURE      8848
#define IDC_HEADER_KIT_PICTURE      8849
#define IDC_LOAD_VALUE              8860
#define IDC_CAPACITY_VALUE          8861
// The cards along the bottom: what is worn, as a picture, and how full it is
#define IDC_PREVIEW_PICTURE_GROUND   8862
#define IDC_PREVIEW_PICTURE_UNIFORM  8863
#define IDC_PREVIEW_PICTURE_VEST     8864
#define IDC_PREVIEW_PICTURE_BACKPACK 8865
#define IDC_PREVIEW_VALUE_GROUND     8866
#define IDC_PREVIEW_VALUE_UNIFORM    8867
#define IDC_PREVIEW_VALUE_VEST       8868
#define IDC_PREVIEW_VALUE_BACKPACK   8869

// The contents window, see RscContents.hpp
#define IDD_CONTENTS            8850
#define IDC_CONTENTS_PICTURE    8851
#define IDC_CONTENTS_TITLE      8852
#define IDC_CONTENTS_CAPACITY   8853
#define IDC_CONTENTS_LIST       8854
#define IDC_CONTENTS_TAKE       8855
#define IDC_CONTENTS_CLOSE      8856
#define PREVIEW_LIST_IDCS IDC_PREVIEW_LIST_UNIFORM, IDC_PREVIEW_LIST_VEST, IDC_PREVIEW_LIST_BACKPACK

// Sort keys, in the order they appear in the sort box
#define SORT_NAME   0
#define SORT_MASS   1
#define SORT_AMOUNT 2

// DIK codes the dialog tracks itself - no command reports whether a key is being held
#define DIK_ESCAPE      1
#define DIK_LCONTROL    29
#define DIK_RCONTROL    157
#define DIK_LSHIFT      42
#define DIK_RSHIFT      54
#define DIK_RETURN      28
#define DIK_NUMPADENTER 156

// A double click this soon after a Ctrl/Shift move is the tail end of fast modifier clicking,
// not a request for one more item.
#define MODIFIER_GRACE 0.5

// ---------------------------------------------------------------------------
// Palette. Every colour once, as the numbers, then as a config array {..} and an SQF array [..], so the
// windows and the code that recolours them can never drift apart.
//
// The windows are dark glass, as Arma's own are: the world shows through them a little. What lies on
// a window - cards, fields, buttons - is a light film over the glass rather than a colour of its own,
// so it stays see-through as well and every layer shows as a step brighter. Drop down menus cover
// what is under them and are nearly solid.
// ---------------------------------------------------------------------------
#define RGBA_CLEAR        0, 0, 0, 0
#define RGBA_DIM          0, 0, 0, 0.35
#define RGBA_WINDOW       0.04, 0.045, 0.055, 0.78
#define RGBA_CARD         1, 1, 1, 0.035
#define RGBA_FIELD        1, 1, 1, 0.06
#define RGBA_FIELD_HOVER  1, 1, 1, 0.1
#define RGBA_RAISED       1, 1, 1, 0.15
#define RGBA_MENU         0.075, 0.083, 0.1, 0.97
#define RGBA_MENU_EDGE    1, 1, 1, 0.14
#define RGBA_THUMB        1, 1, 1, 0.28
#define RGBA_LINE         1, 1, 1, 0.07
#define RGBA_TEXT         0.925, 0.933, 0.949, 1
#define RGBA_TEXT2        0.639, 0.675, 0.725, 1
#define RGBA_MUTED        0.412, 0.443, 0.494, 1
#define RGBA_ACCENT       0.961, 0.647, 0.141, 1
#define RGBA_ACCENT_HOVER 1, 0.733, 0.290, 1
#define RGBA_ACCENT_SOFT  0.961, 0.647, 0.141, 0.22
#define RGBA_ON_ACCENT    0.086, 0.094, 0.114, 1
#define RGBA_GAIN         0.298, 0.765, 0.541, 1
#define RGBA_LOSS         0.941, 0.333, 0.353, 1
#define RGBA_INFO         0.294, 0.612, 0.961, 1

#define C_CLEAR        {RGBA_CLEAR}
#define C_DIM          {RGBA_DIM}
#define C_WINDOW       {RGBA_WINDOW}
#define C_CARD         {RGBA_CARD}
#define C_FIELD        {RGBA_FIELD}
#define C_FIELD_HOVER  {RGBA_FIELD_HOVER}
#define C_RAISED       {RGBA_RAISED}
#define C_LINE         {RGBA_LINE}
#define C_TEXT         {RGBA_TEXT}
#define C_TEXT2        {RGBA_TEXT2}
#define C_MUTED        {RGBA_MUTED}
#define C_ACCENT       {RGBA_ACCENT}
#define C_ACCENT_SOFT  {RGBA_ACCENT_SOFT}
#define C_ON_ACCENT    {RGBA_ON_ACCENT}
#define C_GAIN         {RGBA_GAIN}
#define C_INFO         {RGBA_INFO}
#define C_THUMB        {RGBA_THUMB}

#define S_CLEAR        [RGBA_CLEAR]
#define S_WINDOW       [RGBA_WINDOW]
#define S_CARD         [RGBA_CARD]
#define S_FIELD        [RGBA_FIELD]
#define S_FIELD_HOVER  [RGBA_FIELD_HOVER]
#define S_RAISED       [RGBA_RAISED]
#define S_TEXT         [RGBA_TEXT]
#define S_TEXT2        [RGBA_TEXT2]
#define S_MUTED        [RGBA_MUTED]
#define S_ACCENT       [RGBA_ACCENT]
#define S_ACCENT_HOVER [RGBA_ACCENT_HOVER]
#define S_ON_ACCENT    [RGBA_ON_ACCENT]
#define S_GAIN         [RGBA_GAIN]
#define S_LOSS         [RGBA_LOSS]
#define S_INFO         [RGBA_INFO]

// A drop down menu's surface, and its edge, drawn a pixel outside it
#define S_MENU         [RGBA_MENU]
#define S_MENU_EDGE    [RGBA_MENU_EDGE]

// The same as text markup, for structured text.
#define HEX_TEXT   "#ECEEF2"
#define HEX_TEXT2  "#A3ACB9"
#define HEX_MUTED  "#69717E"
#define HEX_ACCENT "#F5A524"

// Put in front of an item's name in a list: the engine draws the name right against the picture.
#define LIST_NAME_GAP " "

// The columns of the item lists: the name; the change since the window opened, right-aligned against
// the count; the count, right-aligned at the edge. As fractions of the list's width - which the engine
// takes as the width less its scroll bar while there is one. See fnc_fillList.
#define LIST_COLUMNS         {0, 0.6, 0.925}
#define LIST_CHANGE_END      0.925
#define PREVIEW_COLUMNS      {0, 0.5, 0.87}
#define PREVIEW_CHANGE_END   0.87
// What a list's scroll bar takes of its width, near enough, for how long a name may be - measured in
// the game, about half a row whatever the list's width.
#define LIST_SCROLL_W        (ROW * 0.6)

// After the count in the contents window's list, for the same reason - that list has no columns.
#define LIST_COUNT_PAD "   "

// Row colours: the name in the text colour, the count in the accent colour
#define COLOR_NAME   S_TEXT
#define COLOR_COUNT  S_ACCENT
#define COLOR_GREYED [1, 1, 1, 0.3]

// What a list gained and lost since the window was opened
#define COLOR_GAIN  S_GAIN
#define COLOR_LOSS  S_LOSS

// Button states, see fnc_paintButton
#define BUTTON_NORMAL   0
#define BUTTON_HOVER    1
#define BUTTON_ACTIVE   2
#define BUTTON_DISABLED 3

// Textures, drawn by tools/generate_ui_textures.py
#define UI_TEX(NAME) QPATHTOF(ui\NAME.paa)

// How fnc_fillList judges the rows of a list
#define ROWS_KIT        0   // the kit: everything can be taken out
#define ROWS_SOURCE     1   // the left list: only what may go into the kit
#define ROWS_CONTAINER  2   // uniform, vest, backpack: only what arrived there while the window is open
#define ROWS_GROUND     3   // the ground: everything can be picked up again

// Items put on the ground go into one weapon holder for as long as the window is open, as long as
// it is still this close to the player - a new one at the player's feet, or the pile the player
// looked into, which counts as far off as the second tab's crate does (efak_core_fnc_getNearbyContainer).
#define GROUND_RANGE 3
#define GROUND_KEEP_RANGE 6

// Masses are decimals: three bandages at 0.4 must still fit into 1.2 of space.
#define MASS_EPSILON 0.0001

// Kit data index, mirrors addons/core/script_component.hpp
#define KIT_BACKGROUND 8

// What the left list is currently showing
#define SOURCE_INVENTORY 0
#define SOURCE_CRATE     1

// How much of a stack a single transfer moves
#define AMOUNT_ALL   -1
#define AMOUNT_HALF  -2

// A bar's colour by how full it is: its own colour, amber from 85 %, red when full. See fnc_setBar.
#define LEVEL_WARN 0.85
#define LEVEL_FULL 0.999

// ---------------------------------------------------------------------------
// Kit window geometry, relative to the safezone so it scales with the UI size.
//
// The window takes most of the screen height: the row height decides how many items the lists show
// at once. Its width follows the height too, so it looks the same on 4:3, 16:9 and ultra wide screens -
// narrower only where the screen is. It is laid out on a grid of 37 rows and 24 columns and ends at
// 36 rows:
//
//    0.00 -  2.90  header: kit picture and switcher, search, sort, close
//    3.35 -  4.85  section row: inventory / crate tabs over the left list, the kit's label over the right
//    5.25 - 23.25  the two lists as cards, the buttons between them
//   23.70 - 25.15  what each side holds, as words and a bar
//   26.10 - 33.20  ground, uniform, vest and backpack as cards, as far from the bars as from the
//                  line over the hint
//   34.15 - 36.00  the hint, under a line like the header's
// ---------------------------------------------------------------------------
#define POUCH_W ((SQUARE(safezoneH * 1.1)) min (safezoneW * 0.96))
#define POUCH_H (0.95 * safezoneH)
#define POUCH_VISIBLE_H (ROW * 36)
#define POUCH_X (safezoneX + (safezoneW - POUCH_W) / 2)
#define POUCH_Y (safezoneY + (safezoneH - POUCH_VISIBLE_H) / 2)

#define ROW (POUCH_H / 37)
#define COL (POUCH_W / 24)
#define PAD (COL / 2)

// The width of something square that is H high, whatever the screen's shape.
#define SQUARE(H) ((H) * pixelW / pixelH)

// On the screen's pixels: an edge on the nearest one, a length in whole ones. Panels are see-through,
// so their pieces must meet exactly - an overlap would show as a darker line, a gap as a lighter one.
#define SNAP_X(V) (safezoneX + round(((V) - safezoneX) / pixelW) * pixelW)
#define SNAP_Y(V) (safezoneY + round(((V) - safezoneY) / pixelH) * pixelH)
#define SNAP_W(V) (floor((V) / pixelW) * pixelW)
#define SNAP_H(V) (floor((V) / pixelH) * pixelH)

// Corner radii
#define RADIUS_WINDOW (ROW * 0.6)
#define RADIUS_CARD   (ROW * 0.45)
#define RADIUS_FIELD  (ROW * 0.42)

// Header
#define HEAD_Y       (POUCH_Y + ROW * 0.65)
#define HEAD_H       (ROW * 1.6)
#define HEAD_LINE_Y  (POUCH_Y + ROW * 2.9)
// The kit switcher on the left, the search in the middle of the window, and on the right sort, its
// direction and close - three fields the same distance apart.
#define HEAD_GAP     (COL * 0.2)
#define CLOSE_X      (POUCH_X + POUCH_W - PAD - SQUARE(HEAD_H))
#define SORT_DIR_X   (CLOSE_X - HEAD_GAP - SQUARE(HEAD_H))
#define SORT_W       (COL * 3.6)
#define SORT_X       (SORT_DIR_X - HEAD_GAP - SORT_W)
#define SEARCH_W     (COL * 6.8)
#define SEARCH_X     (POUCH_X + (POUCH_W - SEARCH_W) / 2)

// The kit switcher: a field from the window's edge to near the search, as wide as the menu it opens.
#define KIT_SWITCH_X     (POUCH_X + PAD)
#define KIT_SWITCH_W     (COL * 7.5)
#define KIT_SWITCH_PIC_H (ROW * 1.25)
#define KIT_SWITCH_TEXT  (ROW * 0.98)
#define KIT_SWITCH_ICON  (ROW * 0.7)
#define KIT_SWITCH_GAP   (SQUARE(ROW * 0.35))
// Section row
#define SECTION_Y (POUCH_Y + ROW * 3.35)
#define SECTION_H (ROW * 1.5)
#define TAB_INSET (ROW * 0.14)
#define TAB_W     ((LIST_W - SQUARE(TAB_INSET) * 2) / 2)

// The two lists and the column between them
#define LIST_W       (COL * 9.8)
#define LIST_H       (ROW * 18)
#define LIST_Y       (POUCH_Y + ROW * 5.25)
#define LIST_RIGHT_X (POUCH_X + PAD + LIST_W + COL * 3.4)
#define CARD_IN_X    (COL * 0.2)
#define LIST_IN_X    (COL * 0.13)
#define CARD_IN_Y    (ROW * 0.3)
#define LIST_ROW     (ROW * 1.15)
#define LIST_TEXT    (ROW * 0.78)
#define MID_X        (POUCH_X + PAD + LIST_W + COL * 0.3)
#define MID_W        (COL * 2.8)
#define MID_C        (LIST_Y + LIST_H / 2)
#define MID_BUTTON_H (ROW * 1.7)
#define MID_ICON_H   (ROW * 0.95)

// What each side holds, under the lists
#define METER_Y     (LIST_Y + LIST_H + ROW * 0.45)
#define METER_H     (ROW * 1.0)
#define METER_BAR_Y (METER_Y + ROW * 1.1)
#define METER_BAR_H (ROW * 0.35)
#define METER_TEXT  (ROW * 0.72)

// The bottom row: ground, uniform, vest, backpack
#define FULL_W          (POUCH_W - PAD * 2)
#define PREVIEW_Y       (POUCH_Y + ROW * 26.1)
#define PREVIEW_H       (ROW * 7.1)
#define PREVIEW_GAP     (COL * 0.3)
#define PREVIEW_W       ((FULL_W - PREVIEW_GAP * 3) / 4)
#define PREVIEW_X(N)    (POUCH_X + PAD + (N) * (PREVIEW_W + PREVIEW_GAP))
#define PREVIEW_HEAD_Y  (PREVIEW_Y + ROW * 0.05)
#define PREVIEW_HEAD_H  (ROW * 1.35)
#define PREVIEW_PIC_H   (ROW * 0.92)
#define PREVIEW_IN_X(N) (PREVIEW_X(N) + CARD_IN_X * 2)
#define PREVIEW_IN_W    (PREVIEW_W - CARD_IN_X * 4)
#define PREVIEW_BAR_Y   (PREVIEW_Y + ROW * 1.45)
#define PREVIEW_BAR_H   (ROW * 0.22)
#define PREVIEW_LIST_Y  (PREVIEW_Y + ROW * 1.85)
#define PREVIEW_LIST_H  (PREVIEW_Y + PREVIEW_H - PREVIEW_LIST_Y - ROW * 0.2)

// The hint along the bottom of the window, under a line
#define HINT_Y   (POUCH_Y + ROW * 34.15)
#define HINT_H   (ROW * 1.85)

// The scroll bars and the selection of the item lists, drawn by fnc_updateLists: the engine's own
// stop short of the ends and cut the selection off before the count. The thumb runs in the strip the
// engine keeps for its scroll bar, from the top of the card to its bottom.
#define THUMB_W       (ROW * 0.2)
#define THUMB_INSET   (ROW * 0.14)
#define THUMB_END     (ROW * 0.16)
#define THUMB_MIN_H   (ROW * 1.2)
#define SELECT_RADIUS (ROW * 0.3)
#define SELECT_GAP    (ROW * 0.16)

// Drop down menus (fnc_openMenu): a row per choice, eight at most before the menu scrolls.
#define MENU_ROWS       8
#define MENU_ROW_H      (ROW * 1.3)
#define MENU_PAD        (ROW * 0.25)
#define MENU_GAP        (ROW * 0.2)
#define MENU_RADIUS     (ROW * 0.42)
#define MENU_ROW_RADIUS (ROW * 0.3)
#define MENU_PIC_H      (ROW * 0.95)
#define MENU_TEXT       (ROW * 0.78)
#define MENU_CHECK_H    (ROW * 0.62)
#define MENU_SCROLL_W   0.006

// ---------------------------------------------------------------------------
// The contents window: a column at the right edge, centred on the height.
//
//   0.60 -  3.40  kit picture, name and how full it is, close
//   3.75 -  4.10  the fill bar
//   4.55 - 20.25  the list as a card
//  20.75 - 22.45  Take
// ---------------------------------------------------------------------------
#define POPUP_ROW       (safezoneH / 40)
#define POPUP_PAD       (POPUP_ROW * 0.6)
#define POPUP_W         ((SQUARE(POPUP_ROW * 14.9)) min (safezoneW * 0.4))
#define POPUP_H         (POPUP_ROW * 23.05)
#define POPUP_X         (safezoneX + safezoneW - POPUP_W - SQUARE(POPUP_ROW * 1.4))
#define POPUP_Y         (safezoneY + (safezoneH - POPUP_H) / 2)
#define POPUP_IN_X      (SQUARE(POPUP_PAD))
#define POPUP_HEAD_H    (POPUP_ROW * 2.8)
#define POPUP_NAME_H    (POPUP_ROW * 1.35)
#define POPUP_INFO_H    (POPUP_ROW * 0.95)
#define POPUP_NAME_Y    (POPUP_Y + POPUP_ROW * 0.6 + (POPUP_HEAD_H - POPUP_NAME_H - POPUP_INFO_H) / 2)
#define POPUP_CLOSE_H   (POPUP_ROW * 1.4)
#define POPUP_BAR_Y     (POPUP_Y + POPUP_ROW * 3.75)
#define POPUP_BAR_H     (POPUP_ROW * 0.35)
#define POPUP_LIST_Y    (POPUP_Y + POPUP_ROW * 4.55)
#define POPUP_LIST_H    (POPUP_ROW * 15.7)
#define POPUP_BUTTON_Y  (POPUP_Y + POPUP_ROW * 20.75)
#define POPUP_BUTTON_H  (POPUP_ROW * 1.7)
