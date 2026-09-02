#define IDD_POUCH               8800
#define IDC_TITLE               8801
#define IDC_LIST_INVENTORY      8802
#define IDC_LIST_KIT            8803
#define IDC_CAPACITY_TEXT       8804
#define IDC_CAPACITY_BAR        8805
#define IDC_BUTTON_CLOSE        8806
#define IDC_BUTTON_UNPACKALL    8807
#define IDC_BUTTON_TO_KIT       8808
#define IDC_BUTTON_TO_INVENTORY 8809
#define IDC_HEADER_INVENTORY    8810
#define IDC_HEADER_KIT          8811
#define IDC_HINT                8812
#define IDC_BACKGROUND          8813

// How much of a stack a single transfer moves
#define AMOUNT_ALL   -1
#define AMOUNT_HALF  -2

// Dialog geometry, relative to the safezone so it scales with the UI size
#define POUCH_W (0.58 * safezoneW)
#define POUCH_H (0.60 * safezoneH)
#define POUCH_X (safezoneX + (safezoneW - POUCH_W) / 2)
#define POUCH_Y (safezoneY + (safezoneH - POUCH_H) / 2)

#define ROW (POUCH_H / 24)
#define COL (POUCH_W / 24)
#define PAD (COL / 2)

#define LIST_W (COL * 10)
#define LIST_H (ROW * 15)
#define LIST_Y (POUCH_Y + ROW * 4)
