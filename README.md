# Compile Aseprite on Linux
Here's how to compile aseprite for free on Fedora, Ubuntu, and more! If you want to support the developers, buy it from [Aseprite.org](https://aseprite.org)!

To run the script, simply open a terminal window, and paste this:
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

## Credits
I used [Aseprite's official compilation guide](https://github.com/aseprite/aseprite/blob/main/INSTALL.md) to make this script.
