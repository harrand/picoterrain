#version 460
#extension GL_EXT_buffer_reference : require
#extension GL_EXT_scalar_block_layout : require
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable
#extension GL_ARB_shader_draw_parameters : require
#pragma shader_stage(vertex)

void main()
{
	gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
}
