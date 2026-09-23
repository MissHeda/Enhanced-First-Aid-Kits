class RscText;
class RscControlsGroupNoScrollbars;
class ctrlStaticBackground;
class ctrlProgress;
class RscCheckBox;

// Every EFAK control hides itself the moment the arsenal display is built. Only the tab's own
// scripts ever show one - and in the Eden editor, where the arsenal runs without a mission, they
// never do. A control that is merely faded out still sits on top of ACE's lists there and takes
// their clicks.
#define EFAK_STARTS_HIDDEN onLoad = QUOTE((_this select 0) ctrlShow false)
// ACE's own category button, the one mods get when they register a right panel button.
class ace_arsenal_customArsenalButton_Background;
class ace_arsenal_customArsenalButton_Button;

// ACE Arsenal has no way to register a left tab: every panel function switches on ACE's own tab
// IDCs. So the kits tab is an overlay - its own button, lists and bars laid over ACE's panels,
// while ACE keeps believing its previous tab is open. Nothing of ACE's is replaced.
class ace_arsenal_display {
    class controls {
        class ArrowLeft;
        class ArrowRight;
        class blockLeftFrame;
        class blockLeftBackground;
        class leftTabContent;
        class rightTabContentListnBox;
        class buttonRemoveAll;
        class sortRightTab;
        class sortRightTabDirection;
        class rightSearchbar;
        class rightSearchbarButton;

        // Search and sort above the contents list: ACE's own right panel controls, with EFAK's
        // handlers. The focus flag is ACE's, so ACE's key handler lets typing through.
        class GVAR(searchbar): rightSearchbar {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_SEARCH;
            fade = 1;
            enable = 0;
            onSetFocus = QUOTE(ACEGVAR(arsenal,rightSearchbarFocus) = true);
            onKillFocus = QUOTE(ACEGVAR(arsenal,rightSearchbarFocus) = false);
            onMouseButtonClick = QUOTE(_this call FUNC(onSearchClick));
            onEditChanged = QUOTE(_this call FUNC(onSearchChanged));
        };
        class GVAR(searchbarButton): rightSearchbarButton {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_SEARCH_BUTTON;
            fade = 1;
            enable = 0;
            onButtonClick = QUOTE(ctrlSetFocus (ctrlParent (_this select 0) displayCtrl IDC_EFAK_SEARCH));
        };
        class GVAR(sort): sortRightTab {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_SORT;
            fade = 1;
            enable = 0;
            onLBSelChanged = QUOTE(_this call FUNC(onSortChanged));
        };
        class GVAR(sortDirection): sortRightTabDirection {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_SORT_DIR;
            fade = 1;
            enable = 0;
            onLBSelChanged = QUOTE(_this call FUNC(onSortChanged));
        };


        class tabLeft: RscControlsGroupNoScrollbars {
            class controls {
                class iconBackgroundPrimaryWeapon;
                class buttonPrimaryWeapon;

                // ACE's tabs below the backpack keep their config positions. updateTabSlot moves them
                // down a slot only while the unit carries a kit, and shows this tab in the gap.
                class GVAR(iconBackgroundKits): iconBackgroundPrimaryWeapon {
                    EFAK_STARTS_HIDDEN;
                    idc = IDC_EFAK_TAB_BACKGROUND;
                    y = QUOTE(70 * GRID_H);
                };
                // Starts out invisible and switched off: the tab only comes alive once EFAK has
                // checked that the arsenal is editing the player's own unit in a running mission.
                // The Eden editor opens this arsenal without a mission, so none of EFAK's arsenal
                // scripts run there - anything that relied on them to hide it would sit on top of
                // ACE's own buttons.
                class GVAR(buttonKits): buttonPrimaryWeapon {
                    EFAK_STARTS_HIDDEN;
                    idc = IDC_EFAK_TAB;
                    text = QPATHTOF(ui\efak_logo.paa);
                    tooltip = CSTRING(Tab_Tooltip);
                    onButtonClick = QUOTE(if !(isNil QQFUNC(openTab)) then {[ctrlParent (_this select 0)] call FUNC(openTab)});
                    enable = 0;
                    fade = 1;
                    y = QUOTE(70 * GRID_H);
                };
            };
        };

        // ----- Left panel -----
        // Everything below starts invisible and switched off, and is only brought up by openTab.

