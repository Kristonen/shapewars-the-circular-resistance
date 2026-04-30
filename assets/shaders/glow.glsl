#version 330

//Inputs
in vec2 fragTexCoord;
in vec4 fragColor;

//RenderTextur
uniform sampler2D texture0;
uniform vec4 colDiffuse;

//Parameter
uniform float intensity;

out vec4 finalColor;

void main(){
    vec2 texelSize = 1.0 / textureSize(texture0, 0);
    vec4 sum = vec4(0.0);

    for(int x = -8; x <= 8; x++){
        for(int y = -8; y <= 8; y++){
            sum += texture(texture0, fragTexCoord + vec2(x, y) * texelSize);
        }
    }
    vec4 blur = (sum/25.0) * intensity;

    vec4 source = texture(texture0, fragTexCoord);
    finalColor = source + blur;
}