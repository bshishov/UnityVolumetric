Shader "Custom/VolumeShader"
{
	Properties
	{
		_Volume("Volume", 3D) = "" {}
		_TransferTex("Transfer", 2D) = "white" {}
		_TopTex("Top", 2D) = "white" {}
		_FrontTex("Front", 2D) = "white" {}
		_LeftTex("Left", 2D) = "white" {}		
		_Color("Color", Color) = (1,1,1,1)
		_SpecularPower("Specular Power", float) = 0.2
		_Gloss("Glossines", float) = 0.2
		_Treshold("Treshold", float) = 0.2
		_DistanceToAlpha("Distance To Alpha", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off			


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"		
			#include "Lighting.cginc"		
			#include "../Include/Volume.cginc"

			#define STEPS 32
			#define STEP_SIZE (1.5 / STEPS)
			#define MIN_STEP_SIZE (STEP_SIZE * 0.1)
			#define EPS 0.01
			
			#define LIGHT albedoDebug
			//#define LIGHT normalDebug
			//#define LIGHT lambert			
			//#define LIGHT specular			
			//#define LIGHT unityLight

			//#define RAYMARCH tranclucentRaymarch
			#define RAYMARCH sdfRaymarch

			//#define MAP clouds
			#define MAP sphere
			//#define MAP movingSphere
			//#define MAP from3dTex
			//#define MAP fromTexMul
			

			float _SpecularPower;
			float _Gloss;
			float _Treshold;
			float _DistanceToAlpha;
			sampler2D _TransferTex;
			sampler2D _TopTex;
			sampler2D _FrontTex;
			sampler2D _LeftTex;		
			
			sampler3D _Volume;
			float4 _MainTex_ST;
			half4 _Color;





			fixed4 lambert(float4 v, fixed4 albedo, half3 normal, half3 viewDirection)
			{
				//fixed3 lightDir = normalize(mul(unity_WorldToObject, _WorldSpaceLightPos0.xyz));	// Light directionfixed3 lightDir = _WorldSpaceLightPos0.xyz;	// Light direction
				float3 lightDir = ObjSpaceLightDir(v);
				fixed3 lightCol = _LightColor0.rgb;		// Light color

				fixed NdotL = max(dot(normal, lightDir), 0);
				fixed4 c;
				c.rgb = albedo * lightCol * NdotL;
				c.a = albedo.a;
				return c;
			}

			/* 
			fixed4 normalDebug(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
			{
				return fixed4(normal.xyz * 0.5 + 0.5, albedo.a);				
			}
			*/
			fixed4 albedoDebug(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
			{
				return albedo;
			}

			fixed4 unityLight(half3 v, fixed4 albedo, half3 normal, half3 viewDirection)
			{
				UnityLight light;
				light.color = _LightColor0.rgb;
				light.dir = normalize(mul(unity_WorldToObject, _WorldSpaceLightPos0.xyz));
				light.ndotl = max(dot(normal, light.dir), 0);

				SurfaceOutput s;
				s.Albedo = albedo.rgb;
				s.Normal = normal;
				s.Alpha = albedo.a;
				s.Emission = 0.2;				
				s.Specular = _SpecularPower;
				s.Gloss = _Gloss;

				return UnityLambertLight(s, light);
			}

			float sphere(float3 p)
			{
				return length(p) - 0.4;
			}

			float movingSphere(float3 p)
			{
				return length(p + _SinTime.xyz * 0.2) - 0.4;
			}

			
			
			float from3dTex(float3 p)
			{		
				fixed3 pt = clamp(p + 0.5, 0, 1);
				fixed4 color = tex3D(_Volume, pt);
				return _Treshold - color.a;
			}

			float fromTexMul(float3 p)
			{
				fixed3 pt = clamp(p + 0.5, 0, 1);
				fixed top = tex2D(_TopTex, fixed2(pt.x, 1 - pt.z)).r;
				fixed front = tex2D(_FrontTex, fixed2(pt.x, pt.y)).r;
				fixed left = tex2D(_LeftTex, fixed2(1 - pt.z, pt.y)).r;
				return _Treshold - top * front * left;				
			}
			 
			fixed4 volume(half3 p)
			{
				fixed alpha = clamp(sign(0.4 - length(p)), 0, 1);
				return _Color * fixed4(1, 1, 1, alpha);
			}

			half3 volumeGradient(half3 p)
			{
				fixed dx1 = volume(p + half3(EPS, 0, 0)).a;
				fixed dx2 = volume(p - half3(EPS, 0, 0)).a;
				fixed dy1 = volume(p + half3(0, EPS, 0)).a;
				fixed dy2 = volume(p - half3(0, EPS, 0)).a;
				fixed dz1 = volume(p + half3(0, 0, EPS)).a;
				fixed dz2 = volume(p - half3(0, 0, EPS)).a;

				return float3(dx1 - dx2, dy1 - dy2, dz1 - dz2);
			}

			/*
			half3 sdfNormal(half3 p) 
			{
				fixed dx1 = MAP(p + half3(EPS, 0, 0));
				fixed dx2 = MAP(p - half3(EPS, 0, 0));
				fixed dy1 = MAP(p + half3(0, EPS, 0));
				fixed dy2 = MAP(p - half3(0, EPS, 0));
				fixed dz1 = MAP(p + half3(0, 0, EPS));
				fixed dz2 = MAP(p - half3(0, 0, EPS));

				return normalize(half3(dx1 - dx2, dy1 - dy2, dz1 - dz2));
			}*/

			/*
			fixed4 colorFromSdf(half distance)
			{
				//fixed alpha = clamp(1 - distance * _DistanceToAlpha, 0, 1);
				//fixed alpha = clamp(sign(1 - distance), 0, 1);
				fixed alpha = clamp(1 - exp(-distance * _DistanceToAlpha) , 0, 1);
				return _Color * fixed4(1, 1, 1, alpha);
			}*/ 

			fixed4 renderVolume(float3 p, half3 viewDirection)
			{				
				half3 normal = VOLUME_NORMAL_ESTIMATOR(p);
				fixed4 albedo = _Color;				
				return LIGHT(p, albedo, normal, viewDirection);				
			}

			/*
			fixed4 blend(fixed3 srcColor, fixed srcAlpha, fixed3 dstColor, fixed dstAlpha)
			{				
				return fixed4(dstAlpha * dstColor + (1 - dstAlpha) * srcColor, 
					dstAlpha + (1 - dstAlpha) * srcAlpha);
			}
			*/
			fixed4 sdfRaymarch(float3 position, float3 rayDirection)
			{
				float3 t = position;
				
				for (int i = 0; i < STEPS; i++)
				{
					half d = min(MIN_STEP_SIZE, MAP(t));
					if (d < EPS) 
						return renderVolume(t, rayDirection); 

					t += d * rayDirection;
					
					if (t.x > 0.49 || t.x < -0.49)
						break;
					if (t.y > 0.49 || t.y < -0.49)
						break;
					if (t.z > 0.49 || t.z < -0.49)
						break;
				}
				return 0;			 	
			} 
			/*
			fixed4 tranclucentRaymarch(float3 position, float3 direction)
			{
				fixed4 accumulatedColor = 0;				

				for (int i = 0; i < STEPS; i++)
				{
					float d = MAP(position);					
					fixed4 sampleColor = colorFromSdf(d);
					fixed4 lighted = LIGHT(position, sampleColor, sdfNormal(position), direction);
					//lighted = clamp(lighted, 0, 1);

					accumulatedColor = blend(accumulatedColor.rgb, accumulatedColor.a, lighted.rgb, lighted.a);
					
					if (accumulatedColor.a > 1 - EPS || d < EPS)
						break;					
				
					//position += direction * min(d, STEP_SIZE);
					position += direction * clamp(d, MIN_STEP_SIZE, STEP_SIZE);
					//return fixed4(d, d, d, 1);

					//position += direction * STEP_SIZE;
					
					if (position.x > 0.5 || position.x < -0.5)
						break;
					if (position.y > 0.5 || position.y < -0.5)
						break;
					if (position.z > 0.5 || position.z < -0.5)
						break;					
				}

				return clamp(accumulatedColor, 0, 1);
			}									
			*/
			struct v2f
			{				
				float4 screenPos: SV_POSITION;
				float3 uv : TEXCOORD0;
				float4 localPos : TEXCOORD1;
				float3 normal: TEXCOORD2;				

				//float3 worldPos : TEXCOORD0;								
				//float3 localViewDir : TEXCOORD2;	// local camera view direction
				float3 worldPos : TEXCOORD3;	
			};
			 
			
			v2f vert (appdata_base v)
			{
				v2f o;

				// MVP * vertex
				//o.screenPos = ComputeScreenPos(v.vertex);
				//o.screenPos = UnityObjectToClipPos(v.vertex);
				o.screenPos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.localPos = v.vertex;
				o.normal = v.normal;
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				//fixed3 viewDir = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
				//o.localViewDir = -normalize(ObjSpaceViewDir(v.vertex));
				//o.localViewDir = viewDir;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return tex3D(_Volume, i.uv);

				// Manual ZTEST
				//float2 uv2 = (i.screenPos.xy / i.screenPos.w);

				// get the raw Depth relative to the camera
				//float rawDepth = DecodeFloatRG(tex2D(_LastCameraDepthTexture, fixed2(0.5, 0.5)));
				// normalize this between 0 .. 1 where 0 is at the near clipping plane and 1 at the far clipping plane
				//float z = Linear01Depth(rawDepth);
				//return fixed4(z,z,z,1);

				float3 localViewDir = normalize(ObjSpaceViewDir(i.localPos));	
				//float3 localViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				//localViewDir *= sign(dot(-i.normal, localViewDir));
				//float3 localViewDir = (i.localViewDir);
				//float3 localViewDir = -ObjSpaceViewDir(i.localPos);
				//float3 localViewDir = i.viewDir;
				
				//return half4(i.localPos.xyz + 0.5, 1);
				//return half4(localViewDir * 0.5 + 0.5, 1);
				//return half4(normalize(i.normal) * 0.5 + 0.5, 1);
				return RAYMARCH(i.localPos, -localViewDir);
				//return RAYMARCH(i.worldPos, -localViewDir);

				//return RAYMARCH(i.localPos, i.normal * sign(-i.normal * i.localPos));
			}
			ENDCG
		}
	}
}
