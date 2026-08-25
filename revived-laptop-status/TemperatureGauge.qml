import QtQuick

Item {
  id: gauge

  property real value: 0
  property real minimumValue: 35
  property real maximumValue: 100
  property real warningValue: 80
  property color foregroundColor: "white"
  property color urgentColor: "#ff5f5f"
  property string fontFamily: "monospace"

  readonly property real normalizedValue: Math.max(0, Math.min(1,
    (value - minimumValue) / Math.max(1, maximumValue - minimumValue)))

  implicitWidth: 48
  implicitHeight: 24

  Canvas {
    id: dial
    anchors.fill: parent

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()

      var centerX = width / 2
      var centerY = height - 4
      var radius = 17
      var start = Math.PI
      var end = Math.PI * 2
      var warmAt = Math.max(0, Math.min(1,
        (gauge.warningValue - gauge.minimumValue) /
        Math.max(1, gauge.maximumValue - gauge.minimumValue)))

      ctx.lineCap = "round"
      ctx.lineWidth = 2

      ctx.strokeStyle = Qt.rgba(gauge.foregroundColor.r, gauge.foregroundColor.g,
                                gauge.foregroundColor.b, 0.58)
      ctx.beginPath()
      ctx.arc(centerX, centerY, radius, start, start + Math.PI * warmAt, false)
      ctx.stroke()

      ctx.strokeStyle = gauge.urgentColor
      ctx.beginPath()
      ctx.arc(centerX, centerY, radius, start + Math.PI * warmAt, end, false)
      ctx.stroke()

      // Strong endpoint ticks give the dial its min/max calibration marks.
      for (var i = 0; i < 2; i++) {
        var tickAngle = i === 0 ? start : end
        ctx.strokeStyle = i === 0 ? gauge.foregroundColor : gauge.urgentColor
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(centerX + Math.cos(tickAngle) * (radius - 3),
                   centerY + Math.sin(tickAngle) * (radius - 3))
        ctx.lineTo(centerX + Math.cos(tickAngle) * (radius + 2),
                   centerY + Math.sin(tickAngle) * (radius + 2))
        ctx.stroke()
      }

      var needleAngle = start + gauge.normalizedValue * Math.PI
      ctx.strokeStyle = gauge.normalizedValue >= warmAt
        ? gauge.urgentColor : gauge.foregroundColor
      ctx.lineWidth = 1.5
      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.lineTo(centerX + Math.cos(needleAngle) * (radius - 5),
                 centerY + Math.sin(needleAngle) * (radius - 5))
      ctx.stroke()

      ctx.fillStyle = ctx.strokeStyle
      ctx.beginPath()
      ctx.arc(centerX, centerY, 2, 0, Math.PI * 2, false)
      ctx.fill()
    }

    Connections {
      target: gauge
      function onValueChanged() { dial.requestPaint() }
      function onMinimumValueChanged() { dial.requestPaint() }
      function onMaximumValueChanged() { dial.requestPaint() }
      function onWarningValueChanged() { dial.requestPaint() }
      function onForegroundColorChanged() { dial.requestPaint() }
      function onUrgentColorChanged() { dial.requestPaint() }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 7
    text: Math.round(gauge.value) + "°"
    color: gauge.normalizedValue >= Math.max(0, Math.min(1,
      (gauge.warningValue - gauge.minimumValue) /
      Math.max(1, gauge.maximumValue - gauge.minimumValue)))
      ? gauge.urgentColor : gauge.foregroundColor
    font.family: gauge.fontFamily
    font.pixelSize: 8
    font.bold: true
  }
}
