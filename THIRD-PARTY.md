# 资源来源

- 原版桌面 APK、apps APK、工具与 logo.ico：[SmartTV-Toolkit 2.1 Legacy](https://github.com/xiazheteng8/SmartTV-Toolkit/releases/tag/SmartTV-Toolkit_v2.1_Legacy_Edition)。保留用户指定发布包中的原始资源，第三方 APK 由其各自作者提供。
- 布局参考：[LinkAndroid](https://linkandroid.com/)。参考其公开设备管理界面思路，没有将 LinkAndroid 的名称、标志或页面截图作为本程序资源分发。
- 视频引擎：[Genymobile/scrcpy v5.0.1](https://github.com/Genymobile/scrcpy/releases/tag/v5.0.1)，使用官方 scrcpy-win64-v5.0.1.zip。该 ZIP 的 SHA-256：`b12a2c4ee8be317422451fc7dcf8ee20a71b5ea7ef9ad73ddd825a25316227a5`，已与该版本官方 SHA256SUMS.txt 核对。
- scrcpy 使用 Apache License 2.0，随附 LICENSE.txt 未修改。官方 Windows 包的运行依赖包含 SDL、FFmpeg 和 libusb；该官方二进制分发整体保留在 mirror 目录。项目与许可说明：[SDL](https://www.libsdl.org/)、[FFmpeg](https://ffmpeg.org/legal.html)、[libusb](https://libusb.info/)。

内嵌视频采用 Windows 原生窗口宿主；GUI 使用系统自带的 WPF/.NET Framework。TV 助手的业务界面和安装器为本次任务实现，未使用 LinkAndroid 源码。

品牌图标使用 Simple Icons v16 的 YouTube、GitHub、Telegram 标准矢量造型，资源采用 CC0；仅作为用户指定账号的链接入口，不代表这些平台对本项目的背书。源资源：https://github.com/simple-icons/simple-icons 。图形路径保存于 brand-icons.json。
免费 AI 预设核对来源：https://openrouter.ai/docs/guides/routing/model-variants/free ，免费路由为 openrouter/free。仅本地规则无需账号和网络；云端免费服务仍需个人 API Key。


原版 aapt 增加进程级 UTF-8 清单以兼容中文安装路径，补丁源码为 PatchAapt.cs。Windows 官方说明：https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page 。最低对应 Windows 10 1903；不更改系统区域或代码页设置。

