const D = window.DATA;
const $ = (s) => document.querySelector(s);
const view = $("#view");
const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

const NAV = [
  { id: "home", icon: "🏠", label: "Home" },
  { id: "projects", icon: "📁", label: "Projects" },
  { id: "creations", icon: "🖼️", label: "My Creations" },
  { id: "links", icon: "🧭", label: "Explore & Saved" },
  { id: "mentors", icon: "🤝", label: "Mentors" },
  { id: "skills", icon: "🌳", label: "Skills" },
];

let state = { page: "home", projectId: null, linkFilter: null, linkQuery: "" };

function toast(msg) {
  const t = $("#toast");
  t.textContent = msg; t.classList.add("show");
  clearTimeout(toast.h); toast.h = setTimeout(() => t.classList.remove("show"), 2200);
}

function go(page, extra = {}) {
  state = { ...state, page, projectId: null, ...extra };
  render();
  window.scrollTo(0, 0);
}

function renderNav() {
  $("#nav").innerHTML = NAV.map((n) =>
    `<button class="nav ${state.page === n.id ? "active" : ""}" data-go="${n.id}">
       <span class="ic">${n.icon}</span>${n.label}</button>`).join("");
}

function dots(n, goal) {
  return `<div class="dots">${Array.from({ length: goal }, (_, i) => `<i class="${i < n ? "f" : ""}"></i>`).join("")}</div>`;
}

