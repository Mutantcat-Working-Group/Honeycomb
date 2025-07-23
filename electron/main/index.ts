import { app, BrowserWindow, shell, ipcMain, Menu, desktopCapturer, screen } from 'electron'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
import os from 'node:os'
import { spawn, ChildProcess } from 'node:child_process'
import fs from 'node:fs'
import http from 'node:http'

const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))

// 导入MQTT模块以便在主进程中测试
let mqtt;
try {
  mqtt = require('mqtt');
} catch (error) {
  console.error('无法导入MQTT模块:', error);
}

// RTSP流处理相关变量
let ffmpegProcess: ChildProcess | null = null;
let httpServer: http.Server | null = null;
let currentStreamPort: number = 8080;

// The built directory structure
//
// ├─┬ dist-electron
// │ ├─┬ main
// │ │ └── index.js    > Electron-Main
// │ └─┬ preload
// │   └── index.mjs   > Preload-Scripts
// ├─┬ dist
// │ └── index.html    > Electron-Renderer
//
process.env.APP_ROOT = path.join(__dirname, '../..')

export const MAIN_DIST = path.join(process.env.APP_ROOT, 'dist-electron')
export const RENDERER_DIST = path.join(process.env.APP_ROOT, 'dist')
export const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL

process.env.VITE_PUBLIC = VITE_DEV_SERVER_URL
  ? path.join(process.env.APP_ROOT, 'public')
  : RENDERER_DIST

// Disable GPU Acceleration for Windows 7
if (os.release().startsWith('6.1')) app.disableHardwareAcceleration()

// Set application name for Windows 10+ notifications
if (process.platform === 'win32') app.setAppUserModelId(app.getName())

if (!app.requestSingleInstanceLock()) {
  app.quit()
  process.exit(0)
}

let win: BrowserWindow | null = null
const preload = path.join(__dirname, '../preload/index.mjs')
const indexHtml = path.join(RENDERER_DIST, 'index.html')

async function createWindow() {
  win = new BrowserWindow({
    title: '蜂巢工具箱',
    icon: path.join(process.env.VITE_PUBLIC, 'favicon.ico'),
    resizable: false, // 禁止调整窗口大小 
    maximizable: false, // 禁止最大化窗口
    titleBarStyle: 'hidden', // 隐藏标题栏
    webPreferences: {
      preload,
      // Warning: Enable nodeIntegration and disable contextIsolation is not secure in production
      // nodeIntegration: true,

      // Consider using contextBridge.exposeInMainWorld
      // Read more on https://www.electronjs.org/docs/latest/tutorial/context-isolation
      // contextIsolation: false,
    },
  })

  if (VITE_DEV_SERVER_URL) { // #298
    win.loadURL(VITE_DEV_SERVER_URL)
    // Open devTool if the app is not packaged
    win.webContents.openDevTools()
  } else {
    win.loadFile(indexHtml)
  }

  // Test actively push message to the Electron-Renderer
  win.webContents.on('did-finish-load', () => {
    win?.webContents.send('main-process-message', new Date().toLocaleString())
  })

  // 监听窗口关闭事件
  win.on('close', (event) => {
    console.log('主窗口即将关闭，清理资源...');
    cleanupResources();
  });

  // Make all links open with the browser, not with the application
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https:')) shell.openExternal(url)
    return { action: 'deny' }
  })
  // win.webContents.on('will-navigate', (event, url) => { }) #344
}

app.whenReady().then(() => {
  createWindow()
  Menu.setApplicationMenu(null);
})

