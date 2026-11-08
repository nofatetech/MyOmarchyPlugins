// Your game starts here. Try changing the color, the speed, or the size!
const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");

const player = { x: 220, y: 140, size: 30, speed: 4, color: "#9ece6a" };
const keys = {};
addEventListener("keydown", (e) => (keys[e.key] = true));
addEventListener("keyup", (e) => (keys[e.key] = false));

function update() {
  if (keys["ArrowLeft"]) player.x -= player.speed;
  if (keys["ArrowRight"]) player.x += player.speed;
  if (keys["ArrowUp"]) player.y -= player.speed;
  if (keys["ArrowDown"]) player.y += player.speed;
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = player.color;
  ctx.fillRect(player.x, player.y, player.size, player.size);
}

function loop() { update(); draw(); requestAnimationFrame(loop); }
loop();
