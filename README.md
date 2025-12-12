
# FreeFont Pro

FreeFont Pro是一款 iOS 字体浏览、预览与安装工具，专注于收集开源/免费可商用字体（例如 SIL Open Font License / OFL），让你在选择字体时更安心。

## 你能做什么
- 浏览精选字体库，并快速预览字形效果
- 查看字体授权信息（随字体提供 License 文本）
- 下载字体文件并安装到 iOS（便于在支持自定义字体的 App 中使用）

## 收费方式
- 广告（用于解锁下载/安装流程）
- 买断（用于去广告或解锁完整体验）

## 资源结构（开发说明）
- 字体基础信息：Swift 内置（basic_info）
- 首页预览：App 内置资源（home_preview）
- 详情预览：按需资源 ODR（details_preview）
  - `preview_svg`
  - `License.txt`
- 字体文件：按需资源 ODR（font_file）
  - 下载：激励广告
  - 安装：激励广告
