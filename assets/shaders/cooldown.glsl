#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 finalColor;

uniform sampler2D texture0;
uniform float cooldownProgress;

const float PI = 3.14159265359;

void main(){
    vec4 texColor = texture(texture0, fragTexCoord);
    vec2 uv = fragTexCoord - vec2(0.5);

    float angle = atan(uv.x, -uv.y);
    float normalizedAngle = (angle + PI) / (2.0*PI);

    if(normalizedAngle < cooldownProgress){
        finalColor = vec4(texColor.rgb * 0.3, texColor.a * 0.7);
    } else{
        finalColor = texColor;
    }
}