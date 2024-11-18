# Fake library system to manage books

Experimenting with Phoenix and Ash v3.0.

## Install local environment

We use [devbox](https://www.jetify.com/devbox) to install the necesary packages
and [mise](https://mise.jdx.dev/) to install missing packages and run tasks.

Tools that can not be installed directly from `devbox` because of version issue
are installed via `mise`.

Install [devbox](https://www.jetify.com/docs/devbox/quickstart/) (do it only once):

```sh
curl -fsSL https://get.jetpack.io/devbox | bash
```

Prepare your shell for `mise` (do it only once).

For Bash:

```sh
echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> ~/.bashrc
```

For Zsh:

```sh
echo 'command -v mise &> /dev/null && eval "$(mise activate zsh)"' >> "${ZDOTDIR-$HOME}/.zshrc"
```

Install `devbox`:

```sh
devbox install
```

Enter `devbox` shell:

```sh
devbox shell
```

`(devbox)` at the beginning of the prompt shows that you are inside a devbox
shell:

```sh
(devbox) /home/my-user/my-project$
```

Trust `mise` configuration files (do it only once):

```sh
mise trust mise.toml
mise trust mise.local.toml
```

Install `mise` tools:

```sh
mise install
```

Clean and setup everything:

```sh
mise run reset:local
```

### Post-install

#### Open VSCode

You can use the IDE of your choice inside a `devbox` shell. For example with
VSCode:

```sh
code .
```

#### Run a task

To see available tasks or executed one of them, run with this command:

```sh
mise run
```

#### Start Web server

To start the Phoenix Web service, run with this command:

```sh
cd library
mix phx.server
```

If you change environment variables in `devbox.json`, you will need to restart
the devbox shell and your IDE.
