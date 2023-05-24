# Old [esx:getSharedObject](https://connect.esx-framework.org/tutorials/sharedevent/) Event Fix

This repository contains a fix for the old `esx:getSharedObject` event for the new ESX Legacy versions. The `esx:getSharedObject` event was previously used to obtain a shared object in ESX resources, but it was deprecated in version 1.9 and replaced with a new export/import method instead.

However, some older resources still rely on the old `esx:getSharedObject` event and may break when updated to the latest version of ESX. This repository provides a fix for this issue by restoring the old `esx:getSharedObject` event so that older resources can continue to function as intended.

## Installation

1. Download the latest release of this repository.
2. Extract the content of the archive and do the following steps...

3. Copy the `common.lua` from the `client` folder.
4. Go to your `es_extended/client` folder.
5. Replace the existing file with my file. 

6. Copy the `common.lua` from the `server` folder.
7. Go to your `es_extended/server`.
8. Replace the existing file with my file. 

## Alternative Installation

In case you prefer a simpler alternative installation method, you can follow these steps:

Open both the common.lua files located in the client and server folders.
Replace the content at the top of both files with the following code:

```lua
AddEventHandler("esx:getSharedObject", function(cb)
    cb(ESX) 
end)
```

This alternative method allows you to quickly integrate the necessary code without performing file replacements. It provides a convenient option for those who prefer a more streamlined installation process.

### Usage

After installing the fix, restart your server, and you can use the `esx:getSharedObject` event as you would normally in older resources. For example, you can use the following code to get the ESX shared object in a client script:

```lua
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
    end
    -- Do something with the ESX shared object
end)
```

## Contributing

If you encounter any issues or have suggestions for improving this fix, please feel free to open an issue or submit a pull request on GitHub.

## License
This repository is licensed under the MIT License. See the [LICENSE](https://opensource.org/licenses/MIT) file for more information.
