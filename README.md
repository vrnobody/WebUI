## WebUI
V2RayGCon的网页端。  

#### 安装使用
V2RayGCon v1.6.9+包含了WebUI无需另外下载安装。  
在Luna插件中运行以下代码即可：  
```lua
loadfile('./lua/webui/server.lua')()
```
然后在浏览器中访问`http://localhost:4000/`  
  
进阶玩法：  
```lua
local Logger = require('lua.modules.logger')

local serv = './lua/webui/server.lua'
local options = {
    ["url"] = "http://localhost:5000/",
    ["password"] = "123abc中文😀",
    ["salt"] = "485c5940-cccd-484c-883c-66321d577992",
    ["pageSize"] = "50",
    ["public"] = "./lua/webui",
    ["logLevel"] = Logger.logLevels.Info,
}

loadfile(serv)(options)
```

安全提示：  
密码验证不能防中间人攻击，请用Nginx之类的反向代理并启用TLS以提高安全性。  
但是！这还是防不了暴力破解，所以最好还是别放到公网上。  
  
#### 开发
##### 下载源码并安装依赖
```sh
git clone https://github.com/vrnobody/WebUI.git
cd WebUI
npm install
```
  
##### 启动客户端
```sh
npm run dev
```
  
##### 启动服务端
 1. 在Luna脚本编辑器中加载`public/server.lua`并运行  
 2. 禁用浏览器的CORS检测  
```bash
"c:\chrome.exe" --user-data-dir="c:\temp\" --disable-web-security --disable-site-isolation-trials
```
 3. 访问`http://localhost:5173/`  
