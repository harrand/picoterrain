#version 460
#extension GL_EXT_buffer_reference : require
#extension GL_EXT_scalar_block_layout : require
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable
#extension GL_ARB_shader_draw_parameters : require
#pragma shader_stage(vertex)
#include "math.glsl"
#include "simplex.glsl"
#include "terrain.glsl"

#define plane_subdivide_x 128
#define plane_subdivide_y 128

const vec2 positions[6] = vec2[6](
	vec2(0.0, 0.0),
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(1.0, 0.0),
	vec2(1.0, 1.0),
	vec2(0.0, 1.0)
);

struct camera_data
{
	vec3 t;
	vec4 r;
};

layout(scalar, buffer_reference, buffer_reference_align = 8) readonly buffer terrain_t
{
	terrain_data data;
};

layout(scalar, buffer_reference, buffer_reference_align = 8) readonly buffer camera_t
{
	camera_data data;
};

layout(scalar, set = 0, binding = 0) readonly buffer MetaBuffer{
	terrain_t terrain;
	camera_t camera;
};

layout(location = 0) out float height;
layout(location = 1) out terrain_data out_terrain;

mat4 view_matrix()
{
	return inverse(trs2mat(trs(camera.data.t, camera.data.r, vec3(1.0))));
}

vec2 uv_apply_seed(vec2 uv)
{
	float s = terrain.data.seed;
	return uv + vec2(uint(s * 0.3948759) % 69420, s * 1.9048375);
}

void main()
{
	// we have a number of vertices that we assume is equal to 6 * plane_subdivide_x * plane_subdivide_y
	// we plot the positions of each vertex manually here instead of having vertex data
	// this is meant to be a subdivided plane

	// 6 verts per quad
	uint quad_id = gl_VertexIndex / 6;
	uint vtx_id = gl_VertexIndex % 6;
	
	uint x = quad_id % plane_subdivide_x;
	uint z = quad_id / plane_subdivide_y;

	// magic numbers go brrrr
	// increases actual size of terrain (width + breadth)
	const float scale = 8;
	// increases simplex sampler (the higher we go the more zoomed out the noise texture we go)

	vec2 localxz = positions[vtx_id];
	vec2 xz = (vec2(x, z) + localxz) * scale;
	// problem is the corner starts at [0, 0]
	// i want it centered around 0, 0
	xz -= vec2(scale * plane_subdivide_x * 0.5, scale * plane_subdivide_y * 0.5);

	// generate a uv
	vec2 uv = xz / vec2(plane_subdivide_x * scale, plane_subdivide_y * scale);

	const float y = max(simplex(uv_apply_seed(uv * terrain.data.roughness)) * terrain.data.y_scale, terrain.data.sea_level);
	height = y;
	
	// todo: xd remove le epic hardcoded aspect ratio
	gl_Position = perspective(1.5701, 1920.0 / 1080.0) * view_matrix() * vec4(xz.x, y, xz.y, 1.0);
	out_terrain = terrain.data;
}
