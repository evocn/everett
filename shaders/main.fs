#version 330 core
out vec4 FragColor;

in vec3 Fragment_Position;
in vec3 View_Position;
in vec3 Normal;

uniform vec4 color;
uniform float highlight;

uniform vec3 light_direction;
uniform vec3 light_color;

float Cel(float val_in);

//
//

void main()
{
    vec3 light = -light_direction;
    vec3 eye = normalize(-Fragment_Position);
    vec3 halfway = normalize(light + eye);

    vec4 fragment_color_raw = color;

    float ambient_amount = 0.1f;
    vec3 ambient = vec3(fragment_color_raw) * ambient_amount;
    float diffuse_amount = Cel(clamp(dot(Normal, light), 0.0f, 1.0f));
    vec3 diffuse = vec3(fragment_color_raw) * diffuse_amount;
    float specular_amount = 0.1 * Cel(clamp(dot(Normal, halfway), 0.0f, 1.0f));
    vec3 specular = vec3(fragment_color_raw) * specular_amount;

    FragColor = vec4(0.0f);
    FragColor.a = 1.0;
    FragColor.rgb =
        ambient +
        diffuse +
        specular;

    FragColor = mix(FragColor, vec4(highlight, 1 - highlight, 2 - highlight, 1.0), highlight);
}

//
// Cel Shading
//
float cel_threshold_high = 0.8f;
float cel_threshold_mid  = 0.5f;
float cel_threshold_low = 0.0f;

float Cel(float val_in) {
    if(val_in > cel_threshold_high) return 1.00f;
    if(val_in > cel_threshold_mid)  return 0.66f;
    if(val_in > cel_threshold_low)  return 0.33f;
    return 0.00f;
}
