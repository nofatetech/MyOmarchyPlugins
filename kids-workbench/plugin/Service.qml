import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Kids Workbench: a left-edge sidebar. Collapsed it is a thin strip of icons;
// clicked it widens to show "New" (templates) and "My stuff" (projects).
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool expanded: false
  property var templates: []
  property var projects: []
  property string lastMessage: ""

  readonly property string pluginDir: Qt.resolvedUrl(".").toString().replace("file://", "")

  function toggle() {
    expanded = !expanded
    if (expanded) refresh()
  }
  function open() { expanded = true; refresh() }
  function close() { expanded = false }

  function refresh() {
    if (!tplProc.running) tplProc.running = true
    if (!projProc.running) projProc.running = true
  }

  function startNew(templateId) {
    if (newProc.running) return
    lastMessage = "Starting…"
    newProc.command = [pluginDir + "scripts/new-project.sh", templateId]
    newProc.running = true
  }

  function openProject(path) {
    openProc.command = [pluginDir + "scripts/open-project.sh", path]
    openProc.running = true
  }

  function openFolder(path) {
    openProc.command = ["xdg-open", path]
    openProc.running = true
  }

  Component.onCompleted: refresh()

  ShellIpc {
    target: "myomarchy.kids-workbench"
    function toggle(): void { root.toggle() }
    function open(): void { root.open() }
    function close(): void { root.close() }
  }

  Process {
    id: tplProc
    command: [root.pluginDir + "scripts/list-templates.sh"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.templates = JSON.parse(text) } catch (e) { root.templates = [] }
      }
    }
  }

  Process {
    id: projProc
    command: [root.pluginDir + "scripts/list-projects.sh"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.projects = JSON.parse(text) } catch (e) { root.projects = [] }
      }
    }
  }

  Process {
    id: newProc
    stdout: StdioCollector {
      onStreamFinished: {
        root.lastMessage = text.trim() ? "Created " + text.trim().split("/").pop() : ""
        root.expanded = false
        root.refresh()
      }
    }
  }

  Process { id: openProc }

  Variants {
    model: Quickshell.screens
    delegate: Component {
      SidebarWindow {
        required property var modelData
        screen: modelData
        host: root
      }
    }
  }
}
