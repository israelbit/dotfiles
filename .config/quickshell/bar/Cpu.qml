import Quickshell
import QtQuick
import Quickshell.Io

Item {
    id: cpuWidget
    implicitWidth: 32
    height: parent.height

    property real cpuAvgUsed: 0
    property var snapshot: ({})
    property var cpuBuffer: []
    property string iconCpu: "\u{F2DB}"
    property string cpuWidgetBg: ""
    property string cpuWidgetFg: ""

    Rectangle{
            width: parent.width 
            height: parent.height
            radius:12
            color: cpuWidget.cpuWidgetBg
     Canvas {
        id: bgCpu
        anchors.fill: parent
        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            let cx = width / 2
            let cy = height / 2
            ctx.beginPath()
            ctx.arc(cx, cy, 10, 0, Math.PI * 2)
            ctx.strokeStyle = "#2a2a3a"
            ctx.lineWidth = 3
            ctx.stroke()
        }
     }

    Canvas {
        id: progressCircleCpu
        anchors.fill: parent
        property real percent: cpuWidget.cpuAvgUsed
        onPercentChanged: requestPaint()
        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            let cx = width / 2
            let cy = height / 2
            let startAngle = -Math.PI / 2
            let endAngle = startAngle + (Math.PI * 2 * (percent / 100))
            let color
            if (percent > 80)      color = "#f38ba8"
            else if (percent > 50) color = "#f9e2af"
            else                   color = "#a6e3a1"
            ctx.beginPath()
            ctx.arc(cx, cy, 10, startAngle, endAngle)
            ctx.strokeStyle = color
            ctx.lineWidth = 3
            ctx.lineCap = "round"
            ctx.stroke()
        }
    }

    Text {
        anchors.centerIn: parent
        text: cpuWidget.iconCpu
        font.pixelSize: 15
        color: cpuWidget.cpuWidgetFg 
    }
}

    Process {
        id: proc
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (!/^cpu\d+$/.test(parts[0])) return

                const name = parts[0]
                const nums = parts.slice(1).map(Number)
                const idle = nums[3] + nums[4]
                const total = nums.reduce((a, b) => a + b, 0)

                if (cpuWidget.snapshot[name]) {
                    const dTotal = total - cpuWidget.snapshot[name].total
                    const dIdle  = idle  - cpuWidget.snapshot[name].idle
                    const use = dTotal > 0 ? Math.round((dTotal - dIdle) / dTotal * 100) : 0
                    cpuWidget.cpuBuffer.push(use)  // ✅ acumula
                }

                cpuWidget.snapshot[name] = { total, idle }
            }
        }

        onExited: {
            const buf = cpuWidget.cpuBuffer
            if (buf.length > 0) {
                cpuWidget.cpuAvgUsed = Math.round(buf.reduce((a, b) => a + b, 0) / buf.length)
            }
            cpuWidget.cpuBuffer = []  // limpa pra próxima leitura
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
