import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import Quickshell.Io
import "./"

PanelWindow {
    id: bar
    color: "transparent"
    implicitHeight: showWifiSelector ? 24 + wifiSelector.height : 24
    focusable: bar.showWifiSelector

    // ▼ FIX principal: mantém o espaço reservado em 24px independente da altura total
    exclusiveZone: 24

    property bool showWifiSelector: false
    property real sharedWidth: 140
    Behavior on sharedWidth {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    anchors { top: true; left: true; right: true }

    FontLoader { id: scientifica; source: "./fonts/scientifica.ttf" }
    FontLoader { id: nerdFont;    source: "./fonts/SymbolsNerdFont-Regular.ttf" }

    // ── Barra (sempre 24px de visual) ────────────────────────────────────
    Rectangle {
        id: mainRect
        y: 0; width: parent.width; height: 24
        color: "#414868A1"; radius: 12

        QtObject {
            id: theme
            property string main: scientifica.font.family
            property string icon: nerdFont.font.family
            property real   size: 30
        }

        Row {
            anchors.left: parent.left
            height: 24; spacing: 30
            Menu { menuWidgetFg: "#A9B1D6"; menuWidgetBg: "#1A1B26" }
        }

        Row {
            height: 24
            anchors.centerIn: parent

            Workspace { nerdFontFamily: nerdFont.font.family }
        }

        Row {
            id: rightRow
            anchors.right: parent.right
            height: 24; spacing: 5

            Network {
                id: networkWidget
                width: bar.sharedWidth
                fontFamily:      "scientifica"
                fontSizeSymbol:  16
                networkWidgetFg: "#A9B1D6"
                networkWidgetBg: "#1A1B26"
                onClicked: {
                    bar.showWifiSelector = !bar.showWifiSelector
                    bar.sharedWidth = bar.showWifiSelector ? 260 : 140
                    if (bar.showWifiSelector) wifiSelector.triggerScan()
                }
            }
            Ram     { ramWidgetFg:     "#A9B1D6"; ramWidgetBg:     "#1A1B26" }
            Cpu     { cpuWidgetFg:     "#A9B1D6"; cpuWidgetBg:     "#1A1B26" }
            Battery { batteryWidgetFg: "#A9B1D6"; batteryWidgetBg: "#1A1B26" }
            Clock   { fontFamily: "scientifica";  clockWidgetBg: "#1A1B26"; clockWidgetFg: "#A9B1D6" }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  WIFI SELECTOR
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: wifiSelector
        visible: bar.showWifiSelector
        width: bar.sharedWidth

        x: networkWidget.x + rightRow.x
        y: 24

        property int _fixedH: 12 + hdrCol.implicitHeight + 6 + 12
        property int _listAvail: Math.max(40, 300 - _fixedH)
        height: _fixedH + Math.min(netCol.implicitHeight, _listAvail)

        radius: 16; color: "#1A1B26"; clip: true

        // ── estado ────────────────────────────────────────────────────────
        property var    networks:          []
        property var    savedNets:         []
        property string selectedSsid:      ""
        property bool   scanning:          false
        property string statusMsg:         ""
        property string shownPasswordSsid: ""
        property string shownPassword:     ""

        // ── cabeçalho ─────────────────────────────────────────────────────
        Column {
            id: hdrCol
            anchors {
                top: parent.top; topMargin: 12
                left: parent.left; leftMargin: 12
                right: parent.right; rightMargin: 12
            }
            spacing: 6

            Row {
                width: parent.width; spacing: 6

                Text {
                    text: wifiSelector.scanning ? "Scanning…" : "Wi-Fi"
                    font.family: "scientifica"; font.pixelSize: 13; font.bold: true
                    color: "#A9B1D6"
                    width: parent.width - scanBtn.width - 6
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: scanBtn; width: 28; height: 28; radius: 8
                    color: scanMa.containsMouse ? "#2a2b3d" : "#22223a"
                    Text {
                        anchors.centerIn: parent; text: "\u{0F0547}"
                        font.pixelSize: 14; font.family: "scientifica"; color: "#A9B1D6"
                    }
                    MouseArea {
                        id: scanMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: wifiSelector.triggerScan()
                    }
                }
            }

            Text {
                visible: wifiSelector.statusMsg !== ""
                text: wifiSelector.statusMsg
                font.family: "scientifica"; font.pixelSize: 11; color: "#ff6666"
                wrapMode: Text.WordWrap; width: parent.width
            }
        }

        // ── lista scrollável ──────────────────────────────────────────────
        Flickable {
            id: netFlick
            anchors {
                top: hdrCol.bottom; topMargin: 6
                left: parent.left; right: parent.right
                bottom: parent.bottom; bottomMargin: 12
            }
            contentWidth: width
            contentHeight: netCol.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            // scrollbar sutil
            Rectangle {
                anchors.right: parent.right; anchors.rightMargin: 3
                y: netFlick.contentY / Math.max(netFlick.contentHeight, 1) * netFlick.height
                width: 2
                height: (netFlick.height / Math.max(netFlick.contentHeight, 1)) * netFlick.height
                radius: 1; color: "#3a3b5a"
                visible: netFlick.contentHeight > netFlick.height
                opacity: netFlick.moving ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }

            Column {
                id: netCol
                x: 12; width: netFlick.width - 24; spacing: 6

                Repeater {
                    model: wifiSelector.networks

                    delegate: Column {
                        width: netCol.width; spacing: 4

                        // ── card ──────────────────────────────────────────
                        Rectangle {
                            id: netCard
                            width: parent.width; height: 44; radius: 12
                            color: modelData.inUse      ? "#2f3150"
                                 : cardMa.containsMouse ? "#252638"
                                 :                        "#1e1f2e"

                            Row {
                                anchors { fill: parent; leftMargin: 10; rightMargin: 8 }
                                spacing: 6

                                // ícone sinal
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: wifiSelector.signalIcon(modelData.signal)
                                    font.pixelSize: 14; font.family: "scientifica"; color: "#A9B1D6"
                                }

                                // SSID
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                         - 20
                                         - (modelData.secured ? 18 : 0)
                                         - (eyeBtn.visible ? 26 : 0)
                                         - 6 * 3
                                    text: modelData.ssid
                                    font.family: "scientifica"; font.pixelSize: 12
                                    font.bold: modelData.inUse; color: "#A9B1D6"
                                    elide: Text.ElideRight
                                }

                                // cadeado — ícone muda se tem perfil salvo
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: modelData.secured
                                    text: wifiSelector.savedNets.indexOf(modelData.ssid) >= 0
                                        ? "\u{0F0769}"   // cadeado com check = salvo
                                        : "\u{0F0342}"   // cadeado normal
                                    font.pixelSize: 12; font.family: "scientifica"; color: "#6b7099"
                                }

                                // botão olho — só aparece em redes salvas
                                Rectangle {
                                    id: eyeBtn
                                    visible: modelData.secured
                                          && wifiSelector.savedNets.indexOf(modelData.ssid) >= 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22; height: 22; radius: 6
                                    color: eyeMa.containsMouse ? "#3a3b5a" : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: wifiSelector.shownPasswordSsid === modelData.ssid
                                            ? "\uF070" : "\uF06E"
                                        font.pixelSize: 11; font.family: "scientifica"; color: "#7aa2f7"
                                    }
                                    MouseArea {
                                        id: eyeMa; anchors.fill: parent; hoverEnabled: true
                                        onClicked: {
                                            if (wifiSelector.shownPasswordSsid === modelData.ssid) {
                                                wifiSelector.shownPasswordSsid = ""
                                                wifiSelector.shownPassword = ""
                                            } else {
                                                wifiSelector.showSavedPassword(modelData.ssid)
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: cardMa; anchors.fill: parent; hoverEnabled: true; z: -1
                                onClicked: {
                                    if (modelData.inUse) return
                                    // fecha exibição de senha de outro card
                                    wifiSelector.shownPasswordSsid = ""
                                    wifiSelector.shownPassword = ""
                                    const saved = wifiSelector.savedNets.indexOf(modelData.ssid) >= 0
                                    if (!modelData.secured || saved) {
                                        wifiSelector.connectNetwork(modelData.ssid, "")
                                    } else {
                                        wifiSelector.selectedSsid = modelData.ssid
                                        Qt.callLater(() => pwdInput.forceActiveFocus())
                                    }
                                }
                            }
                        }

                        // ── exibição de senha salva ───────────────────────
                        Rectangle {
                            visible: wifiSelector.shownPasswordSsid === modelData.ssid
                            width: parent.width
                            height: visible ? 32 : 0
                            radius: 10; color: "#22223a"; clip: true

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: wifiSelector.shownPassword === ""
                                        ? "buscando…" : wifiSelector.shownPassword
                                    font.family: "scientifica"; font.pixelSize: 12
                                    font.letterSpacing: 1.5; color: "#7dcfff"
                                }

                                // botão copiar
                                Rectangle {
                                    visible: wifiSelector.shownPassword !== ""
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 20; height: 20; radius: 5
                                    color: cpMa.containsMouse ? "#3a3b5a" : "transparent"

                                    Text {
                                        anchors.centerIn: parent; text: "\uF0C5"
                                        font.pixelSize: 10; font.family: "scientifica"; color: "#6b7099"
                                    }
                                    MouseArea {
                                        id: cpMa; anchors.fill: parent; hoverEnabled: true
                                        onClicked: procClipboard.running = true
                                    }
                                }
                            }
                        }

                        // ── campo de senha (rede nova, sem perfil salvo) ──
                        Rectangle {
                            id: pwdBox
                            visible: wifiSelector.selectedSsid === modelData.ssid
                                  && modelData.secured
                                  && wifiSelector.savedNets.indexOf(modelData.ssid) < 0
                            width: parent.width
                            height: visible ? 44 : 0
                            radius: 12; color: "#22223a"; clip: true

                            Row {
                                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                spacing: 8

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - okBtn.width - 8
                                    height: 30; radius: 10; color: "#2a2b3d"

                                    TextInput {
                                        id: pwdInput
                                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                        verticalAlignment:   TextInput.AlignVCenter
                                        horizontalAlignment: TextInput.AlignHCenter
                                        echoMode: TextInput.Password
                                        font.family: "scientifica"; font.pixelSize: 12
                                        color: "#A9B1D6"; clip: true; activeFocusOnTab: true

                                        Text {
                                            anchors.centerIn: parent
                                            visible: pwdInput.text.length === 0 && !pwdInput.activeFocus
                                            text: "Senha…"; color: "#4a4b6a"
                                            font.family: "scientifica"; font.pixelSize: 12
                                        }

                                        onActiveFocusChanged: { if (!activeFocus) text = "" }

                                        Keys.onReturnPressed: wifiSelector.connectNetwork(modelData.ssid, text)
                                        Keys.onEscapePressed: {
                                            wifiSelector.selectedSsid = ""
                                            bar.showWifiSelector = false
                                            bar.sharedWidth = 140
                                        }
                                    }
                                }

                                Rectangle {
                                    id: okBtn
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 48; height: 30; radius: 10
                                    color: okMa.containsMouse ? "#3a3b5a" : "#2f3050"

                                    Text {
                                        anchors.centerIn: parent; text: "OK"
                                        font.family: "scientifica"; font.pixelSize: 12
                                        font.bold: true; color: "#A9B1D6"
                                    }
                                    MouseArea {
                                        id: okMa; anchors.fill: parent; hoverEnabled: true
                                        onClicked: {
                                            const pwd = pwdInput.text
                                            wifiSelector.connectNetwork(modelData.ssid, pwd)
                                        }
                                    }
                                }
                            }
                        }

                    } // delegate Column
                } // Repeater
            } // netCol
        } // Flickable

        // ── processos ─────────────────────────────────────────────────────

        Process {
            id: procScan
            command: ["sh", "-c",
                "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null"]
            stdout: SplitParser {
                onRead: data => {
                    const cols = data.split(":")
                    if (cols.length < 4) return
                    const inUse   = cols[0].trim() === "*"
                    const ssidVal = cols[1].trim()
                    const signal  = parseInt(cols[2].trim()) || 0
                    const sec     = cols.slice(3).join(":").trim()
                    const secured = sec !== "" && sec !== "--"
                    if (ssidVal === "" || ssidVal === "--") return

                    let list = [...wifiSelector.networks]
                    const idx = list.findIndex(n => n.ssid === ssidVal)
                    if (idx >= 0) {
                        if (signal > list[idx].signal)
                            list[idx] = { ssid: ssidVal, signal, secured, inUse }
                    } else {
                        list.push({ ssid: ssidVal, signal, secured, inUse })
                    }
                    list.sort((a, b) => a.inUse !== b.inUse ? (a.inUse ? -1 : 1) : b.signal - a.signal)
                    wifiSelector.networks = list
                    wifiSelector.scanning = false
                }
            }
            stderr: SplitParser {
                onRead: data => { console.log("procScan:", data); wifiSelector.scanning = false }
            }
        }

        // lista SSIDs com perfil salvo
        // formato de saída: "NomeConexao:SsidDaRede"
        Process {
            id: procSaved
            command: ["sh", "-c",
                "nmcli -t -f NAME,802-11-wireless.ssid connection show 2>/dev/null " +
                "| awk -F: 'NF>=2 && $2!=\"\" && $2!=\"--\" {print $2}'"]
            stdout: SplitParser {
                onRead: data => {
                    const ssid = data.trim()
                    if (ssid && ssid !== "--" && wifiSelector.savedNets.indexOf(ssid) < 0)
                        wifiSelector.savedNets = [...wifiSelector.savedNets, ssid]
                }
            }
        }

        // ▼ FIX: resolve o nome do perfil a partir do SSID, depois pega a senha
        Process {
            id: procShowPwd
            stdout: SplitParser {
                onRead: data => {
                    const pwd = data.trim()
                    wifiSelector.shownPassword = (pwd && pwd !== "--") ? pwd : "(sem permissão)"
                }
            }
            stderr: SplitParser {
                onRead: data => { wifiSelector.shownPassword = "(sem permissão)" }
            }
        }

        Process {
            id: procConnect
            stdout: SplitParser {
                onRead: data => {
                    wifiSelector.statusMsg = ""
                    wifiSelector.triggerScan()
                    networkWidget.refresh()
                }
            }
            stderr: SplitParser {
                onRead: data => { wifiSelector.statusMsg = data.toString() }
            }
        }

        // copia senha para clipboard
        Process {
            id: procClipboard
            command: ["sh", "-c",
                `echo -n '${wifiSelector.shownPassword}' | wl-copy 2>/dev/null`]
        }

        // ── funções ───────────────────────────────────────────────────────

        function triggerScan() {
            scanning          = true
            networks          = []
            savedNets         = []
            shownPasswordSsid = ""
            shownPassword     = ""
            selectedSsid      = ""
            procScan.running  = true
            procSaved.running = true
        }

        function connectNetwork(ssid, password) {
            statusMsg = ""
            const cmd = password.length > 0
                ? `nmcli device wifi connect '${ssid}' password '${password}'`
                : `nmcli device wifi connect '${ssid}'`
            procConnect.command = ["sh", "-c", cmd]
            procConnect.running  = true
            selectedSsid         = ""
            bar.showWifiSelector = false
            bar.sharedWidth      = 140
        }

        function showSavedPassword(ssid) {
            shownPasswordSsid = ssid
            shownPassword     = ""
            // 1) resolve o nome do perfil pelo SSID
            // 2) busca o PSK desse perfil com flag -s (secrets)
            procShowPwd.command = ["sh", "-c",
                `conn=$(nmcli -t -f NAME,802-11-wireless.ssid connection show 2>/dev/null ` +
                `| awk -F: -v s='${ssid}' 'NF>=2 && $2==s {print $1; exit}'); ` +
                `[ -n "$conn" ] && nmcli -s -g 802-11-wireless-security.psk connection show "$conn" 2>/dev/null`]
            procShowPwd.running = true
        }

        function signalIcon(s) {
            if (s >= 70) return "\u{0F0928}"
            if (s >= 50) return "\u{0F0925}"
            if (s >= 30) return "\u{0F0922}"
            return "\u{0F091F}"
        }

    } // wifiSelector

    // fecha ao clicar fora
    MouseArea {
        anchors.fill: parent
        anchors.topMargin: 24
        enabled: bar.showWifiSelector
        z: wifiSelector.z - 1
        onClicked: {
            bar.showWifiSelector = false
            bar.sharedWidth = 140
        }
    }
}
