# Compile Aseprite on Linux
Here's how to compile aseprite for free on Fedora, Ubuntu, and more! If you want to support the developers, buy it on their website: https://aseprite.org

Just run [this script.](compile.sh) Click view raw, and then press CTRL+S to save the file.
Go to your downloads folder and open up a terminal window. Type in these commands:
`chmod +x compile.sh`
`./compile.sh`

Please consider giving this repo a star if you found it helpful.

## Where is the executable?
The executable is stored in ~/Applications/aseprite. Have fun!

## Integrating with your desktop environment
Download the aseprite.desktop file from this GitHub repository and move it to ~/.local/share/applications.
Then, it should appear in your application menu!

## Credits
I copied the compile commands from https://github.com/aseprite/aseprite/blob/main/INSTALL.md and condensed them into this script.
