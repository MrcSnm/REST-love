local function generateHeader(tbHeader)
    local header = ""
    if tbHeader == nil then return header end
    for key, value in pairs(tbHeader) do
        header = header..'xhttp.setRequestHeader("'..key..'", "'..value..'");\n'
    end
    return header
end

local function get(url, requestHeader, onDataLoad)
    JS.newPromiseRequest(JS.stringFunc(
        [[
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function()
            {    
                if (this.readyState == 4)
                    if(this.status == 200)
                        _$_(this.responseText);
                    else
                        _$_("ERROR " + this.status + "\n"+this.responseText);
            };
            xhttp.open("GET", "%s", true);
            %s
            xhttp.send();
    ]], url, generateHeader(requestHeader)), onDataLoad, nil, nil, "Get");
end

local function post(url, requestHeader, data, onDataLoad)
    JS.newPromiseRequest(JS.stringFunc(
        [[
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function()
            {    
                if (this.readyState == 4)
                    if(this.status == 200)
                        _$_(this.responseText);
                    else
                        _$_("ERROR " + this.status + "\n"+this.responseText);
            };
            xhttp.open("POST", "%s", true);
            %s
            xhttp.send(%s);
    ]], url, generateHeader(requestHeader), _TABLE_TO_JSON(data)), onDataLoad, nil, nil, "Post");
end

local function patch(url, requestHeader, data, onDataLoad)
    JS.newPromiseRequest(JS.stringFunc(
        [[
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function()
            {    
                if (this.readyState == 4)
                    if(this.status == 200)
                        _$_(this.responseText);
                    else
                        _$_("ERROR " + this.status + "\n"+this.responseText);
            };
            xhttp.open("PATCH", "%s", true);
            %s
            xhttp.send(%s);
    ]], url, generateHeader(requestHeader), _TABLE_TO_JSON(data)), onDataLoad, nil, nil, "Patch");
end

local function put(url, requestHeader, data, onDataLoad)
    JS.newPromiseRequest(JS.stringFunc(
        [[
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function()
            {    
                if (this.readyState == 4)
                    if(this.status == 200)
                        _$_(this.responseText);
                    else
                        _$_("ERROR " + this.status + "\n"+this.responseText);
            };
            xhttp.open("PUT", "%s", true);
            %s
            xhttp.send();
    ]], url, generateHeader(requestHeader), _TABLE_TO_JSON(data)), onDataLoad, nil, nil, "Put");
end

local function delete(url, requestHeader, onDataLoad)
    JS.newPromiseRequest(JS.stringFunc(
        [[
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function()
            {    
                if (this.readyState == 4)
                    if(this.status == 200)
                        _$_(this.responseText);
                    else
                        _$_("ERROR " + this.status + "\n"+this.responseText);
            };
            xhttp.open("DELETE", "%s", true);
            %s
            xhttp.send();
    ]], url, generateHeader(requestHeader)), onDataLoad, nil, nil, "Delete");
end



return {
    get = get;
    post = post;
    put = put;
    patch = patch;
    delete = delete;
    start = nil;
    retrieveFunction = JS.retrieveData
}