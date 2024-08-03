>对于 Docsify 自带 LiveReload 组件加载超时或者想关闭 Docsify 的 LiveReload（实时自动刷新），
>可以通过 Dockerfile 构建镜像时将修改过的 node_modules\connect-livereload\index.js 替换掉原来的 index.js

我发现打开我的网站时，有个 js 脚本加载超时，`https://zy-finn.top:35729/livereload.js?snipver=1` 完整 url 也很奇怪，端口是35729，
docker 中的 Docsify 对应映射的端口是 3000。
![](_media/img.png)
查了之后知道 LiveReload 是 Docsify 内置的小客户端
>Docsify 的 livereload 是一个用于实时自动刷新浏览器的功能。它使得在开发过程中，当你修改 Docsify 网站的内容时，浏览器会自动重新加载，显示最新的更改，而无需手动刷新页面。这对于提高开发效率非常有帮助，特别是当你频繁修改内容时。
工作原理
livereload 的工作原理是通过在开发服务器中嵌入一个小型的 JavaScript 客户端，该客户端会定期检查文件的变化。当检测到文件有变动时，客户端会通知浏览器自动刷新页面。

为什么会超时，我以为是服务器防火墙没开放 35729 这个端口导致的，但在配置后发现还是超时。
![](_media/img_1.png)
根据 chartGPT 提示，添加 Nginx 配置