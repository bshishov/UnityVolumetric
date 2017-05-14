Shader "Volume/Rotation"
{
	Properties
	{
		_MainTexture("State", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Density("DensityToOpacity", float) = 1.0
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

			Lighting Off
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend OneMinusDstColor One // Soft Additive
			//Blend DstColor Zero // Multiplicative
			//Blend DstColor SrcColor // 2x Multiplicative
			//ZWrite Off
			//Cull Off
			//ZTest Always 
			//AlphaTest Greater 0.5

			CGPROGRAM
			#pragma vertex VolumeVert 
			#pragma fragment VolumeFrag
						
			sampler2D _MainTexture;
			fixed4 _Color;
			float _Density;

			float map(float3 p)
			{				
				p = (p + 0.5);
				half r = distance(p.xz, 0.5);
				half2 uv = half2(r * 2.0, p.y);
				return 1 - tex2D(_MainTexture, uv).r;				
			}

			fixed4 colorFromMap(float density)
			{
				//float opacity = clamp(1 - exp(density * _Density), 0, 1);
				float opacity = clamp(1 - density * _Density, 0, 1);
				return _Color * float4(1, 1, 1, opacity);
			}

			#define VOLUME_RAYMARCH_STEPS 48
			//#define VOLUME_RAYMARCH_MIN_STEP_SIZE 0.005
			//#define VOLUME_RAYMARCH_STEP_SIZE 0.01
			//#define VOLUME_NO_DEPTH 
			//#define VOLUME_NO_JITTERING
			//#define VOLUME_RAYMARCH_FUNCTION IsosurfaceRaymarch  
			#define VOLUME_MAP map                           
			//#define VOLUME_LIGHT_FUNCTION specular 
			//#define VOLUME_LIGHT_FUNCTION normalDebug
			#define VOLUME_COLOR_FUNCITON colorFromMap
			#include "Include/Volume.cginc"

		ENDCG
		}
	}
}