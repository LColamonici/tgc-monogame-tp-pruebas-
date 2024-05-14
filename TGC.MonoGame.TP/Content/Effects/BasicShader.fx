#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

// Custom Effects - https://docs.monogame.net/articles/content/custom_effects.html
// High-level shader language (HLSL) - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl
// Programming guide for HLSL - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-pguide
// Reference for HLSL - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-reference
// HLSL Semantics - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics

float4x4 World;
float4x4 View;
float4x4 Projection;

uniform float Min;
uniform float Max;

float3 DiffuseColor;

float Time = 0;

struct VertexShaderInput
{
	float4 Position : POSITION0;
};

struct VertexShaderOutput
{
	float4 LocalPosition: TEXCOORD0; //nuevo
	float4 WorldPosition:TEXCOORD1;
	float4 Position : SV_POSITION;
};

VertexShaderOutput MainVS(in VertexShaderInput input)
{
    // Clear the output
	VertexShaderOutput output = (VertexShaderOutput)0;

	//input.Position.x=clamp(input.Position.x, Min, Max); //SOLUCION 3

    // Model space to World space
    float4 worldPosition = mul(input.Position, World);
    // World space to View space
    float4 viewPosition = mul(worldPosition, View);	
	// View space to Projection space
    output.Position = mul(viewPosition, Projection);
	output.WorldPosition=worldPosition;
	output.LocalPosition=input.Position; //nuevo

    return output;
}
/* SOLUCION 1
float4 MainPS(VertexShaderOutput input) : COLOR
{
	/*if(input.LocalPosition.z < 0.0)
		return float4(1.0, 1.0, 1.0, 1.0); //nuevo
	else
    	return float4(0.0, 0.0, 0.0, 0.0);
		//return float4(-1000.0*input.LocalPosition.z,-1000.0*input.LocalPosition.z,-1000.0*input.LocalPosition.z,1); //bueno para debuggear
		float menorACero = step(input.LocalPosition.z, 0.0);
		return float4(menorACero, menorACero, menorACero, 1);
		//return float4(-1000.0*input.LocalPosition); //muy cursed
}*/

/* SOLUCION 2
float4 MainPS(VertexShaderOutput input) : COLOR
{
	float3 centro=float3(0.0,0.0,0.0);
	float radius=10;
	bool dentro = (distance(input.WorldPosition.xyz, centro) < radius);
	if(dentro)
		return float4(1.0, 1.0, 1.0, 1.0); //nuevo
	else
    	return float4(0.0, 0.0, 0.0, 0.0);
		//return float4(input.LocalPosition.x,input.LocalPosition.y,input.LocalPosition.z,1); //bueno para debuggear
}*/

float4 MainPS(VertexShaderOutput input) : COLOR
{
	return float4(DiffuseColor,1.0);
}

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
