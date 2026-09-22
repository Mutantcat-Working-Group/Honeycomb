<div align=center>
<img src="https://s2.loli.net/2024/03/06/gTFN1fcst8QGeaZ.jpg" style="width:100px;" width="100"/>
<h2>蜂巢工具箱</h2>
</div>

### 一、产品概述

- 一款能离线使用在线工具功能的应用，工具箱封装了各种在线工具的离线版本。
- 覆盖编码、字符、开发、加密、随机、网络、硬件、AI 八大类上百个常用工具，无需联网、无广告、即开即用。
- 已转为 Qt 实现，轻量、快速、稳定、兼容。
- 软件功能还在不断拓展，软件版本会按需打包。
- 三平台安装包由 GitHub Actions 在版本标签推送后自动构建：Windows 输出 NSIS 安装程序，macOS 输出 ad-hoc 签名的 DMG（Apple Silicon 与 Intel 各一个），Linux 输出 amd64 与 arm64 的 AppImage。

### 二、功能说明

#### 编码工具
- 条形码生成
- 批量条形码生成
- 二维码生成
- 识别二维码
- 文件转Base64
- Base64图片预览
- 图片压缩
- 时间戳转换
- 颜色值转换
- 中文转Unicode
- 中文转UTF8
- ASCII码表
- 进制转换
- 补码转换

#### 字符工具
- 字符串去空格
- 字符串去回车
- 去空格回车
- 去除分隔空格
- 替换与转义
- 字数统计
- 文本对比
- 正则测试
- 大小写转换

#### 开发工具
- JSON格式化
- JSON转YAML
- 屏幕取色器
- 颜色选择器
- 常用HTML颜色
- 回车转br标签
- 常用浏览器UA
- PATH查看器
- Docker命令速查
- Docker Compose转换
- SQL格式化
- 快捷LDD
- 进程管理
- 端口管理
- Go交叉编译
- htaccess转nginx
- Android权限
- Harmony权限
- 权限矩阵（UNIX chmod）
- Cron表达式解析
- HTTP状态码
- Content-Type
- HTML特殊字符

#### 加密工具
- Windows加密
- MD5加密
- 文件校验
- 文件MD5
- 文件SHA1
- 文件SHA256
- 文件信息查看
- SHA1加密
- SHA256加密
- 密码强度分析
- 国密加解密
- AES加解密

#### 随机工具
- 随机数字
- 随机字符串
- 随机混合串
- 随机MAC地址
- 随机IPv4地址
- 随机IPv6地址
- 生成UUID

#### 网络工具
- WebSocket测试
- RESTful测试
- MQTT监听
- MQTT广播
- DNS查询
- 子网掩码计算器
- RTSP预览
- 文件夹映射
- Fake API

#### 硬件工具
- 寄存器寻址范围
- 电阻阻值计算
- 串口调试
- RISC-V指令集模块
- 通用寄存器速查
- 汇编速查

#### AI工具
- AI提示词
- Agent协同
- 对照降AI
- 上下文飘窗（支持预设插入）
- OpenAI API测试
- NN对照表
- Layer对照表
- 机器学习手书
- 网页组件选取
- 窗口组件选取

### 三、安装与下载

从 [Releases](https://github.com/Mutantcat-Working-Group/Honeycomb/releases) 下载对应平台的安装包：

| 平台 | 架构 | 安装包 |
| --- | --- | --- |
| Windows | x64 | `Honeycomb-<版本>-windows-amd64.exe`（NSIS） |
| macOS | Apple Silicon | `Honeycomb-<版本>-macOS-arm64.dmg` |
| macOS | Intel | `Honeycomb-<版本>-macOS-x86_64.dmg` |
| Linux | x64 | `Honeycomb-<版本>-linux-amd64.AppImage` |
| Linux | arm64 | `Honeycomb-<版本>-linux-arm64.AppImage` |

macOS 应用及 DMG 使用 ad-hoc 签名，不是 Apple 公证，首次启动可能需在系统设置中允许；Windows 可能出现 SmartScreen 提示。下载后可使用 Release 中的 `checksums.txt`、`checksums-md5.txt` 与 `checksums-sha1.txt` 校验安装包。

### 四、快速上手

1. 安装并启动蜂巢工具箱，左侧选择工具分类。
2. 在分类中找到需要的工具，右侧即为工具界面，所有工具本地离线运行。
3. 涉及文件操作的工具（如文件转 Base64、文件校验）直接选择本地文件即可。

### 五、从源码构建

项目使用 CMake 与 Qt 6.8 构建：

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

版本号唯一事实来源是 `CMakeLists.txt` 中的 `project(... VERSION ...)`，安装脚本、i18n 与「关于」页均由其派生，升级只改这一处。

### 六、版本与发布

版本号格式为 `主版本.次版本.发布日期`，例如 `1.0.20260924`（2026 年 9 月 24 日发布）。

- 发新版本时直接使用当天日期，CI 重跑或连发多个版本时依次往后取日期（`1.0.20260923`、`1.0.20260924`），不要使用 `-1`、`-2` 之类的后缀。
- 打标签 `v<版本号>`（如 `v1.0.20260924`）推送后，由 GitHub Actions 自动完成三平台打包与 Release 发布。
- Release 资产一律使用 ASCII 名称 `Honeycomb-<版本>-<系统>-<架构>.<扩展名>`：GitHub 上传资产时会静默剥掉文件名中的非 ASCII 字符，中文名称只保留在 DMG 内部的 `蜂巢工具箱.app` 与卷标上，用户拖到「应用程序」后看到的仍是「蜂巢工具箱」。
- `.github/workflows/release.yml` 的「Collect installer assets」与「Generate checksums」两处都有非 ASCII 名称守卫，产物名不合规会在构建期直接失败，不会带着坏名字发上网。
