import Quickshell
import QtQuick
import Quickshell.Io

Rectangle {
    id: networkWidget
    width: 140          // Bar.qml sobrescreve com sharedWidth
    height: parent.height
    color: networkWidgetBg
    radius: 12

    property string networkWidgetBg: ""
    property string networkWidgetFg: ""
    property string connected:   ""
    property string ssid:        ""
    property string signalWifi:  ""
    property string fontFamily:  "monospace"
    property real   fontSizeSymbol: 0

    signal clicked()

    // ── força atualização imediata (chamado pelo Bar após conectar) ──────────
    function refresh() {
        procIface.running  = true
        procSignal.running = true
        procSsid.running   = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { if (networkWidget.connected === "Wifi") networkWidget.clicked() }
    }

    Row {
        anchors.centerIn: parent
        anchors.fill: parent

        anchors.leftMargin:5
        anchors.rightMargin: 2

        spacing: 3

        Text {
            // largura do texto = espaço disponível menos ícone de sinal (~20px) e margens
            width: networkWidget.width - 30
            anchors.verticalCenter: parent.verticalCenter
            text: networkWidget.ssid
            font.family: networkWidget.fontFamily
            color: networkWidget.networkWidgetFg
            elide: Text.ElideRight  // trunca com "…" se o nome for longo
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: networkWidget.signalWifi
            font.pixelSize: networkWidget.fontSizeSymbol
            color: networkWidget.networkWidgetFg
        }
    }

    Process {
        id: procSignal
        command: ["sh", "-c",
            "nmcli -f in-use,ssid,signal dev wifi | grep '*' | awk '{print $NF}'"]
        stdout: SplitParser {
            onRead: data => {
                if (networkWidget.connected !== "Wifi") return
                const s = Number(data)
                if      (s >= 70) networkWidget.signalWifi = "\u{0F0928}"
                else if (s >= 50) networkWidget.signalWifi = "\u{0F0925}"
                else if (s >= 30) networkWidget.signalWifi = "\u{0F0922}"
                else              networkWidget.signalWifi = "\u{0F091F}"
            }
        }
        stderr: SplitParser { onRead: data => console.log("procSignal erro:", data) }
    }

    Process {
        id: procSsid
        command: ["sh", "-c", "nmcli -t -f name connection show --active | head -1"]
        running: true
        stdout: SplitParser { onRead: data => { networkWidget.ssid = data.toString().trim() } }
        stderr: SplitParser { onRead: data => console.log("procSsid erro:", data) }
    }

    Process {
        id: procIface
        command: ["sh", "-c",
            "ip route get 1.1.1.1 | awk '{print $5}' | sed 's/^wl.*/Wifi/;s/^eth.*/Ethernet/;s/^en.*/Ethernet/'"]
        stdout: SplitParser {
            onRead: data => {
                const t = data.trim()
                if      (t === "Wifi")     networkWidget.connected = "Wifi"
                else if (t === "Ethernet") networkWidget.connected = "Ethernet"
            }
        }
    }

    // atualiza tudo a cada 2s, incluindo o SSID
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: {
            procIface.running  = true
            procSignal.running = true
            procSsid.running   = true
        }
    }
}
