#define IDD_POUCH               8800
#define IDC_KIT_SWITCH          8801
#define IDC_LIST_INVENTORY      8802
#define IDC_LIST_KIT            8803
#define IDC_CAPACITY_TEXT       8804
#define IDC_CAPACITY_BAR        8805
#define IDC_BUTTON_CLOSE        8806
#define IDC_BUTTON_UNPACKALL    8807
#define IDC_BUTTON_TO_KIT       8808
#define IDC_BUTTON_TO_INVENTORY 8809
#define IDC_TAB_INVENTORY       8810
#define IDC_HEADER_KIT          8811
#define IDC_HINT                8812
#define IDC_BACKGROUND          8813
#define IDC_LOAD_BAR            8814
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
#define IDC_PREVIEW_BAR_UNIFORM     8834
#define IDC_PREVIEW_BAR_VEST        8835
#define IDC_PREVIEW_BAR_BACKPACK    8836
#define IDC_PREVIEW_LIST_UNIFORM    8837
#define IDC_PREVIEW_LIST_VEST       8838
#define IDC_PREVIEW_LIST_BACKPACK   8839
#define IDC_PREVIEW_BAR_GROUND      8840
// How many items the current drag carries, next to the mouse
#define IDC_DRAG_COUNT              8841

// The contents window, see RscContents.hpp
#define IDD_CONTENTS            8850
#define IDC_CONTENTS_PICTURE    8851
#define IDC_CONTENTS_TITLE      8852
#define IDC_CONTENTS_BAR        8853
#define IDC_CONTENTS_LIST       8854
#define IDC_CONTENTS_TAKE       8855
#define IDC_CONTENTS_CLOSE      8856
#define PREVIEW_LIST_IDCS IDC_PREVIEW_LIST_UNIFORM, IDC_PREVIEW_LIST_VEST, IDC_PREVIEW_LIST_BACKPACK

// Sort keys, in the order they appear in the sort box
#define SORT_NAME   0
#define SORT_MASS   1
#define SORT_AMOUNT 2

// DIK codes the dialog tracks itself - no command reports whether a key is being held
#define DIK_LCONTROL    29
#define DIK_RCONTROL    157
#define DIK_LSHIFT      42
#define DIK_RSHIFT      54
#define DIK_RETURN      28
#define DIK_NUMPADENTER 156

// A double click this soon after a Ctrl/Shift move is the tail end of fast modifier clicking,
// not a request for one more item.
#define MODIFIER_GRACE 0.5

// Row colours: the name white, the count in the accent colour
#define COLOR_NAME  [1, 1, 1, 1]
#define COLOR_COUNT [1, 0.78, 0.3, 1]
#define COLOR_GREYED [1, 1, 1, 0.35]

// What a list gained and lost since the window was opened
#define COLOR_GAIN  [0.45, 0.85, 0.45, 1]
#define COLOR_LOSS  [1, 0.45, 0.35, 1]

// How fnc_fillList judges the rows of a list
#define ROWS_KIT        0   // the kit: everything can be taken out
#define ROWS_SOURCE     1   // the left list: only what may go into the kit
#define ROWS_CONTAINER  2   // uniform, vest, backpack: only what arrived there while the window is open
#define ROWS_GROUND     3   // the ground: everything can be picked up again

// Items put on the ground go into one weapon holder for as long as the window is open, as long as
// it is still this close to the player.
#define GROUND_RANGE 3

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

// Dialog geometry, relative to the safezone so it scales with the UI size.
//
// The row height is what decides how many items you can see at once, so the dialog is divided
// into many small rows and given most of the screen height rather than being kept compact: at
// 36 rows the lists show 18 entries instead of 10, with the text no smaller than before.
//
// The grid is laid over 95% of the screen height; the window itself ends half a row under the
// bottom line, where the hint and the Close button sit side by side, and is centred as it is.
#define POUCH_W (0.62 * safezoneW)
#define POUCH_H (0.95 * safezoneH)
#define POUCH_X (safezoneX + (safezoneW - POUCH_W) / 2)
#define POUCH_Y (safezoneY + (safezoneH - POUCH_VISIBLE_H) / 2)

#define ROW (POUCH_H / 37)
#define COL (POUCH_W / 24)
#define PAD (COL / 2)

#define LIST_ROW (ROW * 1.1)
#define LIST_TEXT (ROW * 0.8)

#define LIST_W (COL * 9.8)
#define LIST_H (ROW * 20)
#define LIST_Y (POUCH_Y + ROW * 3.7)
#define LIST_RIGHT_X (POUCH_X + PAD + LIST_W + COL * 3.4)
#define MID_X (POUCH_X + PAD + LIST_W + COL * 0.15)
#define MID_W (COL * 3.1)
#define MID_C (LIST_Y + LIST_H / 2)

// Top row: kit switcher, search, sort key, sort direction
#define TOP_Y (POUCH_Y + ROW * 0.55)
#define TOP_H (ROW * 1.2)

// The row under both lists, full width, because it is about where things end up rather than about
// either side of a move: the ground, then the uniform, the vest and the backpack, each in a column of
// its own.
#define GROUND_Y (POUCH_Y + ROW * 27.2)
#define GROUND_H (ROW * 5.9)
#define FULL_W (POUCH_W - PAD * 2)

#define PREVIEW_Y       (POUCH_Y + ROW * 25.8)
#define PREVIEW_GAP     (COL * 0.3)
#define PREVIEW_W       ((FULL_W - PREVIEW_GAP * 3) / 4)
#define PREVIEW_X(N)    (POUCH_X + PAD + (N) * (PREVIEW_W + PREVIEW_GAP))
#define PREVIEW_LIST_Y  (PREVIEW_Y + ROW * 1.5)
#define PREVIEW_LIST_H  (GROUND_Y + GROUND_H - PREVIEW_LIST_Y)

// The bottom line: the two lines of the hint on the left, the Close button on the right, centred on
// the same level. The window ends half a row under it, at 27.2 + 5.9 + 0.4 + 1.6 + 0.5 = 35.6 rows.
#define BOTTOM_Y        (GROUND_Y + GROUND_H + ROW * 0.4)
#define BOTTOM_H        (ROW * 1.6)
#define POUCH_VISIBLE_H (ROW * 35.6)

// The contents window: a narrow column at the right edge, centred on the height. Picture and name at
// the top, the fill bar under them, the list, and Open and Close at the bottom:
// 0.5 + 2.6 + 0.4 + 0.4 + 0.5 + 15 + 0.5 + 1.3 + 0.5 = 21.7 rows.
#define POPUP_ROW       (safezoneH / 40)
#define POPUP_PAD       (POPUP_ROW * 0.5)
#define POPUP_W         (0.2 * safezoneW)
#define POPUP_H         (POPUP_ROW * 21.7)
#define POPUP_X         (safezoneX + safezoneW - POPUP_W - 0.02 * safezoneW)
#define POPUP_Y         (safezoneY + (safezoneH - POPUP_H) / 2)
#define POPUP_BAR_Y     (POPUP_Y + POPUP_PAD + POPUP_ROW * 3)
#define POPUP_LIST_Y    (POPUP_BAR_Y + POPUP_ROW * 0.9)
#define POPUP_LIST_H    (POPUP_ROW * 15)
#define POPUP_BUTTON_Y  (POPUP_Y + POPUP_H - POPUP_PAD - POPUP_ROW * 1.3)
