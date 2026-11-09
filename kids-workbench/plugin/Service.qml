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
  // The template the kid just picked, waiting for a name. null = not asking.
  property var pendingTemplate: null
  property string suggestedName: ""

  readonly property var adjectives: ["brave", "sunny", "quick", "clever", "wild", "cosmic", "tiny", "mighty", "happy", "lucky"]
  readonly property var nouns: ["fox", "rocket", "otter", "comet", "badger", "robot", "dragon", "owl", "panda", "falcon"]

  readonly property string pluginDir: Qt.resolvedUrl(".").toString().replace("file://", "")

  function toggle() {
    expanded = !expanded
    if (expanded) refresh()
  }
  function open() { expanded = true; refresh() }
  function close() { expanded = false; pendingTemplate = null }

  function randomName() {
    var a = adjectives[Math.floor(Math.random() * adjectives.length)]
    var n = nouns[Math.floor(Math.random() * nouns.length)]
    return a + " " + n
  }

  // Step 1: a tile was clicked. Ask for a name, pre-filled with a suggestion.
  function ask(template) {
    suggestedName = randomName()
    pendingTemplate = template
  }
  function askById(id) {
    for (var i = 0; i < templates.length; i++) {
      if (templates[i].id === id) { expanded = true; ask(templates[i]); return }
    }
  }
  function cancel() { pendingTemplate = null }
  // Step 2: the name was confirmed.
  function confirm(name, idea) {
    if (!pendingTemplate) return
    var id = pendingTemplate.id
    pendingTemplate = null
    startNew(id, name, idea)
  }

  function refresh() {
    if (!tplProc.running) tplProc.running = true
    if (!projProc.running) projProc.running = true
  }

  function startNew(templateId, name, idea) {
    if (newProc.running) return
    lastMessage = "Starting…"
    newProc.command = [pluginDir + "scripts/new-project.sh", templateId, name || "", idea || ""]
    newProc.running = true
  }

  function openProject(path) {
    openProc.command = [pluginDir + "scripts/open-project.sh", path]
    openProc.running = true
  }

  // The project's standards are older than the current ones: update, then the agent migrates.
  function syncProject(path) {
    lastMessage = "Updating…"
    openProc.command = [pluginDir + "scripts/sync-launch.sh", path]
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
    // omarchy-shell myomarchy.kids-workbench create godot-game
    function create(templateId: string): void { root.askById(templateId) }
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