/* ---------- Pages ---------- */
const pages = {
  home() {
    const r = D.rhythm;
    const p = D.projects[0];
    return `
      <h1>Hi ${esc(D.kid.name)} 👋</h1>
      <p class="muted">What do you want to make today?</p>

      <div class="grid cols-3 section">
        ${D.starters.map((s) => `
          <button class="tile" style="background:${s.color}" data-toast="Starting: ${esc(s.title)} (mock)">
            <span class="big">${s.icon}</span><b>${esc(s.title)}</b><span>${esc(s.sub)}</span>
          </button>`).join("")}
      </div>

      <div class="section">
        <h2>Pick up where you left off</h2>
        <button class="card click" style="width:100%" data-project="${p.id}">
          <div class="row between wrap">
            <div class="row"><span style="font-size:2.2rem">${p.icon}</span>
              <div><b>${esc(p.title)}</b><div class="muted small">Next: ${esc(p.next)}</div></div></div>
            <span class="btn">Continue →</span>
          </div>
          <div class="bar" style="margin-top:.8rem"><i style="width:${p.progress}%"></i></div>
        </button>
      </div>

      <div class="section">
        <h2>This week’s rhythm</h2>
        <p class="muted small">A suggestion, not a rule. Nothing is locked.</p>
        <div class="rhythm">
          ${["make", "move", "rest", "share"].map((k) => `
            <div class="r"><b>${{ make: "🔨 Make", move: "🏃 Move", rest: "🌙 Rest", share: "📣 Share" }[k]}</b>
              <div class="muted small">${r[k]} of ${r.goal[k]}</div>${dots(r[k], r.goal[k])}</div>`).join("")}
        </div>
        <div class="card" style="margin-top:1rem">
          💡 <b>Idea:</b> your brake bracket needs a test. Take the kart outside for 20 minutes. That counts as <b>Move</b>.
        </div>
      </div>

      <div class="section">
        <h2>From your mentors</h2>
        <div class="grid cols-2">
          ${D.mentors.slice(0, 2).map((m) => `
            <div class="card"><b>${esc(m.name)}</b> <span class="muted small">· ${esc(m.when)}</span>
              <div>“${esc(m.note)}”</div></div>`).join("")}
        </div>
      </div>`;
  },

  projects() {
    if (state.projectId) return pages.project(D.projects.find((p) => p.id === state.projectId));
    return `
      <div class="row between"><h1>Projects</h1><button class="btn" data-toast="New project wizard (mock)">＋ New project</button></div>
      <div class="grid cols-2 section">
        ${D.projects.map((p) => `
          <button class="card click" data-project="${p.id}">
            <div class="row"><span style="font-size:2.4rem">${p.icon}</span>
              <div><b>${esc(p.title)}</b><div class="row wrap" style="gap:.35rem;margin-top:.25rem">
                <span class="badge">${esc(p.status)}</span>${p.kinds.map((k) => `<span class="tag">${k}</span>`).join("")}</div></div></div>
            <div class="muted small" style="margin:.7rem 0 .4rem">Next: ${esc(p.next)}</div>
            <div class="bar"><i style="width:${p.progress}%"></i></div>
            <div class="muted small" style="margin-top:.5rem">Mentor: ${esc(p.mentor)}</div>
          </button>`).join("")}
      </div>`;
  },

  project(p) {
    const links = D.links.filter((l) => l.project === p.id);
    return `
      <button class="chip" data-go="projects">← All projects</button>
      <div class="row between wrap" style="margin-top:1rem">
        <div class="row"><span style="font-size:3rem">${p.icon}</span>
          <div><h1 style="margin:0">${esc(p.title)}</h1><span class="badge">${esc(p.status)}</span></div></div>
        <div class="row">
          <button class="btn ghost" data-toast="Photo added to log (mock)">📷 Add photo</button>
          <button class="btn" data-step="1">▶ Step mode</button>
        </div>
      </div>
      <div class="bar" style="margin:1rem 0"><i style="width:${p.progress}%"></i></div>

      <div class="grid cols-2">
        <div class="card"><h2>To do</h2>
          ${p.todo.map((t, i) => `
            <label class="todo ${t.done ? "done" : ""}"><input type="checkbox" data-todo="${p.id}:${i}" ${t.done ? "checked" : ""}><span>${esc(t.t)}</span></label>`).join("")}
        </div>
        <div class="card"><h2>Project log</h2>
          ${p.log.map((l) => `
            <div class="log"><div class="ph">${l.photo}</div><div><div class="muted small">${esc(l.when)}</div>${esc(l.text)}</div></div>`).join("")}
          <div class="row" style="margin-top:.8rem"><input type="text" id="logInput" placeholder="What happened? (or just add a photo)"><button class="btn" data-addlog="${p.id}">Add</button></div>
        </div>
        <div class="card"><h2>Saved for this project</h2>
          ${links.length ? links.map((l) => `<div class="todo"><span>${l.icon}</span><span>${esc(l.title)} <span class="muted small">${esc(l.site)}</span></span></div>`).join("") : `<p class="muted">Nothing yet.</p>`}
        </div>
        <div class="card"><h2>Mentor</h2>
          <p><b>${esc(p.mentor)}</b></p>
          <button class="btn ghost" data-toast="Photo + question sent to ${esc(p.mentor)} (mock)">📨 Ask a mentor</button>
          <button class="btn ghost" data-toast="Read-only link copied (mock)">🔗 Share project</button>
        </div>
      </div>`;
  },

  creations() {
    return `
      <div class="row between"><h1>My Creations</h1>
        <button class="btn ghost" data-toast="Family gallery link copied (mock)">🏠 Show the family</button></div>
      <p class="muted">Everything you’ve made, in one place.</p>
      <div class="grid cols-3 section">
        ${D.creations.map((c) => `
          <div class="card">
            <div style="font-size:3.5rem;text-align:center;background:var(--panel2);border-radius:12px;padding:1rem">${c.icon}</div>
            <div style="margin-top:.7rem"><b>${esc(c.title)}</b></div>
            <div class="muted small">${esc(c.kind)} · ${esc(c.when)}</div>
            <div class="row" style="margin-top:.6rem">
              ${c.playable ? `<button class="btn" data-toast="Launching ${esc(c.title)} (mock)">▶ Play</button>` : `<button class="btn ghost" data-toast="Opening ${esc(c.title)} (mock)">Open</button>`}
              <button class="chip" data-toast="Shared (mock)">Share</button>
            </div>
          </div>`).join("")}
      </div>`;
  },

  links() {
    const tags = [...new Set(D.links.flatMap((l) => l.tags))].sort();
    const q = state.linkQuery.toLowerCase();
    const list = D.links.filter((l) =>
      (!state.linkFilter || l.tags.includes(state.linkFilter)) &&
      (!q || (l.title + l.note + l.tags.join(" ")).toLowerCase().includes(q)));
    return `
      <h1>Explore & Saved</h1>
      <p class="muted">Save things you find. Tag them. Come back later.</p>
      <div class="row section" style="margin-top:1rem">
        <input type="text" id="linkSearch" placeholder="Search your saved stuff…" value="${esc(state.linkQuery)}">
        <button class="btn" data-toast="Browser extension: 'Save this page' button (mock)">＋ Save page</button>
      </div>
      <div class="row wrap" style="gap:.4rem;margin:1rem 0">
        <button class="tag ${!state.linkFilter ? "on" : ""}" data-tag="">all</button>
        ${tags.map((t) => `<button class="tag ${state.linkFilter === t ? "on" : ""}" data-tag="${t}">${t}</button>`).join("")}
      </div>
      <div class="grid cols-3">
        ${list.map((l) => `
          <div class="card">
            <div class="row"><span style="font-size:1.8rem">${l.icon}</span><div><b>${esc(l.title)}</b><div class="muted small">${esc(l.site)}</div></div></div>
            ${l.note ? `<p class="small">📝 ${esc(l.note)}</p>` : ""}
            <div class="row wrap" style="gap:.3rem">${l.tags.map((t) => `<span class="tag">${t}</span>`).join("")}</div>
            ${l.project ? `<div class="muted small" style="margin-top:.5rem">📁 ${esc(D.projects.find((p) => p.id === l.project).title)}</div>` : ""}
          </div>`).join("") || `<p class="muted">Nothing found.</p>`}
      </div>
      <div class="card section">
        <b>🔮 Later:</b> turn a tag into a zine or mini-site, e.g. “go-kart” → a one-page build guide.
        <button class="btn ghost" style="margin-left:.5rem" data-toast="Zine builder (mock)">Try it</button>
      </div>`;
  },

  mentors() {
    return `
      <h1>Mentors</h1>
      <p class="muted">People who help you. You choose what to share with them.</p>
      <div class="grid cols-2 section">
        ${D.mentors.map((m) => `
          <div class="card"><div class="row between"><b style="font-size:1.2rem">${esc(m.name)}</b><span class="muted small">${esc(m.when)}</span></div>
            <div class="row wrap" style="gap:.3rem;margin:.4rem 0">${m.skills.map((s) => `<span class="tag">${s}</span>`).join("")}</div>
            <p>“${esc(m.note)}”</p>
            <button class="btn ghost" data-toast="Photo + question sent to ${esc(m.name)} (mock)">📨 Ask ${esc(m.name)}</button>
          </div>`).join("")}
      </div>
      <div class="card section"><h2>What mentors can see</h2>
        <p class="muted">Only projects you shared, read-only. You can stop sharing any time.</p>
        ${D.projects.map((p) => `<label class="todo"><input type="checkbox" ${p.id !== "band" ? "checked" : ""} data-toast="Sharing updated (mock)"><span>${p.icon} ${esc(p.title)} → ${esc(p.mentor)}</span></label>`).join("")}
      </div>`;
  },

  skills() {
    return `
      <div class="row between"><h1>Skills</h1>
        <button class="btn ghost" data-toast="Portfolio PDF exported (mock)">📄 Export portfolio</button></div>
      <p class="muted">Skills you’ve grown, with proof. Mentors can vouch.</p>
      <div class="grid section">
        ${D.skills.map((s) => `
          <div class="card skill">
            <div style="min-width:10rem"><b>${esc(s.name)}</b><div class="stars">${"★".repeat(s.level)}${"☆".repeat(5 - s.level)}</div></div>
            <div style="flex:1" class="small muted">Evidence: ${s.evidence.map(esc).join(", ")}</div>
            <div>${s.vouched.length ? s.vouched.map((v) => `<span class="badge">✔ ${esc(v)}</span>`).join(" ") : `<span class="muted small">no vouch yet</span>`}</div>
          </div>`).join("")}
      </div>`;
  },
};

