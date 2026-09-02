class RscText;
class RscStructuredText;
class RscListBox;
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

    class ControlsBackground {
        class Background: RscText {
            idc = IDC_BACKGROUND;
            x = QUOTE(POUCH_X);
            y = QUOTE(POUCH_Y);
            w = QUOTE(POUCH_W);
            h = QUOTE(POUCH_H);
            colorBackground[] = {0, 0, 0, 0.75};
        };

        class Border: RscFrame {
            idc = -1;
            x = QUOTE(POUCH_X);
            y = QUOTE(POUCH_Y);
            w = QUOTE(POUCH_W);
            h = QUOTE(POUCH_H);
            colorText[] = {1, 1, 1, 0.25};
        };
    };

    class Controls {
        class Title: RscText {
            idc = IDC_TITLE;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(POUCH_Y + ROW * 0.5);
            w = QUOTE(POUCH_W - PAD * 2);
            h = QUOTE(ROW * 1.6);
            sizeEx = QUOTE(ROW);
            colorText[] = {1, 1, 1, 1};
        };

        class HeaderInventory: RscText {
            idc = IDC_HEADER_INVENTORY;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(POUCH_Y + ROW * 2.4);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 1.4);
            sizeEx = QUOTE(ROW * 0.8);
            colorText[] = {0.8, 0.8, 0.8, 1};
        };

        class HeaderKit: HeaderInventory {
            idc = IDC_HEADER_KIT;
            x = QUOTE(POUCH_X + PAD + LIST_W + COL * 3);
        };

        class ListInventory: RscListBox {
            idc = IDC_LIST_INVENTORY;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y);
            w = QUOTE(LIST_W);
            h = QUOTE(LIST_H);
            canDrag = 1;
            rowHeight = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.8);
            colorBackground[] = {0, 0, 0, 0.4};
        };

        class ListKit: ListInventory {
            idc = IDC_LIST_KIT;
            x = QUOTE(POUCH_X + PAD + LIST_W + COL * 3);
        };

        class ButtonToKit: RscButtonMenu {
            idc = IDC_BUTTON_TO_KIT;
            text = ">>";
            x = QUOTE(POUCH_X + PAD + LIST_W + COL * 0.4);
            y = QUOTE(LIST_Y + LIST_H / 2 - ROW * 2);
            w = QUOTE(COL * 2.2);
            h = QUOTE(ROW * 1.6);
            sizeEx = QUOTE(ROW * 0.8);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_INVENTORY,AMOUNT_ALL)] call FUNC(transferSelected));
        };

        class ButtonToInventory: ButtonToKit {
            idc = IDC_BUTTON_TO_INVENTORY;
            text = "<<";
            y = QUOTE(LIST_Y + LIST_H / 2 + ROW * 0.4);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_KIT,AMOUNT_ALL)] call FUNC(transferSelected));
        };

        class CapacityBar: RscProgress {
            idc = IDC_CAPACITY_BAR;
            x = QUOTE(POUCH_X + PAD + LIST_W + COL * 3);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.4);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 0.5);
            colorBar[] = {0.35, 0.75, 0.4, 1};
        };

        class CapacityText: RscText {
            idc = IDC_CAPACITY_TEXT;
            x = QUOTE(POUCH_X + PAD + LIST_W + COL * 3);
            y = QUOTE(LIST_Y + LIST_H + ROW);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 1.2);
            sizeEx = QUOTE(ROW * 0.75);
            colorText[] = {0.8, 0.8, 0.8, 1};
        };

        class Hint: RscText {
            idc = IDC_HINT;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(LIST_Y + LIST_H + ROW * 0.4);
            w = QUOTE(LIST_W);
            h = QUOTE(ROW * 2);
            sizeEx = QUOTE(ROW * 0.7);
            colorText[] = {0.7, 0.7, 0.7, 1};
        };

        class ButtonUnpackAll: RscButtonMenu {
            idc = IDC_BUTTON_UNPACKALL;
            text = CSTRING(UnpackAll);
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(POUCH_Y + POUCH_H - ROW * 2.2);
            w = QUOTE(COL * 6);
            h = QUOTE(ROW * 1.6);
            sizeEx = QUOTE(ROW * 0.8);
            onButtonClick = QUOTE(call FUNC(unpackAllPressed));
        };

        class ButtonClose: RscButtonMenuCancel {
            idc = IDC_BUTTON_CLOSE;
            text = CSTRING(Close);
            x = QUOTE(POUCH_X + POUCH_W - PAD - COL * 6);
            y = QUOTE(POUCH_Y + POUCH_H - ROW * 2.2);
            w = QUOTE(COL * 6);
            h = QUOTE(ROW * 1.6);
            sizeEx = QUOTE(ROW * 0.8);
        };
    };
};
