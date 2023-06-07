#version 330 core
out vec4 FragColor;

in vec3 Normal;

uniform vec4 color;

void main()
{
    FragColor = vec4(Normal, 1);
} 
