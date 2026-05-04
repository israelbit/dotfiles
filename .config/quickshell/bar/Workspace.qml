import Quickshell
import Quickshell.Io
import QtQuick 
import QtQuick.Layouts


Rectangle {
	id: root
	height:parent.height
	width:360
	color: "white"
	radius:20

	property var namesWorkspaces:[];
	property real workspaces: 0;


	Process{
		id: proc
		command:["hyprctl, workspaces -j"]
		running:true
		stdout: StdioCollector{
			onDataChanged: {
				namesWorkspaces = data 
				workspaces = namesWorkspaces.length

			}
		}
	}

	RowLayout{
		anchors.centerIn: parent
		anchors.fill: parent
		Item{Layout.fillWidth:true}
		Repeater{
			model: workspaces
			Rectangle{
				Layout.fillHeight: true
				Layout.preferredWidth:30
				Layout.leftMargin: 15
				Layout.alignment: Qt.AlignVCenter
				color: "#BBDD22"
				radius:18
				Text{
					anchors.centerIn: parent
					text: root.namesWorkspaces[index]
					font.pixelSize: 16
				}
		}
	
	}
	Item{Layout.fillWidth:true}
}
}


