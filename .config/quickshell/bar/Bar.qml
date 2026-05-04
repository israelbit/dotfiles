import Quickshell
import Quickshell.Wayland
import QtQuick
import "./"


PanelWindow {
        color:"transparent"
        implicitHeight:24
	anchors {
		top: true
		left: true
		right: true
        }
        FontLoader{
                id: scientifica
                source:"./fonts/scientifica.ttf"
        }
        FontLoader{
                id: nerdFont
                source: "./fonts/SymbolsNerdFont-Regular.ttf"
        }
        Rectangle{
                color:"#414868A1"
                height:parent.height
                width: parent.width
                radius: 12

        QtObject {
                id:theme
                property string main: scientifica.font.family
                property string icon: nerdFont
                property real size: 30
        }
	Row {
		anchors.left : parent.left
		height: parent.height
		spacing:30
                Menu{
                        menuWidgetFg:"#A9B1D6"
                        menuWidgetBg:"#1A1B26"
                }
	}
	Row{
		anchors.centerIn: parent.centerIn
		height: parent.height
		x: (parent.width - width) / 2
	}
	Row {
		anchors.right: parent.right
                spacing: 5
                height: parent.height
                Network{
                        fontFamily:"scientifica"
                        fontSizeSymbol:16
                        networkWidgetFg:"#A9B1D6"
                        networkWidgetBg:"#1A1B26"

                }
                Ram {
                        ramWidgetFg:"#A9B1D6"
                        ramWidgetBg:"#1A1B26"
                }
                Cpu{
                        cpuWidgetFg:"#A9B1D6"
                        cpuWidgetBg:"#1A1B26"
                }
                Battery{
                        batteryWidgetFg:"#A9B1D6"
                        batteryWidgetBg:"#1A1B26"
                }
                Clock{
                        fontFamily:"scientifica"
                        clockWidgetBg:"#1A1B26"
                        clockWidgetFg:"#A9B1D6"
                }
        }
}
}
