var portNumber = 7000;
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var socketArray = [];
var nameArray = [];
var arrowArray = [];


//設定從網頁連進Server時，回傳index.html給瀏覽器 (瀏覽器端為Client，index.html裡面有client的code)
app.get('/',
        function(req, res)
        {
            res.sendFile(__dirname + '/index.html');
        });

//設定 Server 監聽 3000 這個 port
http.listen(portNumber,
            function()
            {
                console.log('listening on *:' + portNumber);
            });


//可將 io 視為 Server 上管理所有 Socket 的 Manager
io.on('connection',
      
      function(socket) /*[1]*/
      {
	//將新的socket放入sosket array
        socketArray[socketArray.length] = socket;
        console.log('socket count: '+socketArray.length);

//當有socket connect時，將傳入的socket名字存入name array以及用來標示箭頭的
//arrow array，接著將更新過的name array轉成string傳給client
        socket.on('connect',
                  function(name){
                    nameArray.push(name);
                    arrowArray.push(name+"<-")
            
            for(var i = 0; i < socketArray.length; i++){
                var nameArraySpec = nameArray.slice();
                nameArraySpec.splice(i, 1, arrowArray[i]);
                var socketListString = nameArraySpec.join('\n');
                socketArray[i].emit('show all socket list', socketListString);
            }
        });

        //當有client寄出訊息時，將此client名稱及訊息內容一起發給所有client
        socket.on('user send out message', /*[2]*/
                  function(msg)
                  {
                  
                  //only send message back to the client of this socket ( with event string 'show message on screen' )
                  var socketIndex;
                    
                  for(var i=0; i < socketArray.length; i++)
                  {
                      if (socketArray[i] == socket)
                          socketIndex = i;
                         
                  }
                  
                   var socketName = nameArray[socketIndex];
                  io.emit('show message on screen', socketName + ': ' + msg);
                  
                  
        });
              
    //當有client disconnect時，將其以及其名稱從每個array都去掉，接著將更新過的
    //name array轉成string傳給client
    socket.on('disconnect',
              function(){
        var socketIndex;
        for(var i=0; i < socketArray.length; i++)
        {
            if (socketArray[i] == socket)
                socketIndex = i;
        }
        console.log("SI: " + socketIndex)
        socketArray.splice(socketIndex, 1);
        nameArray.splice(socketIndex, 1);
        arrowArray.splice(socketIndex, 1);
        console.log('socket count: '+socketArray.length);
        
        for(var i = 0; i < socketArray.length; i++){
            var nameArraySpec = nameArray.slice();
            nameArraySpec.splice(i, 1, arrowArray[i]);
            var socketListString = nameArraySpec.join('\n');
            socketArray[i].emit('show all socket list', socketListString);
        }
    })

    
});


/*
[1] when a new clinet connect to server, server will deploy a new socket to handle the connection to this client and call this function with the new created socket as parameter.

[2] tells socket to handle 'chat message from clinet' event. when socket get 'chat message frome clinet' event, server will call following function and the event message as the parameter
 
*/
