// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/V-Light/Depth" {
Properties {
	_MainTex ("", 2D) = "white" {}
	_Cutoff ("", Float) = 0.5
	_Color ("", Color) = (1,1,1,1)
}

SubShader {
	Tags { "RenderType"="Opaque" }

	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile _SHADOWMODE_STANDARD _SHADOWMODE_VSM _SHADOWMODE_PCF _SHADOWMODE_PCSS
#pragma multi_compile _ _ALPHATEST

#include "UnityCG.cginc"
struct v2f {
    float4 pos : SV_POSITION;
    float depth : TEXCOORD0;
	float2 uv : TEXCOORD1;
};
uniform float4 _MainTex_ST;
v2f vert( appdata_base v ) {
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.depth = COMPUTE_DEPTH_01;
    return o;
}
uniform sampler2D _MainTex;
float4 frag(v2f i) : SV_Target 
{
	fixed4 col = tex2D(_MainTex, i.uv);
#if _ALPHATEST
    clip(col.a - 0.1);
#endif
#if _SHADOWMODE_VSM
	i.depth = i.depth * 0.5 + 0.5;
#endif
	return float4(i.depth, i.depth * i.depth, 0, 0);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TransparentCutout" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
struct v2f {
    float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
uniform float4 _MainTex_ST;
v2f vert( appdata_base v ) {
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
    return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
uniform fixed4 _Color;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	clip( texcol.a*_Color.a - _Cutoff );


	
	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeBark" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityBuiltin3xTreeLibrary.cginc"
struct v2f {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
v2f vert( appdata_full v ) {
    v2f o;
    TreeVertBark(v);
	
	o.pos = UnityObjectToClipPos( v.vertex );
	o.uv = v.texcoord.xy;
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
    return o;
}
fixed4 frag( v2f i ) : SV_Target {


	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeLeaf" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityBuiltin3xTreeLibrary.cginc"
struct v2f {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
v2f vert( appdata_full v ) {
    v2f o;
    TreeVertLeaf(v);
	o.pos = UnityObjectToClipPos( v.vertex );
	o.uv = v.texcoord.xy;
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
    return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag( v2f i ) : SV_Target {
	half alpha = tex2D(_MainTex, i.uv).a;
	clip (alpha - _Cutoff);
	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeOpaque" "DisableBatching"="True" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD0;
};
struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    fixed4 color : COLOR;
};
v2f vert( appdata v ) {
	v2f o;
	TerrainAnimateTree(v.vertex, v.color.w);
	o.pos = UnityObjectToClipPos( v.vertex );
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
fixed4 frag(v2f i) : SV_Target {


	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
} 

SubShader {
	Tags { "RenderType"="TreeTransparentCutout" "DisableBatching"="True" }
	Pass {
		Cull Back
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    fixed4 color : COLOR;
    float4 texcoord : TEXCOORD0;
};
v2f vert( appdata v ) {
	v2f o;
	TerrainAnimateTree(v.vertex, v.color.w);
	o.pos = UnityObjectToClipPos( v.vertex );
	o.uv = v.texcoord.xy;
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	half alpha = tex2D(_MainTex, i.uv).a;
	clip (alpha - _Cutoff);

	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
	Pass {
		Cull Front
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    fixed4 color : COLOR;
    float4 texcoord : TEXCOORD0;
};
v2f vert( appdata v ) {
	v2f o;
	TerrainAnimateTree(v.vertex, v.color.w);
	o.pos = UnityObjectToClipPos( v.vertex );
	o.uv = v.texcoord.xy;
//    o.nz.xyz = -COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	clip( texcol.a - _Cutoff );

	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}

}

SubShader {
	Tags { "RenderType"="TreeBillboard" }
	Pass {
		Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};
v2f vert (appdata_tree_billboard v) {
	v2f o;
	TerrainBillboardTree(v.vertex, v.texcoord1.xy, v.texcoord.y);
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv.x = v.texcoord.x;
	o.uv.y = v.texcoord.y > 0;
//    o.nz.xyz = float3(0,0,1);
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
uniform sampler2D _MainTex;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	clip( texcol.a - 0.001 );

	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="GrassBillboard" }
	Pass {
		Cull Off		
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

struct v2f {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};

v2f vert (appdata_full v) {
	v2f o;
	WavingGrassBillboardVert (v);
	o.color = v.color;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.texcoord.xy;
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	fixed alpha = texcol.a * i.color.a;
	clip( alpha - _Cutoff );
	return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="Grass" }
	Pass {
		Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	//    float4 nz : TEXCOORD0;
    float depth : TEXCOORD1;
};

v2f vert (appdata_full v) {
	v2f o;
	WavingGrassVert (v);
	o.color = v.color;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.texcoord;
//    o.nz.xyz = COMPUTE_VIEW_NORMAL;
//    o.nz.w = COMPUTE_DEPTH_01;
    o.depth = COMPUTE_DEPTH_01;
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	fixed alpha = texcol.a * i.color.a;
	clip( alpha - _Cutoff );
		return float4(i.depth, 0, 0, 0);
//	return EncodeDepthNormal (i.nz.w, i.nz.xyz);
}
ENDCG
	}
}
Fallback Off
}
