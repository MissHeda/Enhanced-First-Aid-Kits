// The building blocks of EFAK's windows: flat surfaces with round corners, icons, and buttons that are
// only a hit area over artwork - the look is drawn by the controls under them, not by the engine's
// button styles. Colours come from the palette in defines.hpp.

class RscText;
class RscStructuredText;
class RscPicture;
class RscButton;
class RscEdit;
class RscCombo;
class RscListBox;
class RscListNBox;
class ScrollBar;
class RscControlsGroup {
    class VScrollbar;
    class HScrollbar;
};

// ---------------------------------------------------------------------------
// Round corners at any size: a rounded rectangle is three rectangles and four quarter circles, so the
// corners stay round whatever the rectangle's size and the screen's shape. Every edge sits on a screen
// pixel and the pieces meet without overlapping (SNAP_*), so a see-through panel shows no seams:
//
//   TL | Mid | TR        Mid runs the full height between the two sides,
//   Lft|     | Rgt       Lft and Rgt only between their corners.
//   BL |     | BR
//
// NAME prefixes the seven classes - NAME_Mid, NAME_Lft, NAME_Rgt, NAME_TL, NAME_TR, NAME_BL, NAME_BR -
// which is how fnc_paintButton finds a button's surface to recolour it, and fnc_setPanelRect a bar's
// fill to size it. fnc_createPanel builds the same seven at run time.
// ---------------------------------------------------------------------------
#define EFAK_PANEL(NAME,X,Y,W,H,RAD,COLOR) \
    class DOUBLES(NAME,Mid): EFAK_PanelRect { \
        x = QUOTE(SNAP_X(X) + SNAP_W(SQUARE(RAD))); \
        y = QUOTE(SNAP_Y(Y)); \
        w = QUOTE(SNAP_X((X) + (W)) - SNAP_X(X) - 2 * SNAP_W(SQUARE(RAD))); \
        h = QUOTE(SNAP_Y((Y) + (H)) - SNAP_Y(Y)); \
        colorBackground[] = COLOR; \
    }; \
    class DOUBLES(NAME,Lft): EFAK_PanelRect { \
        x = QUOTE(SNAP_X(X)); \
        y = QUOTE(SNAP_Y(Y) + SNAP_H(RAD)); \
        w = QUOTE(SNAP_W(SQUARE(RAD))); \
        h = QUOTE(SNAP_Y((Y) + (H)) - SNAP_Y(Y) - 2 * SNAP_H(RAD)); \
        colorBackground[] = COLOR; \
    }; \
    class DOUBLES(NAME,Rgt): DOUBLES(NAME,Lft) { \
        x = QUOTE(SNAP_X((X) + (W)) - SNAP_W(SQUARE(RAD))); \
    }; \
    class DOUBLES(NAME,TL): EFAK_PanelCorner { \
        text = UI_TEX(corner_tl_ca); \
        x = QUOTE(SNAP_X(X)); \
        y = QUOTE(SNAP_Y(Y)); \
        w = QUOTE(SNAP_W(SQUARE(RAD))); \
        h = QUOTE(SNAP_H(RAD)); \
        colorText[] = COLOR; \
    }; \
    class DOUBLES(NAME,TR): DOUBLES(NAME,TL) { \
        text = UI_TEX(corner_tr_ca); \
        x = QUOTE(SNAP_X((X) + (W)) - SNAP_W(SQUARE(RAD))); \
    }; \
    class DOUBLES(NAME,BL): DOUBLES(NAME,TL) { \
        text = UI_TEX(corner_bl_ca); \
        y = QUOTE(SNAP_Y((Y) + (H)) - SNAP_H(RAD)); \
    }; \
    class DOUBLES(NAME,BR): DOUBLES(NAME,BL) { \
        text = UI_TEX(corner_br_ca); \
        x = QUOTE(SNAP_X((X) + (W)) - SNAP_W(SQUARE(RAD))); \
    }

class EFAK_PanelRect: RscText {
    idc = -1;
    style = 0;
    text = "";
    shadow = 0;
    colorText[] = C_CLEAR;
    colorBackground[] = C_CARD;
};

