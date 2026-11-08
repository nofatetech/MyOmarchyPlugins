// Mock data for the prototype. Edit freely; everything in the UI reads from here.
window.DATA = {
  kid: { name: "Lena", age: 12 },

  starters: [
    { icon: "🎮", title: "Make a game", sub: "Godot or HTML", color: "#7aa2f7" },
    { icon: "🎨", title: "Draw", sub: "Sketch, pixel art, comic", color: "#f7768e" },
    { icon: "✍️", title: "Write", sub: "Story, notes, doc", color: "#9ece6a" },
    { icon: "🔧", title: "Build something", sub: "CAD, print, solder, wood", color: "#e0af68" },
    { icon: "🎵", title: "Make music", sub: "Record, loop, mix", color: "#bb9af7" },
    { icon: "🧭", title: "Explore", sub: "Find and save links", color: "#7dcfff" },
  ],

  rhythm: { make: 5, move: 2, rest: 1, share: 1, goal: { make: 6, move: 4, rest: 3, share: 2 } },

  projects: [
    {
      id: "kart", icon: "🏎️", title: "Go-kart brakes", status: "In progress", progress: 45,
      kinds: ["wood", "cars"], mentor: "Opa",
      next: "Measure the brake pedal bracket",
      todo: [
        { t: "Sketch bracket in FreeCAD", done: true },
        { t: "Buy 6mm steel plate", done: true },
        { t: "Measure the brake pedal bracket", done: false },
        { t: "Cut and drill plate", done: false },
        { t: "Test on the driveway (with Opa)", done: false },
      ],
      log: [
        { when: "Today", text: "Took photos of the old bracket. It bends when I push hard.", photo: "📷" },
        { when: "Tue", text: "FreeCAD sketch v2 done. Thicker plate this time.", photo: "📐" },
        { when: "Sat", text: "Brakes were weak. Figured out why: cable stretch.", photo: "🛠️" },
      ],
      links: ["How disc brakes work", "Steel plate sizes"],
    },
    {
      id: "led", icon: "💡", title: "Treehouse lights", status: "Starting", progress: 15,
      kinds: ["solder", "arduino"], mentor: "Papa",
      next: "Solder the first LED strip connector",
      todo: [
        { t: "Pick LED strip", done: true },
        { t: "Solder connector", done: false },
        { t: "Program ESP32 pattern", done: false },
      ],
      log: [{ when: "Sun", text: "Ordered parts. Arrive Thursday.", photo: "📦" }],
      links: ["WS2812 wiring guide"],
    },
    {
      id: "band", icon: "🎸", title: "Garage concert", status: "Planning", progress: 30,
      kinds: ["music", "dmx"], mentor: "Mia (band friend)",
      next: "Test DMX lights with QLC+",
      todo: [
        { t: "Record 3 songs", done: true },
        { t: "Test DMX lights with QLC+", done: false },
        { t: "Invite friends", done: false },
      ],
      log: [{ when: "Fri", text: "Song 2 sounds good. Needs a drum loop.", photo: "🎧" }],
      links: ["QLC+ quickstart"],
    },
  ],

  // Step mode demo: one project type fully worked out
  steps: {
    title: "Solder the LED strip connector",
    safety: ["Iron is 350°C: stand, not hand", "Window open or fan on", "Safety glasses on"],
    items: [
      { icon: "🧰", title: "Get your tools", body: "Soldering iron, solder, wire strippers, connector, strip.", tip: "Put everything on the mat first." },
      { icon: "✂️", title: "Strip the wires", body: "Strip about 5 mm from each wire end.", tip: "Twist the strands tight with your fingers." },
      { icon: "🔥", title: "Tin the pads", body: "Heat a pad for 2 seconds, touch solder to the pad, not the iron.", tip: "Shiny and cone-shaped means good." },
      { icon: "🔗", title: "Join wire to pad", body: "Hold wire on pad, touch iron, count to 2, remove iron, hold still.", tip: "If it moves while cooling, redo it.", timer: 30 },
      { icon: "🔍", title: "Check the joint", body: "Shiny, smooth, no blobs, no bridges to the next pad.", tip: "Photo it for your project log!" },
    ],
  },

  links: [
    { title: "How disc brakes work", site: "youtube.com", tags: ["cars", "go-kart"], note: "Good animation at 3:10", icon: "▶️", project: "kart" },
    { title: "WS2812 wiring guide", site: "adafruit.com", tags: ["led", "arduino"], note: "Use a 470Ω resistor on data", icon: "💡", project: "led" },
    { title: "Godot 2D platformer in 20 min", site: "youtube.com", tags: ["godot", "game"], note: "", icon: "🎮", project: null },
    { title: "Pixel art for beginners", site: "lospec.com", tags: ["art", "pixel"], note: "Palette list is great", icon: "🎨", project: null },
    { title: "Steel plate sizes", site: "metalsupermarkets.com", tags: ["metal", "go-kart"], note: "6mm is enough", icon: "🔩", project: "kart" },
    { title: "QLC+ quickstart", site: "qlcplus.org", tags: ["dmx", "lights"], note: "", icon: "🔦", project: "band" },
    { title: "Best free synth sounds", site: "surge-synthesizer.github.io", tags: ["music"], note: "Try the pad patches", icon: "🎹", project: null },
  ],

  creations: [
    { icon: "🐉", title: "Dragon sketch", kind: "Drawing", when: "2 days ago" },
    { icon: "🕹️", title: "Space Dodger", kind: "Godot game", when: "last week", playable: true },
    { icon: "🔑", title: "Printed keychain", kind: "3D print", when: "last week" },
    { icon: "🎶", title: "Song 2: Garage", kind: "Recording", when: "Friday" },
    { icon: "📖", title: "Comic page 1", kind: "Comic", when: "3 weeks ago" },
    { icon: "🪵", title: "Bird house", kind: "Woodwork", when: "last month" },
  ],

  mentors: [
    { name: "Opa", skills: ["cars", "woodwork"], note: "Come Saturday, we'll test the brakes.", when: "Yesterday" },
    { name: "Papa", skills: ["electronics", "code"], note: "Nice flux photo! Next try less solder.", when: "2 days ago" },
    { name: "Mia", skills: ["music"], note: "Send me song 2 when it is mixed.", when: "Fri" },
  ],

  skills: [
    { name: "Drawing", level: 3, evidence: ["Dragon sketch", "Comic page 1"], vouched: [] },
    { name: "Godot", level: 2, evidence: ["Space Dodger"], vouched: ["Papa"] },
    { name: "3D printing", level: 2, evidence: ["Printed keychain"], vouched: [] },
    { name: "Soldering", level: 1, evidence: ["LED connector (in progress)"], vouched: ["Papa"] },
    { name: "Woodwork", level: 2, evidence: ["Bird house"], vouched: ["Opa"] },
    { name: "Car repair", level: 1, evidence: ["Go-kart brakes (in progress)"], vouched: ["Opa"] },
    { name: "Music recording", level: 2, evidence: ["Song 2: Garage"], vouched: ["Mia"] },
  ],
};
