import { app, BrowserWindow, shell, ipcMain, Menu, desktopCapturer, screen } from 'electron'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
import os from 'node:os'

const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))

// 导入MQTT模块以便在主进程中测试
let mqtt;
try {
  mqtt = require('mqtt');
} catch (error) {
  console.error('无法导入MQTT模块:', error);
}

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
