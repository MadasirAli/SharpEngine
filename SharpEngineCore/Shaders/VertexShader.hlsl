#include "VertexInputStruct.hlsl"
#include "PixelInputStruct.hlsl"
#include "TransformCBuffer.hlsl"
#include "CamTransformCBuffer.hlsl"
#include "Transformations.hlsl"
#include "LightsSWBuffer.hlsl"

PixelInput main(VertexInput input)
{
    PixelInput output = (PixelInput) 0;
    output.color = input.color;
    output.camPosition = CamPosition;
    output.textureCoord = input.textureCoord;
    
    float4 worldCoords = TransformWorld(input.position, Position, Rotation, Scale);
    float4 camViewCoords = TransformCameraView(worldCoords, CamPosition, CamRotation);
    float4 projectionCoords = TransformPerspective(
                                    camViewCoords, AspectRatio, Fov, NearPlane, FarPlane);
    
    output.position = projectionCoords;
    output.worldPos = worldCoords;
    
    float4 normalCoords = TransformNormal(input.normal, Rotation);
    
    output.normal = normalize(normalCoords);
    
    for (int i = 0; i < LVP_POSITIONS_COUNT; i++)
    {
        LightData data = LightDataBuffer[i];
        
        float4 lightWorldCoords = TransformWorld(
                                input.position, Position, Rotation, Scale);
        float4 lightViewCoords = TransformLightView(
                                lightWorldCoords, data.Position, data.Rotation);
   
        float4 projectionCoords = TransformOrthogonal(lightViewCoords, data.Scale);
        
        output.LVPPositions[i] = projectionCoords;
    }
    
    return output;
}