# PasswdDesktopForMacOS

- Swift 开发的原生 MacOS 桌面应用程序，用来保存个人密码。
- 后端项目见 PasswdBackend，跨平台桌面应用程序见 PasswdDesktop

## 最新更新 (2024-12-19)

### 三列布局重构
- 将原有的双列布局重构为官方推荐的 NavigationSplitView 三列布局
- 实现了更符合 macOS 设计规范的界面结构：
  - **SideBarView**: 左侧分组列表，包含分组管理和登出功能
  - **ContentView**: 中间密码列表，显示当前分组下的所有密码
  - **DetailView**: 右侧详情编辑，显示和编辑选中密码的详细信息

### 技术改进
- 使用 SwiftUI 的 NavigationSplitView 实现标准的三列布局
- 保持了所有原有功能：分组管理、密码增删改查、搜索功能
- 优化了代码结构，将功能模块化分离
- 改进了用户交互体验，符合 macOS 应用的设计规范

### 功能特性
- ✅ 分组管理（创建、编辑、删除分组）
- ✅ 密码管理（添加、编辑、删除密码）
- ✅ 安全字段显示（密码隐藏/显示切换）
- ✅ 一键复制功能
- ✅ 实时搜索功能（Command + F）
- ✅ 数据加密存储
- ✅ 自动登录功能

![截屏2024-02-21 11 53 55](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/f5b07ba0-1aa9-46a2-9376-35a09c1c7aa1)
![截屏2024-02-21 11 54 01](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/353c8d55-ab64-4af3-81c7-c0d4cb11e1cb)
![截屏2024-02-21 11 53 32](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/da6dfeae-7ae2-43bf-9c3e-46e0e0cc7dc9)
![截屏2024-02-21 11 54 28](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/50e236cd-4ca3-4eb4-9b2e-634590469766)
![截屏2024-02-21 11 54 14](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/96d2e938-3984-48be-bdb8-227353e66b75)
![截屏2024-02-21 11 54 21](https://github.com/Leslie-DD/PasswdDesktopForMac/assets/55346933/847a9063-4ddb-44c8-9046-5dca8e580d12)
