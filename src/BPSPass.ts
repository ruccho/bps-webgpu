import { Context } from "./Context";
import metaPassCode from "./shaders/BitonicPixelSorter_MetaPass.wgsl?raw";
import sortPassCode from "./shaders/BitonicPixelSorter_SortPass.wgsl?raw";
import { ComputePass } from "./common";

export class BPSPass implements ComputePass {
    private context: Context;

    readonly uniformBuffer: GPUBuffer;
    private readonly uniformBufferSource: ArrayBuffer;
    private readonly thresholdMinView: Float32Array;
    private readonly thresholdMaxView: Float32Array;
    private readonly maxLevelsView: Int32Array;
    private readonly orderingView: Uint32Array;
    private readonly directionView: Uint32Array;
    private isUniformsDirty: boolean = true;

    private metaBindGroup: GPUBindGroup;
    private sortBindGroup: GPUBindGroup;

    readonly metaTex: GPUTexture;
    readonly srcTex: GPUTexture;
    private readonly metaPassPipeline: GPUComputePipeline;
    private readonly sortPassPipeline: GPUComputePipeline;


    private setUniformsDirty() {
        this.isUniformsDirty = true;
    }

    get thresholdMin() {
        return this.thresholdMinView[0];
    }

    set thresholdMin(value: number) {
        if (this.thresholdMin != value) {
            this.thresholdMinView[0] = value;
            this.setUniformsDirty();
        }
    }

    get thresholdMax() {
        return this.thresholdMaxView[0];
    }

    set thresholdMax(value: number) {
        if (this.thresholdMax != value) {
            this.thresholdMaxView[0] = value;
            this.setUniformsDirty();
        }
    }

    get maxLevels() {
        return this.maxLevelsView[0];
    }

    set maxLevels(value: number) {
        if (this.maxLevels != value) {
            this.maxLevelsView[0] = value;
            this.setUniformsDirty();
        }
    }

    get ordering() {
        return this.orderingView[0] !== 0;
    }

    set ordering(value: boolean) {
        if (this.ordering != value) {
            this.orderingView[0] = value ? 1 : 0;
            this.setUniformsDirty();
        }
    }

    get direction() {
        return this.directionView[0] !== 0;
    }

    set direction(value: boolean) {
        if (this.direction != value) {
            this.directionView[0] = value ? 1 : 0;
            this.setUniformsDirty();
        }
    }

    applyUniforms() {
        if (true || this.isUniformsDirty) {
            this.isUniformsDirty = false;
            this.context.device.queue.writeBuffer(this.uniformBuffer, 0, this.uniformBufferSource, 0, this.uniformBufferSource.byteLength)
        }
    }

    constructor(context: Context) {
        this.context = context
        const buffer = this.uniformBufferSource = new ArrayBuffer(20);
        this.thresholdMinView = new Float32Array(buffer, 0, 1);
        this.thresholdMaxView = new Float32Array(buffer, 4, 1);
        this.maxLevelsView = new Int32Array(buffer, 8, 1);
        this.orderingView = new Uint32Array(buffer, 12, 1);
        this.directionView = new Uint32Array(buffer, 16, 1);

        this.thresholdMax = 0.95;
        this.thresholdMin = 0.2;
        this.ordering = false;
        this.direction = true;

        this.uniformBuffer = context.device.createBuffer({
            size: 20,
            usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
        });

        const metaTex = this.metaTex = context.device.createTexture({
            format: "rg32float",
            size: {
                width: context.width,
                height: context.height,
            },
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING | GPUTextureUsage.COPY_SRC
        });

        const srcTex = this.srcTex = context.device.createTexture({
            format: "rgba8unorm",
            label: "source tex",
            size: {
                width: context.width,
                height: context.height,
            },
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST
        });

        const metaShader = context.device.createShaderModule({
            label: "meta pass",
            code: metaPassCode
        });

        const metaPipeline = this.metaPassPipeline = context.device.createComputePipeline({
            label: "meta pass pipeline",
            layout: "auto",
            compute: {
                module: metaShader,
                entryPoint: "MetaPass"
            }
        });

        const sortShader = context.device.createShaderModule({
            label: "sort pass",
            code: sortPassCode
        });

        const sortPipeline = this.sortPassPipeline = context.device.createComputePipeline({
            label: "sort pass pipeline",
            layout: "auto",
            compute: {
                module: sortShader,
                entryPoint: "SortPass"
            }
        });
        
        this.metaBindGroup = context.device.createBindGroup({
            layout: metaPipeline.getBindGroupLayout(0),
            entries: [
                // srcTex
                {
                    binding: 0,
                    resource: srcTex.createView()
                },
                // metaTex
                {
                    binding: 1,
                    resource: metaTex.createView(),
                },
                // globals
                {
                    binding: 2,
                    resource: {
                        buffer: this.uniformBuffer,
                    }
                },
            ],
        });
        
        this.sortBindGroup = context.device.createBindGroup({
            layout: sortPipeline.getBindGroupLayout(0),
            entries: [
                // srcTex
                {
                    binding: 0,
                    resource: srcTex.createView()
                },
                // globals
                {
                    binding: 2,
                    resource: {
                        buffer: this.uniformBuffer,
                    }
                },
                //srcMetaTex
                {
                    binding: 3,
                    resource: metaTex.createView()
                },
                //sortTex
                {
                    binding: 4,
                    resource: context.mainBuffer.createView()
                }
            ],
        });
    }

    execute(encoder: GPUComputePassEncoder): void {
        const lines = this.direction ? this.context.height : this.context.width;
        const size = !this.direction ? this.context.height : this.context.width;
        this.maxLevels = Math.ceil(Math.log2(size));
        this.applyUniforms();

        encoder.setPipeline(this.metaPassPipeline);
        encoder.setBindGroup(0, this.metaBindGroup);

        const metaDispatchCount = Math.ceil(lines * 2 / 32);
        encoder.dispatchWorkgroups(metaDispatchCount, 1, 1);
        
        encoder.setPipeline(this.sortPassPipeline);
        encoder.setBindGroup(0, this.sortBindGroup);
        encoder.dispatchWorkgroups(lines, 1, 1);
    }
}