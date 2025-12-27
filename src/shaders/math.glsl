mat4 quat2mat(vec4 q)
{
    q = normalize(q);
    float xx = q.x * q.x;
    float yy = q.y * q.y;
    float zz = q.z * q.z;
    float xy = q.x * q.y;
    float xz = q.x * q.z;
    float yz = q.y * q.z;
    float wx = q.w * q.x;
    float wy = q.w * q.y;
    float wz = q.w * q.z;

    return mat4(
        vec4(1.0 - 2.0*(yy + zz),  2.0*(xy + wz),      2.0*(xz - wy),      0.0),
        vec4(2.0*(xy - wz),        1.0 - 2.0*(xx + zz),2.0*(yz + wx),      0.0),
        vec4(2.0*(xz + wy),        2.0*(yz - wx),      1.0 - 2.0*(xx + yy),0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

vec4 quat_mul(vec4 lhs, vec4 rhs)
{
	// updated from psy
	return vec4(
		( rhs.w *  lhs.x) + ( rhs.z *  lhs.y) + ( rhs.y * -lhs.z) + ( rhs.x *  lhs.w),
		( rhs.z * -lhs.x) + ( rhs.w *  lhs.y) + ( rhs.x *  lhs.z) + ( rhs.y *  lhs.w),
		( rhs.y *  lhs.x) + ( rhs.x * -lhs.y) + ( rhs.w *  lhs.z) + ( rhs.z *  lhs.w),
		( rhs.x * -lhs.x) + ( rhs.y * -lhs.y) + ( rhs.z * -lhs.z) + ( rhs.w *  lhs.w)
	);
}

vec3 quat_rotate(vec4 q, vec3 pos)
{
	// updated from psy
	vec3 xyz = q.xyz;
	vec3 t = cross(xyz, pos) * 2.0;
	return pos + ((t * q.w) + cross(xyz, t));
}

vec4 quat_inverse(vec4 q)
{
	// updated from psy
	float dotself = dot(q, q);
	return vec4(
		-q.x / dotself,
		-q.y / dotself,
		-q.z / dotself,
		q.w / dotself
	);
}

vec4 axis2quat(vec3 axis, float angle)
{
	float sinhalf = sin(angle / 2.0);
	float coshalf = cos(angle / 2.0);
	return normalize(vec4(axis.x * sinhalf, axis.y * sinhalf, axis.z * sinhalf, coshalf));
}

vec4 euler2quat(vec3 euler)
{
	vec4 qx = axis2quat(vec3(1.0, 0.0, 0.0), euler.x);
	vec4 qy = axis2quat(vec3(0.0, 1.0, 0.0), euler.y);
	vec4 qz = axis2quat(vec3(0.0, 0.0, 1.0), euler.z);

	return normalize(quat_mul(quat_mul(qz, qy), qx));
}

struct trs
{
	vec3 t;
	vec4 r;
	vec3 s;
};

trs trs_empty()
{
	trs ret;
	ret.t = vec3(0.0, 0.0, 0.0);
	ret.r = vec4(0.0, 0.0, 0.0, 1.0);
	ret.s = vec3(1.0, 1.0, 1.0);
	return ret;
}

trs trs_combine(trs lhs, trs rhs)
{
	trs ret;
	ret.t = lhs.t + quat_rotate(lhs.r, rhs.t);
	//ret.t = lhs.t + rhs.t;
	ret.r = normalize(quat_mul(lhs.r, rhs.r));
	ret.s = (lhs.s * rhs.s);
	return ret;
}

mat4 trs2mat(trs transform)
{
	mat4 tr = mat4(1.0);
	tr[3] = vec4(transform.t, 1.0);

	mat4 ro = quat2mat(transform.r);

	mat4 sc = mat4(1.0);
	sc[0][0] = transform.s.x;
	sc[1][1] = transform.s.y;
	sc[2][2] = transform.s.z;

	return tr * ro * sc;
}

mat4 perspective(float fov, float aspect_ratio)
{
	const float near = 0.1f;
	float f = 1.0 / tan(fov * 0.5);
	return mat4(
        f / aspect_ratio, 0.0,  0.0,    0.0,
        0.0,              f,    0.0,    0.0,
        0.0,              0.0,  -1.0,   -1.0,
        0.0,              0.0,  -near,   0.0
    );
}

vec3 u64_unpack(uint64_t rgb)
{
	uint r = uint(rgb & 0xFFFFul);
	uint g = uint((rgb >> 16ul) & 0xFFFFul);
	uint b = uint((rgb >> 32ul) & 0xFFFFul);
	return vec3(r, g, b) / 65535.0;
}