// 创建清理函数
function cleanupResources() {
  console.log('开始清理资源...');
  
  // 强制终止FFmpeg进程
  if (ffmpegProcess) {
    console.log('终止FFmpeg进程...');
    try {
      if (process.platform === 'win32') {
        // Windows下使用taskkill强制终止
        spawn('taskkill', ['/pid', ffmpegProcess.pid?.toString() || '', '/T', '/F'], { shell: true });
      } else {
        // Unix系统使用SIGKILL
        ffmpegProcess.kill('SIGKILL');
      }
    } catch (error) {
      console.error('终止FFmpeg进程失败:', error);
    }
    ffmpegProcess = null;
  }
  
  // 关闭HTTP服务器
  if (httpServer) {
    console.log('关闭HTTP服务器...');
    try {
      httpServer.close();
    } catch (error) {
      console.error('关闭HTTP服务器失败:', error);
    }
    httpServer = null;
  }
  
  // 清理临时HLS文件
  try {
    let outputDir: string;
    if (app.isPackaged) {
      outputDir = path.join(app.getPath('userData'), 'rtsp_temp');
    } else {
      outputDir = process.env.VITE_PUBLIC || path.join(process.cwd(), 'public');
    }
    
    if (fs.existsSync(outputDir)) {
      console.log('清理HLS临时文件...');
      const files = fs.readdirSync(outputDir);
      files.forEach(file => {
        if (file.startsWith('stream') && (file.endsWith('.m3u8') || file.endsWith('.ts'))) {
          try {
            fs.unlinkSync(path.join(outputDir, file));
            console.log('已删除文件:', file);
          } catch (error) {
            console.warn('删除文件失败:', file, error);
          }
        }
      });
    }
  } catch (error) {
    console.error('清理临时文件失败:', error);
  }
  
  console.log('资源清理完成');
}

// 应用退出时清理资源
app.on('before-quit', () => {
  cleanupResources();
});

// 窗口关闭时也进行清理
app.on('window-all-closed', () => {
  cleanupResources();
  win = null;
  if (process.platform !== 'darwin') app.quit();
});

// 进程退出时的最后清理
process.on('exit', () => {
  cleanupResources();
});

// 处理意外退出
process.on('SIGINT', () => {
  console.log('收到SIGINT信号，清理资源...');
  cleanupResources();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('收到SIGTERM信号，清理资源...');
  cleanupResources();
  process.exit(0);
});

app.on('second-instance', () => {
  if (win) {
    // Focus on the main window if the user tried to open another
    if (win.isMinimized()) win.restore()
    win.focus()
  }
})

app.on('activate', () => {
  const allWindows = BrowserWindow.getAllWindows()
  if (allWindows.length) {
    allWindows[0].focus()
  } else {
    createWindow()
  }
})

// New window example arg: new windows url
ipcMain.handle('open-win', (_, arg) => {
  const childWindow = new BrowserWindow({
    webPreferences: {
      preload,
      nodeIntegration: true,
      contextIsolation: false,
    },
  })

  if (VITE_DEV_SERVER_URL) {
    childWindow.loadURL(`${VITE_DEV_SERVER_URL}#${arg}`)
  } else {
    childWindow.loadFile(indexHtml, { hash: arg })
  }
})

// 监听最小化和关闭事件 
ipcMain.on('minimize-window', () => { win.minimize(); }); 
ipcMain.on('close-window', () => { win.close(); });

// 处理屏幕截图
ipcMain.on('capture-screen', async (event) => {
  try {
    const { sender } = event;
    
    // 获取当前窗口所在的显示器
    const currentWindow = BrowserWindow.fromWebContents(sender);
    const currentDisplayId = screen.getDisplayNearestPoint(currentWindow.getBounds()).id;
    const currentDisplay = screen.getDisplayMatching(currentWindow.getBounds());
    const { width, height } = currentDisplay.size;
    
    // 捕获屏幕截图
    const sources = await desktopCapturer.getSources({
      types: ['screen'],
      thumbnailSize: { width, height }
    });
    
    // 找到当前窗口所在屏幕的源
    const currentSource = sources.find(source => {
      // 有些系统的display_id可能是字符串形式的数字，需要做比较
      return source.display_id === currentDisplayId.toString() || 
             source.display_id === String(currentDisplayId);
    }) || sources[0];
    
    if (currentSource && currentSource.thumbnail) {
      // 将截图转换为Base64格式并发送回渲染进程
      const imageDataUrl = currentSource.thumbnail.toDataURL();
      sender.send('screen-captured', imageDataUrl);
    } else {
      sender.send('screen-captured', null);
    }
  } catch (error) {
    console.error('截图失败:', error);
    event.sender.send('screen-captured', null);
  }
});

