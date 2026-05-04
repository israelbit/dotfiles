	import Quickshell
import QtQuick
import Quickshell.Io


Rectangle {
	id:root
	width: 100
	height: parent.height

	FontLoader{
		id: nerdfontsymbol
		source: "./fonts/SymbolsNerdFont-Regular.ttf"
	}

	property real diskUsage: 0
	Row{
		anchors.centerIn: parent
	Text{ 
		text: "\u{0F02CA}" 
		font.family: nerdfontsymbol.name 
		font.pixelSize: 20
	}
	Text{
		text: `   ${diskUsage}%`
		font.pixelSize: 15
	}
}

	Process{
		id: proc
		command: ["df","-P"]
		stdout: SplitParser{
			onRead: data => {
				const lines = data.trim().split(/\s+/)
				if(lines[5] === "/"){
					diskUsage = parseInt(lines[4])
				}
				}
			}
		}
	Timer{
		interval: 1000
		running:true
		repeat: true
		onTriggered: proc.running = true
	}
}
