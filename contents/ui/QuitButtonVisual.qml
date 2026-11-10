/*
 * Quit Button - the button's appearance (used by the widget and its preview)
 * SPDX-FileCopyrightText: 2026 tjscha4
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Layout and styling replicate plasma-workspace applets/appmenu
 * MenuDelegate.qml, SPDX-FileCopyrightText: Carson Black; GPL-2.0-or-later.
 * The Red highlight follows the Breeze window decoration's close button
 * (KDE breeze, kdecoration/breezebutton.cpp; GPL-2.0-or-later).
 *
 * Written with the assistance of Claude (Anthropic); reviewed and tested by the author.
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

QQC2.AbstractButton {
    id: quitButton

    // 0 = Text Only, 1 = Icon Only, 2 = Text & Icon
    property int displayMode: 0
    // false = Breeze (Plasma theme), true = Red (title-bar close button)
    property bool redHighlight: false
    // false = Close ("Close", X icon), true = Force Quit ("Quit", force quit icon)
    property bool forceQuitAction: false
    // Keep the pressed look (e.g. while the confirmation menu is open).
    property bool forceDown: false

    readonly property bool showText: displayMode !== 1
    readonly property bool showIcon: displayMode !== 0

    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    text: forceQuitAction ? "Quit" : "Close"

    // Accessible name even when only the icon is shown.
    Accessible.name: text

    down: pressed || forceDown

    // 0 = Rest, 1 = Hover, 2 = Down (same states as MenuDelegate).
    readonly property int menuState: down ? 2 : (hovered ? 1 : 0)

    readonly property int iconSize: Kirigami.Units.iconSizes.small
    // Transparent space each Breeze glyph has per side at 16px
    // (window-close ~3px, process-stop ~2px). With text beside the
    // icon, trim it so the visible gaps match the text-only spacing.
    // Icon Only stays symmetric, so no trimming there.
    readonly property int iconInset: (showIcon && showText)
        ? Math.round(iconSize * (forceQuitAction ? 2 : 3) / 16) : 0

    // Breeze decoration close button: the color scheme's negative red,
    // lighter on hover and darker when pressed, with the glyph drawn
    // in the bar's background color.
    readonly property color redBase: Kirigami.Theme.negativeTextColor
    readonly property color foreground: {
        if (menuState === 0) {
            return Kirigami.Theme.textColor;
        }
        return redHighlight ? Kirigami.Theme.backgroundColor : Kirigami.Theme.highlightedTextColor;
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: rest.margins.top
    leftPadding: Math.max(0, rest.margins.left - iconInset)
    rightPadding: rest.margins.right
    bottomPadding: rest.margins.bottom

    background: Item {
        // Breeze: the theme's own menubaritem frames, as in the Global Menu.
        // Red: the same frame supplies margins; the highlight is drawn
        // in the shape of Breeze's menubaritem hover (5px corner radius,
        // inset 1.5px top and bottom).
        KSvg.FrameSvgItem {
            id: rest
            anchors.fill: parent
            imagePath: "widgets/menubaritem"
            prefix: (!quitButton.redHighlight && quitButton.menuState === 2) ? "pressed"
                  : (!quitButton.redHighlight && quitButton.menuState === 1) ? "hover"
                  : "normal"
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1.5
            anchors.bottomMargin: 1.5
            radius: 5
            visible: quitButton.redHighlight && quitButton.menuState !== 0
            color: quitButton.menuState === 2 ? Qt.darker(quitButton.redBase, 2.0)
                                              : Qt.lighter(quitButton.redBase, 1.5)
        }
    }

    // Text: exactly the stock contentItem (a Label filling the padded
    // area, vertically centered by AlignVCenter). The icon is centered
    // on the same area and drawn in the label's color.
    contentItem: Item {
        readonly property int iconGap: Math.max(0, Kirigami.Units.smallSpacing
                                                   - quitButton.iconInset)

        implicitWidth: (quitButton.showIcon ? quitButton.iconSize : 0)
                     + (quitButton.showIcon && quitButton.showText ? iconGap : 0)
                     + (quitButton.showText ? label.implicitWidth : 0)
        implicitHeight: label.implicitHeight

        Kirigami.Icon {
            id: icon
            visible: quitButton.showIcon
            source: quitButton.forceQuitAction ? "process-stop" : "window-close"
            // Recolor to the text color (white on dark themes) instead
            // of the icon's own colors, e.g. process-stop's red.
            isMask: true
            color: quitButton.foreground
            width: quitButton.iconSize
            height: quitButton.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        PC3.Label {
            id: label
            visible: quitButton.showText
            x: quitButton.showIcon ? icon.width + parent.iconGap : 0
            width: parent.width - x
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            text: quitButton.text
            textFormat: Text.StyledText
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: quitButton.foreground
        }
    }
}
