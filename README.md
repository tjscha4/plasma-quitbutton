# Quit Button

A small KDE Plasma 6 panel widget that adds a **Quit** (or **Close**) button next to the Global Menu. Clicking it closes the focused window. Like the Global Menu, it hides itself when no application window has focus.

## Features

- Label: choose **Quit** or **Close**
- Optional close (X) icon to the left of the label
- Matches the Global Menu's look: same spacing, hover/pressed highlight, and text colors, using your Plasma theme
- Works with or without the Global Menu widget in the panel
- Stays visible (dimmed) in panel edit mode so it can be moved

## Install

**From the KDE Store:** Add Widgets → Get New Widgets → Download New Plasma Widgets → search "Quit Button".

**From a release file:** download the `.plasmoid` from [Releases](../../releases), then:

```bash
kpackagetool6 -t Plasma/Applet -i quitbutton-<version>.plasmoid
```

**From source:**

```bash
git clone https://github.com/tjscha4/plasma-quitbutton.git
kpackagetool6 -t Plasma/Applet -i plasma-quitbutton
```

Then add **Quit Button** to a panel via Add Widgets, ideally right after the Global Menu. Right-click → Configure to change the label or toggle the icon.

## Notes

The button sends a standard window close request, the same as the title-bar X or Alt+F4. In apps with multiple windows it closes the focused window only, rather than quitting the whole app like Ctrl+Q. Apps with unsaved changes will still prompt you.

## Requirements

KDE Plasma 6.0 or newer.

## Credits

- Button layout and styling replicate the KDE Global Menu applet from [plasma-workspace](https://invent.kde.org/plasma/plasma-workspace) (`applets/appmenu`: `main.qml` and `MenuDelegate.qml`), © Carson Black, Kai Uwe Broulik, Sebastian Kügler, Heena Mahour and KDE contributors, GPL-2.0-or-later.
- Uses KDE Frameworks and Plasma libraries: Plasma, Kirigami, KSvg, KCMUtils, and the Plasma task manager library (libtaskmanager).
- The button background is drawn by your Plasma theme's `widgets/menubaritem` graphics; the close icon is `window-close` from your icon theme (Breeze by default).

## AI disclosure

This widget was written with the help of an AI assistant (Claude by Anthropic). I directed the design, tested each version on my own system, and reviewed the final code.

## License

GPL-2.0-or-later. See [LICENSE](LICENSE).
