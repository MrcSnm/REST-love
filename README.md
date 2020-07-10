# REST-love
This is a common set of things for calling REST APIs in Love, it supports Android, Web, Linux and Windows.
Every REST API is implemented with async functionality, so, it is running on another thread in every platform
The best thing about that is that every platform doesn't need any additional code (Except for Web that you need to add the script tag)!

## Setting up REST-love
- Clone it on your folder
```sh
git clone https://github.com/MrcSnm/REST-love.git
```
- Enter on it
```sh
cd REST-love
```
- Update every submodule
```sh
git submodule update --init --recursive
```
- Now just `require "REST"`, it defines a global named `REST`
- If you wish to use **module-loader** into your project, just delete the `require module-loader` from REST.lua (First line)

## AsyncLoader
AsyncLoader(Actually CoroutineLoader) is meant to be used by the LoadBar module, but you can extend its use yourself, you can use that
to do any heavy and synchronous operation for thiner operations, this is a Singleton, don't extend it unless
adapting it first, call it directly

## LoadBar
A simple loading bar that uses the AsyncLoader module, there is a default LoadBar made with primitives if no
front and back image is provided, for using it, simply do
```lua
loadBarInstance.addContentToLoad(loadFunction, onLoad, contentName)
```
If you wish, in the content name you can pass a special character that will be replaced by the current load progress,
a simple use-case is:
```lua
require "loadbar"
loadBarInstance = LoadBar:new(width, height, frontTexture, backTexture)
imgs = {}
loadBarInstance.addContentToLoad(function()
    imgs["myImg"] = love.graphics.newImage("myImg.png")
end, nil, "Loading myImg: $")
```

Then just add `loadBarInstance:update(dt)` on your update function
And `loadBarInstance:render` as the last thing to render on your draw function

## Module-Loader
This is a really good thing when you just copy/paste some lib into your project and you need to import it without doing
any kind of code replacement, e.g:
```lua
local js = requireFromLib("js", "js")
local req = requireFromLib("luajit-request", "luajit-request")
```
This is useful as "js" or "luajit-request" may require other libs inside it's own project, so, you won't need to adapt anything

# JS
This is a project dependency, REST calls will be adapted to the [**Love.js-Api-Player**](https://github.com/MrcSnm/Love.js-Api-Player)
Good thing about this is that you won't need to call yourself XMLHttpRequest


## REST
Where the project magic happens, it has its own defined behavior for Default(Android and Linux), Windows and Web, every REST function has
async support, and, for actually 'loading'(actually used for onLoad callback) the request data, you need to include in your love.update function
```lua
REST.retrieve(dt)
```
If you want it to be sync(or execute any action), just make it return if rest.update returns true:
```lua
if(REST.retrieve(dt)) then
    return
end
```

### Notes
- Please, notice that if you're already using Love.js Api-Player, there will be no need to call `JS.retrieveData(dt)`
- Inline sync is implemented for Default and Windows, but as it is still not supported on Web, as it **always** uses the Web thread for making the http request, I did not implement any function for alternating inline sync and async, however, if you do wish to use, just enter in the target (default or win) and change
- I don't really remember if I'm using x32 or x64 libcurl, I believe it is x32(because filesize)
