#version 330

// Eingaben von Raylib
in vec4 fragColor;
out vec4 finalColor;

// Variablen aus Odin
uniform vec2 centerPos;  // Die Position der Pfütze (a.pos)
uniform float radius;    // Der Radius der Pfütze (a.radius)
uniform float time;      // Die Spielzeit (rl.GetTime())

// Eine kleine Hilfsfunktion für Pseudozufall
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    // 1. Wir holen uns die echte Pixel-Position auf dem Bildschirm
    vec2 pixelPos = gl_FragCoord.xy;
    
    // Da gl_FragCoord von unten links zählt, Raylib aber von oben links,
    // messen wir einfach den Abstand zum Zentrum der Pfütze
    float dist = distance(pixelPos, centerPos);
    
    // Wenn wir außerhalb des Kreises sind, zeichnen wir nichts extra (Standardfarbe)
    vec4 color = fragColor;
    
    // 2. Das Bläschen-Raster (Wir teilen die Pfütze in kleine Zellen auf)
    // Multipliziere pixelPos, um die Zellen kleiner oder größer zu machen
    vec2 gridUV = pixelPos * 0.1; 
    vec2 id = floor(gridUV);    // Jede Zelle bekommt eine eigene ID
    vec2 localUV = fract(gridUV) - vec2(0.5); // Koordinaten innerhalb der Zelle (-0.5 bis 0.5)
    
    // 3. Jede Zelle blubbert zeitversetzt dank der ID
    float bubbleTime = time * 1.5 + rand(id) * 20.0;
    float progress = fract(bubbleTime); // Läuft immer von 0.0 bis 1.0 (Entstehen bis Platzen)
    
    // Zufälliger Versatz für das Bläschen innerhalb seiner Zelle
    vec2 bubbleOffset = vec2(rand(id), rand(id + 1.0)) * 0.3 - vec2(0.15);
    // Das Bläschen wandert während seiner Lebenszeit leicht nach oben (Y-Achse)
    bubbleOffset.y += progress * 0.2;
    
    // Abstand des Pixels zum Mittelpunkt des Bläschens in dieser Zelle
    float distToBubble = distance(localUV, bubbleOffset);
    
    // Die maximale Größe, die das Bläschen erreicht, bevor es platzt
    float bubbleSize = 0.08 * sin(progress * 3.1415); // Wird groß und schrumpft vorm Platzen wieder
    
    // 4. Bläschen zeichnen (Wenn wir nah genug am Bläschen-Zentrum sind)
    if (distToBubble < bubbleSize) {
        // Wenn wir ganz nah am Rand des Bläschens sind -> Hellerer grüner Rand (Lichtreflexion)
        if (distToBubble > bubbleSize * 0.7) {
            color.rgb += vec3(0.4, 0.5, 0.2); // Ein giftig-heller Glanzring
        } else {
            color.rgb -= vec3(0.2, 0.1, 0.2); // Das Innere der Blase ist etwas dunkler
        }
    }
    
    finalColor = color;
}