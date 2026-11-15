<div align=center>
<img src="https://s2.loli.net/2024/03/06/gTFN1fcst8QGeaZ.jpg" style="width:100px;" width="100"/>
<h2>蜂巢工具箱</h2>
</div>

### 一、产品概述

- 一款能离线使用在线工具功能的应用，工具箱封装了各种在线工具的离线版本。
- 覆盖编码、字符、开发、加密、随机、网络、硬件、AI、游戏开发九大类上百个常用工具，无需联网、无广告、即开即用。
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

#### 游戏开发
- 精灵图播放
- 黑白透明遮罩

### 三、安装与下载

当前版本 **1.1.20261113**。从 [Releases](https://github.com/Mutantcat-Working-Group/Honeycomb/releases) 下载对应平台的安装包：

| 平台 | 架构 | 安装包 |
| --- | --- | --- |
| Windows | x64 | `Honeycomb-<版本>-windows-amd64.exe`（NSIS 安装程序） |
| macOS | Apple Silicon | `Honeycomb-<版本>-macOS-arm64.dmg` |
| macOS | Intel | `Honeycomb-<版本>-macOS-x86_64.dmg` |
| Linux | x64 | `Honeycomb-<版本>-linux-amd64.AppImage` |
| Linux | arm64 | `Honeycomb-<版本>-linux-arm64.AppImage` |

每个 Release 还会附带 `checksums.txt`（SHA-256）、`checksums-md5.txt`（MD5）与 `checksums-sha1.txt`（SHA-1）。校验方式：

```sh
# 下载安装包与 checksums.txt 到同一目录后
sha256sum --ignore-missing -c checksums.txt
```

首次启动需要注意：

- **macOS**：应用与 DMG 使用 ad-hoc 签名，不是 Apple 公证，首次启动可能需在「系统设置 → 隐私与安全性」中允许。
- **Windows**：安装或首次运行时可能出现 SmartScreen 提示，需选择「仍要运行」。
- **Linux**：AppImage 需先加执行权限：`chmod +x Honeycomb-<版本>-linux-<架构>.AppImage`。

#### 升级

应用内的「关于」页可检查更新：检查结果来自 `version.mutantcat.org`（失败时回退到 `.com.cn` 域名），只读取一个版本描述文件，不上报任何使用数据；检查由手动点击触发。也可以直接下载上面表格中更新的安装包覆盖安装，配置与数据不受影响。

### 四、快速上手

1. 安装并启动蜂巢工具箱，左侧选择工具分类。
2. 在分类中找到需要的工具，右侧即为工具界面，所有工具本地离线运行。
3. 涉及文件操作的工具（如文件转 Base64、文件校验）直接选择本地文件即可。

### 五、离线使用

蜂巢工具箱的工具默认全部本地运行：编解码、格式转换、加解密、随机生成、文件校验、取色、正则、SQL/JSON 处理等都不发出任何网络请求，断网、内网、隔离环境中均可正常使用。

需要联网的只有三类，且都是你主动填了地址或点击之后才发生：

| 工具 | 用途 | 断网时 |
| --- | --- | --- |
| WebSocket 测试、RESTful 测试 | 需要你填写目标地址 | 仅在你填了地址并发起请求时才联网 |
| MQTT 监听 / 广播、RTSP 预览、DNS 查询、Fake API、文件夹映射 | 连接你指定的本地或远程地址 | 连本地地址可用；连不通时报错，不影响其他工具 |
| OpenAI API 测试 | 连接你填写的 API 地址与密钥 | 仅在填写并测试时联网 |

除此之外，AI 提示词、Agent 协同、对照降 AI、上下文飘窗等 AI 工具只在你提供的文本上本地处理；「机器学习手书」等参考表为内置静态数据。

### 六、从源码构建

依赖：Qt 6.8（模块 Quick、QuickControls2、Widgets、WebSockets、Multimedia、Network、SerialPort、WebEngineQuick、WebChannel、DBus）、CMake ≥ 3.16、Conan 2，以及 Qt WebEngine 所需的系统库。

Linux 以 Debian/Ubuntu 为例：

```sh
sudo apt-get install -y build-essential pkg-config libgl1-mesa-dev libdbus-1-dev libssl-dev libatspi2.0-dev
python -m pip install "conan>=2,<3"
conan profile detect --force
conan install . --output-folder=build/conan-deps --build=missing -s build_type=Release
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="$PWD/build/conan-deps/conan_toolchain.cmake" \
  -DCMAKE_PREFIX_PATH="$PWD/build/conan-deps;$QT_ROOT_DIR"
cmake --build build --parallel
```

Windows 上若源码含非 ASCII 字符，建议使用仓库内的 `conan_profile_msvc_utf8`（为 MSVC 追加 `/utf-8`）。

跑测试：

```sh
ctest --test-dir build --output-on-failure
```

其中 `ReleaseMetadataTest` 与 `ReleaseAssetNameTest` 会校验版本号在 CMake、NSIS 脚本、i18n 与「关于」页之间保持一致，并检查发布产物命名不会踩到 GitHub 剥除非 ASCII 字符的问题。

版本号唯一事实来源是 `CMakeLists.txt` 中的 `project(... VERSION ...)`，安装脚本、i18n 与「关于」页均由其派生，升级只改这一处（Windows 的 `sdk/NSIS/Honeycomb.nsi` 中另有一份默认值，发布流水线以 CMake 的版本为准传入）。

### 七、版本与发布

版本号格式为 `主版本.次版本.发布日期`，例如 `1.1.20261113`（2026 年 11 月 13 日发布）。主版本与次版本表示功能层级，日期部分即发布日，因此同一个日期连发多个版本时依次往后取日期（`1.1.20261113`、`1.1.20261114`），不使用 `-1`、`-2` 之类的后缀。

- 打标签 `v<版本号>`（如 `v1.1.20261113`）推送后，由 GitHub Actions 自动完成三平台打包与 Release 发布。
- Release 资产一律使用 ASCII 名称 `Honeycomb-<版本>-<系统>-<架构>.<扩展名>`：GitHub 上传资产时会静默剥掉文件名中的非 ASCII 字符，中文名称只保留在 DMG 内部的 `蜂巢工具箱.app` 与卷标上，用户拖到「应用程序」后看到的仍是「蜂巢工具箱」。
- `.github/workflows/release.yml` 的「Collect installer assets」与「Generate checksums」两处都有非 ASCII 名称守卫，产物名不合规会在构建期直接失败，不会带着坏名字发上网。
