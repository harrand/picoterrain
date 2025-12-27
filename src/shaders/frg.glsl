#version 460
#extension GL_EXT_nonuniform_qualifier : require
#pragma shader_stage fragment

layout(location = 0) in float height;
layout(location = 0) out vec4 fcol;

void main()
{
	fcol = vec4(mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.2), height), 1.0);
}
