# WebBar

<p align="center">
  <img src="./Assets/app_icon.svg" alt="WebBar Icon" width="96" height="96" />
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

## 概览

WebBar 是一个轻量级 `macOS` 菜单栏应用，用来把高频网页变成独立入口。

它适合这样的场景：

- 把 `ChatGPT`、`DeepSeek`、`豆包`、`Gemini` 这类网页服务常驻到状态栏
- 点击图标后直接在默认浏览器打开
- 或者以内嵌网页弹窗打开，保留登录状态并快速继续使用
- 为每个站点配置独立 emoji 图标、独立打开方式、独立重新打开策略

## 功能特性

- 独立状态栏图标：每个网址一个独立入口
- 双打开模式：默认浏览器 / 内嵌弹窗
- 登录状态隔离：每个站点单独保存 Cookie 与本地网页状态
- 重新打开策略：恢复上次页面 / 每次打开首页
- 开机启动：可选启用
- 自定义图标：使用 emoji 作为站点图标
- macOS 原生体验：`AppKit + SwiftUI + WebKit`

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
└── scripts                   # 构建、安装与打包脚本
```

## 环境要求

- `macOS 14+`
- `Xcode 16+` 或支持 `Swift 6` 的命令行工具

## 快速开始

### 1. 克隆仓库

```bash
git clone git@github.com:MaydayV/webbar.git
cd webbar
```

### 2. 运行测试

```bash
swift test
```

### 3. 本地构建

```bash
swift build -c release
```

### 4. 生成并安装应用

```bash
bash scripts/install_app.sh
```

安装完成后，应用会生成到：

```text
/Users/<your-user>/Applications/WebBar.app
```

## 使用方法

### 添加网址

1. 打开 `WebBar 管理`
2. 点击 `新增网址`
3. 输入网址、名称和 emoji
4. 选择打开方式：
   - `默认浏览器`
   - `内嵌弹窗`
5. 如果使用内嵌弹窗，可继续选择：
   - `恢复上次页面`
   - `每次打开首页`

### 状态栏使用

- 左键点击站点图标：按配置打开网页
- 右键点击状态栏图标：打开管理或退出应用
- 如果是内嵌弹窗模式，再次点击同一图标可切换显示/隐藏

### 开机启动

在管理界面顶部右侧卡片中切换 `开机启动 WebBar` 即可。

## 开发命令

### 构建

```bash
swift build
```

### 测试

```bash
swift test
```

### 打包 App

```bash
bash scripts/build_app.sh
```

### 打包 DMG

```bash
bash scripts/build_dmg.sh
```

### 安装到本机

```bash
bash scripts/install_app.sh
```

## GitHub Actions 自动构建与 Release

仓库已经可以接 GitHub Actions 自动构建 `macOS .dmg` 安装包，并发布到 GitHub Releases。

工作流文件：

```text
.github/workflows/release.yml
```

触发方式：

- 推送 `v*` tag，例如 `v1.0.2`
- 在 GitHub Actions 页面手动触发 `workflow_dispatch`

工作流会执行：

1. 在 `macos-14` runner 上构建 `WebBar.app`
2. 生成 `WebBar-<version>.dmg`
3. 上传工作流 artifact
4. 创建或更新 GitHub Release
5. 把 `.dmg` 上传到 Release 资产中

### 发布一个版本

```bash
git tag v1.0.2
git push origin v1.0.2
```

如果仓库已启用 Actions，Release 会自动生成并附带 `.dmg`。

## 未签名安装说明

如果你还没有配置 Apple Developer 签名证书，GitHub Actions 也可以正常构建并发布 `未签名` 的 `.dmg`。

这类安装包在 macOS 上通常会看到：

- “无法验证开发者”
- “Apple 无法检查其是否包含恶意软件”

这种情况下，用户可以手动放行：

1. 打开 `系统设置 -> 隐私与安全性`
2. 在安全提示区域选择 `仍要打开`
3. 或者对应用执行右键 `打开`

## 正式签名与公证

如果你希望发布给更多普通用户，建议开启：

- `Developer ID Application` 签名
- Apple notarization 公证

### 需要准备的 GitHub Secrets

在仓库的 `Settings -> Secrets and variables -> Actions` 中配置：

- `BUILD_CERTIFICATE_BASE64`
  你的 `.p12` 证书文件做 base64 编码后的内容
- `P12_PASSWORD`
  `.p12` 文件密码
- `KEYCHAIN_PASSWORD`
  GitHub runner 临时 keychain 密码
- `APPLE_SIGNING_IDENTITY`
  例如 `Developer ID Application: Your Name (TEAMID)`
- `APPLE_ID`
  Apple ID 邮箱
- `APPLE_TEAM_ID`
  Apple Developer Team ID
- `APPLE_APP_SPECIFIC_PASSWORD`
  Apple ID 的 app-specific password

### 本地导出 `.p12`

1. 打开 `钥匙串访问`
2. 找到 `Developer ID Application` 证书
3. 导出为 `.p12`
4. 对文件做 base64 编码，例如：

```bash
base64 -i developer-id.p12 | pbcopy
```

把复制出来的内容填入 `BUILD_CERTIFICATE_BASE64`。

### 公证流程说明

当这些 secrets 都存在时，工作流会自动执行：

- `codesign` 对 `WebBar.app` 签名
- `codesign` 对 `.dmg` 签名
- `xcrun notarytool submit --wait`
- `xcrun stapler staple`

如果这些 secrets 不存在，工作流会自动退化为“只构建并发布未签名的 `.dmg`”。

## Fork 与提交 PR

如果你想参与开发，推荐使用标准 Fork 工作流。

### 1. Fork 仓库

在 GitHub 页面点击 `Fork`，把仓库 fork 到自己的账号下。

### 2. 克隆你的 Fork

```bash
git clone git@github.com:<your-name>/webbar.git
cd webbar
git remote add upstream git@github.com:MaydayV/webbar.git
```

### 3. 新建分支

```bash
git checkout -b feat/your-feature-name
```

### 4. 开发与验证

```bash
swift test
bash scripts/install_app.sh
```

### 5. 提交代码

```bash
git add .
git commit -m "feat: add your feature"
git push origin feat/your-feature-name
```

### 6. 创建 Pull Request

向 `MaydayV/webbar` 发起 PR，并在描述中说明：

- 改动目标
- 用户可见行为变化
- 测试方法
- 是否影响现有数据或设置

## 推荐的 PR 规范

- 小步提交，避免超大改动
- 保持 `swift test` 通过
- UI 变更尽量附截图
- 不提交 `.build/`、`dist/` 等本地产物

## License

本项目基于 [MIT License](./LICENSE) 开源。
