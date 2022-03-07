# #BuildTool

Welcome to the official BuildTool 2.5 open-source repository! BuildTool is a Lua module for the game [Transformice](https://transformice.com), providing a set of useful utilities for Shamans in the game. It is geared towards the building community, additionally supporting the following building minigames:
- #Divinity
- #Spiritual

This is the ~~third~~ seconrdth generation of BuildTool, born out of increasing acknowledgement since 2018 and the need for a more solid codebase to maintain easily.

_(Buildtool3 when??)_

Report any bugs/issues/suggestions to the issues tab of this repository. ~~If you are good~~ Do submit pull request to correct mistakes or help with feature development – they greatly appreciated and you may even be hired into the contributors team ~~if we like you~~. We are also looking for trusty Translators, contact `Casserole#1717` @ Discord for information.

## Development Information
### Building / Compiling script
You will need to install [Node.js](https://nodejs.org/). After that, clone this repository and run the following commands in the command line. This will install the required Node.js and Lua dependencies needed to build this module.
```
cd buildtool
npm install -g yarn
yarn install
```

You can then compile the BuildTool script directly from the command line:
```
yarn run build
```

Or alternatively, a minified version:
```
yarn run minify
```

## Coding Environment

We recommend using [Visual Studio Code](https://code.visualstudio.com) which is supported on all major platforms, with the following extension installed – [Lua Language Server (sumneko.lua)](https://marketplace.visualstudio.com/items?itemName=sumneko.lua). This is to harness auto-completion and other features like type hinting based on Lua docs (Emmylua format).

### Configure to use MouseTool NPM repository

```sh
npm login --scope=@mousetool --registry=https://npm.pkg.github.com

> Username: Your username here
> Password: Your GitHub PAT token here
> Email: PUBLIC-EMAIL-ADDRESS
```

It is mandatory to set this up for the first time when dealing with MouseTool NPM packages, otherwise GitHub will deny you from installing them. More on authenticating to GitHub NPM repository can be found [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#authenticating-to-github-packages).


You should run an `yarn install` before starting, so that necessary dependencies are updated and picked up by the extension.

## Contributors

Special tribute and shoutout to the original creator of BuildTool – `Emeryaurora#0000`, who had also authored the first and second generation of BuildTool; `Leafileaf#0000` for providing assistance since the beginning and contributing to serveral crucial portions of the database system.

BuildTool 2.5 is currently developed and maintained by `Casserole#1798` (@Cassolette). Its interface was designed by `Tactcat#0000`. We would like to thank our beta testers – Translators, Tribes, individuals alike, for providing bug reports and suggestions to the module:
- Academy of Building
- The Balloon Movement

### Translations

:eyes:
