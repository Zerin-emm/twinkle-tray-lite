# Twinkle Tray Lite

基于 [Twinkle Tray](https://github.com/xanderfrangos/twinkle-tray) 1.17.2 的精简版，版本 **1.0.0**。

保留核心的显示器亮度控制（DDC/CI）、托盘面板、热键、计划调光、多显示器支持；删除了更新检查、遥测、UDP 控制、Apple Studio Display 支持等非必要功能。

## 与原版的差异

| 类别 | 原版 1.17.2 | 本版 1.0.0 |
|---|---|---|
| 自动更新 | 检查 GitHub Releases、下载安装包 | 已删除（含 UI） |
| 遥测 | GA4 匿名统计 | 已删除（含 UI） |
| UDP 远程控制 | 局域网 UDP 命令接口 | 已删除（含 UI） |
| Apple Studio Display | `studio-display-control` 支持 | 已删除（含 UI） |
| 旧版设置迁移 | v1.15 / v1.16 迁移逻辑 | 已删除，设置格式固定为 v1.17.2 |
| 托盘图标主题 | 依赖注册表读取 | 改为 `nativeTheme` + 双重建 + 启动预热，解决任务栏固定区不重绘 |
| 版本号 | 1.17.2 | 1.0.0 |
| AppID | `com.xanderfrangos.twinkle-tray` | `com.zerin.twinkle-tray-lite` |
| 关于页 | 无 | 新增（版本、GitHub、许可证、原作者） |
| debug 页 | 英文硬编码 | 全部走 i18n（中文 / 英文） |
| 平衡亮度页 | `Input` / `Output` / `Calibration Point` 英文 | 已汉化 |

## 构建

```powershell
npm install
npm run parcel-build
npx electron-builder --dir
```

产物：`dist\win-unpacked\Twinkle Tray.exe`

安装包（需 Inno Setup 6）：

```powershell
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" resources\installer.iss
```

产物：`resources\Output\TwinkleTrayLite-Setup-1.0.0-x64.exe`

## 构建环境说明

- Node.js 24、npm 11。
- native 模块需要 VS2022 BuildTools（VS2026 的 MSVC 14.52 移除了 `<experimental/coroutine>`，会导致 `windows-accent-colors` 编译失败）。
- 国内网络可用阿里镜像：`registry.npmmirror.com`；Electron 二进制用 `ELECTRON_MIRROR`。
- `electron-builder` 通过 `electronDist` 指向本地 `node_modules/electron/dist`，避免从 GitHub 下载。
- 源码里的 `.npmrc` 已指向阿里 registry。

## 目录结构

```
src/                    Electron 主进程与 React 设置界面
  electron.js           主进程：托盘、窗口、设置、DDC/CI 调度
  Monitors.js           显示器枚举与亮度读写（独立子进程）
  components/           React 设置窗口与亮度面板
  localization/         多语言（en / zh_Hans 等）
resources/
  installer.iss         Inno Setup 安装脚本
  nsis/                 原版 NSIS 脚本（未使用）
dist/win-unpacked/      electron-builder --dir 产物
```

## 许可

MIT License。原项目版权归 [Xander Frangos](https://github.com/xanderfrangos) 所有，本衍生版保留原始许可与署名。
