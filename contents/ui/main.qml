/*
 * Quit Button - Plasma 6 widget
 * SPDX-FileCopyrightText: 2026 tjscha4
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Button layout and styling replicate plasma-workspace applets/appmenu
 * (main.qml, MenuDelegate.qml), SPDX-FileCopyrightText: Carson Black,
 * Kai Uwe Broulik, Sebastian Kügler, Heena Mahour; GPL-2.0-or-later.
 * The Red highlight follows the Breeze window decoration's close button
 * (KDE breeze, kdecoration/breezebutton.cpp; GPL-2.0-or-later).
 *
 * Written with the assistance of Claude (Anthropic); reviewed and tested by the author.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
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

    // Appearance: 0 = Text Only, 1 = Icon Only, 2 = Text & Icon
    readonly property int displayMode: Plasmoid.configuration.displayMode

    // Action: Force Quit uses "Quit" + the force quit icon; Close uses
    // "Close" + the close (X) icon.
    readonly property bool forceQuitAction: Plasmoid.configuration.action === 1

    // Highlight: false = Breeze (Plasma theme), true = Red (title-bar close).
    readonly property bool redHighlight: Plasmoid.configuration.highlightColor === 1

    property Item button: null
    property QtObject confirmMenu: null

    // Same as stock appmenu main.qml.
    Plasmoid.constraintHints: Plasmoid.CanFillArea
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // Carry over 0.9's "show icon" checkbox to the new Appearance setting once.
    Component.onCompleted: {
        if (!Plasmoid.configuration.displayModeMigrated) {
            if (Plasmoid.configuration.showIcon) {
                Plasmoid.configuration.displayMode = 2;
            }
            Plasmoid.configuration.displayModeMigrated = true;
        }
    }

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortDisabled
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: false
    }

    // Runs the Force Quit command.
    P5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    // ---- Actions ----

    function activate(): void {
        if (!tasksModel.activeTask.valid) {
            return;
        }
        if (forceQuitAction) {
            const p = parseInt(tasksModel.data(tasksModel.activeTask, TaskManager.AbstractTasksModel.AppPid));
            if (isNaN(p) || p <= 0) {
                return;
            }
            const appName = tasksModel.data(tasksModel.activeTask, TaskManager.AbstractTasksModel.AppName)
                         || tasksModel.data(tasksModel.activeTask, Qt.DisplayRole) || "";
            if (Plasmoid.configuration.confirmForceQuit) {
                openConfirm(p, appName);
            } else {
                forceQuit(p);
            }
        } else {
            tasksModel.requestClose(tasksModel.activeTask);
        }
    }

    // SIGKILL the app's process, like KWin's "Terminate" for frozen apps.
    // Refuses Plasma's own processes so this can never kill the desktop.
    function forceQuit(pid): void {
        if (!(pid > 0)) {
            return;
        }
        const cmd = "sh -c 'c=$(ps -o comm= -p " + pid + "); "
            + "case \"$c\" in plasmashell|kwin_wayland|kwin_x11|ksmserver|krunner|kded6|\"\") exit 1;; esac; "
            + "kill -KILL " + pid + "'";
        commandRunner.connectSource(cmd);
    }

    function menuPlacement(): int {
        if (Plasmoid.location === PlasmaCore.Types.LeftEdge) {
            return PlasmaExtras.Menu.RightPosedTopAlignedPopup;
        } else if (Plasmoid.location === PlasmaCore.Types.TopEdge) {
            return PlasmaExtras.Menu.BottomPosedLeftAlignedPopup;
        } else if (Plasmoid.location === PlasmaCore.Types.RightEdge) {
            return PlasmaExtras.Menu.LeftPosedTopAlignedPopup;
        }
        return PlasmaExtras.Menu.TopPosedLeftAlignedPopup;
    }

    function openConfirm(pid, appName): void {
        if (!button || confirmMenu) {
            return;
        }
        const menu = confirmComponent.createObject(root, {
            visualParent: button,
            pid: pid,
            appLabel: appName,
        });
        if (menu) {
            confirmMenu = menu;
            menu.openRelative();
        }
    }

    Component {
        id: confirmComponent

        PlasmaExtras.Menu {
            id: confirm

            property int pid: 0
            property string appLabel: ""

            placement: root.menuPlacement()
            minimumWidth: visualParent ? visualParent.width : 0

            onStatusChanged: {
                if (status === PlasmaExtras.Menu.Closed) {
                    confirm.destroy();
                }
            }

            PlasmaExtras.MenuItem {
                section: true
                text: confirm.appLabel !== "" ? "Force quit " + confirm.appLabel + "?" : "Force quit this app?"
            }

            PlasmaExtras.MenuItem {
                enabled: false
                text: "Unsaved work will be lost."
            }

            PlasmaExtras.MenuItem {
                text: "Force Quit"
                icon: "process-stop"
                onClicked: root.forceQuit(confirm.pid)
            }

            PlasmaExtras.MenuItem {
                text: "Cancel"
                icon: "dialog-cancel"
            }
        }
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

        // Appearance lives in QuitButtonVisual.qml (shared with the settings preview).
        QuitButtonVisual {
            id: quitButton

            Layout.fillWidth: root.vertical
            Layout.fillHeight: !root.vertical

            visible: root.hasActiveWindow || root.editMode
            enabled: root.hasActiveWindow
            opacity: enabled ? 1 : 0.5

            displayMode: root.displayMode
            redHighlight: root.redHighlight
            forceQuitAction: root.forceQuitAction
            // Look pressed while the confirmation menu is open, like the Global Menu.
            forceDown: root.confirmMenu !== null

            Component.onCompleted: root.button = quitButton
            onClicked: root.activate()
        }
    }
}
