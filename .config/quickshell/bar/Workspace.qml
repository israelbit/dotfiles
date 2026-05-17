import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root
    height: parent.height
    implicitWidth: wsRow.width + 20
    color: "transparent"

    // ── Font passada pelo Bar.qml (evita problema de path em FontLoader filho) ──
    property string nerdFontFamily: ""

    // ── Cores ─────────────────────────────────────────────────────────────────
    readonly property color colActive:      "#a6e3a1"   // verde catppuccin mocha
    readonly property color colActiveFg:    "#1a1b26"   // texto escuro sobre o verde
    readonly property color colOccupied:    "#45475a"   // surface1 — ocupado mas inativo
    readonly property color colEmpty:       "#2d2f45"   // quase invisível
    readonly property color colUrgentPulse: "#f38ba8"   // red catppuccin

    readonly property int wsTotal: 5

    // ── Ícones NerdFont por workspace ─────────────────────────────────────────
    // FontAwesome (presente em qualquer NerdFont split): ajuste à vontade
    readonly property var wsIcons: [
        "\uf120",   // 1 — terminal
        "\uf7a2",   // 2 — browser / web
        "\uf121",   // 3 — código
        "\uf07b",   // 4 — arquivos
        "\uf001"    // 5 — mídia
    ]

    // ── Urgent tracking ───────────────────────────────────────────────────────
    property var urgentWsIds: []

    Instantiator {
        model: Hyprland.windows

        delegate: QtObject {
            required property var modelData

            readonly property bool winUrgent: modelData?.urgent        ?? false
            readonly property int  winWsId:   modelData?.workspace?.id ?? -1

            onWinUrgentChanged: {
                if (winUrgent && winWsId > 0) {
                    if (root.urgentWsIds.indexOf(winWsId) < 0)
                        root.urgentWsIds = [...root.urgentWsIds, winWsId]
                } else {
                    root.urgentWsIds = root.urgentWsIds.filter(id => id !== winWsId)
                }
            }
        }
    }

    // ── Pills ─────────────────────────────────────────────────────────────────
    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: root.wsTotal

            delegate: Item {
                id: wsItem
                property int wsId: index + 1

                // ▼ FIX PRINCIPAL: era "activeWorkspace" (não existe / não notifica)
                //   A propriedade correta no QuickShell é "focusedWorkspace"
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                // ocupado: workspace existe na lista (Hyprland destrói ws vazios)
                readonly property var  wsData:    Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isOccupied: wsData !== null && wsData !== undefined

                readonly property bool isUrgent: root.urgentWsIds.indexOf(wsId) >= 0

                // Item tem altura fixa — evita jitter no Row
                width:  isActive ? 32 : 9
                height: 16

                Behavior on width {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // Pill interna cresce quando ativa
                Rectangle {
                    id: pill
                    anchors.centerIn: parent
                    width:  parent.width
                    height: wsItem.isActive ? 16 : 9
                    radius: height / 2

                    Behavior on height {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    color: wsItem.isUrgent   ? urgCol.color
                         : wsItem.isActive   ? root.colActive
                         : wsItem.isOccupied ? root.colOccupied
                         :                     root.colEmpty

                    Behavior on color { ColorAnimation { duration: 140 } }

                    // Ícone — visível apenas no pill ativo
                    Text {
                        anchors.centerIn: parent
                        visible:         wsItem.isActive
                        text:            root.wsIcons[index]
                        color:           root.colActiveFg
                        font.family:     root.nerdFontFamily
                        font.pixelSize:  10
                    }
                }

                // ── Urgent pulse ───────────────────────────────────────────────
                QtObject {
                    id: urgCol
                    property color color: root.colOccupied
                }
                SequentialAnimation {
                    running:   wsItem.isUrgent
                    loops:     Animation.Infinite
                    onStopped: urgCol.color = root.colOccupied

                    ColorAnimation {
                        target: urgCol; property: "color"
                        from: root.colOccupied; to: root.colUrgentPulse
                        duration: 400; easing.type: Easing.InOutSine
                    }
                    ColorAnimation {
                        target: urgCol; property: "color"
                        from: root.colUrgentPulse; to: root.colOccupied
                        duration: 400; easing.type: Easing.InOutSine
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Hyprland.dispatch("workspace " + wsItem.wsId)
                }
            }
        }
    }
}
