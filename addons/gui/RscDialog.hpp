class RscText;
class RscStructuredText;
class RscListNBox;
class RscPicture;
class RscEdit;
class RscCheckBox;
class RscCombo;
class RscButtonMenu;
class RscButtonMenuCancel;
class RscProgress;
class RscFrame;

class EFAK_PouchDialog {
    idd = IDD_POUCH;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),_this select 0)]);
    onUnload = QUOTE(call FUNC(onPouchClosed));
    // Nothing reports whether a key is held, so the dialog keeps track of Ctrl and Shift itself.
    onKeyDown = QUOTE(_this call FUNC(onKeyDown));
    onKeyUp = QUOTE(_this call FUNC(onKeyUp));

    class ControlsBackground {
        class Background: RscText {
            idc = IDC_BACKGROUND;
            x = QUOTE(POUCH_X);
            y = QUOTE(POUCH_Y);
            w = QUOTE(POUCH_W);
            h = QUOTE(POUCH_VISIBLE_H);
            colorBackground[] = {0, 0, 0, 0.75};
        };

        // The dark boxes behind the lists, which draw none of their own.
        class ListBoxInventory: RscText {
            idc = -1;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y);
            w = QUOTE(LIST_W);
            h = QUOTE(LIST_H);
            colorBackground[] = {0, 0, 0, 0.4};
        };
        class ListBoxKit: ListBoxInventory {
            x = QUOTE(LIST_RIGHT_X);
        };
        class ListBoxGround: ListBoxInventory {
            x = QUOTE(PREVIEW_X(0));
            y = QUOTE(PREVIEW_LIST_Y);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(PREVIEW_LIST_H);
        };
        class ListBoxUniform: ListBoxGround {
            x = QUOTE(PREVIEW_X(1));
        };
        class ListBoxVest: ListBoxGround {
            x = QUOTE(PREVIEW_X(2));
        };
        class ListBoxBackpack: ListBoxGround {
            x = QUOTE(PREVIEW_X(3));
        };

        // Optional artwork behind the two lists - an open bag on the left, the opened kit on the
        // right. Both are empty by default and stay hidden until something is set.
        class BackgroundSource: RscPicture {
            idc = IDC_BG_SOURCE;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y);
            w = QUOTE(LIST_W);
            h = QUOTE(LIST_H);
        };

        class BackgroundKit: BackgroundSource {
            idc = IDC_BG_KIT;
            x = QUOTE(LIST_RIGHT_X);
        };

        class Border: RscFrame {
            idc = -1;
            x = QUOTE(POUCH_X);
            y = QUOTE(POUCH_Y);
            w = QUOTE(POUCH_W);
            h = QUOTE(POUCH_VISIBLE_H);
            colorText[] = {1, 1, 1, 0.25};
        };
    };

    class Controls {
        // Doubles as the title: every kit this window can reach - the player's own, those of the
        // casualty it was opened on and those in the crate. Picking one switches to it.
        class KitSwitch: RscCombo {
            idc = IDC_KIT_SWITCH;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(TOP_Y);
            w = QUOTE(COL * 8.5);
            h = QUOTE(TOP_H);
            sizeEx = QUOTE(ROW * 0.8);
            tooltip = CSTRING(KitSwitch_Tooltip);
            onLBSelChanged = QUOTE(_this call FUNC(onKitSwitchChanged));
        };

        // One search and one sort for every list - they are all the same kind of list, and a second
        // set would cost a row of list height.
        class Search: RscEdit {
            idc = IDC_SEARCH;
            x = QUOTE(POUCH_X + PAD + COL * 8.7);
            y = QUOTE(TOP_Y);
            w = QUOTE(COL * 6.6);
            h = QUOTE(TOP_H);
            sizeEx = QUOTE(ROW * 0.8);
            maxChars = 40;
            tooltip = CSTRING(Search_Tooltip);
            colorBackground[] = {0, 0, 0, 0.5};
            onEditChanged = QUOTE(_this call FUNC(onSearchChanged));
            onMouseButtonClick = QUOTE(_this call FUNC(onSearchClick));
        };

        class Sort: RscCombo {
            idc = IDC_SORT;
            x = QUOTE(POUCH_X + PAD + COL * 15.5);
            y = QUOTE(TOP_Y);
            w = QUOTE(COL * 4);
            h = QUOTE(TOP_H);
            sizeEx = QUOTE(ROW * 0.8);
            tooltip = CSTRING(Sort_Tooltip);
            onLBSelChanged = QUOTE(_this call FUNC(onSortChanged));
        };

        class SortDirection: Sort {
            idc = IDC_SORT_DIR;
            x = QUOTE(POUCH_X + PAD + COL * 19.7);
            w = QUOTE(COL * 3.3);
            tooltip = CSTRING(SortDirection_Tooltip);
        };

        // The left list has two sources - what you are carrying and, when you are standing at
        // one, the crate or vehicle in front of you. The tabs pick between them.
        class TabInventory: RscButtonMenu {
            idc = IDC_TAB_INVENTORY;
            text = CSTRING(Header_Inventory);
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(POUCH_Y + ROW * 2.1);
            w = QUOTE((LIST_W - COL * 0.2) / 2);
            h = QUOTE(ROW * 1.4);
            sizeEx = QUOTE(ROW * 0.8);
            onButtonClick = QUOTE([SOURCE_INVENTORY] call FUNC(selectSource));
            // The word in the middle of the tab, both ways.
            class TextPos {
                left = 0;
                top = QUOTE((ROW * 1.4 - ROW * 0.8) / 2);
                right = 0;
                bottom = 0;
            };
            class Attributes {
                font = "PuristaLight";
                color = "#E5E5E5";
                align = "center";
                shadow = "false";
            };
        };

        class TabCrate: TabInventory {
            idc = IDC_TAB_CRATE;
            text = CSTRING(Header_Crate);
            // Ends where the list ends.
            x = QUOTE(POUCH_X + PAD + (LIST_W + COL * 0.2) / 2);
            onButtonClick = QUOTE([SOURCE_CRATE] call FUNC(selectSource));
        };

        // Centred over the kit list, with the picture of the kit being edited - the same as the
        // containers along the bottom.
        class HeaderKit: RscStructuredText {
            idc = IDC_HEADER_KIT;
            x = QUOTE(LIST_RIGHT_X);
            y = QUOTE(POUCH_Y + ROW * 2.2);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 1.3);
            size = QUOTE(ROW * 0.8);
            colorBackground[] = {0, 0, 0, 0};
        };

        // Two columns: the name, and the change since the window opened in front of the count, which
        // sits right-aligned at the edge. Each in a colour of its own (fnc_fillList) - a plain list
        // has one colour for everything on the right. The engine drags rows of these like those of a
        // plain list; the multiplayer lobby's player pool is one. The dark box behind each list is a
        // control of its own (ControlsBackground): this kind of list draws none.
        class ListInventory: RscListNBox {
            idc = IDC_LIST_INVENTORY;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y);
            w = QUOTE(LIST_W);
            h = QUOTE(LIST_H);
            canDrag = 1;
            rowHeight = QUOTE(LIST_ROW);
            sizeEx = QUOTE(LIST_TEXT);
            columns[] = {0, 0.8};
            drawSideArrows = 0;
            idcLeft = -1;
            idcRight = -1;
            colorBackground[] = {0, 0, 0, 0};
            // A light bar rather than a white one, so white and amber stay readable on it.
            colorSelectBackground[] = {1, 1, 1, 0.18};
            colorSelectBackground2[] = {1, 1, 1, 0.18};
        };

        class ListKit: ListInventory {
            idc = IDC_LIST_KIT;
            x = QUOTE(LIST_RIGHT_X);
        };

        // Whether the left list also shows what cannot go into the kit. Off by default.
        class ShowAll: RscCheckBox {
            idc = IDC_SHOW_ALL;
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y);
            w = QUOTE(COL * 0.7);
            h = QUOTE(ROW * 1.2);
            tooltip = CSTRING(ShowAll_Tooltip);
            onCheckedChanged = QUOTE(GVAR(showAll) = (_this select 1) == 1; call FUNC(refreshPouch));
        };

        class ShowAllLabel: RscText {
            idc = IDC_SHOW_ALL_LABEL;
            text = CSTRING(ShowAll);
            tooltip = CSTRING(ShowAll_Tooltip);
            x = QUOTE(MID_X + COL * 0.75);
            y = QUOTE(LIST_Y);
            w = QUOTE(MID_W - COL * 0.75);
            h = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.75);
        };

        // The middle column, in the order things move: everything in, the selected stack in, how
        // much of it, the selected stack out, everything out.
        class ButtonPackAll: RscButtonMenu {
            idc = IDC_BUTTON_PACKALL;
            text = CSTRING(PackAll);
            tooltip = CSTRING(PackAll_Tooltip);
            x = QUOTE(MID_X);
            y = QUOTE(MID_C - ROW * 4.5);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.6);
            sizeEx = QUOTE(ROW * 1.1);
            onButtonClick = QUOTE(call FUNC(packAllPressed));
            // Arrows only, centred. A shortcut button aligns its label through this class, and
            // redefining it replaces the whole class, so the other values are the game's defaults.
            class Attributes {
                font = "RobotoCondensed";
                color = "#E5E5E5";
                align = "center";
                shadow = "true";
            };
            // Pushes the label down to the middle of the button - the default sits near the top.
            class TextPos {
                left = 0;
                top = QUOTE(ROW * 0.2);
                right = 0;
                bottom = 0;
            };
        };

        class ButtonToKit: ButtonPackAll {
            idc = IDC_BUTTON_TO_KIT;
            text = CSTRING(ToKit);
            tooltip = CSTRING(ToKit_Tooltip);
            y = QUOTE(MID_C - ROW * 2.6);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_INVENTORY,call FUNC(getAmount))] call FUNC(transferSelected));
        };

        // How many the two buttons above and below move. Empty means the whole stack.
        class Amount: RscEdit {
            idc = IDC_AMOUNT;
            style = 2;
            x = QUOTE(MID_X);
            y = QUOTE(MID_C - ROW * 0.7);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.4);
            sizeEx = QUOTE(ROW * 0.85);
            maxChars = 3;
            text = "1";
            tooltip = CSTRING(Amount_Tooltip);
            colorBackground[] = {0, 0, 0, 0.5};
            onEditChanged = QUOTE(_this call FUNC(onAmountChanged));
        };

        class ButtonToInventory: ButtonPackAll {
            idc = IDC_BUTTON_TO_INVENTORY;
            text = CSTRING(ToInventory);
            tooltip = CSTRING(ToInventory_Tooltip);
            y = QUOTE(MID_C + ROW * 1.0);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_KIT,call FUNC(getAmount))] call FUNC(transferSelected));
        };

        class ButtonUnpackAll: ButtonPackAll {
            idc = IDC_BUTTON_UNPACKALL;
            text = CSTRING(UnpackAll);
            tooltip = CSTRING(UnpackAll_Tooltip);
            y = QUOTE(MID_C + ROW * 2.9);
            onButtonClick = QUOTE(call FUNC(unpackAllPressed));
        };

        // Where items taken out of the kit go first. Under the buttons that take them out, level with
        // the bottom of the lists.
        class TakeIntoLabel: RscText {
            idc = IDC_TAKE_INTO_LABEL;
            style = 2;
            text = CSTRING(TakeInto);
            tooltip = CSTRING(TakeInto_Tooltip);
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y + LIST_H - ROW * 2.3);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.1);
            sizeEx = QUOTE(ROW * 0.7);
            colorText[] = {0.8, 0.8, 0.8, 1};
        };

        class TakeInto: RscCombo {
            idc = IDC_TAKE_INTO;
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y + LIST_H - ROW * 1.2);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.75);
            tooltip = CSTRING(TakeInto_Tooltip);
            onLBSelChanged = QUOTE(_this call FUNC(onTakeIntoChanged));
        };

        // The track behind the two bars under the lists. Without it an empty kit shows nothing at
        // all where its bar should be.
        class LoadBarTrack: RscText {
            idc = -1;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.25);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 0.45);
            colorBackground[] = {1, 1, 1, 0.08};
        };
        class CapacityBarTrack: LoadBarTrack {
            x = QUOTE(LIST_RIGHT_X);
        };

        class CapacityBar: RscProgress {
            idc = IDC_CAPACITY_BAR;
            x = QUOTE(LIST_RIGHT_X);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.25);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 0.45);
            colorBar[] = {0.35, 0.75, 0.4, 1};
            colorFrame[] = {1, 1, 1, 0.35};
        };

        class CapacityText: RscText {
            idc = IDC_CAPACITY_TEXT;
            x = QUOTE(LIST_RIGHT_X);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.85);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.75);
            colorText[] = {0.8, 0.8, 0.8, 1};
        };

        class LoadBar: RscProgress {
            idc = IDC_LOAD_BAR;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.25);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 0.45);
            colorBar[] = {0.35, 0.6, 0.85, 1};
            colorFrame[] = {1, 1, 1, 0.35};
        };

        class LoadText: RscText {
            idc = IDC_LOAD_TEXT;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.85);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.75);
            colorText[] = {0.8, 0.8, 0.8, 1};
        };

        // ----- The bottom row: ground, uniform, vest, backpack -----

        // Over each column, centred: the picture of the uniform, vest or backpack worn, and its name
        // with how full it is. Structured text, so picture and words centre as one.
        class HeaderGround: RscStructuredText {
            idc = IDC_HEADER_GROUND;
            x = QUOTE(PREVIEW_X(0));
            y = QUOTE(PREVIEW_Y);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(ROW * 1.1);
            size = QUOTE(ROW * 0.75);
            colorBackground[] = {0, 0, 0, 0};
        };
        class HeaderUniform: HeaderGround {
            idc = IDC_PREVIEW_HEADER_UNIFORM;
            x = QUOTE(PREVIEW_X(1));
        };
        class HeaderVest: HeaderGround {
            idc = IDC_PREVIEW_HEADER_VEST;
            x = QUOTE(PREVIEW_X(2));
        };
        class HeaderBackpack: HeaderGround {
            idc = IDC_PREVIEW_HEADER_BACKPACK;
            x = QUOTE(PREVIEW_X(3));
        };

        // How full each container is. The ground has no limit - its bar fills in the accent colour
        // once anything lies there, so it reads as a warning rather than a level.
        class BarGround: RscProgress {
            idc = IDC_PREVIEW_BAR_GROUND;
            x = QUOTE(PREVIEW_X(0));
            y = QUOTE(PREVIEW_Y + ROW * 1.1);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(ROW * 0.3);
            colorBar[] = {1, 0.72, 0.3, 1};
            colorFrame[] = {1, 1, 1, 0.35};
        };
        class BarUniform: RscProgress {
            idc = IDC_PREVIEW_BAR_UNIFORM;
            x = QUOTE(PREVIEW_X(1));
            y = QUOTE(PREVIEW_Y + ROW * 1.1);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(ROW * 0.3);
            colorBar[] = {0.35, 0.6, 0.85, 1};
            colorFrame[] = {1, 1, 1, 0.35};
        };
        class BarVest: BarUniform {
            idc = IDC_PREVIEW_BAR_VEST;
            x = QUOTE(PREVIEW_X(2));
        };
        class BarBackpack: BarUniform {
            idc = IDC_PREVIEW_BAR_BACKPACK;
            x = QUOTE(PREVIEW_X(3));
        };

        // Dropping a row here puts it on the ground at the player's feet; double clicking one puts it
        // back into the kit.
        class ListGround: ListInventory {
            idc = IDC_LIST_GROUND;
            x = QUOTE(PREVIEW_X(0));
            y = QUOTE(PREVIEW_LIST_Y);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(PREVIEW_LIST_H);
            rowHeight = QUOTE(LIST_ROW * 0.9);
            sizeEx = QUOTE(LIST_TEXT * 0.9);
            columns[] = {0, 0.66};
            // Rows along the bottom are dragged or double clicked, never picked: no selection bar,
            // and a clicked row keeps its colour (set per row as well, see fnc_fillList).
            colorSelectBackground[] = {0, 0, 0, 0};
            colorSelectBackground2[] = {0, 0, 0, 0};
            colorSelect[] = {1, 1, 1, 1};
            colorSelect2[] = {1, 1, 1, 1};
        };
        // A kit stack dropped here goes into this container; what arrived here while the window is
        // open can be dragged on to another container, the ground or back into the kit. The player's
        // own gear stays put.
        class ListUniform: ListGround {
            idc = IDC_PREVIEW_LIST_UNIFORM;
            x = QUOTE(PREVIEW_X(1));
        };
        class ListVest: ListUniform {
            idc = IDC_PREVIEW_LIST_VEST;
            x = QUOTE(PREVIEW_X(2));
        };
        class ListBackpack: ListUniform {
            idc = IDC_PREVIEW_LIST_BACKPACK;
            x = QUOTE(PREVIEW_X(3));
        };

        // The controls in short, or what just happened. The tooltip explains the controls in full.
        class Hint: RscStructuredText {
            idc = IDC_HINT;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(BOTTOM_Y);
            w = QUOTE(PREVIEW_X(3) - PREVIEW_GAP - POUCH_X - PAD);
            h = QUOTE(BOTTOM_H);
            size = QUOTE(ROW * 0.64);
            colorBackground[] = {0, 0, 0, 0};
            class Attributes {
                font = "RobotoCondensed";
                color = "#B3B3B3";
                align = "left";
                valign = "middle";
                shadow = 0;
            };
        };

        // Every move takes effect the moment it is made, so there is nothing to confirm or cancel -
        // only a way out. Escape does the same.
        class ButtonClose: RscButtonMenuCancel {
            idc = IDC_BUTTON_CLOSE;
            text = CSTRING(Close);
            onButtonClick = QUOTE(closeDialog 0);
            // Lined up with the backpack column above it.
            x = QUOTE(PREVIEW_X(3));
            y = QUOTE(BOTTOM_Y + ROW * 0.1);
            w = QUOTE(PREVIEW_W);
            h = QUOTE(ROW * 1.4);
            sizeEx = QUOTE(ROW * 0.8);
            // The word in the middle of the button, both ways.
            class TextPos {
                left = 0;
                top = QUOTE((ROW * 1.4 - ROW * 0.8) / 2);
                right = 0;
                bottom = 0;
            };
            class Attributes {
                font = "PuristaLight";
                color = "#E5E5E5";
                align = "center";
                shadow = "false";
            };
        };

        // How many items the current drag carries, next to the mouse. Hidden until a drag starts.
        class DragCount: RscStructuredText {
            idc = IDC_DRAG_COUNT;
            x = 0;
            y = 0;
            w = QUOTE(COL * 1.6);
            h = QUOTE(ROW * 0.9);
            size = QUOTE(ROW * 0.62);
            colorBackground[] = {0, 0, 0, 0};
            class Attributes {
                font = "RobotoCondensedBold";
                color = "#FFFFFF";
                align = "center";
                valign = "middle";
                shadow = 2;
            };
        };
    };
};
