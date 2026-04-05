#!/bin/sh
if makoctl mode | grep -q do-not-disturb; then
  echo '{"text":"󰂛","class":"disabled"}'
else
  echo '{"text":"󰂚","class":"enabled"}'
fi
