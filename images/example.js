function showToast() {
        Toaster.postMessage(false);
    }

    function showSimpleDialog() {
        DialogMaker.postMessage(JSON.stringify({"title":"标题","content":"内容"}));
    }

    function selectFile(){
      Filer.postMessage('showToastMessage');
    }

    function showToastMessage(message){
      Toaster.postMessage(message);
    }

    var callbacks = {};

    //window.axj

    function invokeNative(funcName,data,cb){
        var id = //"自己生成"
        callbacks[id] = cb;
        var json = {};
        json.data = data;
        json.funcName = funcName;
        json.callbackId = id;
        axj.postMessage(JSON.stringify(json));
    }

    // {
    //      callbackId:xxxx,
    //      status:1,
    //      funcName:xxxx,
    //      data:{
    //
    //      }
    // }
    function invokeJs(json){
        if(status == 0){
            ...
        }
         var f = callbacks[json.callbackId]
         f(data);
    }


    function getNativeToken(){
       showToast();
       var json = {
         "funcName":"getToken",
         "data":{
            "callbackName": "funcTwoParams",
             "backRoute":"/home"
         }
       };
       var param = JSON.stringify(json);
       UserState.postMessage(
         param
       );
    }

    function funcTwoParams(message1,message2){
          Toaster.postMessage(message1+message2);
    }

    function getNativeToken(){

      var json = {
        "funcName":"getToken",
        "data":{
           "callbackName": "funcTwoParams",
            "backRoute":"/home"
        }
      };

      var param = JSON.stringify(json);

      UserState.postMessage(param);
    }

