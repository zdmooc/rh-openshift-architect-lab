const http=require('http');
const port=process.env.PORT||8080;
const name=process.env.APP_NAME||'ex288-app';
const msg=process.env.MSG||'hello';
http.createServer((req,res)=>{res.writeHead(200,{'Content-Type':'text/plain'});res.end(name+':'+msg+'
');}).listen(port);
