/*
 * SPDX-FileCopyrightText: 2026 tjscha4
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksvg as KSvg

KCM.SimpleKCM {
    id: page

    property int cfg_displayMode
    property int cfg_highlightColor
    property int cfg_action
    property bool cfg_confirmForceQuit

    Kirigami.FormLayout {
        // ---- Appearance ----
        QQC2.ButtonGroup { id: modeGroup }

        QQC2.RadioButton {
            Kirigami.FormData.label: "Appearance:"
            QQC2.ButtonGroup.group: modeGroup
            text: "Text Only"
            checked: page.cfg_displayMode === 0
            onToggled: if (checked) page.cfg_displayMode = 0
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: modeGroup
            text: "Icon Only"
            checked: page.cfg_displayMode === 1
            onToggled: if (checked) page.cfg_displayMode = 1
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: modeGroup
            text: "Text & Icon"
            checked: page.cfg_displayMode === 2
            onToggled: if (checked) page.cfg_displayMode = 2
        }

        Item { Kirigami.FormData.isSection: true }

        // ---- Highlight Color ----
        QQC2.ButtonGroup { id: highlightGroup }

        QQC2.RadioButton {
            Kirigami.FormData.label: "Highlight Color:"
            QQC2.ButtonGroup.group: highlightGroup
            text: "Breeze"
            checked: page.cfg_highlightColor === 0
            onToggled: if (checked) page.cfg_highlightColor = 0
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: highlightGroup
            text: "Red"
            checked: page.cfg_highlightColor === 1
            onToggled: if (checked) page.cfg_highlightColor = 1
        }

        Item { Kirigami.FormData.isSection: true }

        // ---- Action ----
        QQC2.ButtonGroup { id: actionGroup }

        QQC2.RadioButton {
            Kirigami.FormData.label: "Action:"
            QQC2.ButtonGroup.group: actionGroup
            text: "Close"
            checked: page.cfg_action === 0
            onToggled: if (checked) page.cfg_action = 0
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: actionGroup
            text: "Force Quit"
            checked: page.cfg_action === 1
            onToggled: if (checked) page.cfg_action = 1
        }
        QQC2.CheckBox {
            leftPadding: Kirigami.Units.gridUnit
            enabled: page.cfg_action === 1
            text: "Ask for confirmation before Force Quit"
            checked: page.cfg_confirmForceQuit
            onToggled: page.cfg_confirmForceQuit = checked
        }

        Item { Kirigami.FormData.isSection: true }

        // ---- Preview ----
        // Shows the current (not yet applied) choices on a panel-style
        // background. Hover or press it to see the highlight; it does
        // nothing when clicked.
        Item {
            Kirigami.FormData.label: "Preview:"
            implicitWidth: previewButton.implicitWidth + Kirigami.Units.gridUnit * 2
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.2)

            KSvg.FrameSvgItem {
                id: previewPanel
                anchors.fill: parent
                imagePath: "widgets/panel-background"
            }

            QuitButtonVisual {
                id: previewButton
                // Left edge lines up with the radio buttons' circles above.
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                height: parent.height - previewPanel.margins.top - previewPanel.margins.bottom
                width: implicitWidth

                displayMode: page.cfg_displayMode
                redHighlight: page.cfg_highlightColor === 1
                forceQuitAction: page.cfg_action === 1
            }
        }
    }
}
