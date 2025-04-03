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
6. 确保你已经配置好了 MySQL。将 `config` 文件夹下的 `config_template.exs` 重命名为 `config.exs`，编辑以下字段：
   ```elixir
   config :idb, Idb.Auth,
     issuer: "idb",
     secret_key: "" # 填写 JWT 的 secret key，可以用 mix guardian.gen.secret 生成一个
   ```

   ```elixir
   config :idb, Idb.Repo,
     database: "", # 数据库名称
     username: "", # MySQL 用户名
     password: "", # 对应上述用户的密码
     hostname: "", # MySQL 所在的主机地址
     port: 0,      # MySQL 端口号
     log: false
   ```

   ```elixir
   config :idb,
     port: 0, # IDB 使用的端口
     ecto_repos: [Idb.Repo]
   ```

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
