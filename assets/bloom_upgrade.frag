#version 330 // Specifies the OpenGL version

// Input from Raylib (the default Vertex Shader)
in vec2 fragTexCoord; // The UV coordinate of the current pixel (0.0 to 1.0)
in vec4 fragColor;    // The color passed from DrawRectangle or DrawTexture

// The texture being drawn (automatically passed by Raylib)
uniform sampler2D texture0;

// The final output color of this pixel
out vec4 finalColor;

void main() {
    // 1. Look up the color of the current pixel from the texture
    vec4 texelColor = texture(texture0, fragTexCoord);

    // 2. Modify that color (e.g., multiply by the tint color)
    vec4 result = texelColor * fragColor;

    // 3. Output the result
    finalColor = result;
}