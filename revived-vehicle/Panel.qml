import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "myomarchy.revived-vehicle"
  ipcTarget: "myomarchy.revived-vehicle"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var sample: ({})
  property string errorMessage: ""
  readonly property var barIdentity: hostWidget || root
  readonly property int refreshInterval: Math.max(250, Number(setting("refreshIntervalMs", 1000)))
  readonly property string dataSource: String(setting("dataSource", "simulation"))
  readonly property string telemetryFile: String(setting("telemetryFile", ""))
  readonly property bool useMph: String(setting("speedUnit", "km/h")).toLowerCase() === "mph"
  readonly property real displaySpeed: useMph ? Number(sample.speedKph || 0) * 0.621371 : Number(sample.speedKph || 0)
  readonly property string speedUnit: useMph ? "mph" : "km/h"
  readonly property bool warning: sample.warning && String(sample.warning) !== "none"
  readonly property string barLabel: "󰄋 " + Math.round(displaySpeed) + " " + (useMph ? "mph" : "km/h")

  function tooltipText() {
    if (errorMessage) return "Vehicle telemetry unavailable: " + errorMessage
    return String(sample.vehicle || "Vehicle") + "\n" +
      Math.round(displaySpeed) + " " + speedUnit + " · " +
      Math.round(Number(sample.powerPercent || 0)) + "% power\n" +
      Number(sample.voltage || 0).toFixed(1) + " V · " +
      Math.round(Number(sample.temperatureC || 0)) + "°C"
  }

  function collectorCommand() {
    var script = Qt.resolvedUrl("adapters/telemetry.sh").toString().replace("file://", "")
    return [script, "--source", dataSource, "--file", telemetryFile]
  }

  function refresh() {
    if (!collector.running) {
      collector.command = collectorCommand()
      collector.running = true
    }
  }

  function open() {
    root.controller.show()
    root.refresh()
  }

  function openFromHotkey() { root.open() }
  function close() { root.controller.hide() }
  function toggle() { root.opened ? root.close() : root.openFromHotkey() }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  Process {
    id: collector
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        try {
          var parsed = JSON.parse(raw)
          if (parsed.error) {
            root.errorMessage = String(parsed.error)
            return
          }
          root.sample = parsed
          root.errorMessage = ""
        } catch (e) {
          root.errorMessage = "invalid adapter output"
        }
      }
    }
  }

  Timer {
    interval: root.refreshInterval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.openFromHotkey() }
    function close(): void { root.close() }
    function show(): void { root.openFromHotkey() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): void { root.refresh() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(500))
    contentHeight: panel.fittedContentHeight(dashboard.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: dashboard
        width: parent.width
        spacing: Style.space(16)

        Row {
          width: parent.width
          spacing: Style.space(14)

          Column {
            width: parent.width - connectionLabel.width - parent.spacing
            spacing: Style.space(3)

            Text {
              text: String(root.sample.vehicle || "REVIVED VEHICLE").toUpperCase()
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              font.letterSpacing: 1
            }

            Text {
              text: root.dataSource === "simulation" ? "SIMULATED TELEMETRY" : "LIVE FILE TELEMETRY"
              color: Qt.darker(root.bar.foreground, 1.5)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
            }
          }

          Text {
            id: connectionLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.errorMessage ? "● OFFLINE" : "● CONNECTED"
            color: root.errorMessage ? root.bar.urgent : Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }

        Rectangle {
          width: parent.width
          height: Style.spacing.hairline
          color: root.bar.foreground
          opacity: 0.12
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(24)

          Column {
            width: Style.space(190)
            spacing: Style.space(2)

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: Math.round(root.displaySpeed)
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: 72
              font.bold: true
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.speedUnit.toUpperCase()
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.letterSpacing: 2
            }
          }

          Rectangle {
            width: Style.spacing.hairline
            height: Style.space(96)
            color: root.bar.foreground
            opacity: 0.12
          }

          Grid {
            columns: 2
            columnSpacing: Style.space(28)
            rowSpacing: Style.space(16)

            Metric { label: "POWER"; value: Math.round(Number(root.sample.powerPercent || 0)) + "%" }
            Metric { label: "RPM"; value: Math.round(Number(root.sample.rpm || 0)).toLocaleString() }
            Metric { label: "VOLTAGE"; value: Number(root.sample.voltage || 0).toFixed(1) + " V" }
            Metric { label: "TEMP"; value: Math.round(Number(root.sample.temperatureC || 0)) + "°C" }
          }
        }

        Rectangle {
          visible: root.warning || root.errorMessage
          width: parent.width
          height: warningText.implicitHeight + Style.space(16)
          radius: Style.cornerRadius
          color: Qt.rgba(1, 0.25, 0.25, 0.12)

          Text {
            id: warningText
            anchors.centerIn: parent
            text: root.errorMessage ? root.errorMessage : "⚠ " + String(root.sample.warning).toUpperCase()
            color: root.bar.urgent || "#ff5f5f"
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
          }
        }
      }
    }
  }

  component Metric: Column {
    required property string label
    required property string value
    width: Style.space(92)
    spacing: Style.space(3)

    Text {
      text: parent.label
      color: Qt.darker(root.bar.foreground, 1.5)
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.caption
      font.letterSpacing: 1
    }

    Text {
      text: parent.value
      color: root.bar.foreground
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.title
      font.bold: true
    }
  }
}