// MQTT客户端对象
let mqttClient: any = null;
let mqttSender: any = null;
// MQTT发布者客户端
let mqttPublisher: any = null;
let mqttPublisherInterval: any = null;

// 处理MQTT断开连接
ipcMain.on('mqtt-disconnect', (event) => {
  console.log('收到MQTT断开连接请求');
  
  if (mqttClient) {
    try {
      // 断开MQTT客户端连接
      mqttClient.end(true);
      console.log('MQTT客户端已断开连接');
    } catch (err) {
      console.error('断开MQTT连接时出错:', err);
    } finally {
      mqttClient = null;
      mqttSender = null;
    }
  } else {
    console.log('没有活动的MQTT客户端连接');
  }
});

// 处理MQTT连接
ipcMain.on('test-mqtt-connection', async (event, options) => {
  console.log('收到MQTT连接请求:', options);
  mqttSender = event.sender;
  
  // 如果已有连接，先断开
  if (mqttClient) {
    try {
      mqttClient.end();
      mqttClient = null;
    } catch (err) {
      console.error('断开现有MQTT连接时出错:', err);
    }
  }
  
  try {
    if (!mqtt) {
      event.sender.send('mqtt-connection-result', {
        success: false,
        error: '主进程无法加载MQTT模块'
      });
      return;
    }
    
    // 创建MQTT客户端配置
    const mqttOptions: any = {
      clientId: 'mqtt_subscriber_' + Math.random().toString(16).substr(2, 8),
      clean: true
    };
    
    // 添加认证信息（如果提供）
    if (options.username) {
      mqttOptions.username = options.username;
    }
    if (options.password) {
      mqttOptions.password = options.password;
    }
    
    console.log('尝试连接MQTT服务器:', options.host, options.port);
    
    // 创建客户端并连接
    mqttClient = mqtt.connect(`mqtt://${options.host}:${options.port}`, mqttOptions);
    
    // 设置超时
    const timeout = setTimeout(() => {
      if (mqttClient) {
        mqttClient.end();
        mqttClient = null;
      }
      event.sender.send('mqtt-connection-result', {
        success: false,
        error: '连接超时'
      });
    }, 10000);
    
    // 连接成功
    mqttClient.on('connect', () => {
      clearTimeout(timeout);
      console.log('主进程成功连接到MQTT服务器');
      
      // 通知渲染进程
      event.sender.send('mqtt-connection-result', {
        success: true,
        message: '成功连接到MQTT服务器'
      });
      
      // 订阅主题
      if (options.topic) {
        console.log('订阅主题:', options.topic);
        mqttClient.subscribe(options.topic);
      }
    });
    
    // 接收消息
    mqttClient.on('message', (topic: string, message: Buffer) => {
      console.log('主进程收到MQTT消息:', topic);
      if (mqttSender) {
        try {
          // 尝试解析JSON
          let messageStr = message.toString();
          let jsonData = null;
          try {
            jsonData = JSON.parse(messageStr);
            messageStr = JSON.stringify(jsonData, null, 2);
          } catch (e) {
            // 消息不是JSON格式
          }
          
          mqttSender.send('mqtt-message', {
            topic: topic,
            message: messageStr
          });
        } catch (err) {
          console.error('处理MQTT消息时出错:', err);
        }
      }
    });
    
    // 错误处理
    mqttClient.on('error', (err: Error) => {
      clearTimeout(timeout);
      console.error('主进程MQTT连接错误:', err);
      
      // 通知渲染进程
      event.sender.send('mqtt-connection-result', {
        success: false,
        error: err.toString()
      });
      
      mqttClient = null;
    });
  } catch (error) {
    console.error('处理MQTT连接时出错:', error);
    event.sender.send('mqtt-connection-result', {
      success: false,
      error: (error as Error).toString()
    });
  }
});

