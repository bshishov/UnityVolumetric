Shader "Hidden/Depth"
{
	Properties
	{		
		_From("From", float) = 0.0
		_To("To", float) = 1.0
	}
	SubShader
	{		
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}
			
			float _From;
			float _To;
			sampler2D _CameraDepthTexture;

			fixed4 frag (v2f i) : SV_Target
			{
				float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv).r);
				//float depth = tex2D(_CameraDepthTexture, i.uv).r;  
				float k = (depth - _From) / (_To - _From);
				return k;
			}
			ENDCG
		}
	}
}
