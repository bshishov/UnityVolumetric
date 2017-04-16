#ifndef VOLUMETRIC_INCLUDED
#define VOLUMETRIC_INCLUDED

// Unity standard includes
#include "UnityCG.cginc"
#include "Lighting.cginc"

// Raymarch defaults
#ifndef VOLUME_BOUND
#define VOLUME_BOUND 0.5
#endif

#ifndef VOLUME_RAYMARCH_STEPS
#define VOLUME_RAYMARCH_STEPS 32
#endif

#ifndef VOLUME_RAYMARCH_STEP_SIZE
#define VOLUME_RAYMARCH_STEP_SIZE (1.7 * VOLUME_BOUND * 2.0 / VOLUME_RAYMARCH_STEPS)
#endif

#ifndef VOLUME_RAYMARCH_MIN_STEP_SIZE
#define VOLUME_RAYMARCH_MIN_STEP_SIZE 0.02
#endif

#ifndef VOLUME_RAYMARCH_JITTER
#define VOLUME_RAYMARCH_JITTER 0.05
#endif

#ifndef VOLUME_EPSILON
#define VOLUME_EPSILON 0.01
#endif

// Default functions
#ifndef VOLUME_RAYMARCH_FUNCTION
#define VOLUME_RAYMARCH_FUNCTION TranclucentRaymarch
#endif

#ifndef VOLUME_MAP
#define VOLUME_MAP testSphere
#endif

#ifndef VOLUME_NORMAL_ESTIMATOR
#define VOLUME_NORMAL_ESTIMATOR centralDifference
#endif

#ifndef VOLUME_LIGHT_FUNCTION
#define VOLUME_LIGHT_FUNCTION noLight
#endif

#ifndef VOLUME_COLOR_FUNCITON
#define VOLUME_COLOR_FUNCITON oneMinusDistance
#endif

fixed4 specular(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
{
	fixed3 lightDir = normalize(mul(unity_WorldToObject, _WorldSpaceLightPos0.xyz));	// Light direction
	fixed3 lightCol = _LightColor0.rgb;		// Light color

	fixed NdotL = max(dot(normal, lightDir), 0);
	fixed4 c;

	// Specular				
	fixed3 h = (lightDir - viewDirection) / 2.;
	fixed s = pow(max(dot(normal, h), 0), 0.5) * 0.5;
	c.rgb = albedo.rgb * lightCol * NdotL + s;
	c.a = albedo.a;
	return clamp(c, 0, 1);
}

fixed4 normalDebug(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
{
	return fixed4(normal.xyz * 0.5 + 0.5, albedo.a);
}

fixed4 noLight(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
{
	return albedo;
}

fixed4 blend(fixed3 srcColor, fixed srcAlpha, fixed3 dstColor, fixed dstAlpha)
{
	return fixed4(dstAlpha * dstColor + (1 - dstAlpha) * srcColor,
		dstAlpha + (1 - dstAlpha) * srcAlpha);
}

float rand(float2 co) {
	return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float testSphere(float3 position)
{
	return length(position) - 0.5;
}

inline float3 centralDifference(float3 p)
{
	return normalize(float3(
		VOLUME_MAP(p + float3(VOLUME_EPSILON, 0, 0)) - VOLUME_MAP(p - float3(VOLUME_EPSILON, 0, 0)),
		VOLUME_MAP(p + float3(0, VOLUME_EPSILON, 0)) - VOLUME_MAP(p - float3(0, VOLUME_EPSILON, 0)),
		VOLUME_MAP(p + float3(0, 0, VOLUME_EPSILON)) - VOLUME_MAP(p - float3(0, 0, VOLUME_EPSILON))));
}

fixed4 oneMinusDistance(float distance)
{	
	return fixed4(1, 1, 1, clamp(1 - distance, 0, 1));
}

fixed4 TranclucentRaymarch(float3 rayOrigin, float3 rayDirection)
{
	float d;
	float3 position = rayOrigin;
	
	#ifndef VOLUME_NO_JITTERING
	position += rayDirection * rand(rayOrigin.xy) * VOLUME_RAYMARCH_JITTER;
	#endif	
	
	float4 accumulatedColor = 0;

	for (int i = 0; i < VOLUME_RAYMARCH_STEPS; i++)
	{		
		d = VOLUME_MAP(position);
		fixed4 sampleColor = VOLUME_COLOR_FUNCITON(d);
		fixed4 lighted = VOLUME_LIGHT_FUNCTION(position, sampleColor, VOLUME_NORMAL_ESTIMATOR(position), rayDirection);
		lighted = clamp(lighted, 0, 1);

		accumulatedColor = blend(accumulatedColor.rgb, accumulatedColor.a, lighted.rgb, lighted.a);

		if (accumulatedColor.a > 1.0 - VOLUME_EPSILON)
			break;

		position += rayDirection * clamp(d, VOLUME_RAYMARCH_MIN_STEP_SIZE, VOLUME_RAYMARCH_STEP_SIZE);

		if (position.x > VOLUME_BOUND || position.x < -VOLUME_BOUND)
			break;
		if (position.y > VOLUME_BOUND || position.y < -VOLUME_BOUND)
			break;
		if (position.z > VOLUME_BOUND || position.z < -VOLUME_BOUND)
			break;
	}

	return clamp(accumulatedColor, 0, 1);
}

fixed4 IsosurfaceRaymarch(float3 rayOrigin, float3 rayDirection)
{
	float3 position = rayOrigin;		

	#ifndef VOLUME_NO_JITTERING
	position += rayDirection * rand(rayOrigin.xy) * VOLUME_RAYMARCH_JITTER;
	#endif	

	for (int i = 0; i < VOLUME_RAYMARCH_STEPS; i++)
	{		
		float d = VOLUME_MAP(position);
		if (d < VOLUME_EPSILON)
		{
			fixed4 color = VOLUME_COLOR_FUNCITON(d);
			fixed4 lighted = VOLUME_LIGHT_FUNCTION(position, color, VOLUME_NORMAL_ESTIMATOR(position), rayDirection);
			return lighted;
		}			
		position += rayDirection * clamp(d, VOLUME_RAYMARCH_MIN_STEP_SIZE, VOLUME_RAYMARCH_STEP_SIZE);		
		
		if (position.x > VOLUME_BOUND || position.x < -VOLUME_BOUND)
			break;
		if (position.y > VOLUME_BOUND || position.y < -VOLUME_BOUND)
			break;
		if (position.z > VOLUME_BOUND || position.z < -VOLUME_BOUND)
			break;
	}

	return 0;
}

struct VolumeV2F
{
	float4 screenPos: SV_POSITION;	
	float4 localPos : TEXCOORD0;	
};

VolumeV2F VolumeVert(appdata_base v)
{
	VolumeV2F o;
	o.screenPos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.localPos = v.vertex;	
	return o;
}

fixed4 VolumeFrag(VolumeV2F i) : SV_Target
{
	float3 localViewDir = normalize(ObjSpaceViewDir(i.localPos));
	return VOLUME_RAYMARCH_FUNCTION(i.localPos, -localViewDir);
}


#endif // VOLUMETRIC_INCLUDED