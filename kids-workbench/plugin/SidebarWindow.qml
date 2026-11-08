import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// One screen's sidebar. The window is always as wide as the expanded panel but
// its mask only covers the visible body, so clicks outside fall through.
PanelWindow {
  id: win

  property var host: null
  readonly property bool expanded: !!host && host.expanded
  readonly property int stripWidth: Math.round(56 * Style.fontScale)
  readonly property int panelWidth: Math.round(360 * Style.fontScale)
  readonly property int pad: Style.spacing.md
  readonly property bool asking: !!host && host.pendingTemplate !== null

  color: "transparent"
  WlrLayershell.namespace: "kids-workbench"
  WlrLayershell.layer: WlrLayer.Top
  // Only grab the keyboard while a name is being typed (Esc gives it back).
  WlrLayershell.keyboardFocus: !!host && host.pendingTemplate !== null ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
    color: Color.popups.background
    clip: true

    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    Rectangle {
      anchors.right: parent.right
      width: 2
      height: parent.height
      color: Color.accent
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
            color: Color.popups.text
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
          visible: !win.asking
          text: "What do you want to make?"
          font.pixelSize: Math.round(20 * Style.fontScale)
          font.bold: true
          color: Color.popups.text
        }

        // Name prompt: shown after a tile is clicked.
        Rectangle {
          id: prompt
          visible: win.asking
          width: parent.width
          height: promptCol.implicitHeight + win.pad * 2
          radius: 14
          color: Qt.rgba(1, 1, 1, 0.06)
          border.width: 2
          border.color: Color.accent

          onVisibleChanged: if (visible) {
            nameInput.text = win.host.suggestedName
            nameInput.forceActiveFocus()
            nameInput.selectAll()
          }

          Column {
            id: promptCol
            x: win.pad
            y: win.pad
            width: parent.width - win.pad * 2
            spacing: Style.spacing.sm

            Text {
              text: win.asking ? (win.host.pendingTemplate.icon + "  New " + win.host.pendingTemplate.name) : ""
              font.pixelSize: Math.round(16 * Style.fontScale)
              font.bold: true
              color: Color.popups.text
            }
            Text {
              text: "What is it called?"
              font.pixelSize: Math.round(13 * Style.fontScale)
              color: Color.popups.text
              opacity: 0.7
            }
            Rectangle {
              width: parent.width
              height: Math.round(40 * Style.fontScale)
              radius: 10
              color: Qt.rgba(1, 1, 1, 0.1)
              border.width: nameInput.activeFocus ? 2 : 0
              border.color: Color.accent
              TextInput {
                id: nameInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: Math.round(15 * Style.fontScale)
                color: Color.popups.text
                selectByMouse: true
                clip: true
                onAccepted: win.host.confirm(text)
                Keys.onEscapePressed: win.host.cancel()
              }
            }
            Row {
              spacing: Style.spacing.sm
              Rectangle {
                width: Math.round(110 * Style.fontScale)
                height: Math.round(36 * Style.fontScale)
                radius: 10
                color: Color.accent
                Text { anchors.centerIn: parent; text: "Create"; font.bold: true; color: "#11131f"; font.pixelSize: Math.round(14 * Style.fontScale) }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.host.confirm(nameInput.text) }
              }
              Rectangle {
                width: Math.round(90 * Style.fontScale)
                height: Math.round(36 * Style.fontScale)
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.1)
                Text { anchors.centerIn: parent; text: "Cancel"; color: Color.popups.text; font.pixelSize: Math.round(14 * Style.fontScale) }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.host.cancel() }
              }
            }
          }
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
              border.color: Color.accent
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
                  color: Color.popups.text
                }
              }
              MouseArea {
                id: tileMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: win.host.ask(modelData)
              }
            }
          }
        }

        Text {
          visible: !!win.host && win.host.lastMessage !== ""
          text: win.host ? win.host.lastMessage : ""
          color: Color.accent
          font.pixelSize: Math.round(13 * Style.fontScale)
        }

        Rectangle { width: parent.width; height: 1; color: Color.popups.text; opacity: 0.15 }

        Text {
          text: "My stuff"
          font.pixelSize: Math.round(20 * Style.fontScale)
          font.bold: true
          color: Color.popups.text
        }

        Text {
          visible: !!win.host && win.host.projects.length === 0
          text: "Nothing yet. Pick something above and start!"
          color: Color.popups.text
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
                  color: Color.popups.text
                  font.pixelSize: Math.round(14 * Style.fontScale)
                  font.bold: true
                }
                Text {
                  text: modelData.ago
                  color: Color.popups.text
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
          color: Color.popups.text
          opacity: 0.4
          font.pixelSize: Math.round(11 * Style.fontScale)
        }
      }
    }
  }
}