// A texture stretched over a whole window - the sheen on its glass and its light edge. Drawn for the
// window's shape by tools/generate_ui_textures.py.
class EFAK_Gloss: RscPicture {
    idc = -1;
    style = 48;
    shadow = 0;
    colorBackground[] = C_CLEAR;
    colorText[] = {1, 1, 1, 1};
};

class EFAK_PanelCorner: RscPicture {
    idc = -1;
    style = 48;
    shadow = 0;
    colorBackground[] = C_CLEAR;
    colorText[] = C_CARD;
};

// ---------------------------------------------------------------------------
// Text, icons, hit areas
// ---------------------------------------------------------------------------
class EFAK_Label: RscText {
    idc = -1;
    style = 0;
    shadow = 0;
    font = "RobotoCondensed";
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
};

class EFAK_StructuredText: RscStructuredText {
    idc = -1;
    shadow = 0;
    colorBackground[] = C_CLEAR;
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
    class Attributes {
        font = "RobotoCondensed";
        color = HEX_TEXT;
        align = "left";
        valign = "middle";
        shadow = 0;
    };
};

// Square icons keep their shape whatever box they are given (ST_PICTURE + ST_KEEP_ASPECT_RATIO).
class EFAK_Icon: RscPicture {
    idc = -1;
    style = 2096;
    shadow = 0;
    colorBackground[] = C_CLEAR;
    colorText[] = C_TEXT2;
};

// A button with no look of its own: it only catches the mouse, over artwork drawn by the controls under
// it. Hovering recolours those (fnc_onButtonHover).
class EFAK_Hitbox: RscButton {
    idc = -1;
    style = 2;
    text = "";
    shadow = 0;
    borderSize = 0;
    colorText[] = C_CLEAR;
    colorDisabled[] = C_CLEAR;
    colorBackground[] = C_CLEAR;
    colorBackgroundDisabled[] = C_CLEAR;
    colorBackgroundActive[] = C_CLEAR;
    colorFocused[] = C_CLEAR;
    colorShadow[] = C_CLEAR;
    colorBorder[] = C_CLEAR;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    soundEnter[] = {"", 0, 1};
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
    onMouseEnter = QUOTE([ARR_2(_this select 0,true)] call FUNC(onButtonHover));
    onMouseExit = QUOTE([ARR_2(_this select 0,false)] call FUNC(onButtonHover));
};

// ---------------------------------------------------------------------------
// Inputs, lists, bars - the engine's controls with their chrome taken off
// ---------------------------------------------------------------------------

// No frame (ST_NO_RECT): the field is drawn by the panel under it.
class EFAK_Edit: RscEdit {
    style = 512;
    shadow = 0;
    font = "RobotoCondensed";
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
    colorSelection[] = C_ACCENT_SOFT;
    colorDisabled[] = C_MUTED;
    autocomplete = "";
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
};

// Thin, quiet scroll bars without arrows; the thumb a slim bar with round ends.
class EFAK_ScrollBar: ScrollBar {
    color[] = {1, 1, 1, 0.3};
    colorActive[] = {1, 1, 1, 0.5};
    colorDisabled[] = {1, 1, 1, 0.08};
    thumb = UI_TEX(scroll_thumb_ca);
    arrowEmpty = "#(argb,8,8,3)color(0,0,0,0)";
    arrowFull = "#(argb,8,8,3)color(0,0,0,0)";
    border = "#(argb,8,8,3)color(0,0,0,0)";
    shadow = 0;
};

// The field's colour is its own background, so the drop down list matches it.
class EFAK_Combo: RscCombo {
    shadow = 0;
    font = "RobotoCondensed";
    colorText[] = C_TEXT;
    colorBackground[] = C_FIELD;
    colorSelect[] = C_TEXT;
    colorSelectBackground[] = C_ACCENT_SOFT;
    colorDisabled[] = C_MUTED;
    colorBorder[] = C_CLEAR;
    colorScrollbar[] = C_TEXT2;
    colorPicture[] = {1, 1, 1, 1};
    colorPictureSelected[] = {1, 1, 1, 1};
    colorPictureDisabled[] = {1, 1, 1, 0.4};
    colorPictureRight[] = {1, 1, 1, 1};
    colorPictureRightSelected[] = {1, 1, 1, 1};
    colorPictureRightDisabled[] = {1, 1, 1, 0.4};
    arrowEmpty = UI_TEX(icon_chevron_down_ca);
    arrowFull = UI_TEX(icon_chevron_down_ca);
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
    class ComboScrollBar: EFAK_ScrollBar {};
};

