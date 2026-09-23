// A small window on the right edge that shows what a kit holds - the "Show contents" action. Pick a
// row and Take (or double click it) to take the whole stack out; Escape or Close shuts it.
class RscListBox;

class EFAK_ContentsPopup {
    idd = IDD_CONTENTS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(contentsDisplay),_this select 0)]);
    onUnload = QUOTE(call FUNC(onContentsClosed));

    class ControlsBackground {
        class Background: RscText {
            idc = -1;
            x = QUOTE(POPUP_X);
            y = QUOTE(POPUP_Y);
            w = QUOTE(POPUP_W);
            h = QUOTE(POPUP_H);
            colorBackground[] = {0, 0, 0, 0.8};
        };

        class Border: RscFrame {
            idc = -1;
            x = QUOTE(POPUP_X);
            y = QUOTE(POPUP_Y);
            w = QUOTE(POPUP_W);
            h = QUOTE(POPUP_H);
            colorText[] = {1, 1, 1, 0.25};
        };

        class ListBox: RscText {
            idc = -1;
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_LIST_Y);
            w = QUOTE(POPUP_W - POPUP_PAD * 2);
            h = QUOTE(POPUP_LIST_H);
            colorBackground[] = {0, 0, 0, 0.4};
        };
    };

    class Controls {
        // The kit's own picture, square whatever the screen.
        class Picture: RscPicture {
            idc = IDC_CONTENTS_PICTURE;
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_Y + POPUP_PAD);
            w = QUOTE(POPUP_ROW * 2.6 * pixelW / pixelH);
            h = QUOTE(POPUP_ROW * 2.6);
            text = "";
        };

        // Name, and under it how full the kit is.
        class Title: RscStructuredText {
            idc = IDC_CONTENTS_TITLE;
            x = QUOTE(POPUP_X + POPUP_PAD + POPUP_ROW * 2.9 * pixelW / pixelH);
            y = QUOTE(POPUP_Y + POPUP_PAD);
            w = QUOTE(POPUP_W - POPUP_PAD * 2 - POPUP_ROW * 2.9 * pixelW / pixelH);
            h = QUOTE(POPUP_ROW * 2.6);
            size = QUOTE(POPUP_ROW * 0.85);
            colorBackground[] = {0, 0, 0, 0};
            class Attributes {
                font = "RobotoCondensed";
                color = "#FFFFFF";
                align = "left";
                valign = "middle";
                shadow = 0;
            };
        };

        class CapacityTrack: RscText {
            idc = -1;
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_BAR_Y);
            w = QUOTE(POPUP_W - POPUP_PAD * 2);
            h = QUOTE(POPUP_ROW * 0.4);
            colorBackground[] = {1, 1, 1, 0.08};
        };

        class CapacityBar: RscProgress {
            idc = IDC_CONTENTS_BAR;
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_BAR_Y);
            w = QUOTE(POPUP_W - POPUP_PAD * 2);
            h = QUOTE(POPUP_ROW * 0.4);
            colorBar[] = {0.35, 0.75, 0.4, 1};
            colorFrame[] = {1, 1, 1, 0.35};
        };

        // Name on the left, the count on the right in the accent colour, as in the kit window.
        class List: RscListBox {
            idc = IDC_CONTENTS_LIST;
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_LIST_Y);
            w = QUOTE(POPUP_W - POPUP_PAD * 2);
            h = QUOTE(POPUP_LIST_H);
            rowHeight = QUOTE(POPUP_ROW * 0.95);
            sizeEx = QUOTE(POPUP_ROW * 0.72);
            colorBackground[] = {0, 0, 0, 0};
            colorSelectBackground[] = {1, 1, 1, 0.15};
            colorSelectBackground2[] = {1, 1, 1, 0.15};
            onLBSelChanged = QUOTE(call FUNC(onContentsSelect));
            onLBDblClick = QUOTE(call FUNC(onContentsTake));
            colorSelect[] = {1, 1, 1, 1};
            colorSelect2[] = {1, 1, 1, 1};
            colorTextRight[] = {1, 0.78, 0.3, 1};
            colorSelectRight[] = {1, 0.78, 0.3, 1};
            colorSelect2Right[] = {1, 0.78, 0.3, 1};
        };

        class ButtonTake: RscButtonMenu {
            idc = IDC_CONTENTS_TAKE;
            text = CSTRING(Contents_Take);
            tooltip = CSTRING(Contents_Take_Tooltip);
            onButtonClick = QUOTE(call FUNC(onContentsTake));
            x = QUOTE(POPUP_X + POPUP_PAD);
            y = QUOTE(POPUP_BUTTON_Y);
            w = QUOTE((POPUP_W - POPUP_PAD * 3) / 2);
            h = QUOTE(POPUP_ROW * 1.3);
            sizeEx = QUOTE(POPUP_ROW * 0.75);
            class TextPos {
                left = 0;
                top = QUOTE((POPUP_ROW * 1.3 - POPUP_ROW * 0.75) / 2);
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

        class ButtonClose: ButtonTake {
            idc = IDC_CONTENTS_CLOSE;
            text = CSTRING(Close);
            tooltip = "";
            onButtonClick = "closeDialog 0";
            x = QUOTE(POPUP_X + POPUP_PAD * 2 + (POPUP_W - POPUP_PAD * 3) / 2);
        };
    };
};
