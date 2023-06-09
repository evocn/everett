#version 330 core
out vec4 FragColor;

in vec3 Normal;

uniform vec4 color;
uniform float highlight;

void main()
{
    FragColor = mix(vec4(Normal, 1), vec4(highlight, 1 - highlight, 2 - highlight, 1.0), highlight);
}
