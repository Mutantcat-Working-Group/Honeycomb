declare module '@cycjimmy/jsmpeg-player' {
  export interface JSMpegPlayerOptions {
    canvas?: HTMLCanvasElement | string;
    poster?: string;
    autoplay?: boolean;
    autoSetWrapperSize?: boolean;
    loop?: boolean;
    control?: boolean;
    decodeFirstFrame?: boolean;
    picMode?: boolean;
    progressive?: boolean;
    chunkSize?: number;
    hooks?: {
      play?: () => void;
      pause?: () => void;
      stop?: () => void;
      load?: () => void;
    };
    // JSMpeg原生选项
    audio?: boolean;
    video?: boolean;
    pauseWhenHidden?: boolean;
    disableGl?: boolean; // 禁用WebGL以避免上下文问题
    disableWebAssembly?: boolean; // 禁用WebAssembly以提高兼容性
    preserveDrawingBuffer?: boolean;
    throttled?: boolean;
    maxAudioLag?: number;
    videoBufferSize?: number;
    audioBufferSize?: number;
    onVideoDecode?: (decoder: any, time: number) => void;
    onAudioDecode?: (decoder: any, time: number) => void;
    onPlay?: (player: any) => void;
    onPause?: (player: any) => void;
    onEnded?: (player: any) => void;
    onStalled?: (player: any) => void;
    onSourceEstablished?: (source: any) => void;
    onSourceCompleted?: (source: any) => void;
  }

  export interface JSMpegVideoElement {
    play(): void;
    pause(): void;
    stop(): void;
    destroy(): void;
    player: JSMpegPlayer;
  }

  export interface JSMpegPlayer {
    play(): void;
    pause(): void;
    stop(): void;
    destroy(): void;
    volume: number;
    currentTime: number;
    paused: boolean;
  }

  export class VideoElement {
    constructor(
      wrapper: string | HTMLElement,
      url: string,
      options?: JSMpegPlayerOptions,
      overlayOptions?: any
    );
    play(): void;
    pause(): void;
    stop(): void;
    destroy(): void;
    player: JSMpegPlayer;
  }

  export class Player {
    constructor(url: string, options?: JSMpegPlayerOptions);
    play(): void;
    pause(): void;
    stop(): void;
    destroy(): void;
    volume: number;
    currentTime: number;
    paused: boolean;
  }

  const JSMpeg: {
    VideoElement: typeof VideoElement;
    Player: typeof Player;
  };

  export default JSMpeg;
} 