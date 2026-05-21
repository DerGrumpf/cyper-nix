async function submitRegistration() {
  const usernameInput = document.getElementById("reg-username");
  const emailInput = document.getElementById("reg-email");
  const btn = document.getElementById("reg-btn");
  const status = document.getElementById("reg-status");

  const username = usernameInput.value.trim();
  const email = emailInput.value.trim();

  // Validierung
  status.className = "reg-status";
  status.style.display = "none";

  if (!username || !email) {
    status.className = "reg-status error";
    status.textContent = "⚠️ Bitte Benutzernamen und E-Mail-Adresse eingeben.";
    return;
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    status.className = "reg-status error";
    status.textContent = "⚠️ Bitte eine gültige E-Mail-Adresse eingeben.";
    return;
  }

  btn.disabled = true;
  btn.textContent = "Wird übertragen...";

  try {
    const res = await fetch("register.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username,
        email,
        website: document.getElementById("reg-website").value,
      }),
    });

    const data = await res.json().catch(() => ({}));

    if (res.ok && data.success) {
      status.className = "reg-status success";
      status.innerHTML =
        "✅ <strong>Anfrage erfolgreich gesendet!</strong><br>" +
        "Die Administration wurde benachrichtigt. Du erhältst deine Login-Daten in Kürze an die angegebene E-Mail-Adresse.";
      usernameInput.value = "";
      emailInput.value = "";
    } else {
      throw new Error(
        data.error ||
          (res.status === 429
            ? "Zu viele Anfragen. Bitte warte einige Minuten."
            : `HTTP ${res.status}`),
      );
    }
  } catch (e) {
    status.className = "reg-status error";
    status.textContent = `❌ Übertragung fehlgeschlagen: ${e.message}`;
  } finally {
    btn.disabled = false;
    btn.textContent = "Zugang anfordern";
  }
}

// Enter-Taste in Feldern
document.addEventListener("DOMContentLoaded", () => {
  ["reg-username", "reg-email"].forEach((id) => {
    document.getElementById(id).addEventListener("keydown", (e) => {
      if (e.key === "Enter") submitRegistration();
    });
  });
});

const canvas = document.getElementById("matrix-bg");
const ctx = canvas.getContext("2d");

function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
resizeCanvas();
window.addEventListener("resize", resizeCanvas);

const katakana =
  "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const alphabet = katakana.split("");

const fontSize = 16;
let columns = canvas.width / fontSize;

const rainDrops = [];
for (let x = 0; x < columns; x++) {
  rainDrops[x] = 1;
}

window.addEventListener("resize", () => {
  columns = canvas.width / fontSize;
  for (let x = rainDrops.length; x < columns; x++) {
    rainDrops[x] = 1;
  }
});

function drawMatrixRain() {
  ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.fillStyle = "#0f0";
  ctx.font = fontSize + "px monospace";

  for (let i = 0; i < rainDrops.length; i++) {
    const text = alphabet[Math.floor(Math.random() * alphabet.length)];
    ctx.fillText(text, i * fontSize, rainDrops[i] * fontSize);

    if (rainDrops[i] * fontSize > canvas.height && Math.random() > 0.975) {
      rainDrops[i] = 0;
    }
    rainDrops[i]++;
  }
}

setInterval(drawMatrixRain, 30);