// 处理MQTT单次广播
ipcMain.on('mqtt-publish', async (event, options) => {
  console.log('收到MQTT单次广播请求:', options);
  
  try {
    if (!mqtt) {
      event.sender.send('mqtt-publish-result', {
        success: false,
        error: '主进程无法加载MQTT模块'
      });
      return;
    }
    
    // 创建MQTT客户端配置
    const mqttOptions: any = {
      clientId: 'mqtt_publisher_' + Math.random().toString(16).substr(2, 8),
      clean: true
    };
    
    // 添加认证信息（如果提供）
    if (options.username) {
      mqttOptions.username = options.username;
    }
    if (options.password) {
      mqttOptions.password = options.password;
    }
    
    console.log('尝试连接MQTT服务器进行单次广播:', options.host, options.port);
    
    // 创建一个临时客户端
    const tempClient = mqtt.connect(`mqtt://${options.host}:${options.port}`, mqttOptions);
    
    // 设置超时
    const timeout = setTimeout(() => {
      if (tempClient) {
        tempClient.end();
      }
      event.sender.send('mqtt-publish-result', {
        success: false,
        error: '连接超时'
      });
    }, 5000);
    
    // 连接成功
    tempClient.on('connect', () => {
      clearTimeout(timeout);
      console.log('主进程成功连接到MQTT服务器进行单次广播');
      
      // 发布消息
      tempClient.publish(options.topic, options.message, { qos: 0 }, (err) => {
        if (err) {
          console.error('发布消息失败:', err);
          event.sender.send('mqtt-publish-result', {
            success: false,
            error: err.toString()
          });
        } else {
          console.log('消息发布成功');
          event.sender.send('mqtt-publish-result', {
            success: true,
            message: '消息发布成功'
          });
        }
        
        // 完成后断开连接
        tempClient.end();
      });
    });
    
    // 错误处理
    tempClient.on('error', (err: Error) => {
      clearTimeout(timeout);
      console.error('主进程MQTT连接错误:', err);
      
      // 通知渲染进程
      event.sender.send('mqtt-publish-result', {
        success: false,
        error: err.toString()
      });
      
      tempClient.end();
    });
  } catch (error) {
    console.error('处理MQTT单次广播时出错:', error);
    event.sender.send('mqtt-publish-result', {
      success: false,
      error: (error as Error).toString()
    });
  }
});

// 处理持续MQTT广播连接
ipcMain.on('mqtt-publish-connect', async (event, options) => {
  console.log('收到MQTT持续广播连接请求:', options);
  
  // 如果已有发布者连接，先断开
  if (mqttPublisher) {
    try {
      clearInterval(mqttPublisherInterval);
      mqttPublisherInterval = null;
      mqttPublisher.end();
      mqttPublisher = null;
    } catch (err) {
      console.error('断开现有MQTT发布者连接时出错:', err);
    }
  }
  
  try {
    if (!mqtt) {
      event.sender.send('mqtt-publish-connect-result', {
        success: false,
        error: '主进程无法加载MQTT模块'
      });
      return;
    }
    
    // 创建MQTT客户端配置
    const mqttOptions: any = {
      clientId: 'mqtt_continuous_publisher_' + Math.random().toString(16).substr(2, 8),
      clean: true
    };
    
    // 添加认证信息（如果提供）
    if (options.username) {
      mqttOptions.username = options.username;
    }
    if (options.password) {
      mqttOptions.password = options.password;
    }
    
    console.log('尝试连接MQTT服务器进行持续广播:', options.host, options.port);
    
    // 创建客户端并连接
    mqttPublisher = mqtt.connect(`mqtt://${options.host}:${options.port}`, mqttOptions);
    
    // 设置超时
    const timeout = setTimeout(() => {
      if (mqttPublisher) {
        mqttPublisher.end();
        mqttPublisher = null;
      }
      event.sender.send('mqtt-publish-connect-result', {
        success: false,
        error: '连接超时'
      });
    }, 10000);
    
    // 连接成功
    mqttPublisher.on('connect', () => {
      clearTimeout(timeout);
      console.log('主进程成功连接到MQTT服务器进行持续广播');
      
      // 通知渲染进程
      event.sender.send('mqtt-publish-connect-result', {
        success: true,
        message: '成功连接到MQTT服务器'
      });
      
      // 设置定时广播
      mqttPublisherInterval = setInterval(() => {
        if (mqttPublisher && mqttPublisher.connected) {
          // 发布消息
          mqttPublisher.publish(options.topic, options.message, { qos: 0 }, (err) => {
            if (err) {
              console.error('发布消息失败:', err);
            } else {
              console.log('持续广播消息发布成功');
              event.sender.send('mqtt-publish-message', {
                message: options.message
              });
            }
          });
        } else {
          console.log('MQTT发布者未连接，跳过定时发布');
        }
      }, options.interval * 1000); // 转换为毫秒
    });
    
    // 错误处理
    mqttPublisher.on('error', (err: Error) => {
      clearTimeout(timeout);
      console.error('主进程MQTT发布者连接错误:', err);
      
      // 通知渲染进程
      event.sender.send('mqtt-publish-connect-result', {
        success: false,
        error: err.toString()
      });
      
      // 清除定时器
      if (mqttPublisherInterval) {
        clearInterval(mqttPublisherInterval);
        mqttPublisherInterval = null;
      }
      
      mqttPublisher = null;
    });
  } catch (error) {
    console.error('处理MQTT持续广播连接时出错:', error);
    event.sender.send('mqtt-publish-connect-result', {
      success: false,
      error: (error as Error).toString()
    });
  }
});

