# MouseBase
A bare minimum set of tools to get your Transformice script started hazzle-free.

## Usage

### Configure to use MouseTool NPM repository

```sh
npm login --scope=@mousetool --registry=https://npm.pkg.github.com

> Username: Your username here
> Password: Your GitHub PAT token here
> Email: PUBLIC-EMAIL-ADDRESS
```

It is mandatory to set this up for the first time when dealing with MouseTool NPM packages, otherwise GitHub will deny you from installing them. More on authenticating to GitHub NPM repository can be found [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#authenticating-to-github-packages).


### Install

```sh
npm install --save-dev @mousetool/mousebase
```
