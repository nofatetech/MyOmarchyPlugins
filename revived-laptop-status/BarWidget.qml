import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "myomarchy.revived-laptop-status"

  property var sample: ({})
  readonly property int refreshInterval: Math.max(2, Number(settings.refreshIntervalSec || 3)) * 1000
  readonly property bool showFan: settings.showFan !== false
  readonly property bool showMemory: settings.showMemory === true
  readonly property int minimumTemperature: Number(settings.minimumTemperatureC || 35)
  readonly property int maximumTemperature: Number(settings.maximumTemperatureC || 100)
  readonly property int warningTemperature: Number(settings.temperatureWarningC || 80)
  readonly property bool warning: Number(sample.temperatureC || 0) >= warningTemperature
  readonly property bool hasTemperature: sample.temperatureC !== null && sample.temperatureC !== undefined

  implicitWidth: contents.implicitWidth + 15
  implicitHeight: contents.implicitHeight

  function auxiliaryText() {
    var parts = []
    if (showFan && Number(sample.fanRpm || 0) > 0)
      parts.push(Math.round(Number(sample.fanRpm) / 100) / 10 + "k")
    if (showMemory)
      parts.push("RAM " + Math.round(Number(sample.memoryPercent || 0)) + "%")
    return parts.join("  ")
  }

  function tooltipText() {
    if (sample.error) return "Laptop status unavailable: " + sample.error
    var lines = [
      "CPU usage: " + Math.round(Number(sample.cpuPercent || 0)) + "%",
      "CPU temperature: " + (sample.temperatureC === null || sample.temperatureC === undefined ? "not exposed" : Math.round(Number(sample.temperatureC)) + "°C"),
      "Gauge range: " + minimumTemperature + "–" + maximumTemperature + "°C",
      "Fan: " + (Number(sample.fanRpm || 0) > 0 ? Math.round(Number(sample.fanRpm)) + " RPM" : "not exposed"),
      "Memory: " + Math.round(Number(sample.memoryPercent || 0)) + "%",
      "Swap: " + Math.round(Number(sample.swapPercent || 0)) + "%",
      "Load average: " + String(sample.loadAverage || "?")
    ]
    return lines.join("\n")
  }

  function refresh() {
    if (!collector.running) collector.running = true
  }

  Row {
    id: contents
    anchors.centerIn: parent
    spacing: 5

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.sample.error ? "\uf4bc ?" : "\uf4bc " + Math.round(Number(root.sample.cpuPercent || 0)) + "%"
      color: root.bar ? root.bar.foreground : "white"
      font.family: root.bar ? root.bar.fontFamily : "monospace"
      font.pixelSize: 12
    }

    TemperatureGauge {
      visible: root.hasTemperature
      width: visible ? implicitWidth : 0
      value: Number(root.sample.temperatureC || 0)
      minimumValue: root.minimumTemperature
      maximumValue: root.maximumTemperature
      warningValue: root.warningTemperature
      foregroundColor: root.bar ? root.bar.foreground : "white"
      urgentColor: root.bar ? root.bar.urgent : "#ff5f5f"
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: text.length > 0
      text: root.auxiliaryText()
      color: root.bar ? root.bar.foreground : "white"
      font.family: root.bar ? root.bar.fontFamily : "monospace"
      font.pixelSize: 12
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltipText())
    onExited: if (root.bar) root.bar.hideTooltip(root)
    onClicked: if (root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
  }

  Process {
    id: collector
    command: [Qt.resolvedUrl("collect-status.sh").toString().replace("file://", "")]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.sample = JSON.parse(text.trim())
        } catch (e) {
          root.sample = { "error": "invalid collector output" }
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
}
