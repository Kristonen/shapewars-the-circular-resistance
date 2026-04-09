#version 330

uniform float u_time;
uniform vec4 color;

void main(){
    float test = 50;
    float r = abs(sin(u_time * test));
    float g = abs(sin(u_time * test));
    float b = abs(sin(u_time * test));

    // gl_FragColor = vec4(r,g,b,1.0);
    gl_FragColor = color;
}