#version 330

//Inputs
in vec2 fragTexCoord;
in vec4 fragColor;

//RenderTextur
uniform sampler2D texture0;
uniform vec4 colDiffuse;

//Parameter
uniform float intensity;
// uniform int raster;

out vec4 finalColor;

void main(){
    vec2 texelSize = 1.0 / textureSize(texture0, 0);
    vec4 sum = vec4(0.0);
    int raster = 5;
    int median = raster * 4 + 2;

    for(int x = -raster; x <= raster; x++){
        for(int y = -raster; y <= raster; y++){
            // sum += texture(texture0, fragTexCoord + vec2(x, y) * texelSize);
            vec4 sample = texture(texture0, fragTexCoord + vec2(x, y) * texelSize);
            sample.rgb *= sample.a;
            sum += sample;
        }
    }
    // finalColor = (sum/median) * intensity;
    vec4 blur = (sum/median);

    vec4 source = texture(texture0, fragTexCoord);
    float final_intensity = intensity * (1.0 * source.a);
    finalColor = (source + blur) * final_intensity;
}