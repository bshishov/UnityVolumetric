Shader "Volume/Sphere"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)		
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha			
			ZWrite Off

			CGPROGRAM
			#pragma vertex VolumeVert 
			#pragma fragment VolumeFrag			
			
			fixed4 _Color;			

			float sphere(float3 p)
			{	
				return length(p) - 0.4;				
			}			

			fixed4 colorFromMap(float density)   
			{  				
				return _Color;
			}
			 
			#define VOLUME_NO_JITTERING      
			#define VOLUME_RAYMARCH_STEPS 16     
			#define VOLUME_RAYMARCH_FUNCTION IsosurfaceRaymarch    
			#define VOLUME_MAP sphere                    
			#define VOLUME_RAYMARCH_MIN_STEP_SIZE 0.001
			#define VOLUME_LIGHT_FUNCTION specular   
			//#define VOLUME_LIGHT_FUNCTION normalDebug
			#define VOLUME_COLOR_FUNCITON colorFromMap  
			#include "Include/Volume.cginc"

			ENDCG 
		}
	}
}
