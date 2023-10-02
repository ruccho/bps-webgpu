import { Context } from "./Context";
import { RenderPass } from "./common";

export class VideoPass implements RenderPass {

    private readonly context: Context;
    private readonly pipeline: GPURenderPipeline;
    private readonly vertexBuffer: GPUBuffer;
    private readonly video: HTMLVideoElement;
    private readonly sampler: GPUSampler;

    constructor(context: Context, video: HTMLVideoElement, targetFormat: GPUTextureFormat) {
        this.context = context;
        this.video = video;
        const device = context.device;
        this.sampler = device.createSampler({
            magFilter: 'linear',
            minFilter: 'linear',
        });

        const textureShaderModule = device.createShaderModule({
            label: "TexturePass shader module",
            code: `
@group(0) @binding(0) var myTexture: texture_external;
@group(0) @binding(1) var mySampler: sampler;

struct VertexOutput {
  @builtin(position) Position : vec4f,
  @location(0) fragUV : vec2<f32>,
}

@vertex
fn vertexMain(
  @location(0) position: vec2f,
  @location(1) color: vec4<f32>,
  @location(2) uv: vec2<f32>  
) -> VertexOutput {

  var output : VertexOutput;
  output.Position = vec4f(position, 0, 1);
  output.fragUV = uv;
  
  return output;
}

@fragment
fn fragmentMain(
  @location(0) fragUV: vec2<f32>,
) -> @location(0) vec4<f32> {
  return textureSampleBaseClampToEdge(myTexture, mySampler, fragUV);
}
    `});

        const vertexBufferLayout: GPUVertexBufferLayout = {
            arrayStride: 32,
            attributes: [
                // @location(0) position: vec2f,
                {
                    format: "float32x2",
                    offset: 0,
                    shaderLocation: 0, // Position, see vertex shader
                },
                // @location(1) color: vec4<f32>,
                {
                    format: "float32x4",
                    offset: 8,
                    shaderLocation: 1, // Position, see vertex shader
                },
                // @location(2) uv: vec2<f32> 
                {
                    format: "float32x2",
                    offset: 24,
                    shaderLocation: 2, // Position, see vertex shader
                },
            ],
        };

        const vertices = new Float32Array(8 * 3);
        const setVertex = (index: number, x: number, y: number, r: number, g: number, b: number, a: number, u: number, v: number) => {
            vertices[index * 8] = x;
            vertices[index * 8 + 1] = y;
            vertices[index * 8 + 2] = r;
            vertices[index * 8 + 3] = g;
            vertices[index * 8 + 4] = b;
            vertices[index * 8 + 5] = a;
            vertices[index * 8 + 6] = u;
            vertices[index * 8 + 7] = v;
        };

        setVertex(0, -1, -1, 1, 1, 1, 1, 0, 1);
        setVertex(1, 3, -1, 1, 1, 1, 1, 2, 1);
        setVertex(2, -1, 3, 1, 1, 1, 1, 0, -1);

        const vertexBuffer = this.vertexBuffer = device.createBuffer({
            label: "Cell vertices",
            size: vertices.byteLength,
            usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
        });

        this.pipeline = device.createRenderPipeline({
            label: "texture pipeline",
            layout: "auto",
            vertex: {
                module: textureShaderModule,
                entryPoint: "vertexMain",
                buffers: [vertexBufferLayout],
            },
            fragment: {
                module: textureShaderModule,
                entryPoint: "fragmentMain",
                targets: [
                    {
                        format: targetFormat,
                    },
                ],
            },
        });

        device.queue.writeBuffer(vertexBuffer, 0, vertices);
    }

    execute(encoder: GPURenderPassEncoder): void {
        const bindGroup = this.context.device.createBindGroup({
            layout: this.pipeline.getBindGroupLayout(0),
            entries: [
                {
                    binding: 0,
                    resource: this.context.device.importExternalTexture({
                        source: this.video,
                      }),
                },
                {
                    binding: 1,
                    resource: this.sampler,
                },
            ],
        });
        encoder.setPipeline(this.pipeline);
        encoder.setBindGroup(0, bindGroup);
        encoder.setVertexBuffer(0, this.vertexBuffer);
        encoder.draw(this.vertexBuffer.size / 32);
    }

}