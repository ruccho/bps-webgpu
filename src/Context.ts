export class Context{
    readonly canvas: HTMLCanvasElement;
    readonly device: GPUDevice;
    readonly canvasContext: GPUCanvasContext;
    readonly mainBuffer: GPUTexture;

    get width()
    {
        return this.canvas.width;
    }

    get height()
    {
        return this.canvas.height;
    }

    constructor(
        canvas: HTMLCanvasElement,
        device: GPUDevice,
        canvasContext: GPUCanvasContext
    )
    {
        this.canvas = canvas;
        this.device = device;
        this.canvasContext = canvasContext;
        this.mainBuffer = device.createTexture({
            format: "rgba8unorm",
            size: [this.width, this.height, 1],
            usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING | GPUTextureUsage.COPY_SRC,
        })
    }
}