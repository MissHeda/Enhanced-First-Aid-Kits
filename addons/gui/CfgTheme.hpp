// The look of the kit window and the contents window. Another mod restyles both by changing these
// values in its own config.cpp (requiredAddons[] = {"efak_gui"}) - nothing else of EFAK to patch, so
// the look survives EFAK updates. fnc_applyTheme puts them on the windows when they open.
//
//   accent[]       the highlight: counts, the take button, bar fills, chosen menu entries
//   accentHover[]  the highlight under the mouse
//   accentSoft[]   the selection bars of the lists
//   onAccent[]     text and icons on the highlight
//   window[]       the glass of both windows
//   glossPouch     texture over the whole kit window, its sheen and light edge ("" for none)
//   glossContents  the same for the contents window
//
// Colours are {r, g, b, a} from 0 to 1. A value that is missing or malformed keeps EFAK's own.
class EFAK_Theme {
    accent[] = C_ACCENT;
    accentHover[] = {RGBA_ACCENT_HOVER};
    accentSoft[] = C_ACCENT_SOFT;
    onAccent[] = C_ON_ACCENT;
    window[] = C_WINDOW;
    glossPouch = UI_TEX(gloss_pouch_ca);
    glossContents = UI_TEX(gloss_contents_ca);
};
