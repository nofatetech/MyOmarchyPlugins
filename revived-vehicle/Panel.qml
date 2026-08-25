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
  readonly property string vehicleProfile: String(setting("vehicleProfile", "honda-civic-1996-us"))
  readonly property bool useMph: String(setting("speedUnit", "km/h")).toLowerCase() === "mph"
  readonly property real displaySpeed: useMph ? Number(sample.speedKph || 0) * 0.621371 : Number(sample.speedKph || 0)
  readonly property string speedUnit: useMph ? "mph" : "km/h"
  readonly property bool warning: Boolean(sample.warning) && String(sample.warning) !== "none"
  readonly property var profile: sample.profile || ({})
  readonly property var transport: sample.transport || ({})
  readonly property var obd: sample.obd || ({})
  readonly property var signals: sample.signals || ({})
  readonly property string barLabel: "󰄋 " + Math.round(displaySpeed) + " " + speedUnit

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
    return [script, "--source", dataSource, "--file", telemetryFile, "--profile", vehicleProfile]
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

      Flickable {
        id: dashboardScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: dashboard.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: dashboard
          width: dashboardScroll.width
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

        Rectangle {
          width: parent.width
          height: profileContent.implicitHeight + Style.space(24)
          radius: Style.cornerRadius
          color: Style.normalFillFor(root.bar.foreground, Color.accent, root.bar.urgent)

          Column {
            id: profileContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(7)

            SectionTitle { text: "VEHICLE PROFILE" }
            InfoRow { label: "Profile"; value: String(root.profile.name || "Unspecified") }
            InfoRow { label: "Generation"; value: String(root.profile.generation || "Unknown") }
            InfoRow { label: "Region"; value: String(root.profile.region || "Unknown") }
            InfoRow { label: "Engine / transmission"; value: String(root.profile.engine || "Unknown") + " / " + String(root.profile.transmission || "Unknown") }
            InfoRow { label: "Connector"; value: String(root.profile.connector || "Unknown") }
          }
        }

        Rectangle {
          width: parent.width
          height: networkContent.implicitHeight + Style.space(24)
          radius: Style.cornerRadius
          color: Style.normalFillFor(root.bar.foreground, Color.accent, root.bar.urgent)

          Column {
            id: networkContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(7)

            SectionTitle { text: "VEHICLE NETWORK" }
            InfoRow { label: "Transport"; value: String(root.transport.kind || "unknown").toUpperCase() + " · " + String(root.transport.protocol || "not detected") }
            InfoRow { label: "Interface"; value: String(root.transport.interface || "none") + " · " + String(root.transport.state || "offline") }
            InfoRow { label: "Safety"; value: root.transport.readOnly === true ? "READ ONLY" : "WRITE CAPABLE"; urgent: root.transport.readOnly !== true }
            InfoRow { label: "Traffic"; value: Math.round(Number(root.transport.rxRate || 0)) + " msg/s · " + Math.round(Number(root.transport.rxTotal || 0)).toLocaleString() + " total" }
            InfoRow { label: "IDs / errors / dropped"; value: Math.round(Number(root.transport.uniqueIds || 0)) + " / " + Math.round(Number(root.transport.errorFrames || 0)) + " / " + Math.round(Number(root.transport.droppedFrames || 0)) }
            InfoRow { label: "Bitrate / bus load"; value: root.transport.bitrateKbps === null || root.transport.bitrateKbps === undefined ? "n/a" : Number(root.transport.bitrateKbps).toFixed(1) + " kbps · " + (root.transport.busLoadPercent === null || root.transport.busLoadPercent === undefined ? "n/a" : Number(root.transport.busLoadPercent).toFixed(1) + "%") }
            InfoRow { label: "Last frame"; value: String(root.transport.lastFrame || "—"); mono: true }
          }
        }

        Rectangle {
          width: parent.width
          height: obdContent.implicitHeight + Style.space(24)
          radius: Style.cornerRadius
          color: Style.normalFillFor(root.bar.foreground, Color.accent, root.bar.urgent)

          Column {
            id: obdContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(7)

            SectionTitle { text: "OBD OVERVIEW" }
            InfoRow { label: "Mode / ECU"; value: String(root.obd.mode || "unavailable") + " · " + String(root.obd.ecu || "none") }
            InfoRow { label: "Ignition"; value: String(root.obd.ignition || "unknown") }
            InfoRow { label: "Supported data / latency"; value: Math.round(Number(root.obd.supportedItems || 0)) + " items · " + Math.round(Number(root.obd.latencyMs || 0)) + " ms" }
            InfoRow { label: "MIL / trouble codes"; value: (root.obd.mil === true ? "ON" : "off") + " · " + Math.round(Number(root.obd.dtcCount || 0)) + " DTCs"; urgent: root.obd.mil === true || Number(root.obd.dtcCount || 0) > 0 }
            InfoRow { label: "Readiness"; value: String(root.obd.readiness || "unknown") }

            Rectangle { width: parent.width; height: Style.spacing.hairline; color: root.bar.foreground; opacity: 0.1 }

            Grid {
              columns: 3
              columnSpacing: Style.space(24)
              rowSpacing: Style.space(12)
              Metric { label: "STFT"; value: Number(root.signals.shortFuelTrimPercent || 0).toFixed(1) + "%" }
              Metric { label: "INTAKE"; value: Math.round(Number(root.signals.intakeTemperatureC || 0)) + "°C" }
              Metric { label: "THROTTLE"; value: Math.round(Number(root.signals.throttlePercent || 0)) + "%" }
              Metric { label: "MAP"; value: Math.round(Number(root.signals.mapKpa || 0)) + " kPa" }
              Metric { label: "FUEL"; value: Math.round(Number(root.signals.fuelLevelPercent || 0)) + "%" }
            }
          }
        }

        Rectangle {
          width: parent.width
          height: debugContent.implicitHeight + Style.space(24)
          radius: Style.cornerRadius
          color: Style.normalFillFor(root.bar.foreground, Color.accent, root.bar.urgent)

          Column {
            id: debugContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(6)

            SectionTitle { text: "OBD DEBUG · MOCK DATA" }

            Repeater {
              model: root.obd.debug || []

              Text {
                required property var modelData
                width: debugContent.width
                text: String(modelData)
                color: Qt.darker(root.bar.foreground, 1.25)
                font.family: "monospace"
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
              }
            }
          }
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

  component SectionTitle: Text {
    color: Qt.darker(root.bar.foreground, 1.35)
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
    font.letterSpacing: 1.4
  }

  component InfoRow: Row {
    required property string label
    required property string value
    property bool urgent: false
    property bool mono: false

    width: parent.width
    spacing: Style.space(10)

    Text {
      width: parent.width * 0.38
      text: parent.label
      color: Qt.darker(root.bar.foreground, 1.5)
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    Text {
      width: parent.width * 0.62 - parent.spacing
      text: parent.value
      color: parent.urgent ? root.bar.urgent : root.bar.foreground
      font.family: parent.mono ? "monospace" : root.bar.fontFamily
      font.pixelSize: Style.font.bodySmall
      horizontalAlignment: Text.AlignRight
      elide: Text.ElideRight
    }
  }
}
