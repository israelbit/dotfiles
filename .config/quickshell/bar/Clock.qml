import QtQuick

Rectangle{
        id:clockWidget
	implicitWidth: 80
        height: parent.height
        radius:12
        color: clockWidget.clockWidgetBg 
        property string clockWidgetBg:""
        property string clockWidgetFg:""
        property string fontFamily:"monospace" 
	Text {
		anchors.centerIn: parent
                text: Qt.formatTime(new Date(), "hh:mm")
                font.family:fontFamily
                font.pixelSize: 16
                color: clockWidget.clockWidgetFg 
		Timer{
			interval: 30000
			running: true
			repeat: true
			onTriggered: parent.text = Qt.formatTime(new Date(), "hh:mm")
		}
	}
}
