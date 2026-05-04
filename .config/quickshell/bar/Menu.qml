import QtQuick
import QtQuick.Layouts
import Quickshell 



Item{
        id:menuWidget
	height: parent.height
        width:20
        property string menuWidgetBg:""
        property string menuWidgetFg:""
	RowLayout{
		anchors.verticalCenter: parent.verticalCenter
		height: parent.height
                Rectangle{
			height: parent.height - 2
			Layout.leftMargin: 13
                        width:25
                        color: menuWidget.menuWidgetBg 
                        radius:20
			Text{
				anchors.centerIn:parent
				text:"\u{F303}"
                                font.pixelSize:16
                                color:menuWidgetFg 
			}
                
                }
        
        }

}
