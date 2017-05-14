Shader "Volume/Darkness"
{
	Properties
	{
		_StateTexture("State", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Noise("Noise", 2D) = "white" {}
		_Density("DensityToOpacity", float) = 1.0  
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		//Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"  }
		LOD 100

		/*
		Pass{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" "RenderType" = "Opaque" "Queue" = "Geometry" }

			Fog{ Mode Off } 
			ZWrite On  
			//ZTest Less			
			//Cull Off
			Offset 1, 1
			 
			CGPROGRAM   

			#pragma vertex VolumeVert
			#pragma fragment VolumeFrag
			//#pragma multi_compile_shadowcaster 
			//#pragma fragmentoption ARB_precision_hint_fastest
			 
			#include "UnityCG.cginc"                    
			      
			sampler2D _Noise;    
			sampler2D _StateTexture;    
			fixed4 _Color;
			float _Density;                      
			      
			float darkness(float3 p)                
			{        
				fixed state = tex2D(_StateTexture, p.xy + 0.5).r;
				float2 offset = p.xy - _Time.xy * 0.2;
				float noise = tex2D(_Noise, offset).r + 0.01;
				float d = 1 - abs(p.z * 2);
				return 1 - state * 10 * noise * d * noise;
			}  
			    
			fixed4 colorFromMap(float density)               
			{    
				float opacity = clamp(1 - exp(density * _Density), 0, 1);				
				return half4(1, 1, 1, opacity);   
			}

			#define VOLUME_RAYMARCH_STEPS 8  
			//#define VOLUME_NO_DEPTH
			//#define VOLUME_NO_JITTERING     
			//#define VOLUME_RAYMARCH_FUNCTION IsosurfaceRaymarch  
			#define VOLUME_MAP darkness       
			//#define VOLUME_LIGHT_FUNCTION specular 
			//#define VOLUME_LIGHT_FUNCTION normalDebug
			#define VOLUME_COLOR_FUNCITON colorFromMap  
			#include "../Include/Volume.cginc" 

			ENDCG			
		} 
		*/
			 
		Pass  
		{ 
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
			  
			Lighting Off
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend OneMinusDstColor One // Soft Additive
			//Blend DstColor Zero // Multiplicative
			//Blend DstColor SrcColor // 2x Multiplicative
			//ZWrite Off
			//Cull Off
			//ZTest Always 
			//AlphaTest Greater 0.5
			 
			CGPROGRAM  
			#pragma vertex VolumeVert 
			#pragma fragment VolumeFrag			
			 

			sampler2D _Noise;
			sampler2D _StateTexture;  
			fixed4 _Color;
			float _Density;

	
			float darkness(float3 p) 
			{
				fixed state = tex2D(_StateTexture, p.xy + 0.5).r;
				float2 offset = p.xy - _Time.xy * 0.2;
				float noise = tex2D(_Noise, offset).r + 0.01;
				float d = 1 - abs(p.z * 2); 				
				return 1 - state * 10 * noise * d * noise;
			}

			fixed4 colorFromMap(float density)  
			{ 
				float opacity = clamp(1 - exp(density * _Density), 0, 1);				
				//float opacity = clamp(1 - density * _Density, 0, 1);
				return _Color * float4(1, 1, 1, opacity);   
			}
			   
			#define VOLUME_RAYMARCH_STEPS 24
			//#define VOLUME_RAYMARCH_MIN_STEP_SIZE 0.005
			//#define VOLUME_RAYMARCH_STEP_SIZE 0.05
			//#define VOLUME_NO_DEPTH 
			//#define VOLUME_NO_JITTERING      
			//#define VOLUME_RAYMARCH_FUNCTION IsosurfaceRaymarch  
			#define VOLUME_MAP darkness                           
			//#define VOLUME_LIGHT_FUNCTION specular 
			//#define VOLUME_LIGHT_FUNCTION normalDebug
			#define VOLUME_COLOR_FUNCITON colorFromMap
			#include "Include/Volume.cginc"

			ENDCG  
		}
	}
}