#!/usr/bin/env fish

set INSTALL_DIR "$argv[1]"
if [ -z "$INSTALL_DIR" ]
    set INSTALL_DIR "$HOME/.config/fish/functions"
end

echo "Installing to $INSTALL_DIR"

if [ ! -d functions ]
    echo "functions directory not found, please run this from the root of the repository" >&2
    exit 1
end

if [ ! -d "$INSTALL_DIR" ]
    mkdir -p "$INSTALL_DIR"
    echo "$INSTALL_DIR did not exist, had to create it"
end

echo
echo "Beginning to copy files into $INSTALL_DIR/"

for file in functions/*.fish
    echo "Copying $file to $INSTALL_DIR/"
    cp $file "$INSTALL_DIR/"
end
