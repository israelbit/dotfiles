import Quickshell
import Quickshell.Io
import QtQuick 


Item {
        id: batteryWidget
        width: 32
        height: parent.height

        property var statusBattery: ""
        property int percentBattery: 0
        property string batteryWidgetBg: ""
        property string batteryWidgetFg:""

        Rectangle {
                height: parent.height
                width: parent.width
                radius:12 
                color: batteryWidget.batteryWidgetBg
        Canvas{
                id:bgCircle 
                anchors.fill: parent


                onPaint:{
                        let ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)
                        
                        let cx = width / 2
                        let cy = height / 2
                        let radius = 10
                        let lineWidth = 3


                        ctx.beginPath()
                        ctx.arc(cx, cy, radius, 0, Math.PI * 2)
                        ctx.strokeStyle = "#2a2a3a"   // cor do fundo
                        ctx.lineWidth = lineWidth
                        ctx.stroke()

                }

        }
        Canvas{
                id:progressCircle
                anchors.fill: parent
                property var percent: batteryWidget.percentBattery
                onPercentChanged: requestPaint()

                onPaint:{
                        let ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)

                        let cx = width / 2
                        let cy = height / 2 
                        let radius = 10 
                        let lineWidth = 3

                        let startAngle = -Math.PI / 2
                        let endAngle = startAngle + (Math.PI * 2 * (percent / 100))
                        let color 
                        if (percent > 60)      color = "#a6e3a1"
                        else if (percent > 30) color = "#f9e2af"
                        else                   color = "#f38ba8"

                        ctx.beginPath()
                        ctx.arc(cx,cy,radius,startAngle,endAngle)
                        ctx.strokeStyle = color
                        ctx.lineWidth = lineWidth 
                        ctx.lineCap = "round"
                        ctx.stroke()
                }
        }



}














        function testeBat(){
                if(batteryWidget.percentBattery === 100){ return "\u{0F0079}" }
                if(batteryWidget.statusBattery !== "Discharging"){return "\u{0F0084}"}
                if(batteryWidget.statusBattery === "Discharging"){
                        if(batteryWidget.percentBattery > 90 ){return "\u{0F0082}"}
                        if(percentBattery >= 90 || percentBattery > 80){return "\u{0F0081}"}
                        if(percentBattery >= 80 || percentBattery > 70){return "\u{0F0080}"}
                        if(percentBattery >= 70 || percentBattery > 60){return "\u{0F007F}"}
                        if(percentBattery >= 50 || percentBattery > 40){return "\u{0F007E}"}
                        if(percentBattery >= 40 || percentBattery > 30){return "\u{0F007D}"}
                        if(percentBattery >= 30 || percentBattery > 20){return "\u{0F007C}"}
                        if(percentBattery >= 20 || percentBattery > 10){return "\u{0F007B}"}
                        if(percentBattery >= 10 || percentBattery > 0){return "\u{0F007A}"}
                }
        }
        Text{
                text: testeBat()
                anchors.centerIn: parent 
                font.pixelSize: 16
                color: batteryWidget.batteryWidgetFg 
        }



        Process {
                id:procBatPercent
                running: true
                command:["cat","/sys/class/power_supply/BAT0/capacity"]
                stdout:SplitParser{
                        onRead: data => {
                                percentBattery = data
                        }
                }  
        }
        Process {
                id:procBatStatus
                running:true 
                command:["cat","/sys/class/power_supply/BAT0/status"]
                stdout:SplitParser{
                        onRead:data=>{
                                statusBattery = data
                        }
                }
        }
        Timer {
                running:true
                interval: 1000
                repeat:true 
                onTriggered: procBatPercent.running = true,procBatStatus.running = true
        }
}
