# Compile Aseprite on Linux
This is a script to automate compiling Aseprite on Ubuntu, Fedora, and more! If you're using an immutable distro, run it in a container with toolbox or distrobox. See section on [Immutable Distros](https://github.com/mak448a/compile-aseprite-linux/edit/main/README.md).

If you want to support the developers, buy it from [Aseprite.org](https://aseprite.org)!

## Compilation
To run the script, simply open a terminal window and paste this command:
```bash
bash -c "$(curl -sSf 'https://raw.githubusercontent.com/mak448a/compile-aseprite-linux/refs/heads/main/compile.sh')"
```

Please consider giving this repo a star if you found it helpful.
If you encounter any errors, please report them in the issues tab.

## Where is the executable?
The executable is stored in ~/.local/share/aseprite. Have fun!

## How do I run Aseprite?
This script automatically adds Aseprite to your desktop environment's application launcher and to $PATH.
You can launch it from your desktop environment's application launcher or by entering `aseprite` in the terminal.

## Uninstall
To remove all files created by the compile.sh script, paste this command. Your configuration, themes, or installed templates in ~/.config/aseprite will not be deleted.
```bash
bash -c "$(curl -sSf 'https://raw.githubusercontent.com/mak448a/compile-aseprite-linux/refs/heads/main/uninstall.sh')"
```

## Immutable Distros
For Fedora Silverblue
```shell
toolbox create
toolbox enter
bash -c "$(curl -sSf 'https://raw.githubusercontent.com/mak448a/compile-aseprite-linux/refs/heads/main/compile.sh')"
```
For other distros with distrobox
```shell
distrobox create -n box
distrobox enter box
bash -c "$(curl -sSf 'https://raw.githubusercontent.com/mak448a/compile-aseprite-linux/refs/heads/main/compile.sh')"
```

## Credits
I used [Aseprite's official compilation guide](https://github.com/aseprite/aseprite/blob/main/INSTALL.md) to make this script.
