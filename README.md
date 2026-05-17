# PartsPoster 🎨

> 零部件电子海报 — 基于 [Processing 4](https://processing.org/) 开发的交互式零部件电子海报展示程序。

## ✨ 功能特性

- **双零件展示**：支持 "Claw" 与 "Claw_v2" 两个零部件的交互式浏览
- **三视图切换**：每个零件支持前视图、俯视图、左视图，切换时带有平滑淡入淡出动画
- **唱片播放器**：右下角旋转唱片控件，点击可切换背景音乐静音/播放
- **过渡动画**：主菜单进入视图页带有文字放大 + 背景变暗的过渡效果
- **中文界面**：完整的中文按钮和标签，使用微软雅黑字体
- **蒂芙尼蓝主题**：UI 采用 Tiffany Blue 配色，视觉风格统一

## 🖼️ 截图

> 运行程序后，主菜单显示两个零件入口按钮；进入视图后可切换前/上/左视角。

## 🚀 运行环境

| 依赖 | 说明 |
|------|------|
| [Processing 4](https://processing.org/download/) | 开发与运行平台 |
| Processing Sound Library | 音频播放支持（Processing 内置库管理器安装） |

## 📦 资源文件

确保以下文件位于 `data/` 目录下：

| 文件 | 用途 |
|------|------|
| `BG.jpg` | 主菜单背景图 |
| `BGM.mp3` | 背景音乐 |
| `Sd1.wav` | 按钮点击音效 |
| `Claw_Front.png` / `Claw_Up.png` / `Claw_Left.PNG` | Claw 零件三视图 |
| `Claw2_Front.png` / `Claw2_Up.png` / `Claw2_Left.png` | Claw_v2 零件三视图 |

## 🎮 操作说明

| 操作 | 说明 |
|------|------|
| 点击按钮 | 在主菜单选择零件进入视图 |
| 点击"前/上/左" | 切换零件视角 |
| 点击🏠图标 | 返回主菜单 |
| 点击唱片 | 切换背景音乐静音/播放 |

## 📂 项目结构

```
PartsPoster/
├── zzx_.pde              # Processing 主程序
├── data/                  # 资源文件（图片、音频）
├── code/                  # 第三方 Java 库（音频解码）
├── .gitignore
├── LICENSE
└── README.md
```

## 📄 许可证

本项目采用 [MIT License](LICENSE)。

---

*Built with Processing 4.5.2*
