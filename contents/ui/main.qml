/*
 * Quit Button - Plasma 6 widget
 * SPDX-FileCopyrightText: 2026 tjscha4
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Button layout and styling replicate plasma-workspace applets/appmenu
 * (main.qml, MenuDelegate.qml), SPDX-FileCopyrightText: Carson Black,
 * Kai Uwe Broulik, Sebastian Kügler, Heena Mahour; GPL-2.0-or-later.
 *
 * Written with the assistance of Claude (Anthropic).
 * Reviewed and tested by the author.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // True when a normal app window has focus. Desktop/panels are skip-taskbar,
    // so they leave activeTask invalid, which mirrors the global menu.
    readonly property bool hasActiveWindow: tasksModel.activeTask.valid

    // Stay visible (dimmed) in panel edit mode so the widget can be grabbed.
    readonly property bool editMode: Plasmoid.containment?.corona?.editMode ?? false

    // Same as stock appmenu main.qml.
    Plasmoid.constraintHints: Plasmoid.CanFillArea
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortDisabled
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: false
    }

    // Same container as stock appmenu: zero-spacing GridLayout whose minimum
    // size is its implicit size (0 when the button is hidden).
    fullRepresentation: GridLayout {
        id: buttonGrid

        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight

        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rowSpacing: 0
        columnSpacing: 0

        // Mirrors stock MenuDelegate.qml.
        QQC2.AbstractButton {
            id: quitButton

            Layout.fillWidth: root.vertical
            Layout.fillHeight: !root.vertical

            visible: root.hasActiveWindow || root.editMode
            enabled: root.hasActiveWindow
            opacity: enabled ? 1 : 0.5
            hoverEnabled: true
            focusPolicy: Qt.NoFocus
            text: Plasmoid.configuration.labelText || "Quit"

            // 0 = Rest, 1 = Hover, 2 = Down (same states as MenuDelegate).
            readonly property int menuState: down ? 2 : (hovered ? 1 : 0)

            readonly property bool showIcon: Plasmoid.configuration.showIcon
            // Breeze's 16px X glyph has ~3px transparent space per side; trim it
            // so the visible gaps match the text-only spacing.
            readonly property int iconInset: showIcon ? Math.round(iconSize * 3 / 16) : 0
            readonly property int iconSize: Kirigami.Units.iconSizes.small

            implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                    implicitContentWidth + leftPadding + rightPadding)
            implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                     implicitContentHeight + topPadding + bottomPadding)

            topPadding: rest.margins.top
            leftPadding: Math.max(0, rest.margins.left - iconInset)
            rightPadding: rest.margins.right
            bottomPadding: rest.margins.bottom

            onClicked: tasksModel.requestClose(tasksModel.activeTask)

            background: KSvg.FrameSvgItem {
                id: rest
                imagePath: "widgets/menubaritem"
                prefix: quitButton.menuState === 2 ? "pressed"
                      : quitButton.menuState === 1 ? "hover"
                      : "normal"
            }

            // Without the icon this is exactly the stock contentItem: a Label
            // filling the padded area, vertically centered by AlignVCenter.
            // With the icon, the icon is centered on that same area beside it.
            contentItem: Item {
                implicitWidth: (icon.visible ? icon.width + iconGap : 0) + label.implicitWidth
                implicitHeight: label.implicitHeight

                readonly property int iconGap: Math.max(0, Kirigami.Units.smallSpacing
                                                           - quitButton.iconInset)

                Kirigami.Icon {
                    id: icon
                    visible: quitButton.showIcon
                    source: "window-close"
                    width: quitButton.iconSize
                    height: quitButton.iconSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                PC3.Label {
                    id: label
                    x: icon.visible ? icon.width + parent.iconGap : 0
                    width: parent.width - x
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    text: quitButton.text
                    textFormat: Text.StyledText
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    color: quitButton.menuState === 0 ? Kirigami.Theme.textColor
                                                      : Kirigami.Theme.highlightedTextColor
                }
            }
        }
    }
}