// 处理MQTT广播断开连接
ipcMain.on('mqtt-publish-disconnect', (event) => {
  console.log('收到MQTT广播断开连接请求');
  
  if (mqttPublisher) {
    try {
      // 清除定时器
      if (mqttPublisherInterval) {
        clearInterval(mqttPublisherInterval);
        mqttPublisherInterval = null;
      }
      
      // 断开MQTT客户端连接
      mqttPublisher.end(true);
      console.log('MQTT发布者客户端已断开连接');
    } catch (err) {
      console.error('断开MQTT发布者连接时出错:', err);
    } finally {
      mqttPublisher = null;
    }
  } else {
    console.log('没有活动的MQTT发布者客户端连接');
  }
});

// RTSP流处理功能

// 检查FFmpeg是否可用
function checkFFmpegAvailable(): Promise<boolean> {
  return new Promise((resolve) => {
    const spawnOptions = process.platform === 'win32' ? { shell: true } : {};
    const ffmpegTest = spawn('ffmpeg', ['-version'], spawnOptions);
    
    let output = '';
    ffmpegTest.stdout?.on('data', (data) => {
      output += data.toString();
    });
    
    ffmpegTest.on('close', (code) => {
      if (code === 0 && output.includes('ffmpeg version')) {
        resolve(true);
      } else {
        resolve(false);
      }
    });
    
    ffmpegTest.on('error', () => {
      resolve(false);
    });
  });
}

// 找到可用端口
function findAvailablePort(startPort: number): Promise<number> {
  return new Promise((resolve, reject) => {
    const server = http.createServer();
    
    server.listen(startPort, () => {
      const port = (server.address() as any)?.port;
      server.close(() => {
        resolve(port);
      });
    });
    
    server.on('error', () => {
      findAvailablePort(startPort + 1).then(resolve).catch(reject);
    });
  });
}

