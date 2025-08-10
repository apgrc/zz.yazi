# zz.yazi

Simple [Yazi](https://github.com/sxyazi/yazi) plugin to move the cursor the
center of the screen, like vim's `zz` motion. It also can move the cursor
to the top (`zt`) and to the bottom (`zb`) of the screen.

## Installation

```sh
ya pkg add apgrc/zz

```

## Configuration

After installation add this to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = [ "z", "z" ]
run = "plugin zz center"
desc = "center cursor"

[[mgr.prepend_keymap]]
on = [ "z", "t" ]
run = "plugin zz top"
desc = "top cursor"

[[mgr.prepend_keymap]]
on = [ "z", "b" ]
run = "plugin zz bottom"
desc = "bottom cursor"
```
