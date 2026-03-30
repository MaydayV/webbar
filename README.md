# WebBar

<p align="center">
  <img src="https://raw.githubusercontent.com/MaydayV/webbar/main/Assets/app_icon.svg" alt="WebBar Icon" width="96" height="96" />
</p>

<p align="center">
  一个面向 macOS 的菜单栏网页工作区。
  <br />
  为常用网站提供独立状态栏入口，支持默认浏览器直达或内嵌弹窗打开。
</p>

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-000000?style=for-the-badge&logo=apple" />
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" />
  <img alt="SwiftUI" src="https://img.shields.io/badge/SwiftUI-UI-0A84FF?style=for-the-badge&logo=swift" />
  <img alt="AppKit" src="https://img.shields.io/badge/AppKit-menu%20bar-111111?style=for-the-badge&logo=apple" />
  <img alt="WebKit" src="https://img.shields.io/badge/WebKit-WKWebView-4EAA25?style=for-the-badge&logo=safari" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge" />
</p>

## 目录

- [项目简介](#项目简介)
- [核心能力](#核心能力)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [使用方式](#使用方式)
- [开发命令](#开发命令)
- [自动构建与 Release](#自动构建与-release)
- [未签名安装说明](#未签名安装说明)
- [贡献指南](#贡献指南)
- [License](#license)

## 项目简介

WebBar 是一个轻量级 `macOS` 菜单栏应用，用来把高频网页变成独立入口。

它适合这些场景：

- 把 `ChatGPT`、`DeepSeek`、`豆包`、`Gemini` 等网页服务常驻到状态栏
- 点击图标后直接在默认浏览器打开
- 或者以内嵌弹窗打开，并继续保留网页登录状态
- 为每个站点配置独立 emoji 图标、打开方式和重新打开策略

## 核心能力

- 独立状态栏图标：每个网址一个入口
- 双打开模式：`默认浏览器` / `内嵌弹窗`
- 登录状态隔离：每个站点单独保存 Cookie 与网页状态
- 重新打开策略：`恢复上次页面` / `每次打开首页`
- 开机启动：可选启用
- 自定义图标：使用 emoji 作为站点图标
- 原生实现：基于 `AppKit + SwiftUI + WebKit`

## 技术栈

- `Swift 6`
- `SwiftUI`
- `AppKit`
- `WebKit / WKWebView`
- `ServiceManagement`
- `UserNotifications`
- `Swift Package Manager`

## 项目结构

```text
WebBar/
├── Sources/WebBar/App        # App 生命周期、状态栏、网页弹窗
├── Sources/WebBar/Core       # 模型、校验、数据存储
├── Sources/WebBar/UI         # 管理界面与表单
├── Resources                 # Info.plist 等资源
├── Assets                    # App 图标等静态资源
├── Tests/WebBarTests         # 单元测试
└── scripts                   # 构建、安装、打包脚本
```

## 快速开始

### 环境要求

- `macOS 14+`
- `Xcode 16+` 或支持 `Swift 6` 的命令行工具

### 克隆仓库

```bash
git clone git@github.com:MaydayV/webbar.git
cd webbar
```

### 运行测试

```bash
swift test
```

### 本地构建

```bash
swift build -c release
```

### 安装应用

```bash
bash scripts/install_app.sh
```

安装完成后，应用会生成到：

```text
/Users/<your-user>/Applications/WebBar.app
```

## 使用方式

### 添加网址

1. 打开 `WebBar 管理`
2. 点击 `新增网址`
3. 输入网址、名称和 emoji
4. 选择打开方式：
   - `默认浏览器`
   - `内嵌弹窗`
5. 如果使用内嵌弹窗，可继续设置：
   - `恢复上次页面`
   - `每次打开首页`

### 状态栏交互

- 左键点击站点图标：按配置打开网页
- 右键点击状态栏图标：打开管理或退出应用
- 如果是内嵌弹窗模式，再次点击同一图标会切换显示/隐藏

### 开机启动

在管理界面顶部右侧卡片中切换 `开机启动 WebBar` 即可。

## 开发命令

### 构建调试版本

```bash
swift build
```

### 运行测试

```bash
swift test
```

### 打包 `.app`

```bash
bash scripts/build_app.sh
```

### 打包 `.dmg`

```bash
bash scripts/build_dmg.sh
```

### 安装到本机

```bash
bash scripts/install_app.sh
```

## 自动构建与 Release

仓库已配置 GitHub Actions，可自动构建 `macOS .dmg` 并上传到 GitHub Releases。

工作流文件：

```text
.github/workflows/release.yml
```

### 触发方式

- 推送 `v*` tag，例如 `v1.0.2`
- 在 GitHub Actions 页面手动触发 `workflow_dispatch`

### 工作流会做什么

1. 在 `macos-14` runner 上选择 `Xcode 16`
2. 构建 `WebBar.app`
3. 打包 `WebBar-<version>.dmg`
4. 上传 workflow artifact
5. 创建或更新 GitHub Release
6. 把 `.dmg` 上传到 Release 资产中

### 发布一个版本

```bash
git tag v1.0.2
git push origin v1.0.2
```

## 未签名安装说明

当前自动发布的 `.dmg` 可以正常下载和安装，但如果尚未配置 Apple Developer 签名，macOS 可能会提示：

- “无法验证开发者”
- “Apple 无法检查其是否包含恶意软件”

遇到这种情况，可以手动放行：

1. 打开 `系统设置 -> 隐私与安全性`
2. 在安全提示区域选择 `仍要打开`
3. 或者对应用执行右键 `打开`

## 贡献指南

如果你想参与开发，推荐使用标准 Fork 工作流。

### Fork 与同步

```bash
git clone git@github.com:<your-name>/webbar.git
cd webbar
git remote add upstream git@github.com:MaydayV/webbar.git
```

### 新建分支

```bash
git checkout -b feat/your-feature-name
```

### 开发与验证

```bash
swift test
bash scripts/install_app.sh
```

### 提交代码

```bash
git add .
git commit -m "feat: add your feature"
git push origin feat/your-feature-name
```

### 创建 Pull Request

向 `MaydayV/webbar` 发起 PR 时，建议说明：

- 改动目标
- 用户可见行为变化
- 测试方法
- 是否影响现有数据或设置

### 推荐规范

- 小步提交，避免超大改动
- 保持 `swift test` 通过
- UI 变更尽量附截图
- 不提交 `.build/`、`dist/` 等本地产物

## License

本项目基于 [MIT License](./LICENSE) 开源。