        class GVAR(leftTitle): RscText {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_LEFT_TITLE;
            fade = 1;
            enable = 0;
            text = CSTRING(Header_Kits);
            colorBackground[] = {0, 0, 0, 0.8};
            x = QUOTE(safeZoneX + 13 * GRID_W);
            y = QUOTE(safeZoneY + 1.8 * GRID_H);
            w = QUOTE(80 * GRID_W);
            h = QUOTE(6 * GRID_H);
            sizeEx = QUOTE(5 * GRID_H);
        };
        class GVAR(leftHint): GVAR(leftTitle) {
            idc = IDC_EFAK_LEFT_HINT;
            text = CSTRING(Hint_Kits);
            colorText[] = {1, 1, 1, 0.7};
            colorBackground[] = {0, 0, 0, 0.5};
            y = QUOTE(safeZoneY + 8 * GRID_H);
            sizeEx = QUOTE(4.5 * GRID_H);
        };
        // Borrows ACE's left list focus flag on purpose: ACE's key handler swallows the arrow keys
        // unless one of its lists has focus, and that flag is what lets up/down move through this one.
        class GVAR(kitList): leftTabContent {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_KIT_LIST;
            fade = 1;
            enable = 0;
            // White, and a size down from ACE's own left list (7). The selection bar is see-through,
            // so the white text stays readable on the selected row.
            sizeEx = QUOTE(6 * GRID_H);
            colorText[] = {1, 1, 1, 1};
            colorSelect[] = {1, 1, 1, 1};
            colorSelect2[] = {1, 1, 1, 1};
            colorSelectBackground[] = {1, 1, 1, 0.25};
            colorSelectBackground2[] = {1, 1, 1, 0.25};
            onLBSelChanged = QUOTE(call FUNC(onKitSelected));
            onLBDblClick = "";
            onSetFocus = QUOTE(ACEGVAR(arsenal,leftTabFocus) = true; GVAR(kitListFocus) = true);
            onKillFocus = QUOTE(ACEGVAR(arsenal,leftTabFocus) = false; GVAR(kitListFocus) = false);
        };

        // ----- Right panel -----
        // Built from ACE's left panel pieces, which are named the same in every ACE version.

        class GVAR(rightFrame): blockLeftFrame {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_RIGHT_FRAME;
            fade = 1;
            enable = 0;
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            h = QUOTE(safeZoneH - 34 * GRID_H);
        };
        class GVAR(rightBackground): blockLeftBackground {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_RIGHT_BACKGROUND;
            fade = 1;
            enable = 0;
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            h = QUOTE(safeZoneH - 34 * GRID_H);
        };

        // Declared before the list they belong to, the same order ACE uses for its own arrows.
        class GVAR(arrowMinus): ArrowLeft {
            idc = IDC_EFAK_ARROW_MINUS;
            onButtonClick = QUOTE([ARR_2(ctrlParent (_this select 0),-1)] call FUNC(buttonCargo));
        };
        class GVAR(arrowPlus): ArrowRight {
            idc = IDC_EFAK_ARROW_PLUS;
            onButtonClick = QUOTE([ARR_2(ctrlParent (_this select 0),1)] call FUNC(buttonCargo));
        };

        // Must not set ACE's rightTabLnBFocus: ACE's key handler would then run its own cargo
        // function on the arrow keys. rightTabFocus only lets up/down through.
        class GVAR(contentsList): rightTabContentListnBox {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_CONTENTS;
            fade = 1;
            enable = 0;
            idcLeft = IDC_EFAK_ARROW_MINUS;
            idcRight = IDC_EFAK_ARROW_PLUS;
            // Row colours are set per cell, which the selection keeps - on a solid white bar the
            // selected row's text vanished. A see-through bar keeps it readable.
            colorSelectBackground[] = {1, 1, 1, 0.25};
            colorSelectBackground2[] = {1, 1, 1, 0.25};
            onLBSelChanged = QUOTE(call FUNC(onContentSelected));
            onLBDblClick = "";
            onSetFocus = QUOTE(ACEGVAR(arsenal,rightTabFocus) = true; GVAR(contentsFocus) = true);
            onKillFocus = QUOTE(ACEGVAR(arsenal,rightTabFocus) = false; GVAR(contentsFocus) = false);
        };

        class GVAR(rightTitle): GVAR(leftTitle) {
            idc = IDC_EFAK_RIGHT_TITLE;
            text = "";
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
        };
        class GVAR(rightHint): GVAR(leftHint) {
            idc = IDC_EFAK_RIGHT_HINT;
            text = "";
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
        };

