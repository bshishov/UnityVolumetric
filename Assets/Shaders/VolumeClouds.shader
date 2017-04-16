Shader "Volume/Clouds"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Noise("Noise", 2D) = "white" {}
		_Density("DensityToOpacity", float) = 1.0
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend OneMinusDstColor One // Soft Additive
			//Blend DstColor Zero // Multiplicative
			//Blend DstColor SrcColor // 2x Multiplicative
			ZWrite Off

			CGPROGRAM
			#pragma vertex VolumeVert 
			#pragma fragment VolumeFrag			
			

			sampler2D _Noise;
			fixed4 _Color;
			float _Density;

			//==============================================================
			// otaviogood's noise from https://www.shadertoy.com/view/ld2SzK
			//--------------------------------------------------------------
			// This spiral noise works by successively adding and rotating sin waves while increasing frequency.
			// It should work the same on all computers since it's not based on a hash function like some other noises.
			// It can be much faster than other noise functions if you're ok with some repetition.
			const float nudge = 2.;	// size of perpendicular vector
			float normalizer = 1.0 / sqrt(1.0 + 2.*2.);	// pythagorean theorem on that perpendicular to maintain scale
			float SpiralNoiseC(float3 p)
			{
				//float n = -fmod(_Time.z * 0.2, -2.); // noise amount
				float n = _SinTime.z * 2.0 - 1.0;
				float iter = 2.0;
				for (int i = 0; i < 4; i++)
				{
					// add sin and cos scaled inverse with the frequency
					n += -abs(sin(p.y*iter) + cos(p.x*iter)) / iter;	// abs for a ridged look
																		// rotate by adding perpendicular and scaling down
					p.xy += float2(p.y, -p.x) * nudge;
					p.xy *= normalizer;
					// rotate on other axis
					p.xz += float2(p.z, -p.x) * nudge; 
					p.xz *= normalizer;
					// increase the frequency
					iter *= 1.733733;
				}
				return n;
			}

			// iq's noise
			float noise(float3 x)
			{
				float3 p = floor(x);
				float3 f = frac(x);
				f = f*f*(3.0 - 2.0*f);
				float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
				float2 rg = tex2D(_Noise, (uv + 0.5) / 256.0).yx;
				return lerp(rg.x, rg.y, f.z);
			}

			float fbm(float3 p)
			{
				return noise(p*.06125)*.75 + noise(p*.125)*.325 + noise(p*.4)*.2;
			}

			float clouds(float3 p)
			{
				//return p.y + 0.1 + sin(p.x * 20 + _Time.z) * 0.1 + cos(p.z * 20 + _Time.z) * 0.1;
				
				return length(p) - 0.4;
				p = p * 50;
				 
				float final = length(p) - 4.0; // eg. sphere
				//float tnoise = noise(p * 0.5);
				//final += SpiralNoiseC(p.zxy*0.3132*tnoise + 333.)*3.25;

				final += SpiralNoiseC(p*0.35 + 333.)*3.0 + fbm(p*50.)*1.25; 
				return final; 
			}			

			fixed4 colorFromMap(float density)
			{  
				//float opacity = clamp(1 - exp(density * _Density), 0, 1);
				float opacity = clamp(1 - density * _Density, 0, 1);
				return _Color * float4( 1, 1, 1, opacity);
			}

			 
			//#define VOLUME_NO_JITTERING      
			#define VOLUME_RAYMARCH_STEPS 48  
			#define VOLUME_RAYMARCH_FUNCTION IsosurfaceRaymarch
			#define VOLUME_MAP clouds              
			#define VOLUME_LIGHT_FUNCTION specular
			//#define VOLUME_LIGHT_FUNCTION normalDebug
			#define VOLUME_COLOR_FUNCITON colorFromMap 
			#include "../Include/Volume.cginc"

			ENDCG 
		}
	}
}
