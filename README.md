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
echo 'eval "$(mise activate bash)" 2> /dev/null' >> ~/.bashrc
```

For Zsh:

```sh
echo 'eval "$(mise activate zsh)" 2> /dev/null' >> "${ZDOTDIR-$HOME}/.zshrc"
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

Clean and setup everything:

```sh
mise run reset:local
```

You can use the IDE of your choice inside a `devbox` shell. For example with
VSCode:

```sh
code .
```

To see available tasks or executed one of them, run with this command:

```sh
mise run
```

If you change environment variables in `devbox.json`, you will need to restart
the devbox shell and your IDE.
