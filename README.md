# sandbox.js

Sandboxing javascript in embedded iframe.


## Usage

var sandbox = new Sandbox(config);

## Configurations

 * root - root element. sandbox.js will create one if this is omitted.
 * container - if root is not specified or root doesn't have a parent, attach root to container.
   default to document.body if both root and container are omitted.
 * sandbox - iframe sandbox attributes. default to "allow-scripts allow-pointer-lock".
   Note: blob iframe in Firefox exploits host cookie with empty sandbox.


## Methods

 * setProxy(({obj: obj}) - set an object as proxy interface. Proxy object must passed in an object like:

   ```
   sandbox.setProxy({ Interface: Interface });
   ```

   once set, you can invoke corresponding object in sandbox with following:

   ```
   sandbox.proxy.someFunc(args);
   ```

   you must have the object ( e.g., Interface ) with the exact same name as a global object in sandbox context.

 * send(msg) - send message to sandbox. msg will be wrapped in an object as:

   ```
   { type: \msg, payload: your-msg-data }
   ```

 * reload() - reload sandbox.
 * load(obj), loadUrl(obj) - initialize sandbox content. obj has following structure:

   ```
   {
      "html": ( html code or url ),
      "css":  ( html code or url ),
      "js":   ( html code or url )
   }
   ```



## License

MIT
