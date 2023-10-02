import './style.css'
import sampleVideoUrl from "./out_1024.mp4";
import { TexturePass } from './TexturePass';
import { Context } from './Context';
import { BPSPass } from './BPSPass';
import GUI from 'lil-gui'; 
import { VideoPass } from './VideoPass';

const gui = new GUI();

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
<div>
<h3>BitonicPixelSorter on WebGPU</h3>
  <canvas width="1024" height="576"></canvas>
</div>
`;

runAsync();

async function runAsync() {

  const canvas = document.querySelector("canvas") as HTMLCanvasElement;
  if (!navigator.gpu) {
    throw new Error("WebGPU not supported on this browser.");
  }

  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) {
    throw new Error("No appropriate GPUAdapter found.");
  }

  const device = await adapter.requestDevice();

  const canvasContext = canvas.getContext("webgpu");
  if (!canvasContext) {
    throw new Error("No WebGPU context!");
  }
  const canvasFormat = navigator.gpu.getPreferredCanvasFormat();
  canvasContext.configure({
    device: device,
    format: canvasFormat,
  });

  const context = new Context(canvas, device, canvasContext);

  const video = document.createElement('video');
  video.loop = true;
  video.autoplay = true;
  video.muted = true;
  video.src = sampleVideoUrl;
  await video.play();

  const renderImagePass = new VideoPass(context, video, context.mainBuffer.format);
  const bpsPass = new BPSPass(context);
  const renderResultPass = new TexturePass(context, context.mainBuffer, canvasFormat);

  const bpsParams = {
    thresholdMin: bpsPass.thresholdMin,
    thresholdMax: bpsPass.thresholdMax,
    ordering: bpsPass.ordering,
    direction: bpsPass.direction,
  }

  gui.add(bpsParams, "thresholdMin", 0, 1).onChange((v: number) => bpsPass.thresholdMin = v);
  gui.add(bpsParams, "thresholdMax", 0, 1).onChange((v: number) => bpsPass.thresholdMax = v);
  gui.add(bpsParams, "ordering").onChange((v: boolean) => bpsPass.ordering = v);
  gui.add(bpsParams, "direction").onChange((v: boolean) => bpsPass.direction = v);

  const update = () => {

    let encoder = device.createCommandEncoder();
    {
      const passEncoder = encoder.beginRenderPass({
        colorAttachments: [
          {
            view: context.mainBuffer.createView(),
            loadOp: "clear",
            storeOp: "store",
          },
        ],
      });
      renderImagePass.execute(passEncoder);
      passEncoder.end();
    }

    encoder.copyTextureToTexture({
      texture: context.mainBuffer
    }, {
      texture: bpsPass.srcTex
    }, [context.width, context.height, 1]);

    {
      const passEncoder = encoder.beginComputePass({
        label: "bps pass"
      });
      bpsPass.execute(passEncoder);
      passEncoder.end();
    }

    {
      const passEncoder = encoder.beginRenderPass({
        colorAttachments: [
          {
            view: canvasContext.getCurrentTexture().createView(),
            loadOp: "clear",
            storeOp: "store",
          },
        ],
      });
      renderResultPass.execute(passEncoder);
      passEncoder.end();
    }
    device.queue.submit([encoder.finish()]);
    requestAnimationFrame(update);
  }
  requestAnimationFrame(update);

}
