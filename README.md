## WebUI
V2RayGCon的网页端。  

#### 安装使用
V2RayGCon v1.6.9+包含了WebUI无需另外下载安装。  
在Luna插件中运行以下代码即可：  
```lua
local serv = './lua/webui/server.lua'
loadfile(serv)()
-- 也可以传入参数 loadfile(serv)("http://localhost:1234/") 
```
然后在浏览器中访问`http://localhost:4000/`  

#### 开发
##### 启动客户端：  
```sh
npm install
npm run dev
```

##### 启动服务端：  
在Luna插件中加载`public/server.lua`并运行。  
注意要禁用浏览器的CORS检测。  
