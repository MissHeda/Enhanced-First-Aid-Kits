// A small window on the right edge that shows what a kit holds - the "Quick access" action. Pick a
// row and Take (or double click it) to take the whole stack out; Escape or the cross shuts it. Built
// from the pieces in RscBase.hpp, laid out in defines.hpp.

class EFAK_ContentsPopup {
    idd = IDD_CONTENTS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(contentsDisplay),_this select 0)]);
    onUnload = QUOTE(call FUNC(onContentsClosed));
    onKeyDown = QUOTE(_this call FUNC(onCycleKey));

    class ControlsBackground {
        EFAK_PANEL(PopupWindow,POPUP_X,POPUP_Y,POPUP_W,POPUP_H,POPUP_ROW * 0.6,C_WINDOW);
        class PopupGloss: EFAK_Gloss {
            text = UI_TEX(gloss_contents_ca);
            x = QUOTE(SNAP_X(POPUP_X));
            y = QUOTE(SNAP_Y(POPUP_Y));
            w = QUOTE(SNAP_X(POPUP_X + POPUP_W) - SNAP_X(POPUP_X));
            h = QUOTE(SNAP_Y(POPUP_Y + POPUP_H) - SNAP_Y(POPUP_Y));
        };
        EFAK_PANEL(PopupTrack,POPUP_X + POPUP_IN_X,POPUP_BAR_Y,POPUP_W - POPUP_IN_X * 2,POPUP_BAR_H,POPUP_BAR_H / 2,C_FIELD);
        EFAK_PANEL(PopupFill,POPUP_X + POPUP_IN_X,POPUP_BAR_Y,POPUP_W - POPUP_IN_X * 2,POPUP_BAR_H,POPUP_BAR_H / 2,C_GAIN);
        EFAK_PANEL(PopupCard,POPUP_X + POPUP_IN_X,POPUP_LIST_Y,POPUP_W - POPUP_IN_X * 2,POPUP_LIST_H,POPUP_ROW * 0.45,C_CARD);
    };

    class Controls {
        // The kit's own picture, square whatever the screen.
        class Picture: RscPicture {
            idc = IDC_CONTENTS_PICTURE;
            style = 2096;
            x = QUOTE(POPUP_X + POPUP_IN_X);
            y = QUOTE(POPUP_Y + POPUP_ROW * 0.6);
            w = QUOTE(SQUARE(POPUP_HEAD_H));
            h = QUOTE(POPUP_HEAD_H);
            text = "";
        };

        // The kit's short name, and under it how full it is - the two together in the middle of the
        // picture's height.
        class Title: EFAK_Label {
            idc = IDC_CONTENTS_TITLE;
            x = QUOTE(POPUP_X + POPUP_IN_X + SQUARE(POPUP_HEAD_H + POPUP_ROW * 0.35));
            y = QUOTE(POPUP_NAME_Y);
            w = QUOTE(POPUP_W - POPUP_IN_X * 2 - SQUARE(POPUP_HEAD_H + POPUP_ROW * 0.35 + POPUP_CLOSE_H + POPUP_ROW * 0.2));
            h = QUOTE(POPUP_NAME_H);
            sizeEx = QUOTE(POPUP_ROW * 1.05);
            font = "RobotoCondensedBold";
        };
        class Capacity: Title {
            idc = IDC_CONTENTS_CAPACITY;
            y = QUOTE(POPUP_NAME_Y + POPUP_NAME_H);
            h = QUOTE(POPUP_INFO_H);
            sizeEx = QUOTE(POPUP_ROW * 0.7);
            font = "RobotoCondensed";
            colorText[] = C_TEXT2;
        };

        EFAK_PANEL(PopupClose,POPUP_X + POPUP_W - POPUP_IN_X - SQUARE(POPUP_CLOSE_H),POPUP_Y + POPUP_ROW * 0.6,SQUARE(POPUP_CLOSE_H),POPUP_CLOSE_H,POPUP_ROW * 0.42,C_CLEAR);
        class PopupClose_Icon: EFAK_Icon {
            text = UI_TEX(icon_close_ca);
            x = QUOTE(POPUP_X + POPUP_W - POPUP_IN_X - SQUARE(POPUP_CLOSE_H * 0.78));
            y = QUOTE(POPUP_Y + POPUP_ROW * 0.6 + POPUP_CLOSE_H * 0.22);
            w = QUOTE(SQUARE(POPUP_CLOSE_H * 0.56));
            h = QUOTE(POPUP_CLOSE_H * 0.56);
        };
        class PopupClose_Hit: EFAK_Hitbox {
            idc = IDC_CONTENTS_CLOSE;
            x = QUOTE(POPUP_X + POPUP_W - POPUP_IN_X - SQUARE(POPUP_CLOSE_H));
            y = QUOTE(POPUP_Y + POPUP_ROW * 0.6);
            w = QUOTE(SQUARE(POPUP_CLOSE_H));
            h = QUOTE(POPUP_CLOSE_H);
            tooltip = CSTRING(Close);
            onButtonClick = "closeDialog 0";
        };

        // Name on the left, the count on the right in the accent colour, as in the kit window.
        class List: EFAK_ListBox {
            idc = IDC_CONTENTS_LIST;
            x = QUOTE(POPUP_X + POPUP_IN_X + SQUARE(POPUP_ROW * 0.18));
            y = QUOTE(POPUP_LIST_Y + POPUP_ROW * 0.3);
            w = QUOTE(POPUP_W - POPUP_IN_X * 2 - SQUARE(POPUP_ROW * 0.5));
            h = QUOTE(POPUP_LIST_H - POPUP_ROW * 0.6);
            rowHeight = QUOTE(POPUP_ROW * 1.05);
            sizeEx = QUOTE(POPUP_ROW * 0.74);
            onLBSelChanged = QUOTE(call FUNC(onContentsSelect));
            onLBDblClick = QUOTE(call FUNC(onContentsTake));
        };

        // The one thing to do here.
        EFAK_PANEL(BtnTake,POPUP_X + POPUP_IN_X,POPUP_BUTTON_Y,POPUP_W - POPUP_IN_X * 2,POPUP_BUTTON_H,POPUP_ROW * 0.42,C_ACCENT);
        class BtnTake_Label: EFAK_Label {
            style = 2;
            text = CSTRING(Contents_Take);
            x = QUOTE(POPUP_X + POPUP_IN_X);
            y = QUOTE(POPUP_BUTTON_Y);
            w = QUOTE(POPUP_W - POPUP_IN_X * 2);
            h = QUOTE(POPUP_BUTTON_H);
            sizeEx = QUOTE(POPUP_ROW * 0.82);
            font = "RobotoCondensedBold";
            colorText[] = C_ON_ACCENT;
        };
        class BtnTake_Hit: EFAK_Hitbox {
            idc = IDC_CONTENTS_TAKE;
            x = QUOTE(POPUP_X + POPUP_IN_X);
            y = QUOTE(POPUP_BUTTON_Y);
            w = QUOTE(POPUP_W - POPUP_IN_X * 2);
            h = QUOTE(POPUP_BUTTON_H);
            tooltip = CSTRING(Contents_Take_Tooltip);
            onButtonClick = QUOTE(call FUNC(onContentsTake));
        };
    };
};