// 修改RTSP流处理相关的IPC处理器
ipcMain.handle('start-rtsp-stream', async (event, params: { rtspUrl: string, config: any }) => {
  const { rtspUrl, config = {} } = params;
  
  // 设置默认配置
  const finalConfig = {
    enableAudio: false,
    quality: 'medium',
    protocol: 'tcp',
    bufferSize: '1M',
    ...config
  };
  try {
    console.log('启动RTSP流转换:', rtspUrl);
    console.log('配置参数:', finalConfig);
    
    // 停止之前的流
    if (ffmpegProcess) {
      ffmpegProcess.kill();
      ffmpegProcess = null;
    }
    
    if (httpServer) {
      httpServer.close();
      httpServer = null;
    }
    
    // 检查FFmpeg是否可用
    try {
      const spawnOptions = process.platform === 'win32' ? { shell: true } : {};
      const testProcess = spawn('ffmpeg', ['-version'], spawnOptions);
      await new Promise((resolve, reject) => {
        let output = '';
        testProcess.stdout?.on('data', (data) => {
          output += data.toString();
        });
        testProcess.stderr?.on('data', (data) => {
          output += data.toString();
        });
        testProcess.on('close', (code) => {
          console.log('FFmpeg版本检查输出:', output);
          if (code === 0 && output.includes('ffmpeg version')) {
            resolve(true);
          } else {
            reject(new Error(`FFmpeg不可用，退出码: ${code}`));
          }
        });
        testProcess.on('error', (error) => {
          reject(new Error(`FFmpeg进程错误: ${error.message}`));
        });
      });
    } catch (error) {
      throw new Error(`FFmpeg不可用，请确保已安装FFmpeg并添加到系统PATH。错误: ${error instanceof Error ? error.message : String(error)}`);
    }
    
    // 获取正确的临时目录
    let outputDir: string;
    if (app.isPackaged) {
      // 生产环境：使用用户数据目录下的临时文件夹
      outputDir = path.join(app.getPath('userData'), 'rtsp_temp');
    } else {
      // 开发环境：使用public目录
      outputDir = process.env.VITE_PUBLIC || path.join(process.cwd(), 'public');
    }
    
    // 确保输出目录存在
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    console.log('HLS输出目录:', outputDir);
    
    // 清理旧的HLS文件
    try {
      const files = fs.readdirSync(outputDir);
      files.forEach(file => {
        if (file.startsWith('stream') && (file.endsWith('.m3u8') || file.endsWith('.ts'))) {
          fs.unlinkSync(path.join(outputDir, file));
        }
      });
    } catch (error) {
      console.warn('清理旧文件失败:', error);
    }
    
    // 构建FFmpeg命令 - 转换为HLS格式实现低延迟流
    const ffmpegArgs = [];
    
    // 处理协议设置 - 必须在-i参数之前
    if (finalConfig.protocol === 'tcp') {
      ffmpegArgs.push('-rtsp_transport', 'tcp');
    } else if (finalConfig.protocol === 'udp') {
      ffmpegArgs.push('-rtsp_transport', 'udp');
    }
    
    // 添加输入和输出参数
    ffmpegArgs.push(
      '-i', rtspUrl,
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-tune', 'zerolatency',
      '-crf', '23',
      '-maxrate', '2000k',
      '-bufsize', '1M',
      '-g', '20',
      '-profile:v', 'baseline',
      '-level', '3.1',
      '-pix_fmt', 'yuv420p',
      '-f', 'hls',
      '-hls_time', '1',
      '-hls_list_size', '3',
      '-hls_flags', 'delete_segments+independent_segments',
      '-hls_allow_cache', '0',
      '-hls_segment_type', 'mpegts',
      '-hls_segment_filename', path.join(outputDir, 'stream_%03d.ts'),
      path.join(outputDir, 'stream.m3u8')
    );
    
    // 处理音频设置
    if (!finalConfig.enableAudio) {
      ffmpegArgs.push('-an');
    }
    
    console.log('FFmpeg命令:', 'ffmpeg', ffmpegArgs.join(' '));
    console.log('输出目录权限检查:', outputDir);
    console.log('当前工作目录:', process.cwd());
    console.log('平台:', process.platform);
    console.log('环境变量 VITE_PUBLIC:', process.env.VITE_PUBLIC);
    console.log('App isPackaged:', app.isPackaged);
    
    // 检查输出目录权限
    try {
      const testFile = path.join(outputDir, 'test_write_before_ffmpeg.tmp');
      fs.writeFileSync(testFile, 'test');
      fs.unlinkSync(testFile);
      console.log('输出目录写入权限正常');
    } catch (error) {
      throw new Error(`输出目录无法写入: ${outputDir}, 错误: ${error}`);
    }
    
    // 启动FFmpeg进程
    const spawnOptions = process.platform === 'win32' ? { shell: true } : {};
    console.log('启动FFmpeg进程，选项:', spawnOptions);
    
    ffmpegProcess = spawn('ffmpeg', ffmpegArgs, spawnOptions);
    
    let ffmpegStdout = '';
    let ffmpegStderr = '';
    let processStarted = false;
    
    ffmpegProcess.stdout?.on('data', (data) => {
      const output = data.toString();
      ffmpegStdout += output;
      console.log('FFmpeg stdout:', output);
    });
    
    ffmpegProcess.stderr?.on('data', (data) => {
      const output = data.toString();
      ffmpegStderr += output;
      console.log('FFmpeg stderr:', output);
      
      // 检查是否成功开始处理
      if (!processStarted && (output.includes('Stream mapping:') || output.includes('Press [q] to stop'))) {
        processStarted = true;
        console.log('FFmpeg开始处理流');
      }
    });
    
    ffmpegProcess.on('close', (code) => {
      console.log('FFmpeg进程退出，代码:', code);
      console.log('FFmpeg最终输出 (stderr):', ffmpegStderr);
      console.log('FFmpeg最终输出 (stdout):', ffmpegStdout);
    });
    
    ffmpegProcess.on('error', (error) => {
      console.error('FFmpeg进程错误:', error);
      throw new Error(`FFmpeg进程启动失败: ${error.message}`);
    });
    
    // 启动HTTP服务器
    const port = 8080;
    currentStreamPort = port;
    
    httpServer = http.createServer((req, res) => {
      const urlPath = req.url || '';
      let filePath = '';
      
      if (urlPath === '/stream.m3u8') {
        filePath = path.join(outputDir, 'stream.m3u8');
        res.setHeader('Content-Type', 'application/vnd.apple.mpegurl');
      } else if (urlPath.match(/^\/stream_\d+\.ts$/)) {
        filePath = path.join(outputDir, path.basename(urlPath));
        res.setHeader('Content-Type', 'video/mp2t');
      } else {
        res.writeHead(404);
        res.end('Not Found');
        return;
      }
      
      // 设置CORS和缓存控制头
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
      res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
      res.setHeader('Pragma', 'no-cache');
      res.setHeader('Expires', '0');
      
      if (fs.existsSync(filePath)) {
        const fileStream = fs.createReadStream(filePath);
        fileStream.pipe(res);
        fileStream.on('error', () => {
          res.writeHead(500);
          res.end('File read error');
        });
      } else {
        res.writeHead(404);
        res.end('File not found');
      }
    });
    
    await new Promise<void>((resolve, reject) => {
      httpServer!.listen(port, () => {
        console.log('HTTP服务器启动在端口', port);
        resolve();
      });
      httpServer!.on('error', reject);
    });
    
    // 等待FFmpeg生成HLS流文件
    const m3u8Path = path.join(outputDir, 'stream.m3u8');
    let attempts = 0;
    const maxAttempts = 30; // 增加到30秒等待时间
    
    console.log('等待HLS文件生成，目标路径:', m3u8Path);
    
    // 等待FFmpeg开始处理
    let waitForStart = 0;
    while (waitForStart < 10 && !processStarted) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      waitForStart++;
      
      if (!ffmpegProcess || ffmpegProcess.killed) {
        throw new Error(`FFmpeg进程启动失败或意外终止。错误输出: ${ffmpegStderr}`);
      }
    }
    
    if (!processStarted) {
      throw new Error(`FFmpeg未能在10秒内开始处理RTSP流。可能的原因: RTSP地址无效、网络问题或认证失败。FFmpeg输出: ${ffmpegStderr}`);
    }
    
    console.log('FFmpeg已开始处理，等待HLS文件生成...');
    
    while (attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      attempts++;
      
      console.log(`等待HLS生成，尝试 ${attempts}/${maxAttempts}`);
      
      if (fs.existsSync(m3u8Path)) {
        // 检查是否有至少一个TS分片文件
        const files = fs.readdirSync(outputDir);
        const tsFiles = files.filter(file => file.startsWith('stream_') && file.endsWith('.ts'));
        console.log(`找到 m3u8 文件，TS分片数量: ${tsFiles.length}`);
        
        if (tsFiles.length > 0) {
          console.log(`HLS流已生成，分片数量: ${tsFiles.length}`);
          break;
        }
      }
      
      // 检查FFmpeg进程是否还在运行
      if (!ffmpegProcess || ffmpegProcess.killed) {
        throw new Error(`FFmpeg进程意外终止。最终输出: ${ffmpegStderr}`);
      }
      
      if (attempts >= maxAttempts) {
        // 提供更详细的错误信息
        const dirContents = fs.existsSync(outputDir) ? fs.readdirSync(outputDir) : [];
        throw new Error(`FFmpeg生成HLS流超时。输出目录: ${outputDir}，目录内容: ${dirContents.join(', ')}。FFmpeg输出: ${ffmpegStderr}`);
      }
    }
    
    return {
      success: true,
      streamUrl: `http://localhost:${port}/stream.m3u8`,
      message: '流转换成功启动'
    };
    
  } catch (error) {
    console.error('启动RTSP流时出错:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    };
  }
});

