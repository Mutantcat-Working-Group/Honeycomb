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

app.on('window-all-closed', () => {
  win = null
  if (process.platform !== 'darwin') app.quit()
})

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
    const ffmpegTest = spawn('ffmpeg', ['-version']);
    
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

// 启动RTSP流转换
ipcMain.handle('start-rtsp-stream', async (event, { rtspUrl, config }) => {
  try {
    console.log('启动RTSP流转换:', rtspUrl);
    
    // 检查FFmpeg是否可用
    const ffmpegAvailable = await checkFFmpegAvailable();
    if (!ffmpegAvailable) {
      return {
        success: false,
        error: 'FFmpeg未安装或不可用。请安装FFmpeg并确保其在系统PATH中。'
      };
    }
    
    // 停止现有的流
    if (ffmpegProcess) {
      ffmpegProcess.kill();
      ffmpegProcess = null;
    }
    
    if (httpServer) {
      httpServer.close();
      httpServer = null;
    }
    
    // 找到可用端口
    currentStreamPort = await findAvailablePort(8080);
    
    // 构建FFmpeg命令 - 转换为HLS格式实现低延迟流
    const ffmpegArgs = [
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
      '-hls_segment_filename', path.join(process.env.VITE_PUBLIC || '', 'stream_%03d.ts'),
      path.join(process.env.VITE_PUBLIC || '', 'stream.m3u8')
    ];
    
    // 添加音频处理
    if (config.enableAudio) {
      ffmpegArgs.push('-c:a', 'aac', '-b:a', '128k');
    } else {
      ffmpegArgs.push('-an');
    }
    
    // 设置传输协议
    if (config.protocol === 'tcp') {
      ffmpegArgs.unshift('-rtsp_transport', 'tcp');
    }
    
    console.log('FFmpeg命令:', 'ffmpeg', ffmpegArgs.join(' '));
    
    // 启动FFmpeg进程
    ffmpegProcess = spawn('ffmpeg', ffmpegArgs);
    
    let ffmpegOutput = '';
    
    ffmpegProcess.stderr?.on('data', (data) => {
      const output = data.toString();
      ffmpegOutput += output;
      console.log('FFmpeg输出:', output);
    });
    
    ffmpegProcess.on('close', (code) => {
      console.log(`FFmpeg进程退出，代码: ${code}`);
      if (code !== 0) {
        console.error('FFmpeg错误输出:', ffmpegOutput);
      }
    });
    
    ffmpegProcess.on('error', (err) => {
      console.error('FFmpeg进程错误:', err);
    });
    
    // 启动HTTP服务器来提供HLS文件
    const publicDir = process.env.VITE_PUBLIC || '';
    
    httpServer = http.createServer((req, res) => {
      const urlPath = req.url || '';
      let filePath = '';
      
      if (urlPath === '/stream.m3u8') {
        filePath = path.join(publicDir, 'stream.m3u8');
        res.setHeader('Content-Type', 'application/vnd.apple.mpegurl');
      } else if (urlPath.match(/^\/stream_\d+\.ts$/)) {
        filePath = path.join(publicDir, path.basename(urlPath));
        res.setHeader('Content-Type', 'video/mp2t');
      } else {
        res.writeHead(404);
        res.end('Not Found');
        return;
      }
      
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
    
    httpServer.listen(currentStreamPort, () => {
      console.log(`HTTP服务器启动在端口 ${currentStreamPort}`);
    });
    
    // 等待FFmpeg生成HLS流文件
    const m3u8Path = path.join(publicDir, 'stream.m3u8');
    let attempts = 0;
    const maxAttempts = 15; // 最多等待15秒
    
    while (attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      attempts++;
      
      if (fs.existsSync(m3u8Path)) {
        // 检查是否有至少一个TS分片文件
        const files = fs.readdirSync(publicDir);
        const tsFiles = files.filter(file => file.startsWith('stream_') && file.endsWith('.ts'));
        if (tsFiles.length > 0) {
          console.log(`HLS流已生成，分片数量: ${tsFiles.length}`);
          break;
        }
      }
      
      if (attempts >= maxAttempts) {
        throw new Error('FFmpeg生成HLS流超时');
      }
    }
    
    return {
      success: true,
      streamUrl: `http://localhost:${currentStreamPort}/stream.m3u8`
    };
    
  } catch (error) {
    console.error('启动RTSP流时出错:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    };
  }
});

// 停止RTSP流
ipcMain.handle('stop-rtsp-stream', async (event) => {
  try {
    console.log('停止RTSP流');
    
    if (ffmpegProcess) {
      ffmpegProcess.kill('SIGTERM');
      
      // 如果优雅关闭失败，强制关闭
      setTimeout(() => {
        if (ffmpegProcess && !ffmpegProcess.killed) {
          ffmpegProcess.kill('SIGKILL');
        }
      }, 5000);
      
      ffmpegProcess = null;
    }
    
    if (httpServer) {
      httpServer.close();
      httpServer = null;
    }
    
    // 清理HLS文件
    try {
      const publicDir = process.env.VITE_PUBLIC || '';
      const m3u8Path = path.join(publicDir, 'stream.m3u8');
      
      if (fs.existsSync(m3u8Path)) {
        fs.unlinkSync(m3u8Path);
      }
      
      // 删除TS分片文件
      const files = fs.readdirSync(publicDir);
      files.forEach(file => {
        if (file.startsWith('stream_') && file.endsWith('.ts')) {
          const filePath = path.join(publicDir, file);
          fs.unlinkSync(filePath);
        }
      });
    } catch (cleanupError) {
      console.error('清理HLS文件时出错:', cleanupError);
    }
    
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
      
      const testProcess = spawn('ffmpeg', testArgs);
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

// 应用退出时清理资源
app.on('before-quit', () => {
  if (ffmpegProcess) {
    ffmpegProcess.kill();
  }
  if (httpServer) {
    httpServer.close();
  }
});
