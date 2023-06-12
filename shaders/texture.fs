#version 330 core
out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D texture;

void main()
{
    FragColor = texture(texture, texture_coordinates);
} 
