# CipherBox 密码工具箱

一个纯本地运行的密码 / 加解密小工具：不联网、不写注册表、不上传任何数据。
界面为自绘的深色单窗口（1180×760），四页功能：文本加解密、编码转换、哈希与摘要、密码中心。

![文本加解密](docs/shot-text.png)

## 一、功能

### 1. 文本加解密
- 算法：AES-128 / AES-192 / AES-256 / DES / 3DES / RC4 / XOR
- 模式：CBC（带随机 IV）/ ECB
- 口令派生：PBKDF2-HMAC-SHA256，20000 次迭代，16 字节随机盐
- 编码：Base64 / Base64URL / Hex / Base32 输出
- 密文自带盐与 IV，同一个口令每次加密结果都不同；解密时自动读取
- 一键交换输入输出、复制结果、清空

### 2. 编码转换
Base64、Base32、Base64URL、十六进制、URL 编码、Unicode 转义、HTML 实体、
二进制位串、摩斯电码、凯撒移位、Atbash、维吉尼亚密码、字符串反转、大小写转换。
编码 / 解码双向，凯撒可一次列出 26 种偏移结果。

### 3. 哈希与摘要
- MD5 / SHA-1 / SHA-256 / SHA-384 / SHA-512
- HMAC（同样的 5 种算法，可填密钥）
- 输出十六进制或 Base64
- 「哈希比对」：粘贴已有摘要，直接判断两条内容是否一致

### 4. 密码中心
- 强度检测：长度、字符种类、重复 / 顺序模式、常见弱口令命中，给出 0–100 分与改进建议
- 随机口令生成：长度 4–64，可选大写 / 小写 / 数字 / 符号，排除易混淆字符（O0Il1），
  使用 RNGCryptoServiceProvider 生成，每类字符至少出现一次
- 内置常见弱口令库（约 330 条：数字串、键盘序列、姓名、年份组合等），
  支持导入自定义 .txt / .dic 字典
- 哈希反查：粘贴 MD5 / SHA-1 / SHA-256 / SHA-512 十六进制摘要，在字典内比对，
  用于自查某个口令是否早已出现在公开弱口令表中

## 二、快速开始

要求 Windows 7 SP1 及以上 + .NET Framework 4.6+（Win10/11 自带），无需安装任何运行库。

1. 把整个 `CipherBox` 文件夹放到任意位置（例如 `D:\Tools\CipherBox`）。
2. **仅第一次**：右键 `加入白名单.bat` → 以管理员身份运行，UAC 点「是」。
   它只对**本工具所在目录**加一条 Defender 排除项，随时可在安全中心删除。
   （这一步不能省：否则下面生成的 exe 会在几秒到几分钟内被删掉。）
3. 生成 exe：

   ```
   powershell -ExecutionPolicy Bypass -File .\build.ps1
   ```

   产物 `dist\CipherBox.exe` 约 107 KB。
4. 双击 `dist\CipherBox.exe` 即可。

> 不想改动安全设置时，可以不执行第 2 步，但 Defender 会按下一节的误报模型直接删除 exe。
## 三、为什么会被杀软误报（重要）

本工具没有任何联网、驻留、自启动、读写用户文件的行为，源码全部附在本目录，
但因为它同时包含**加密算法 + 口令字典 + 剪贴板 / 界面代码**，且**没有代码签名**，
Windows Defender 的机器学习模型有可能误报为
`Trojan:MSIL/XWorm.ZBB!MTB`（`!MTB` 表示由云端 ML 模型给出，而非特征命中），
并在首次运行时直接删除 exe。

处理办法（任选其一）：

1. **加入排除目录**（推荐，本机自用工具的标准做法）
   右键以管理员身份运行 `加入白名单.bat`，它只做一件事：
   `Add-MpPreference -ExclusionPath "<本工具所在目录>"`。
   也可以手动执行：Windows 安全中心 → 病毒和威胁防护 → 管理设置 → 排除项 → 添加文件夹。
2. 把误报提交给微软（不影响本地使用）：
   <https://www.microsoft.com/en-us/wdsi/filesubmission>
3. 自行编译：`powershell -ExecutionPolicy Bypass -File .\build.ps1`
   （编译产物同样可能被误报，需要配合第 1 条。）

工具不修改系统设置，只有第 1 条需要管理员权限，且完全可逆（在排除项里删除即可）。

## 四、安全说明

- 所有运算都在本机进程内完成，无网络请求、无日志落盘；
- RSA、文件加解密等"重"功能未包含在本版本中（按要求裁剪），只保留最常用的能力；
- 口令派生使用 PBKDF2-SHA256 20000 次迭代，密文每次随机加盐，相同口令不会产生相同密文；
- ECB 模式仅用于兼容旧数据，相同明文块会产生相同密文块，不建议用于新数据；
- DES / 3DES / RC4 / XOR 仅作学习与兼容用途，强度不足以保护真实机密；
- 「密码中心」的字典与哈希反查只用于**自查自己的口令是否已泄露**，请勿用于未授权的口令猜解。

## 五、源码结构

```
src/
  Core/
    Crypto.cs        编码、对称算法、摘要/HMAC/PBKDF2、古典密码
    PasswordTools.cs 常见弱口令库、强度评估、生成器、哈希反查
  App/
    Theme.cs         配色、字体、圆角绘制、图标
    Controls.cs      按钮 / 输入框 / 下拉框 / 分段控件 / 开关 / 卡片 / 进度条
    Page.cs          页面基类（标题、卡片、控件工厂、提示）
    MainForm.cs      无边框主窗口：标题栏、侧边导航、状态栏、Toast
    PageText.cs      文本加解密页
    PageEncode.cs    编码转换页
    PageHash.cs      哈希与摘要页
    PagePasswordTools.cs 密码中心页
    Program.cs       入口
build.ps1            一键编译（使用系统自带 csc.exe，无第三方依赖）
assets/app.ico       应用图标
```

编译命令（与 build.ps1 等价）：

```
%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /optimize+ ^
  /win32icon:assets\app.ico /win32manifest:src\App\app.manifest ^
  /out:dist\CipherBox.exe ^
  /r:System.dll /r:System.Core.dll /r:System.Drawing.dll /r:System.Windows.Forms.dll ^
  src\Core\Crypto.cs src\Core\PasswordTools.cs ^
  src\App\Theme.cs src\App\Controls.cs src\App\Page.cs src\App\MainForm.cs ^
  src\App\PageText.cs src\App\PageEncode.cs src\App\PageHash.cs ^
  src\App\PagePasswordTools.cs src\App\Program.cs src\App\AssemblyInfo.cs
```

## 六、界面

| 文本加解密 | 编码转换 |
| --- | --- |
| ![文本](docs/shot-text.png) | ![编码](docs/shot-encode.png) |

| 哈希与摘要 | 密码中心 |
| --- | --- |
| ![哈希](docs/shot-hash.png) | ![密码](docs/shot-pass.png) |
