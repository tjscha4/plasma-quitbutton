import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property string cfg_labelText
    property alias cfg_showIcon: iconCheck.checked

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: labelCombo
            Kirigami.FormData.label: "Label:"
            model: ["Quit", "Close"]
            currentIndex: Math.max(0, model.indexOf(cfg_labelText))
            onActivated: cfg_labelText = currentText
        }

        QQC2.CheckBox {
            id: iconCheck
            Kirigami.FormData.label: "Icon:"
            text: "Show close (X) icon before the label"
        }
    }
}
