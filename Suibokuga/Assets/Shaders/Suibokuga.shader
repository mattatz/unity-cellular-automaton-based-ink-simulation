Shader "Suibokuga/Suibokuga" {

	Properties {
		_MainTex ("Water Texture", 2D) = "white" {}
		_Alpha ("Transfer/Diffusion coefficient for water particles", Range(0.01, 1.5)) = 1.0
		_Evaporation ("a unit quantity of water for evaporation", Range(0.0001, 0.005)) = 0.00015
		
		_PaperTex ("Paper Texture", 2D) = "white" {}
		
		_Brush ("brush", Vector) = (-1, -1, -1, -1)
		_Prev ("previous brush position", Vector) = (-1, -1, -1, -1)
	}
	
	CGINCLUDE
		
	#include "UnityCG.cginc"
	#pragma target 3.0
	
	/*
	 * r : water particles
	 * b : capacities of water 
	 * a : the heights of the bottoms
	 */
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	
	float _Alpha;
	float _Evaporation;
	
	sampler2D _PaperTex;
	
	float2 _Prev;
	float3 _Brush; // x,y : position, z : size
		
	struct appdata {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
		
	struct v2f {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
		
	v2f vert (appdata IN) {
		v2f OUT;
		OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
		OUT.uv = IN.uv;
		return OUT;
	}
	
	void sample (float2 uv, out float4 o, out float4 l, out float4 t, out float4 r, out float4 b) {
		float2 texel = _MainTex_TexelSize.xy;
		o = tex2D(_MainTex, uv);
		l = tex2D(_MainTex, uv + float2(-texel.x,        0));
		t = tex2D(_MainTex, uv + float2(	   0, -texel.y));
		r = tex2D(_MainTex, uv + float2( texel.x,        0));
		b = tex2D(_MainTex, uv + float2(       0,  texel.y));
	}

	float waterDelta (float4 k, float4 o) {
		float ld = (k.w + k.x) - (o.w + o.x); // level difference 
		float transfer = (k.w + k.x) - max(o.w, k.w + k.z); // transferable water particles
		return max(
			0.0,
			0.25 * _Alpha * min(ld, transfer)
		);
	}
	
	float waterFlow (float2 uv) {
		float4 o, l, t, r, b;
		sample(uv, o, l, t, r, b);
		
		float nw = o.r;
		nw += (waterDelta(l, o) - waterDelta(o, l));
		nw += (waterDelta(t, o) - waterDelta(o, t));
		nw += (waterDelta(r, o) - waterDelta(o, r));
		nw += (waterDelta(b, o) - waterDelta(o, b));
		return max(nw, 0);
	}
	
	float evaporation (float wo) {
		return max(wo - _Evaporation, 0.0);
	}
	
	float brush (float2 uv) {
		const int count = 10;
	
		float2 dir = _Brush.xy - _Prev.xy;
		float l = length(dir);
		if(l <= 0) {
			float d = length(uv - _Brush.xy);
			return smoothstep(0.0, _Brush.z, _Brush.z - d);
		}
		
		float ld = l / count;
		float2 norm = normalize(dir);
		float md = 100;
		for(int i = 0; i < count; i++) {
			float2 p = _Prev.xy + norm * ld * i;
			float d = length(uv - p);
			if(d < md) {
				md = d;
			}
		}
		return smoothstep(0.0, _Brush.z, _Brush.z - md);
		
		// float d = length(uv - _Brush.xy);
		// return smoothstep(0.0, _Brush.z, _Brush.z - d);
	}

	ENDCG
	
	SubShader {
		Cull Off ZWrite Off ZTest Always
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment init
			
			float4 init (v2f IN) : SV_Target {
				float4 paper = tex2D(_PaperTex, IN.uv);
				return float4(
					0,
					0,
					paper.r,
					paper.r
				);
			}
			
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment waterUpdate
			
			float4 waterUpdate (v2f IN) : SV_Target {
				float4 col = tex2D(_MainTex, IN.uv);
				col.x = evaporation(waterFlow(IN.uv));
		
				float dw = brush(IN.uv);
				// if(dw > 0) {
					col.x = min(col.x + brush(IN.uv), 1.0);
				// }
				
				return col;
			}
			
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment visualize
			
			float4 visualize (v2f IN) : SV_Target {
				float4 col = tex2D(_MainTex, IN.uv);
				return float4(1.0 - col.xxx, 1.0);
			}
			
			ENDCG
		}

	} 
	
}
