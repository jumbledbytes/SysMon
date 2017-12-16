#!/bin/zsh

icon=$1

mkdir $icon.iconset                                                                      
sips -z 58 58       $icon.png --out $icon.iconset/$icon.settings@2x.png
sips -z 120 120     $icon.png --out $icon.iconset/$icon.logo@2x.png

