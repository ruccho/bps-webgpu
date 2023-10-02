export interface RenderPass {
    execute(encoder : GPURenderPassEncoder): void;
}

export interface ComputePass {
    execute(encoder : GPUComputePassEncoder): void;
}