// The engine's scroll bar, there to scroll with but not to be seen - EFAK draws its own over it.
class EFAK_HiddenScrollBar: EFAK_ScrollBar {
    color[] = C_CLEAR;
    colorActive[] = C_CLEAR;
    colorDisabled[] = C_CLEAR;
    thumb = "#(argb,8,8,3)color(0,0,0,0)";
};

// Transparent over the card behind it. The selection bar and the scroll bar are drawn by
// fnc_updateLists - round, and the whole width - so the engine's are clear.
class EFAK_List: RscListNBox {
    shadow = 0;
    font = "RobotoCondensed";
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
    colorDisabled[] = C_MUTED;
    colorSelect[] = C_TEXT;
    colorSelect2[] = C_TEXT;
    colorSelectBackground[] = C_CLEAR;
    colorSelectBackground2[] = C_CLEAR;
    colorPicture[] = {1, 1, 1, 1};
    colorPictureSelected[] = {1, 1, 1, 1};
    colorPictureDisabled[] = {1, 1, 1, 0.35};
    drawSideArrows = 0;
    idcLeft = -1;
    idcRight = -1;
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
    class ListScrollBar: EFAK_HiddenScrollBar {};
};

// Both selection colours are the same - a list alternates between them while it has the focus, which
// reads as flicker.
class EFAK_ListBox: RscListBox {
    shadow = 0;
    font = "RobotoCondensed";
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
    colorDisabled[] = C_MUTED;
    colorSelect[] = C_TEXT;
    colorSelect2[] = C_TEXT;
    colorSelectBackground[] = C_ACCENT_SOFT;
    colorSelectBackground2[] = C_ACCENT_SOFT;
    colorTextRight[] = C_ACCENT;
    colorSelectRight[] = C_ACCENT;
    colorSelect2Right[] = C_ACCENT;
    colorPicture[] = {1, 1, 1, 1};
    colorPictureSelected[] = {1, 1, 1, 1};
    colorPictureDisabled[] = {1, 1, 1, 0.35};
    tooltipColorText[] = C_TEXT;
    tooltipColorBox[] = {1, 1, 1, 0.1};
    tooltipColorShade[] = {0.07, 0.078, 0.098, 0.97};
    class ListScrollBar: EFAK_ScrollBar {};
};

// ---------------------------------------------------------------------------
// Drop down menus, created at run time by fnc_openMenu
// ---------------------------------------------------------------------------

// Over the whole screen under an open menu: a click anywhere but on the menu closes it. The menu goes
// a frame later - a control must not be deleted inside its own event.
class EFAK_MenuCatcher: EFAK_Hitbox {
    onMouseEnter = "";
    onMouseExit = "";
    onButtonClick = QUOTE([ARR_2(FUNC(closeMenu),[])] call CBA_fnc_execNextFrame);
};

// The rows, which scroll once there are more than fit.
class EFAK_MenuGroup: RscControlsGroup {
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    shadow = 0;
    class VScrollbar: VScrollbar {
        width = MENU_SCROLL_W;
        autoScrollEnabled = 0;
        color[] = {1, 1, 1, 0.3};
        colorActive[] = {1, 1, 1, 0.5};
        colorDisabled[] = {1, 1, 1, 0.08};
        thumb = UI_TEX(scroll_thumb_ca);
        arrowEmpty = "#(argb,8,8,3)color(0,0,0,0)";
        arrowFull = "#(argb,8,8,3)color(0,0,0,0)";
        border = "#(argb,8,8,3)color(0,0,0,0)";
        shadow = 0;
    };
    class HScrollbar: HScrollbar {
        height = 0;
    };
    class Controls {};
};

// A row's hit area: it lights its row up and picks it.
class EFAK_MenuRow: EFAK_Hitbox {
    onMouseEnter = QUOTE([ARR_2(_this select 0,true)] call FUNC(onMenuHover));
    onMouseExit = QUOTE([ARR_2(_this select 0,false)] call FUNC(onMenuHover));
    onButtonClick = QUOTE(_this call FUNC(onMenuPick));
};
