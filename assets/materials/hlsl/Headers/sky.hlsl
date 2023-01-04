
float3 rotateY(float3 normal, float angle)
{
	float sin_a, cos_a;
	sincos(angle, sin_a, cos_a);
	float x = normal.x * cos_a - normal.z * sin_a;
	float z = normal.x * sin_a + normal.z * cos_a;
	return float3(x, normal.y, z);
}

float3 rotateZ(float3 normal, float angle)
{
	float sin_a, cos_a;
	sincos(angle, sin_a, cos_a);
	float x = normal.x * cos_a - normal.y * sin_a;
	float y = normal.x * sin_a + normal.y * cos_a;
	return float3(x, y, normal.z);
}

/**
 * @param https://en.wikipedia.org/wiki/Cube_mapping
 * @param direction Non-normalized vector
 * @param index     Face index, +X, -X, +Y, -Y, +Z, -Z
 * @param texcoord  Texture coordinates
 */
void convertDirectionToCubeTexcoord(in float3 direction, out int index, out float2 texcoord)
{
	float3 _abs = abs(direction);
	bool3 positive = direction > float3(0, 0, 0);
  
	float maxAxis;
	if(_abs.x >= _abs.y && _abs.x >= _abs.z)
	{
		maxAxis = _abs.x;
		if(positive.x)  // POSITIVE X
		{
			// u (0 to 1) goes from +z to -z
			// v (0 to 1) goes from -y to +y
			texcoord = float2(-direction.z, +direction.y);
			index = 0;
		}
		else  // NEGATIVE X
		{
			// u (0 to 1) goes from -z to +z
			// v (0 to 1) goes from -y to +y
			texcoord = float2(+direction.z, +direction.y);
			index = 1;
		}
	}
	else if(_abs.y >= _abs.x && _abs.y >= _abs.z)
	{
		maxAxis = _abs.y;
		if(positive.y)   // POSITIVE Y
		{
			// u (0 to 1) goes from -x to +x
			// v (0 to 1) goes from +z to -z
			texcoord = float2(+direction.x, -direction.z);
			index = 2;
		}
		else
		{
			// u (0 to 1) goes from -x to +x
			// v (0 to 1) goes from -z to +z
			texcoord = float2(+direction.x, +direction.z);
			index = 3;
		}
	}
	else  // if(_abs.z >= _abs.x && _abs.z >= _abs.y)
	{
		maxAxis = _abs.z;
		if(positive.z)  // POSITIVE Z
		{
			// u (0 to 1) goes from -x to +x
			// v (0 to 1) goes from -y to +y
			texcoord = float2(direction.x, direction.y);
			index = 4;
		}
		else  // NEGATIVE Z
		{
			// u (0 to 1) goes from +x to -x
			// v (0 to 1) goes from -y to +y
			texcoord = float2(-direction.x, direction.y);
			index = 5;
		}
	}

	texcoord /= maxAxis;
	// Convert range from [-1, 1] to [0, 1]
	texcoord = 0.5 * (texcoord + 1.0);
}

/*
	       +------+
	       |  +Y  |
	       | top  |
	+------+------+------+------+
	|  -X  |  +Z  |  +X  |  -Z  |
	| left |front |right | back |
	+------+------+------+------+
	       |  -Y  |
	       |bottom|
	       +------+
*/
float2 calculatePackedTexcoord(int index, float2 texcoord)
{
	const float2 offsets[6] =
	{
		float2(2.0, 2.0),  // +X
		float2(0.0, 2.0),  // -X
		float2(1.0, 1.0),  // +Y
		float2(1.0, 3.0),  // -Y
		float2(1.0, 2.0),  // +Z
		float2(3.0, 2.0),  // -Z
/*
		float2(2.0, 1.0),  // +X
		float2(0.0, 1.0),  // -X
		float2(1.0, 0.0),  // +Y
		float2(1.0, 2.0),  // -Y
		float2(1.0, 1.0),  // +Z
		float2(3.0, 1.0),  // -Z
*/
	};
	texcoord.y = -texcoord.y;
	return (offsets[index] + texcoord) / float2(4.0, 3.0);
}
