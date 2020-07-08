# REST-love
This is a common set of things for calling REST APIs in Love, it supports Android, Web, Linux and Windows.
The best thing about that is that Android doesn't need any additional code!

## AsyncLoader
AsyncLoader is meant to be used by the LoadBar module, but you can extend its use yourself, you can use that
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
EXAMPLE_HTML = ""
loadBarInstance.addContentToLoad(function()
    EXAMPLE_HTML = betterOs.curl.get("https://example.com")
end, nil, "Getting Example.html: $")
```

## Module-Loader
This is a really good thing when you just copy/paste some lib into your project and you need to import it without doing
any kind of code replace, e.g:
```lua
local js = requireFromLib("js", "js")
```
This is useful as "js" may require other libs inside it's own project, so, you won't need to adapt anything

# JS
This is a project dependency, REST calls will be adapted to the [**Love.js-Api-Player**](https://github.com/MrcSnm/Love.js-Api-Player)
Good thing about this is that you won't need to call yourself XMLHttpRequest


## REST
Where the project magic happens, it has its own defined behavior for Default(Android and Linux), Windows and Web, every REST function has
async support, and, for actually 'loading' the request data, you need to include in your love.update function
```lua
rest.update(dt)
```
If you want it to be sync, just make it return if rest.update returns true:
```lua
if(rest.update(dt)) then
    return
end
```
Please, notice that if you're already using Love.js Api-Player, there will be no need to call `JS.retrieveData(dt)`
