需要V2RayGCon v1.6.9+

1.解压webui.zip到lua/webui/目录中

2.在Luna插件中运行以下代码：  
local file = './lua/webui/server.lua'
local url = 'http://localhost:4000/'
loadfile(file)(url)

3.打开浏览器访问http://localhost:4000/