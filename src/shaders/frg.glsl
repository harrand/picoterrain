#version 460
#extension GL_EXT_nonuniform_qualifier : require
#pragma shader_stage fragment
#include "terrain.glsl"

layout(location = 0) in float height;
layout(location = 1) flat in terrain_data terrain;
layout(location = 0) out vec4 fcol;

void main()
{
	vec3 col = terrain.base_colour;
	if(height <= (terrain.sea_level + terrain.sea_banding))
	{
		// if height == level + banding
		// then interp is 0
		// if height == level
		// then interp is 1
		float interp = clamp((terrain.sea_level + terrain.sea_banding - height) / terrain.sea_banding, 0.0, 1.0);
		col = mix(col, terrain.sea_colour, interp);
	}
	else if(height >= (terrain.sky_level - terrain.sky_banding))
	{
		float interp = clamp((height - (terrain.sky_level - terrain.sky_banding)) / terrain.sky_banding, 0.0, 1.0);
		col = mix(col, terrain.sky_colour, interp);
	}
	// very slightly brighten the colour by the height
	col += vec3(height * 0.004);
	fcol = vec4(col, 1.0);
}
