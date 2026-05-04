import QtQuick
import Quickshell 
import Quickshell.Io


Item{
	id:ramWidget
	implicitWidth: 32
	height: parent.height


        property string iconRam: "\u{0F061A}"
	property real ramUsage: 0
	property real ramTotal: 0
        property real ramUsed:  0
        property var memInfo: ({})
        property string ramWidgetBg: ""
        property string ramWidgetFg: ""


        Rectangle{
                height: parent.height
                width: parent.width
                radius: 12
                color: ramWidget.ramWidgetBg
        Canvas{
                id:bgRamCircle
                anchors.fill: parent
                onPaint:{
                        let ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)
                        let cx = width / 2
                        let cy = height / 2
                        let radius = 10
                        let lineWidth = 3


                        ctx.beginPath()
                        ctx.arc(cx,cy,radius,0,Math.PI * 2)
                        ctx.strokeStyle = "#2a2a3a"
                        ctx.lineWidth = lineWidth 
                        ctx.stroke()
                }

        }
        Canvas{
                id:progressRamCircle
                anchors.fill:parent 
                property int percent: ramUsage
                onPercentChanged:requestPaint()
                onPaint: {
                        let ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)
                        let cx = width / 2 
                        let cy = height / 2
                        let radius = 10
                        let lineWidth = 3 
                        let startAngle = -Math.PI / 2
                        let endAngle = startAngle + (Math.PI * 2 * (percent / 100))
                        
                        let color
                        if(percent > 60 )      color = "#f38ba8"
                        else if(percent > 30)  color = "#f9e2af"
                        else                   color = "#a6e3a1"
                        ctx.beginPath()
                        ctx.arc(cx,cy,radius,startAngle,endAngle)
                        ctx.strokeStyle = color
                        ctx.lineWidth = lineWidth
                        ctx.lineCap = "round"
                        ctx.stroke()
                }
        }

        Text{
                text:iconRam
                anchors.centerIn: parent
                font.pixelSize:16
                color: ramWidget.ramWidgetFg 

        }

}
	Process{
		id:proc
		command: ["cat","/proc/meminfo"]

		stdout: SplitParser {
			onRead: data => {
			  const parts = data.trim().split(/\s+/);
			  const key = parts[0].replace(":", "");
			  memInfo[key] = parseInt(parts[1])

			  if(key === "MemAvailable"){
				  const total = memInfo["MemTotal"]
				  const available = memInfo["MemAvailable"]
				  const used = total - available


				  ramTotal = (total / 1024 / 1024).toFixed(1)
				  ramUsed = (used / 1024 / 1024).toFixed(1)
				  ramUsage = Math.round(( used / total ) * 100)
			  }
				}
			}
                }
	Timer {
		interval: 1000
		running: true
		repeat:true
		onTriggered: {
			memInfo = {}
			proc.running = true
		}
	}

}
