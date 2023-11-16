## WebUI
V2RayGCon的网页端。  

#### 安装使用
V2RayGCon v1.8+包含了WebUI无需另外下载安装。  

在NeoLuna插件中运行以下代码：  
```lua
loadfile('3rd/neolua/webui/server.lua')()
```
然后在浏览器中访问`http://localhost:4000/`  
注意每次更新后要在浏览中按shift+F5刷新缓存。  
  
进阶用法：
```lua
local Logger = require('3rd/neolua/mods/logger')

local serv = '3rd/neolua/webui/server.lua'
local options = {
    ["url"] = "http://localhost:5000/",
    ["password"] = "123abc中文😀",
    ["adminpassword"] = "123456",
    ["salt"] = "485c5940-cccd-484c-883c-66321d577992",
    ["pageSize"] = "50",
    ["public"] = "./3rd/neolua/webui",
    ["logLevel"] = Logger.logLevels.Info,
}

loadfile(serv)(options)
```
password存储在本地，下次打开浏览器不需要再次输入。可以点右上角的“登出”清除密码。  
adminpassword在关闭浏览器后自动清除，修改设置、使用NeoLuna等危险操作时会检查这个密码。  
上面两个选项留空就不会弹出输密码窗口。  
  
安全提示：  
密码验证不能防中间人攻击，请用Nginx之类的反向代理并启用TLS以提高安全性。  
但是！这还是防不了暴力破解，所以最好还是别放到公网上。  
  
#### 开发
下载源码并安装依赖
```sh
git clone https://github.com/vrnobody/WebUI.git
cd WebUI
npm install
```
  
启动客户端
```sh
npm run dev
```
  
启动服务端
```lua
在NeoLuna脚本编辑器中加载`public/server.lua`
注释掉`args = {...}`这行，然后按F5运行
```

禁用浏览器的CORS检测
```bash
"c:\chrome.exe" --user-data-dir="c:\temp\" --disable-web-security --disable-site-isolation-trials
```

最后访问网址  
```js
http://localhost:5173/
```

#### 升级package.json
```bash
npm outdated
npm update --save
```

#### 更新记录
[update-log.txt](https://github.com/vrnobody/WebUI/blob/main/update-log.txt)  

