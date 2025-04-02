# IDB: Introduction to Database

## 配置开发环境

1. 安装 [Erlang/OTP](https://www.erlang.org/) 27；
2. 安装 [Elixir](https://elixir-lang.org/) 1.18；

   对于 Windows，安装以上两者是简单的。对于 Linux（仅在 Ubuntu 24.04 测试），请依 [Install Elixir](https://elixir-lang.org/install.html#install-scripts) 操作。
3. （可选）为 Hex 包管理器配置中国大陆镜像源（又拍云）
   ```bash
   mix hex.config mirror_url https://hexpm.upyun.com
   ```
4. 克隆本仓库；
5. 运行 `mix deps.get` 获取依赖库；

## Debug 运行

```bash
mix run
```

## Release 编译

1. 临时设定 `MIX_ENV` 环境变量为 `prod`。
   - PowerShell：
     ```pwsh
     $env:MIX_ENV = "prod"
     ```
   - Zsh/Bash
     ```bash
     export MIX_ENV=prod
     ```
   - Nushell
     ```nu
     $env.MIX_ENV = "prod"
     ```
2. 编译
   ```bash
   mix release
   ```

## Release 运行

```bash
./_build/prod/rel/idb/bin/idb start
```

## 构建文档

```bash
mix doc
```