        // Same place and look as ACE's container load bar.
        class GVAR(loadBackground): ctrlStaticBackground {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_LOAD_BACKGROUND;
            fade = 1;
            enable = 0;
            colorBackground[] = {0, 0, 0, 0.5};
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            y = QUOTE(safeZoneH + safeZoneY - 20 * GRID_H);
            w = QUOTE(80 * GRID_W);
            h = QUOTE(6 * GRID_H);
        };
        class GVAR(loadBar): ctrlProgress {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_LOAD_BAR;
            fade = 1;
            enable = 0;
            style = 0;
            texture = "#(argb,8,8,3)color(1,1,1,1)";
            colorBar[] = {1, 1, 1, 1};
            colorFrame[] = {0, 0, 0, 1};
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            y = QUOTE(safeZoneH + safeZoneY - 20 * GRID_H);
            w = QUOTE(80 * GRID_W);
            h = QUOTE(6 * GRID_H);
        };

        // Exactly where ACE puts the item info it shows for the selected row, and the same size:
        // the box runs from 14 grid rows off the bottom to 2, level with the buttons. The word is
        // on the left, the number right against the edge, the way ACE writes a weight.
        class GVAR(loadTitle): GVAR(leftTitle) {
            idc = IDC_EFAK_LOAD_TITLE;
            style = ST_LEFT;
            text = CSTRING(Load);
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            y = QUOTE(safeZoneH + safeZoneY - 14 * GRID_H);
            w = QUOTE(30 * GRID_W);
            h = QUOTE(7 * GRID_H);
            sizeEx = QUOTE(5.5 * GRID_H);
        };
        class GVAR(loadText): GVAR(loadTitle) {
            idc = IDC_EFAK_LOAD_TEXT;
            style = ST_RIGHT;
            text = "";
            x = QUOTE(safeZoneX + safeZoneW - 63 * GRID_W);
            w = QUOTE(50 * GRID_W);
        };

        // The second line of that box, where ACE writes the author: whether this kit comes back
        // from a saved loadout with the mission's default contents. A square box, then its label.
        class GVAR(useDefaults): RscCheckBox {
            idc = IDC_EFAK_DEFAULTS;
            EFAK_STARTS_HIDDEN;
            fade = 1;
            enable = 0;
            tooltip = CSTRING(UseDefaults_Tooltip);
            // The same black in every state - by default a clicked or hovered box loses it.
            colorBackground[] = {0, 0, 0, 0.8};
            colorBackgroundFocused[] = {0, 0, 0, 0.8};
            colorBackgroundHover[] = {0, 0, 0, 0.8};
            colorBackgroundPressed[] = {0, 0, 0, 0.8};
            colorBackgroundDisabled[] = {0, 0, 0, 0.8};
            x = QUOTE(safeZoneX + safeZoneW - 93 * GRID_W);
            y = QUOTE(safeZoneH + safeZoneY - 7 * GRID_H);
            w = QUOTE(5 * GRID_W);
            h = QUOTE(5 * GRID_H);
            onCheckedChanged = QUOTE(_this call FUNC(onUseDefaultsChanged));
        };
        class GVAR(useDefaultsLabel): GVAR(loadTitle) {
            idc = IDC_EFAK_DEFAULTS_LABEL;
            text = CSTRING(UseDefaults);
            tooltip = CSTRING(UseDefaults_Tooltip);
            x = QUOTE(safeZoneX + safeZoneW - 88 * GRID_W);
            y = QUOTE(safeZoneH + safeZoneY - 7 * GRID_H);
            w = QUOTE(75 * GRID_W);
            h = QUOTE(5 * GRID_H);
            sizeEx = QUOTE(4.5 * GRID_H);
        };

        // The kits' own category button, for missions that leave the kits among the medical items.
        // It is only up while the tab is, and openTab drops it in under ACE's last category button.
        class GVAR(categoryBackground): ace_arsenal_customArsenalButton_Background {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_CATEGORY_BG;
        };
        // ACE's class is visible and live by default, and sits on the first custom slot - in the
        // Eden editor, where openTab never runs, it covered another mod's button.
        class GVAR(categoryButton): ace_arsenal_customArsenalButton_Button {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_CATEGORY;
            fade = 1;
            enable = 0;
            text = QPATHTOF(ui\efak_logo.paa);
            tooltip = CSTRING(Button_Contents);
            onButtonClick = QUOTE([ARR_3(ctrlParent (_this select 0),ctrlIDC (_this select 0),true)] call FUNC(selectCategory));
        };

        class GVAR(buttonClear): buttonRemoveAll {
            EFAK_STARTS_HIDDEN;
            idc = IDC_EFAK_CLEAR;
            tooltip = CSTRING(Clear_Tooltip);
            onButtonClick = QUOTE([ctrlParent (_this select 0)] call FUNC(buttonClear));
        };
    };
};
