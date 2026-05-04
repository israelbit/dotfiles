import Quickshell
import QtQuick
import Quickshell.Io


Rectangle {
	id:networkWidget
	width: 140
	height: parent.height
        color: networkWidget.networkWidgetBg
        radius:12

        property string networkWidgetBg:"" 
        property string networkWidgetFg:""
        property string connected: ""
        property string ssid : ""
        property string signalWifi : ""
        property string fontFamily:"monospace"
        property real fontSizeSymbol: 0 


        Row{
                anchors.centerIn: parent
                spacing:3
                Text{
                        id:ssidText
                        width: networkWidget.width - 40 
                        anchors.verticalCenter:parent.verticalCenter
                        text:`${ssid}`
                        font.family: networkWidget.fontFamily
                        color:networkWidget.networkWidgetFg 
                        elide: Text.ElideRight
                }
                Text{
                        anchors.verticalCenter:parent.verticalCenter 
                        text:`${signalWifi}`
                        font.pixelSize: networkWidget.fontSizeSymbol
                        color:networkWidget.networkWidgetFg 
                }
        }

        Process{
                id: procSignal
                command:["sh","-c","nmcli -f in-use,ssid,signal dev wifi | grep '*'| awk '{print $NF}'  "]
                stdout:SplitParser{
                        onRead: data => {
                                const signal_wireless = Number(data);
                                switch(connected == "Wifi"){
                                        case signal_wireless >= 70 && signal_wireless <= 100:
                                        signalWifi = "\u{0F0928}"
                                        break

                                        case signal_wireless >= 50 && signal_wireless <= 69:
                                        signalWifi = "\u{0F0925}"
                                        break

                                        case signal_wireless >= 30 && signal_wireless <= 49 :
                                        signalWifi = "\u{0F0922}"
                                        break

                                        case signal_wireless < 29:
                                        signalWifi = "\u{0F091F}"
                                        break

                                }
                        }
                }
                stderr:SplitParser{
                        onRead:data=>{
                                console.log("erro procSignal",data)
                        }
                }
        }

        Process{
                id: procSsid
                command:["sh", "-c", "nmcli -t -f name connection show --active | head -1 "]
                running: true
                stdout: SplitParser {
                        onRead: data => {
                                ssid = data.toString()
                        }
                }
                stderr: SplitParser {
                        onRead: data => {
                                console.log("ERRO",data)
                        }
                }
        }
        Process{
		id: proc
                command: ["sh", "-c", "ip route get 1.1.1.1 | awk '{print $5}'|sed 's/^wl.*/Wifi/;s/^eth.*/Ethernet/;s/^en.*/Ethernet/'"]
		stdout: SplitParser{
                        onRead: data => {
                                const teste = data.trim();
                                

                                switch(true){
                                        case teste == "Wifi":
                                        connected = "Wifi"
                                        break
                                        case teste == "Ethernet":
                                        connected = "Ethernet"
                                        break
                                }
			}
                }

        }
        Timer{ 
                interval: 1000  
                running:true
                repeat: true
                onTriggered: {
                        proc.running = true
                        procSignal.running = true
                }
        }
        function wifi_data() {

        }

}
