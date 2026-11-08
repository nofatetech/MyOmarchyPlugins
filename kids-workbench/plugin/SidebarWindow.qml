import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// One screen's sidebar. The window is always as wide as the expanded panel but
// its mask only covers the visible body, so clicks outside fall through.
PanelWindow {
  id: win

  property var host: null
  readonly property bool expanded: !!host && host.expanded
  readonly property int stripWidth: Math.round(56 * Style.fontScale)
  readonly property int panelWidth: Math.round(360 * Style.fontScale)
  readonly property int pad: Style.spacing.md

  color: "transparent"
  WlrLayershell.namespace: "kids-workbench"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0

  anchors {
    top: true
    bottom: true
    left: true
  }
  implicitWidth: panelWidth

  mask: Region { item: body }

  Rectangle {
    id: body
    x: 0
    y: 0
    height: parent.height
    width: win.expanded ? win.panelWidth : win.stripWidth
    color: Commons.Color.popups.background
    clip: true

    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    Rectangle {
      anchors.right: parent.right
      width: 2
      height: parent.height
      color: Commons.Color.accent
      opacity: 0.6
    }

    // ---- collapsed strip (always visible, left edge) ----
    Column {
      id: strip
      width: win.stripWidth
      spacing: Style.spacing.xs
      topPadding: win.pad

      Repeater {
        model: [
          { icon: "🛠️", tip: "Kids Workbench", action: "toggle" },
          { icon: "＋", tip: "New", action: "open" },
          { icon: "📁", tip: "My stuff", action: "open" }
        ]
        delegate: Rectangle {
          required property var modelData
          width: win.stripWidth - win.pad
          height: width
          anchors.horizontalCenter: parent.horizontalCenter
          radius: 12
          color: stripMouse.containsMouse ? Style.hoverFill : "transparent"
          Text {
            anchors.centerIn: parent
            text: modelData.icon
            font.pixelSize: Math.round(22 * Style.fontScale)
            color: Commons.Color.popups.text
          }
          MouseArea {
            id: stripMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: modelData.action === "toggle" ? win.host.toggle() : win.host.open()
          }
        }
      }
    }

    // ---- expanded content ----
    Flickable {
      id: content
      visible: body.width > win.stripWidth + 40
      opacity: win.expanded ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 120 } }
      x: win.stripWidth
      y: 0
      width: win.panelWidth - win.stripWidth - win.pad
      height: parent.height
      contentHeight: col.implicitHeight + win.pad * 2
      boundsBehavior: Flickable.StopAtBounds
      clip: true

      Column {
        id: col
        width: content.width
        y: win.pad
        spacing: Style.spacing.md

        Text {
          text: "What do you want to make?"
          font.pixelSize: Math.round(20 * Style.fontScale)
          font.bold: true
          color: Commons.Color.popups.text
        }

        // New: template tiles
        Flow {
          width: parent.width
          spacing: Style.spacing.sm
          Repeater {
            model: win.host ? win.host.templates : []
            delegate: Rectangle {
              required property var modelData
              width: (col.width - Style.spacing.sm) / 2
              height: Math.round(92 * Style.fontScale)
              radius: 14
              color: tileMouse.containsMouse ? Style.hoverFill : Qt.rgba(1, 1, 1, 0.06)
              border.width: tileMouse.containsMouse ? 2 : 0
              border.color: Commons.Color.accent
              Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.icon || "✨"
                  font.pixelSize: Math.round(30 * Style.fontScale)
                }
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.name
                  font.pixelSize: Math.round(14 * Style.fontScale)
                  font.bold: true
                  color: Commons.Color.popups.text
                }
              }
              MouseArea {
                id: tileMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: win.host.startNew(modelData.id)
              }
            }
          }
        }

        Text {
          visible: !!win.host && win.host.lastMessage !== ""
          text: win.host ? win.host.lastMessage : ""
          color: Commons.Color.accent
          font.pixelSize: Math.round(13 * Style.fontScale)
        }

        Rectangle { width: parent.width; height: 1; color: Commons.Color.popups.text; opacity: 0.15 }

        Text {
          text: "My stuff"
          font.pixelSize: Math.round(20 * Style.fontScale)
          font.bold: true
          color: Commons.Color.popups.text
        }

        Text {
          visible: !!win.host && win.host.projects.length === 0
          text: "Nothing yet. Pick something above and start!"
          color: Commons.Color.popups.text
          opacity: 0.6
          wrapMode: Text.WordWrap
          width: parent.width
        }

        Repeater {
          model: win.host ? win.host.projects : []
          delegate: Rectangle {
            required property var modelData
            width: col.width
            height: Math.round(52 * Style.fontScale)
            radius: 12
            color: rowMouse.containsMouse ? Style.hoverFill : "transparent"
            Row {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: Style.spacing.sm
              spacing: Style.spacing.sm
              Text {
                text: modelData.icon
                font.pixelSize: Math.round(22 * Style.fontScale)
                anchors.verticalCenter: parent.verticalCenter
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                  text: modelData.name
                  color: Commons.Color.popups.text
                  font.pixelSize: Math.round(14 * Style.fontScale)
                  font.bold: true
                }
                Text {
                  text: modelData.ago
                  color: Commons.Color.popups.text
                  opacity: 0.55
                  font.pixelSize: Math.round(11 * Style.fontScale)
                }
              }
            }
            MouseArea {
              id: rowMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) win.host.openFolder(modelData.path)
                else { win.host.openProject(modelData.path); win.host.close() }
              }
            }
          }
        }

        Text {
          text: "Click = open · Right-click = show folder"
          color: Commons.Color.popups.text
          opacity: 0.4
          font.pixelSize: Math.round(11 * Style.fontScale)
        }
      }
    }
  }
}