ipcMain.handle('stop-rtsp-stream', async () => {
  try {
    console.log('手动停止RTSP流');
    cleanupResources();
    return { success: true };
  } catch (error) {
    console.error('停止RTSP流时出错:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    };
  }
});

// 测试RTSP连接
ipcMain.handle('test-rtsp-connection', async (event, params) => {
  const { rtspUrl, timeout = 10000 } = params;
  
  try {
    console.log('测试RTSP连接:', rtspUrl);
    
    // 检查FFmpeg是否可用
    const ffmpegAvailable = await checkFFmpegAvailable();
    if (!ffmpegAvailable) {
      return JSON.parse(JSON.stringify({
        success: false,
        error: 'FFmpeg未安装或不可用'
      }));
    }
    
    return new Promise((resolve) => {
      const testArgs = [
        '-i', rtspUrl,
        '-t', '1',
        '-f', 'null',
        '-'
      ];
      
      const spawnOptions = process.platform === 'win32' ? { shell: true } : {};
      const testProcess = spawn('ffmpeg', testArgs, spawnOptions);
      let errorOutput = '';
      
      testProcess.stderr?.on('data', (data) => {
        errorOutput += data.toString();
      });
      
      const timeoutId = setTimeout(() => {
        testProcess.kill();
        resolve(JSON.parse(JSON.stringify({
          success: false,
          error: '连接超时'
        })));
      }, timeout);
      
      testProcess.on('close', (code) => {
        clearTimeout(timeoutId);
        
        try {
          if (code === 0 || errorOutput.includes('Stream #0')) {
            // 尝试解析视频信息
            const resolutionMatch = errorOutput.match(/(\d+)x(\d+)/);
            const codecMatch = errorOutput.match(/Video: (\w+)/);
            
            const resolution = resolutionMatch ? `${resolutionMatch[1]}x${resolutionMatch[2]}` : '未知';
            const codec = codecMatch ? codecMatch[1] : '未知';
            
            resolve(JSON.parse(JSON.stringify({
              success: true,
              info: {
                resolution: resolution,
                codec: codec
              }
            })));
          } else {
            resolve(JSON.parse(JSON.stringify({
              success: false,
              error: '无法连接到RTSP流'
            })));
          }
        } catch (parseError) {
          resolve(JSON.parse(JSON.stringify({
            success: false,
            error: '解析测试结果时出错'
          })));
        }
      });
      
      testProcess.on('error', () => {
        clearTimeout(timeoutId);
        resolve(JSON.parse(JSON.stringify({
          success: false,
          error: 'FFmpeg进程启动失败'
        })));
      });
    });
    
  } catch (error) {
    console.error('测试RTSP连接时出错:', error);
    return JSON.parse(JSON.stringify({
      success: false,
      error: '测试连接时发生错误'
    }));
  }
});