function render() {
  renderNav();
  view.innerHTML = pages[state.page]();
}

/* ---------- Step mode ---------- */
let step = { i: 0, timer: null, left: 0 };
function openStep() {
  step.i = 0;
  $("#stepProject").textContent = "Treehouse lights";
  $("#stepHeading").textContent = D.steps.title;
  $("#stepSafety").innerHTML = `<div class="safety"><b>⚠ Before you start</b><ul>${D.steps.safety.map((s) => `<li>${esc(s)}</li>`).join("")}</ul></div>`;
  $("#step").classList.add("open");
  drawStep();
}
function drawStep() {
  clearInterval(step.timer);
  const it = D.steps.items[step.i];
  const n = D.steps.items.length;
  $("#stepSafety").style.display = step.i === 0 ? "block" : "none";
  $("#stepBody").innerHTML = `
    <div class="muted">Step ${step.i + 1} of ${n}</div>
    <div class="step-icon">${it.icon}</div>
    <div class="step-title">${esc(it.title)}</div>
    <div class="step-text">${esc(it.body)}</div>
    <div class="step-tip">💡 ${esc(it.tip)}</div>
    ${it.timer ? `<div><div class="timer" id="timer">${it.timer}s</div><button class="btn ghost" id="timerBtn">⏱ Start timer</button></div>` : ""}`;
  $("#stepBar").style.width = ((step.i + 1) / n) * 100 + "%";
  $("#stepNext").textContent = step.i === n - 1 ? "Done ✓" : "Next →";
  const tb = $("#timerBtn");
  if (tb) tb.onclick = () => {
    step.left = it.timer; tb.disabled = true;
    step.timer = setInterval(() => {
      step.left--; $("#timer").textContent = step.left + "s";
      if (step.left <= 0) { clearInterval(step.timer); $("#timer").textContent = "✅ done"; }
    }, 1000);
  };
}
function stepMove(d) {
  const n = D.steps.items.length;
  if (d > 0 && step.i === n - 1) { closeStep(); toast("Nice work! Logged to your project (mock)"); return; }
  step.i = Math.max(0, Math.min(n - 1, step.i + d));
  drawStep();
}
function closeStep() { clearInterval(step.timer); $("#step").classList.remove("open"); }

