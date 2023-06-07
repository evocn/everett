#version 330 core
layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;
layout (location = 2) in vec3 BoneWeights;
layout (location = 3) in ivec4 BoneIDs;
//layout (location = 2) in vec2 TextureCoordinates;

const int MAX_JOINTS  = 1000;
const int MAX_WEIGHTS = 4;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

/*
// A simple uniform variable cannot hold a lot of data,
// so we use a uniform block to store the skinning information.
// A uniform block can hold more data, and we check if the
// OpenGL implementation allows us to store enough at the
// start of the program.
layout (std140) uniform Big_Data
{
	mat4 u_Skinning_Matrices[MAX_JOINTS];
};
*/

out vec3 Normal;

void main()
{
    Normal = VertexNormal;
    gl_Position = projection * view * model * vec4(VertexPosition, 1.0);
}

//
//

/*
void main ()
{
	vec3 model_position = vec3 (0);
	vec3 model_normal = vec3 (0);
	if (a_Joint_Ids[0] == -1)
	{
		model_position = a_Position;
		model_normal   = a_Normal;
	}
	for (int i = 0; i < MAX_WEIGHTS && a_Joint_Ids[i] != -1; i += 1)
	{
		int joint_id = a_Joint_Ids[i];
		float weight;
		if (i == MAX_WEIGHTS - 1)
			weight = 1 - (a_Weights.x + a_Weights.y + a_Weights.z);
		else
			weight = a_Weights[i];
		mat4 skinning_matrix = u_Skinning_Matrices[joint_id];
		vec3 pose_position = (skinning_matrix * vec4 (a_Position, 1)).xyz;
		model_position += pose_position * weight;
		vec3 pose_normal = (skinning_matrix * vec4 (a_Normal, 0)).xyz;
		model_normal += pose_normal * weight;
	}
	gl_Position = u_View_Projection_Matrix * u_Model_Matrix * vec4 (model_position, 1);
	Normal = model_normal.xyz;
}
*/
