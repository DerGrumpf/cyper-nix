<?php
// Nur POST-Requests erlauben
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit(json_encode(['error' => 'Method not allowed']));
}

header('Content-Type: application/json');

// --- Konfiguration ---
define('MATRIX_HOMESERVER',  'https://cyperpunk.de');
define('MATRIX_ACCESS_TOKEN', 'syt_cmVnaXN0cmF0aW9uLWJvdA_tWjAfJOYDoJSuoCWoYIQ_4YuoMw');
define('MATRIX_ROOM_ID',      '!xBizjYatXLfpCorAXt:cyperpunk.de');

// Rate-Limit: max. Anfragen pro Zeitfenster
define('RATE_LIMIT_MAX',     5);    // Anfragen
define('RATE_LIMIT_WINDOW',  300);  // Sekunden (5 Minuten)
define('RATE_LIMIT_DIR',     sys_get_temp_dir() . '/matrix_reg_rl');

// --- IP ermitteln (auch hinter Proxies) ---
function getClientIP(): string {
    $headers = ['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'];
    foreach ($headers as $header) {
        if (!empty($_SERVER[$header])) {
            $ip = explode(',', $_SERVER[$header])[0];
            $ip = trim($ip);
            if (filter_var($ip, FILTER_VALIDATE_IP)) {
                return $ip;
            }
        }
    }
    return 'unknown';
}

// --- Rate-Limiting (dateibasiert) ---
function checkRateLimit(string $ip): bool {
    $dir = RATE_LIMIT_DIR;
    if (!is_dir($dir)) {
        mkdir($dir, 0700, true);
    }

    $file = $dir . '/' . hash('sha256', $ip) . '.json';
    $now  = time();
    $data = ['count' => 0, 'window_start' => $now];

    if (file_exists($file)) {
        $data = json_decode(file_get_contents($file), true) ?? $data;
        // Zeitfenster abgelaufen → zurücksetzen
        if ($now - $data['window_start'] > RATE_LIMIT_WINDOW) {
            $data = ['count' => 0, 'window_start' => $now];
        }
    }

    if ($data['count'] >= RATE_LIMIT_MAX) {
        return false;
    }

    $data['count']++;
    file_put_contents($file, json_encode($data), LOCK_EX);
    return true;
}

// --- Honeypot prüfen ---
$input = json_decode(file_get_contents('php://input'), true);

if (!empty($input['website'])) {
    // Bot hat das versteckte Feld ausgefüllt – still ablehnen
    http_response_code(200);
    exit(json_encode(['success' => true]));
}

// --- Rate-Limit prüfen ---
$ip = getClientIP();
if (!checkRateLimit($ip)) {
    http_response_code(429);
    exit(json_encode(['error' => 'Zu viele Anfragen. Bitte warte einige Minuten.']));
}

// --- Eingabe validieren ---
$username = isset($input['username']) ? trim($input['username']) : '';
$email    = isset($input['email'])    ? trim($input['email'])    : '';

if (empty($username) || empty($email)) {
    http_response_code(400);
    exit(json_encode(['error' => 'Benutzername und E-Mail sind erforderlich.']));
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    exit(json_encode(['error' => 'Ungültige E-Mail-Adresse.']));
}

// Eingaben bereinigen
$username = htmlspecialchars($username, ENT_QUOTES, 'UTF-8');
$email    = htmlspecialchars($email,    ENT_QUOTES, 'UTF-8');

// --- Nachricht zusammenstellen ---
$timestamp = date('d.m.Y H:i:s T');
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unbekannt';

$message = "🔐 Registration Request\n\n"
         . "Username: {$username}\n"
         . "E-Mail: {$email}\n"
         . "IP: {$ip}\n"
         . "Zeitstempel: {$timestamp}\n"
         . "User-Agent: {$userAgent}";

$formattedMessage = "🔐 <strong>Registration Request</strong><br><br>"
                  . "<strong>Username:</strong> {$username}<br>"
                  . "<strong>E-Mail:</strong> {$email}<br>"
                  . "<strong>IP:</strong> {$ip}<br>"
                  . "<strong>Zeitstempel:</strong> {$timestamp}<br>"
                  . "<strong>User-Agent:</strong> {$userAgent}";

// --- An Matrix senden ---
$txnId   = 'reg_' . time() . '_' . bin2hex(random_bytes(8));
$url     = MATRIX_HOMESERVER
         . '/_matrix/client/v3/rooms/'
         . urlencode(MATRIX_ROOM_ID)
         . '/send/m.room.message/'
         . $txnId;

$payload = json_encode([
    'msgtype'        => 'm.text',
    'body'           => $message,
    'format'         => 'org.matrix.custom.html',
    'formatted_body' => $formattedMessage,
]);

$ch = curl_init($url);
curl_setopt_array($ch, [
    CURLOPT_CUSTOMREQUEST  => 'PUT',
    CURLOPT_POSTFIELDS     => $payload,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => [
        'Authorization: Bearer ' . MATRIX_ACCESS_TOKEN,
        'Content-Type: application/json',
    ],
    CURLOPT_TIMEOUT => 10,
]);

$response  = curl_exec($ch);
$httpCode  = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

if ($curlError) {
    http_response_code(502);
    exit(json_encode(['error' => 'Verbindung zum Matrix-Server fehlgeschlagen.']));
}

if ($httpCode >= 200 && $httpCode < 300) {
    http_response_code(200);
    exit(json_encode(['success' => true]));
} else {
    $matrixError = json_decode($response, true);
    http_response_code(502);
    exit(json_encode(['error' => 'Matrix-Fehler: ' . ($matrixError['error'] ?? "HTTP {$httpCode}")]));
}
