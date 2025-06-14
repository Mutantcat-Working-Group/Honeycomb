import { app, BrowserWindow, shell, ipcMain, Menu, desktopCapturer, screen } from 'electron'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
import os from 'node:os'

const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))

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
