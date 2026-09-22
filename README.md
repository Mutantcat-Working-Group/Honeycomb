<div align="center">
<img src="https://s2.loli.net/2024/03/06/gTFN1fcst8QGeaZ.jpg" style="width:100px;" width="100"/>
<h2>蜂巢工具箱</h2>
</div>


### 一、功能简介

- 一款能离线使用在线工具功能的应用
- 工具箱封装了各种在线工具的离线版本
- 软件功能还在不断拓展，软件版本会按需打包
- 已转为Qt实现，轻量、快速、稳定、兼容

### 二、功能列表

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

### 三、版本号规则

版本号格式为 `主版本.次版本.发布日期`，例如 `1.0.20260922`（2026 年 9 月 22 日发布）。

- 唯一事实来源是 `CMakeLists.txt` 中的 `project(... VERSION ...)`，安装脚本、i18n、「关于」页均由其派生，升级时只改这一处。
- 发新版本时直接使用当天日期，CI 重跑或连发多个版本时依次往后取日期（`1.0.20260923`、`1.0.20260924`），不要使用 `-1`、`-2` 之类的后缀。
- 打标签 `v<版本号>`（如 `v1.0.20260924`）推送后，由 GitHub Actions 自动完成三平台打包与 Release 发布。

### 四、Release 资产命名约束

GitHub 上传 Release 资产时会把文件名里的非 ASCII 字符整体剥掉，且不会报错：`蜂巢工具箱-1.0.20260924-macOS-arm64.dmg` 会静默变成 `-1.0.20260924-macOS-arm64.dmg`（以连字符开头，甚至会让后续 shell 命令把它当成参数）。这是服务端行为，换 `gh` 版本、改用 `gh api` 显式传 `name` 都无法绕过。

因此 CI 一律发布 ASCII 资产名 `Honeycomb-<版本>-<系统>-<架构>.<扩展名>`，中文名称只保留在 DMG 内部的 `蜂巢工具箱.app` 与卷标上——用户拖到「应用程序」后看到的仍是「蜂巢工具箱」。

`.github/workflows/release.yml` 的「Collect installer assets」与「Generate checksums」两处都有非 ASCII 名称守卫，一旦产物名不合规会在构建期直接失败，不会带着坏名字发上网。
