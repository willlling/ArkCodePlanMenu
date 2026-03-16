# ArkCodePlanMenu

macOS 菜单栏方舟编辑器 (ark.dev) Code Plan 套餐额度监控工具.

实时显示剩余 token 数量，一目了然你的套餐使用情况。

## 功能

- ✅ 菜单栏实时显示剩余 token
- ✅ 弹窗显示完整信息（套餐名称、总额、已用、剩余）
- ✅ 进度条可视化使用比例
- ✅ 颜色提醒（剩余过少自动变色提醒）
- ✅ 自动定时刷新
- ✅ 开机自启动选项

## 截图

*(待补充)*

## 安装

1. 从 [Releases](../../releases) 下载最新的 `ArkCodePlanMenu.app`
2. 拖到 Applications 文件夹
3. 第一次打开需要在 系统设置 → 隐私与安全性 允许打开
4. 点击菜单栏图标，进入设置，输入你的方舟 API Token

## 获取 API Token

1. 登录 https://ark.dev
2. 打开开发者工具 → 网络面板
3. 找到任意请求到 `ark.dev/api`
4. 从请求头中复制 `Authorization: Bearer <token>` 中的 token
5. 粘贴到应用设置中

## 开发

### 环境要求

- Xcode 15+
- macOS 13+

### 构建

```bash
git clone https://github.com/willlling/ArkCodePlanMenu.git
cd ArkCodePlanMenu
open ArkCodePlanMenu.xcodeproj
```

然后在 Xcode 中点击 Build。

## 许可证

MIT
