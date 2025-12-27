#version 460
#extension GL_EXT_nonuniform_qualifier : require
#pragma shader_stage fragment

layout(location = 0) out vec4 fcol;

void main()
{
	fcol = vec4(1.0);
}