$("#stepNext").onclick = () => stepMove(1);
$("#stepPrev").onclick = () => stepMove(-1);
$("#stepClose").onclick = closeStep;
$("#stepPhoto").onclick = () => toast("Photo saved to project log (mock)");
document.addEventListener("keydown", (e) => {
  if (!$("#step").classList.contains("open")) return;
  if (e.key === "ArrowRight" || e.key === " ") { e.preventDefault(); stepMove(1); }
  if (e.key === "ArrowLeft") stepMove(-1);
  if (e.key === "Escape") closeStep();
});

/* ---------- Events ---------- */
document.addEventListener("click", (e) => {
  const el = e.target.closest("[data-go],[data-project],[data-toast],[data-step],[data-tag],[data-addlog]");
  if (!el) return;
  if (el.dataset.go) return go(el.dataset.go);
  if (el.dataset.project) return go("projects", { projectId: el.dataset.project });
  if (el.dataset.step) return openStep();
  if (el.dataset.tag !== undefined) { state.linkFilter = el.dataset.tag || null; return render(); }
  if (el.dataset.addlog) {
    const inp = $("#logInput"); const p = D.projects.find((x) => x.id === el.dataset.addlog);
    p.log.unshift({ when: "Now", text: inp.value || "(photo)", photo: "📷" }); return render();
  }
  if (el.dataset.toast) toast(el.dataset.toast);
});
document.addEventListener("change", (e) => {
  const t = e.target.dataset.todo;
  if (t) { const [id, i] = t.split(":"); const p = D.projects.find((x) => x.id === id);
    p.todo[i].done = e.target.checked;
    p.progress = Math.round((p.todo.filter((x) => x.done).length / p.todo.length) * 100); render(); }
});
document.addEventListener("input", (e) => {
  if (e.target.id === "linkSearch") {
    state.linkQuery = e.target.value; const pos = e.target.selectionStart; render();
    const n = $("#linkSearch"); n.focus(); n.setSelectionRange(pos, pos);
  }
});
$("#newBtn").onclick = () => go("home");
$("#sizeBtn").onclick = () => {
  const r = document.documentElement; const big = r.dataset.size === "big";
  r.dataset.size = big ? "" : "big"; $("#sizeBtn").textContent = big ? "Aa Bigger" : "Aa Smaller";
};
$("#themeBtn").onclick = () => {
  const r = document.documentElement; r.dataset.theme = r.dataset.theme === "light" ? "" : "light";
};

render();
