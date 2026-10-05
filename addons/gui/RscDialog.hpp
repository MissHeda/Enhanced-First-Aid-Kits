// The kit window. Built from the pieces in RscBase.hpp: flat surfaces with round corners, icons, and
// buttons that are only a hit area over artwork (fnc_paintButton recolours a button's surface on hover
// and for the tab that is on). The three choosers are drop down menus of EFAK's own (fnc_openMenu).
// Layout in defines.hpp.

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
        // The world behind, dimmed, so the window has the attention.
        class Dim: EFAK_PanelRect {
            idc = IDC_BACKGROUND;
            x = QUOTE(safezoneX);
            y = QUOTE(safezoneY);
            w = QUOTE(safezoneW);
            h = QUOTE(safezoneH);
            colorBackground[] = C_DIM;
        };

        // Dark glass, with a sheen along its top and a light edge.
        EFAK_PANEL(Window,POUCH_X,POUCH_Y,POUCH_W,POUCH_VISIBLE_H,RADIUS_WINDOW,C_WINDOW);
        class WindowGloss: EFAK_Gloss {
            text = UI_TEX(gloss_pouch_ca);
            x = QUOTE(SNAP_X(POUCH_X));
            y = QUOTE(SNAP_Y(POUCH_Y));
            w = QUOTE(SNAP_X(POUCH_X + POUCH_W) - SNAP_X(POUCH_X));
            h = QUOTE(SNAP_Y(POUCH_Y + POUCH_VISIBLE_H) - SNAP_Y(POUCH_Y));
        };


        // Under the header, the width of the content.
        class HeaderLine: EFAK_PanelRect {
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(HEAD_LINE_Y);
            w = QUOTE(FULL_W);
            h = QUOTE(pixelH);
            colorBackground[] = C_LINE;
        };

        // Over the hint, the same.
        class FooterLine: HeaderLine {
            y = QUOTE(SNAP_Y(HINT_Y));
        };

        // The fields in the header and the middle column: the controls on them draw nothing themselves.
        // KitSwitch, Sort and TakeInto are the surfaces of their drop downs, painted like buttons.
        EFAK_PANEL(KitSwitch,KIT_SWITCH_X,HEAD_Y,KIT_SWITCH_W,HEAD_H,RADIUS_FIELD,C_FIELD);
        // The pencil's own film, clear until the mouse is on it (fnc_paintButton).
        EFAK_PANEL(Rename,RENAME_X,RENAME_Y,RENAME_W,RENAME_H,RADIUS_FIELD,C_CLEAR);
        EFAK_PANEL(SearchField,SEARCH_X,HEAD_Y,SEARCH_W,HEAD_H,RADIUS_FIELD,C_FIELD);
        EFAK_PANEL(Sort,SORT_X,HEAD_Y,SORT_W,HEAD_H,RADIUS_FIELD,C_FIELD);
        EFAK_PANEL(TabTrack,POUCH_X + PAD,SECTION_Y,LIST_W,SECTION_H,RADIUS_FIELD,C_FIELD);
        EFAK_PANEL(AmountField,MID_X,MID_C - ROW * 0.7,MID_W,ROW * 1.4,RADIUS_FIELD,C_FIELD);
        EFAK_PANEL(TakeInto,MID_X,LIST_Y + LIST_H - ROW * 1.5,MID_W,ROW * 1.5,RADIUS_FIELD,C_FIELD);

        // The two lists
        EFAK_PANEL(CardInventory,POUCH_X + PAD,LIST_Y,LIST_W,LIST_H,RADIUS_CARD,C_CARD);
        EFAK_PANEL(CardKit,LIST_RIGHT_X,LIST_Y,LIST_W,LIST_H,RADIUS_CARD,C_CARD);

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

        // The selection bars of the two lists and the thumbs of every list's scroll bar, placed by
        // fnc_updateLists: round, the whole width of a row, and from the top of a card to its bottom.
        EFAK_PANEL(SelectInventory,POUCH_X + PAD,LIST_Y,LIST_W,LIST_ROW,SELECT_RADIUS,C_ACCENT_SOFT);
        EFAK_PANEL(SelectKit,LIST_RIGHT_X,LIST_Y,LIST_W,LIST_ROW,SELECT_RADIUS,C_ACCENT_SOFT);
        EFAK_PANEL(ThumbInventory,POUCH_X + PAD,LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);
        EFAK_PANEL(ThumbKit,LIST_RIGHT_X,LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);

        // The bars under the lists: a round track, and on it a round fill as long as the bar is full
        // (fnc_setBar).
        EFAK_PANEL(LoadTrack,POUCH_X + PAD,METER_BAR_Y,LIST_W,METER_BAR_H,METER_BAR_H / 2,C_FIELD);
        EFAK_PANEL(LoadFill,POUCH_X + PAD,METER_BAR_Y,LIST_W,METER_BAR_H,METER_BAR_H / 2,C_INFO);
        EFAK_PANEL(CapacityTrack,LIST_RIGHT_X,METER_BAR_Y,LIST_W,METER_BAR_H,METER_BAR_H / 2,C_FIELD);
        EFAK_PANEL(CapacityFill,LIST_RIGHT_X,METER_BAR_Y,LIST_W,METER_BAR_H,METER_BAR_H / 2,C_GAIN);

        // The bottom row: a card per place, and the bar of each. The ground has no limit - its bar
        // fills in the accent colour once anything lies there, so it reads as a warning, not a level.
        EFAK_PANEL(CardGround,PREVIEW_X(0),PREVIEW_Y,PREVIEW_W,PREVIEW_H,RADIUS_CARD,C_CARD);
        EFAK_PANEL(CardUniform,PREVIEW_X(1),PREVIEW_Y,PREVIEW_W,PREVIEW_H,RADIUS_CARD,C_CARD);
        EFAK_PANEL(CardVest,PREVIEW_X(2),PREVIEW_Y,PREVIEW_W,PREVIEW_H,RADIUS_CARD,C_CARD);
        EFAK_PANEL(CardBackpack,PREVIEW_X(3),PREVIEW_Y,PREVIEW_W,PREVIEW_H,RADIUS_CARD,C_CARD);

        EFAK_PANEL(GroundTrack,PREVIEW_IN_X(0),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_FIELD);
        EFAK_PANEL(GroundFill,PREVIEW_IN_X(0),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_ACCENT);
        EFAK_PANEL(UniformTrack,PREVIEW_IN_X(1),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_FIELD);
        EFAK_PANEL(UniformFill,PREVIEW_IN_X(1),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_INFO);
        EFAK_PANEL(VestTrack,PREVIEW_IN_X(2),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_FIELD);
        EFAK_PANEL(VestFill,PREVIEW_IN_X(2),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_INFO);
        EFAK_PANEL(BackpackTrack,PREVIEW_IN_X(3),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_FIELD);
        EFAK_PANEL(BackpackFill,PREVIEW_IN_X(3),PREVIEW_BAR_Y,PREVIEW_IN_W,PREVIEW_BAR_H,PREVIEW_BAR_H / 2,C_INFO);

        EFAK_PANEL(ThumbGround,PREVIEW_X(0),PREVIEW_LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);
        EFAK_PANEL(ThumbUniform,PREVIEW_X(1),PREVIEW_LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);
        EFAK_PANEL(ThumbVest,PREVIEW_X(2),PREVIEW_LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);
        EFAK_PANEL(ThumbBackpack,PREVIEW_X(3),PREVIEW_LIST_Y,SQUARE(THUMB_W),THUMB_MIN_H,THUMB_W / 2,C_THUMB);
    };

    class Controls {
        // In the game the first control here drew no background - the kit switcher's surface, when it
        // stood here (2026-09). This empty one takes the place.
        class First: EFAK_Label {
            x = 0;
            y = 0;
            w = 0;
            h = 0;
        };

        // ----- Header -----

        // Doubles as the title: the kit's picture and name, on the KitSwitch field. A click opens every
        // kit this window can reach - the player's own, those of the casualty it was opened on and
        // those in the crate - in a menu exactly as wide as the field.
        class KitSwitch_Picture: EFAK_Icon {
            idc = IDC_KIT_SWITCH_PICTURE;
            x = QUOTE(KIT_SWITCH_X + KIT_SWITCH_GAP);
            y = QUOTE(HEAD_Y + (HEAD_H - KIT_SWITCH_PIC_H) / 2);
            w = QUOTE(SQUARE(KIT_SWITCH_PIC_H));
            h = QUOTE(KIT_SWITCH_PIC_H);
            colorText[] = {1, 1, 1, 1};
        };
        class KitSwitch_Label: EFAK_Label {
            idc = IDC_KIT_SWITCH;
            x = QUOTE(KIT_NAME_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(KIT_NAME_W);
            h = QUOTE(HEAD_H);
            sizeEx = QUOTE(KIT_SWITCH_TEXT);
            font = "RobotoCondensedBold";
        };
        class KitSwitch_Icon: EFAK_Icon {
            text = UI_TEX(icon_chevron_down_ca);
            x = QUOTE(KIT_SWITCH_X + KIT_SWITCH_W - KIT_SWITCH_GAP - SQUARE(KIT_SWITCH_ICON));
            y = QUOTE(HEAD_Y + (HEAD_H - KIT_SWITCH_ICON) / 2);
            w = QUOTE(SQUARE(KIT_SWITCH_ICON));
            h = QUOTE(KIT_SWITCH_ICON);
        };
        // In two pieces, left and right of the pencil, never under it: the engine draws a control that
        // was clicked on top of the others, and a switcher field across the pencil would take its clicks.
        class KitSwitch_Hit: EFAK_Hitbox {
            x = QUOTE(KIT_SWITCH_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(RENAME_X - KIT_SWITCH_X);
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(KitSwitch_Tooltip);
            onButtonClick = QUOTE(_this call FUNC(onDropdownClick));
        };
        class KitSwitch_HitArrow: KitSwitch_Hit {
            x = QUOTE(RENAME_X + RENAME_W);
            w = QUOTE(KIT_SWITCH_X + KIT_SWITCH_W - RENAME_X - RENAME_W);
        };

        // The pencil next to the name: click it and the name becomes a text box (fnc_onRenameClick).
        // Over the switcher's own hit box, so the click is the pencil's.
        class Rename_Icon: EFAK_Icon {
            idc = IDC_RENAME_ICON;
            text = UI_TEX(icon_edit_ca);
            x = QUOTE(RENAME_X + (RENAME_W - SQUARE(KIT_SWITCH_ICON)) / 2);
            y = QUOTE(HEAD_Y + (HEAD_H - KIT_SWITCH_ICON) / 2);
            w = QUOTE(SQUARE(KIT_SWITCH_ICON));
            h = QUOTE(KIT_SWITCH_ICON);
        };
        class Rename_Hit: EFAK_Hitbox {
            idc = IDC_RENAME_HIT;
            x = QUOTE(RENAME_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(RENAME_W);
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(Rename_Tooltip);
            onButtonClick = QUOTE(_this call FUNC(onRenameClick));
        };
        class Rename_Edit: EFAK_Edit {
            idc = IDC_RENAME_EDIT;
            x = QUOTE(KIT_NAME_X);
            y = QUOTE(HEAD_Y + HEAD_H * 0.12);
            w = QUOTE(KIT_NAME_W - SQUARE(KIT_SWITCH_ICON) - KIT_SWITCH_GAP);
            h = QUOTE(HEAD_H * 0.76);
            sizeEx = QUOTE(KIT_SWITCH_TEXT);
            colorBackground[] = {0, 0, 0, 0.55};
            maxChars = 40; // KIT_LABEL_MAX in core
            onLoad = "(_this select 0) ctrlShow false";
            onKillFocus = QUOTE([true] call FUNC(onRenameDone));
        };
        // Back to the usual name, at the end of the box - only while typing the name of a kit that has
        // one of its own. On the press: the press already ends the typing.
        class RenameReset_Icon: EFAK_Icon {
            idc = IDC_RENAME_RESET_ICON;
            text = UI_TEX(icon_reset_ca);
            x = QUOTE(KIT_NAME_X + KIT_NAME_W - SQUARE(KIT_SWITCH_ICON));
            y = QUOTE(HEAD_Y + (HEAD_H - KIT_SWITCH_ICON) / 2);
            w = QUOTE(SQUARE(KIT_SWITCH_ICON));
            h = QUOTE(KIT_SWITCH_ICON);
            onLoad = "(_this select 0) ctrlShow false";
        };
        class RenameReset_Hit: EFAK_Hitbox {
            idc = IDC_RENAME_RESET_HIT;
            x = QUOTE(KIT_NAME_X + KIT_NAME_W - SQUARE(KIT_SWITCH_ICON) - KIT_SWITCH_GAP * 0.5);
            y = QUOTE(HEAD_Y);
            w = QUOTE(SQUARE(KIT_SWITCH_ICON) + KIT_SWITCH_GAP);
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(RenameReset_Tooltip);
            onLoad = "(_this select 0) ctrlShow false";
            onMouseButtonDown = QUOTE(call FUNC(onRenameReset));
        };

        // One search for every list. The whole field focuses the words; "Search" shows while it is empty.
        class SearchIcon: EFAK_Icon {
            text = UI_TEX(icon_search_ca);
            x = QUOTE(SEARCH_X + SQUARE(ROW * 0.4));
            y = QUOTE(HEAD_Y + (HEAD_H - ROW * 0.85) / 2);
            w = QUOTE(SQUARE(ROW * 0.85));
            h = QUOTE(ROW * 0.85);
            colorText[] = C_MUTED;
        };
        class SearchPlaceholder: EFAK_Label {
            idc = IDC_SEARCH_PLACEHOLDER;
            text = CSTRING(Search_Placeholder);
            x = QUOTE(SEARCH_X + SQUARE(ROW * 1.45));
            y = QUOTE(HEAD_Y);
            w = QUOTE(SEARCH_W - SQUARE(ROW * 1.8));
            h = QUOTE(HEAD_H);
            sizeEx = QUOTE(ROW * 0.8);
            colorText[] = C_MUTED;
        };
        class SearchHit: EFAK_Hitbox {
            x = QUOTE(SEARCH_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(SEARCH_W);
            h = QUOTE(HEAD_H);
            onMouseEnter = "";
            onMouseExit = "";
            onButtonClick = QUOTE(ctrlSetFocus ((ctrlParent (_this select 0)) displayCtrl IDC_SEARCH));
        };
        class Search: EFAK_Edit {
            idc = IDC_SEARCH;
            x = QUOTE(SEARCH_X + SQUARE(ROW * 1.35));
            y = QUOTE(HEAD_Y + (HEAD_H - ROW * 1.15) / 2);
            w = QUOTE(SEARCH_W - SQUARE(ROW * 1.7));
            h = QUOTE(ROW * 1.15);
            sizeEx = QUOTE(ROW * 0.8);
            maxChars = 40;
            tooltip = CSTRING(Search_Tooltip);
            onEditChanged = QUOTE(_this call FUNC(onSearchChanged));
            onMouseButtonClick = QUOTE(_this call FUNC(onSearchClick));
        };

        // One sort for every list - a drop down on the Sort field - and which way round.
        class Sort_Label: EFAK_Label {
            idc = IDC_SORT;
            x = QUOTE(SORT_X + SQUARE(ROW * 0.45));
            y = QUOTE(HEAD_Y);
            w = QUOTE(SORT_W - SQUARE(ROW * 1.5));
            h = QUOTE(HEAD_H);
            sizeEx = QUOTE(ROW * 0.8);
        };
        class Sort_Icon: EFAK_Icon {
            text = UI_TEX(icon_chevron_down_ca);
            x = QUOTE(SORT_X + SORT_W - SQUARE(ROW * 0.4) - SQUARE(ROW * 0.7));
            y = QUOTE(HEAD_Y + (HEAD_H - ROW * 0.7) / 2);
            w = QUOTE(SQUARE(ROW * 0.7));
            h = QUOTE(ROW * 0.7);
        };
        class Sort_Hit: EFAK_Hitbox {
            x = QUOTE(SORT_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(SORT_W);
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(Sort_Tooltip);
            onButtonClick = QUOTE(_this call FUNC(onDropdownClick));
        };

        EFAK_PANEL(BtnSortDir,SORT_DIR_X,HEAD_Y,SQUARE(HEAD_H),HEAD_H,RADIUS_FIELD,C_FIELD);
        class BtnSortDir_Icon: EFAK_Icon {
            idc = IDC_SORT_DIR_ICON;
            text = UI_TEX(icon_sort_asc_ca);
            x = QUOTE(SORT_DIR_X + SQUARE(HEAD_H * 0.2));
            y = QUOTE(HEAD_Y + HEAD_H * 0.2);
            w = QUOTE(SQUARE(HEAD_H * 0.6));
            h = QUOTE(HEAD_H * 0.6);
        };
        class BtnSortDir_Hit: EFAK_Hitbox {
            idc = IDC_SORT_DIR;
            x = QUOTE(SORT_DIR_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(SQUARE(HEAD_H));
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(SortDirection_Tooltip);
            onButtonClick = QUOTE(call FUNC(onSortDirClicked));
        };

        // Every move takes effect the moment it is made, so there is nothing to confirm or cancel -
        // only a way out. Escape does the same.
        EFAK_PANEL(BtnClose,CLOSE_X,HEAD_Y,SQUARE(HEAD_H),HEAD_H,RADIUS_FIELD,C_FIELD);
        class BtnClose_Icon: EFAK_Icon {
            text = UI_TEX(icon_close_ca);
            x = QUOTE(CLOSE_X + SQUARE(HEAD_H * 0.22));
            y = QUOTE(HEAD_Y + HEAD_H * 0.22);
            w = QUOTE(SQUARE(HEAD_H * 0.56));
            h = QUOTE(HEAD_H * 0.56);
        };
        class BtnClose_Hit: EFAK_Hitbox {
            idc = IDC_BUTTON_CLOSE;
            x = QUOTE(CLOSE_X);
            y = QUOTE(HEAD_Y);
            w = QUOTE(SQUARE(HEAD_H));
            h = QUOTE(HEAD_H);
            tooltip = CSTRING(Close);
            onButtonClick = QUOTE(closeDialog 0);
        };

        // ----- Section row -----

        // The left list has two sources - what you are carrying and, when you are standing at one,
        // the crate or vehicle in front of you. A segmented switch picks between them.
        EFAK_PANEL(TabInventory,POUCH_X + PAD + SQUARE(TAB_INSET),SECTION_Y + TAB_INSET,TAB_W,SECTION_H - TAB_INSET * 2,RADIUS_FIELD * 0.8,C_FIELD);
        class TabInventory_Icon: EFAK_Icon {
            text = UI_TEX(icon_inventory_ca);
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET) + COL * 0.55);
            y = QUOTE(SECTION_Y + (SECTION_H - ROW * 0.8) / 2);
            w = QUOTE(SQUARE(ROW * 0.8));
            h = QUOTE(ROW * 0.8);
        };
        class TabInventory_Label: EFAK_Label {
            idc = IDC_TAB_INVENTORY_LABEL;
            text = CSTRING(Header_Inventory);
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET) + COL * 0.55 + SQUARE(ROW * 1.05));
            y = QUOTE(SECTION_Y);
            w = QUOTE(TAB_W - COL * 0.6 - SQUARE(ROW * 1.05));
            h = QUOTE(SECTION_H);
            sizeEx = QUOTE(ROW * 0.78);
            colorText[] = C_TEXT2;
        };
        class TabInventory_Hit: EFAK_Hitbox {
            idc = IDC_TAB_INVENTORY;
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET));
            y = QUOTE(SECTION_Y);
            w = QUOTE(TAB_W);
            h = QUOTE(SECTION_H);
            onButtonClick = QUOTE([SOURCE_INVENTORY] call FUNC(selectSource));
        };

        EFAK_PANEL(TabCrate,POUCH_X + PAD + SQUARE(TAB_INSET) + TAB_W,SECTION_Y + TAB_INSET,TAB_W,SECTION_H - TAB_INSET * 2,RADIUS_FIELD * 0.8,C_FIELD);
        class TabCrate_Icon: TabInventory_Icon {
            text = UI_TEX(icon_crate_ca);
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET) + TAB_W + COL * 0.55);
        };
        class TabCrate_Label: TabInventory_Label {
            idc = IDC_TAB_CRATE_LABEL;
            text = CSTRING(Header_Crate);
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET) + TAB_W + COL * 0.55 + SQUARE(ROW * 1.05));
        };
        class TabCrate_Hit: TabInventory_Hit {
            idc = IDC_TAB_CRATE;
            x = QUOTE(POUCH_X + PAD + SQUARE(TAB_INSET) + TAB_W);
            onButtonClick = QUOTE([SOURCE_CRATE] call FUNC(selectSource));
        };

        // Over the kit list: the kit's picture and what the list is, and on the right how much is in
        // it - each a control of its own, so all three sit in the middle of the row like the tabs.
        class HeaderKit_Picture: EFAK_Icon {
            idc = IDC_HEADER_KIT_PICTURE;
            x = QUOTE(LIST_RIGHT_X + SQUARE(ROW * 0.2));
            y = QUOTE(SECTION_Y + (SECTION_H - ROW * 1.1) / 2);
            w = QUOTE(SQUARE(ROW * 1.1));
            h = QUOTE(ROW * 1.1);
            colorText[] = {1, 1, 1, 1};
        };
        class HeaderKit: EFAK_Label {
            idc = IDC_HEADER_KIT;
            x = QUOTE(LIST_RIGHT_X + SQUARE(ROW * 1.6));
            y = QUOTE(SECTION_Y);
            w = QUOTE(LIST_W * 0.6);
            h = QUOTE(SECTION_H);
            sizeEx = QUOTE(ROW * 0.78);
            font = "RobotoCondensedBold";
        };
        class HeaderKitCount: EFAK_Label {
            idc = IDC_HEADER_KIT_COUNT;
            style = 1;
            x = QUOTE(LIST_RIGHT_X + LIST_W * 0.6);
            y = QUOTE(SECTION_Y);
            w = QUOTE(LIST_W * 0.4 - SQUARE(ROW * 0.3));
            h = QUOTE(SECTION_H);
            sizeEx = QUOTE(ROW * 0.72);
            colorText[] = C_MUTED;
        };

        // ----- The two lists -----

        // The name, the change since the window opened right against the count, and the count, each in a
        // colour of its own (fnc_fillList, LIST_COLUMNS). The engine drags rows of these like those of a
        // plain list.
        class ListInventory: EFAK_List {
            idc = IDC_LIST_INVENTORY;
            x = QUOTE(POUCH_X + PAD + LIST_IN_X);
            y = QUOTE(LIST_Y + CARD_IN_Y);
            w = QUOTE(LIST_W - LIST_IN_X * 2);
            h = QUOTE(LIST_H - CARD_IN_Y * 2);
            canDrag = 1;
            rowHeight = QUOTE(LIST_ROW);
            sizeEx = QUOTE(LIST_TEXT);
            columns[] = LIST_COLUMNS;
        };
        class ListKit: ListInventory {
            idc = IDC_LIST_KIT;
            x = QUOTE(LIST_RIGHT_X + LIST_IN_X);
        };

        // ----- The middle column -----

        // Whether the left list also shows what cannot go into the kit - a switch. Off by default.
        EFAK_PANEL(BtnShowAll,MID_X,LIST_Y,MID_W,ROW * 1.4,RADIUS_FIELD,C_CLEAR);
        class BtnShowAll_Icon: EFAK_Icon {
            idc = IDC_SHOW_ALL_ICON;
            style = 48;
            text = UI_TEX(toggle_off_ca);
            x = QUOTE(MID_X + SQUARE(ROW * 0.3));
            y = QUOTE(LIST_Y + ROW * 0.36);
            w = QUOTE(SQUARE(ROW * 1.36));
            h = QUOTE(ROW * 0.68);
            colorText[] = {1, 1, 1, 1};
        };
        class BtnShowAll_Label: EFAK_Label {
            idc = IDC_SHOW_ALL_LABEL;
            text = CSTRING(ShowAll);
            x = QUOTE(MID_X + SQUARE(ROW * 1.85));
            y = QUOTE(LIST_Y);
            w = QUOTE(MID_W - SQUARE(ROW * 1.9));
            h = QUOTE(ROW * 1.4);
            sizeEx = QUOTE(ROW * 0.72);
            colorText[] = C_TEXT2;
        };
        class BtnShowAll_Hit: EFAK_Hitbox {
            idc = IDC_SHOW_ALL;
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.4);
            tooltip = CSTRING(ShowAll_Tooltip);
            onButtonClick = QUOTE(GVAR(showAll) = !GVAR(showAll); call FUNC(refreshPouch));
        };

        // In the order things move: everything in, the selected stack in, how much of it, the selected
        // stack out, everything out.
        EFAK_PANEL(BtnPackAll,MID_X,MID_C - ROW * 4.7,MID_W,MID_BUTTON_H,RADIUS_FIELD,C_FIELD);
        class BtnPackAll_Icon: EFAK_Icon {
            text = UI_TEX(icon_chevrons_right_ca);
            x = QUOTE(MID_X + (MID_W - SQUARE(MID_ICON_H)) / 2);
            y = QUOTE(MID_C - ROW * 4.7 + (MID_BUTTON_H - MID_ICON_H) / 2);
            w = QUOTE(SQUARE(MID_ICON_H));
            h = QUOTE(MID_ICON_H);
        };
        class BtnPackAll_Hit: EFAK_Hitbox {
            idc = IDC_BUTTON_PACKALL;
            x = QUOTE(MID_X);
            y = QUOTE(MID_C - ROW * 4.7);
            w = QUOTE(MID_W);
            h = QUOTE(MID_BUTTON_H);
            tooltip = CSTRING(PackAll_Tooltip);
            onButtonClick = QUOTE(call FUNC(packAllPressed));
        };

        EFAK_PANEL(BtnToKit,MID_X,MID_C - ROW * 2.7,MID_W,MID_BUTTON_H,RADIUS_FIELD,C_FIELD);
        class BtnToKit_Icon: BtnPackAll_Icon {
            text = UI_TEX(icon_chevron_right_ca);
            y = QUOTE(MID_C - ROW * 2.7 + (MID_BUTTON_H - MID_ICON_H) / 2);
        };
        class BtnToKit_Hit: BtnPackAll_Hit {
            idc = IDC_BUTTON_TO_KIT;
            y = QUOTE(MID_C - ROW * 2.7);
            tooltip = CSTRING(ToKit_Tooltip);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_INVENTORY,call FUNC(getAmount))] call FUNC(transferSelected));
        };

        // How many the two buttons around it move. Empty means the whole stack.
        class Amount: EFAK_Edit {
            idc = IDC_AMOUNT;
            style = 514;
            x = QUOTE(MID_X + SQUARE(RADIUS_FIELD));
            y = QUOTE(MID_C - ROW * 0.55);
            w = QUOTE(MID_W - SQUARE(RADIUS_FIELD) * 2);
            h = QUOTE(ROW * 1.1);
            sizeEx = QUOTE(ROW * 0.85);
            font = "RobotoCondensedBold";
            maxChars = 3;
            text = "1";
            tooltip = CSTRING(Amount_Tooltip);
            onEditChanged = QUOTE(_this call FUNC(onAmountChanged));
        };

        EFAK_PANEL(BtnToInventory,MID_X,MID_C + ROW * 1.0,MID_W,MID_BUTTON_H,RADIUS_FIELD,C_FIELD);
        class BtnToInventory_Icon: BtnPackAll_Icon {
            text = UI_TEX(icon_chevron_left_ca);
            y = QUOTE(MID_C + ROW * 1.0 + (MID_BUTTON_H - MID_ICON_H) / 2);
        };
        class BtnToInventory_Hit: BtnPackAll_Hit {
            idc = IDC_BUTTON_TO_INVENTORY;
            y = QUOTE(MID_C + ROW * 1.0);
            tooltip = CSTRING(ToInventory_Tooltip);
            onButtonClick = QUOTE([ARR_2(IDC_LIST_KIT,call FUNC(getAmount))] call FUNC(transferSelected));
        };

        EFAK_PANEL(BtnUnpackAll,MID_X,MID_C + ROW * 3.0,MID_W,MID_BUTTON_H,RADIUS_FIELD,C_FIELD);
        class BtnUnpackAll_Icon: BtnPackAll_Icon {
            text = UI_TEX(icon_chevrons_left_ca);
            y = QUOTE(MID_C + ROW * 3.0 + (MID_BUTTON_H - MID_ICON_H) / 2);
        };
        class BtnUnpackAll_Hit: BtnPackAll_Hit {
            idc = IDC_BUTTON_UNPACKALL;
            y = QUOTE(MID_C + ROW * 3.0);
            tooltip = CSTRING(UnpackAll_Tooltip);
            onButtonClick = QUOTE(call FUNC(unpackAllPressed));
        };

        // Where items taken out of the kit go first, at the bottom of the column: a drop down on the
        // TakeInto field.
        class TakeIntoCaption: EFAK_Label {
            idc = IDC_TAKE_INTO_LABEL;
            style = 2;
            text = CSTRING(TakeInto);
            tooltip = CSTRING(TakeInto_Tooltip);
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y + LIST_H - ROW * 2.55);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.0);
            sizeEx = QUOTE(ROW * 0.66);
            colorText[] = C_MUTED;
        };
        class TakeInto_Label: EFAK_Label {
            idc = IDC_TAKE_INTO;
            x = QUOTE(MID_X + SQUARE(ROW * 0.4));
            y = QUOTE(LIST_Y + LIST_H - ROW * 1.5);
            w = QUOTE(MID_W - SQUARE(ROW * 1.35));
            h = QUOTE(ROW * 1.5);
            sizeEx = QUOTE(ROW * 0.72);
        };
        class TakeInto_Icon: EFAK_Icon {
            text = UI_TEX(icon_chevron_down_ca);
            x = QUOTE(MID_X + MID_W - SQUARE(ROW * 0.35) - SQUARE(ROW * 0.6));
            y = QUOTE(LIST_Y + LIST_H - ROW * 1.05);
            w = QUOTE(SQUARE(ROW * 0.6));
            h = QUOTE(ROW * 0.6);
        };
        class TakeInto_Hit: EFAK_Hitbox {
            x = QUOTE(MID_X);
            y = QUOTE(LIST_Y + LIST_H - ROW * 1.5);
            w = QUOTE(MID_W);
            h = QUOTE(ROW * 1.5);
            tooltip = CSTRING(TakeInto_Tooltip);
            onButtonClick = QUOTE(_this call FUNC(onDropdownClick));
        };

        // ----- What each side holds: what it is on the left, how much on the right -----

        class LoadText: EFAK_Label {
            idc = IDC_LOAD_TEXT;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(METER_Y);
            w = QUOTE(LIST_W * 0.5);
            h = QUOTE(METER_H);
            sizeEx = QUOTE(METER_TEXT);
            colorText[] = C_TEXT2;
        };
        class LoadValue: LoadText {
            idc = IDC_LOAD_VALUE;
            style = 1;
            x = QUOTE(POUCH_X + PAD + LIST_W * 0.5);
            colorText[] = C_TEXT;
        };
        class CapacityText: LoadText {
            idc = IDC_CAPACITY_TEXT;
            x = QUOTE(LIST_RIGHT_X);
        };
        class CapacityValue: LoadValue {
            idc = IDC_CAPACITY_VALUE;
            x = QUOTE(LIST_RIGHT_X + LIST_W * 0.5);
        };

        // ----- The bottom row: ground, uniform, vest, backpack -----

        // In each card: the picture of what is worn and its name on the left, how full it is on the
        // right, all in the middle of the space over the bar.
        class PictureGround: EFAK_Icon {
            idc = IDC_PREVIEW_PICTURE_GROUND;
            x = QUOTE(PREVIEW_IN_X(0));
            y = QUOTE(PREVIEW_HEAD_Y + (PREVIEW_HEAD_H - PREVIEW_PIC_H) / 2);
            w = QUOTE(SQUARE(PREVIEW_PIC_H));
            h = QUOTE(PREVIEW_PIC_H);
        };
        class PictureUniform: PictureGround {
            idc = IDC_PREVIEW_PICTURE_UNIFORM;
            x = QUOTE(PREVIEW_IN_X(1));
        };
        class PictureVest: PictureGround {
            idc = IDC_PREVIEW_PICTURE_VEST;
            x = QUOTE(PREVIEW_IN_X(2));
        };
        class PictureBackpack: PictureGround {
            idc = IDC_PREVIEW_PICTURE_BACKPACK;
            x = QUOTE(PREVIEW_IN_X(3));
        };

        class HeaderGround: EFAK_Label {
            idc = IDC_HEADER_GROUND;
            x = QUOTE(PREVIEW_IN_X(0) + SQUARE(PREVIEW_PIC_H) + SQUARE(ROW * 0.25));
            y = QUOTE(PREVIEW_HEAD_Y);
            w = QUOTE(PREVIEW_IN_W * 0.66 - SQUARE(PREVIEW_PIC_H));
            h = QUOTE(PREVIEW_HEAD_H);
            sizeEx = QUOTE(ROW * 0.68);
        };
        class HeaderUniform: HeaderGround {
            idc = IDC_PREVIEW_HEADER_UNIFORM;
            x = QUOTE(PREVIEW_IN_X(1) + SQUARE(PREVIEW_PIC_H) + SQUARE(ROW * 0.25));
        };
        class HeaderVest: HeaderGround {
            idc = IDC_PREVIEW_HEADER_VEST;
            x = QUOTE(PREVIEW_IN_X(2) + SQUARE(PREVIEW_PIC_H) + SQUARE(ROW * 0.25));
        };
        class HeaderBackpack: HeaderGround {
            idc = IDC_PREVIEW_HEADER_BACKPACK;
            x = QUOTE(PREVIEW_IN_X(3) + SQUARE(PREVIEW_PIC_H) + SQUARE(ROW * 0.25));
        };

        class ValueGround: EFAK_Label {
            idc = IDC_PREVIEW_VALUE_GROUND;
            style = 1;
            x = QUOTE(PREVIEW_IN_X(0) + PREVIEW_IN_W * 0.5);
            y = QUOTE(PREVIEW_HEAD_Y);
            w = QUOTE(PREVIEW_IN_W * 0.5);
            h = QUOTE(PREVIEW_HEAD_H);
            sizeEx = QUOTE(ROW * 0.68);
            colorText[] = C_TEXT2;
        };
        class ValueUniform: ValueGround {
            idc = IDC_PREVIEW_VALUE_UNIFORM;
            x = QUOTE(PREVIEW_IN_X(1) + PREVIEW_IN_W * 0.5);
        };
        class ValueVest: ValueGround {
            idc = IDC_PREVIEW_VALUE_VEST;
            x = QUOTE(PREVIEW_IN_X(2) + PREVIEW_IN_W * 0.5);
        };
        class ValueBackpack: ValueGround {
            idc = IDC_PREVIEW_VALUE_BACKPACK;
            x = QUOTE(PREVIEW_IN_X(3) + PREVIEW_IN_W * 0.5);
        };

        // Dropping a row here puts it on the ground at the player's feet; double clicking one puts it
        // back into the kit. Rows along the bottom are dragged or double clicked, never picked.
        class ListGround: ListInventory {
            idc = IDC_LIST_GROUND;
            x = QUOTE(PREVIEW_X(0) + CARD_IN_X);
            y = QUOTE(PREVIEW_LIST_Y);
            w = QUOTE(PREVIEW_W - CARD_IN_X * 2);
            h = QUOTE(PREVIEW_LIST_H);
            rowHeight = QUOTE(LIST_ROW * 0.9);
            sizeEx = QUOTE(LIST_TEXT * 0.9);
            columns[] = PREVIEW_COLUMNS;
            colorSelect[] = C_TEXT2;
            colorSelect2[] = C_TEXT2;
        };
        // A kit stack dropped here goes into this container; what arrived here while the window is
        // open can be dragged on to another container, the ground or back into the kit. The player's
        // own gear stays put.
        class ListUniform: ListGround {
            idc = IDC_PREVIEW_LIST_UNIFORM;
            x = QUOTE(PREVIEW_X(1) + CARD_IN_X);
        };
        class ListVest: ListUniform {
            idc = IDC_PREVIEW_LIST_VEST;
            x = QUOTE(PREVIEW_X(2) + CARD_IN_X);
        };
        class ListBackpack: ListUniform {
            idc = IDC_PREVIEW_LIST_BACKPACK;
            x = QUOTE(PREVIEW_X(3) + CARD_IN_X);
        };

        // ----- The hint -----

        // The controls in short, or what just happened, along the bottom of the window. Centred on its
        // height by fnc_refreshPouch. The tooltip explains the controls in full.
        class Hint: EFAK_StructuredText {
            idc = IDC_HINT;
            x = QUOTE(POUCH_X + PAD);
            y = QUOTE(HINT_Y);
            w = QUOTE(FULL_W);
            h = QUOTE(HINT_H);
            size = QUOTE(ROW * 0.62);
            class Attributes {
                font = "RobotoCondensed";
                color = HEX_TEXT2;
                align = "center";
                valign = "middle";
                shadow = 0;
            };
        };

        // How many items the current drag carries, next to the mouse: just the number, as the counts
        // in the lists show it. Hidden until a drag starts.
        class DragCount: EFAK_StructuredText {
            idc = IDC_DRAG_COUNT;
            x = 0;
            y = 0;
            w = QUOTE(COL * 1.6);
            h = QUOTE(LIST_ROW);
            size = QUOTE(LIST_TEXT);
            class Attributes {
                font = "RobotoCondensed";
                color = HEX_ACCENT;
                align = "center";
                valign = "middle";
                shadow = 0;
            };
        };
    };
};
