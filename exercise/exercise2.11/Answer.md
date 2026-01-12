Not a dev. So I can't think of a dev like app. But I love python http server. Whenever I need to transfer files between laptops and it's too cumbersome to setup SSH or other file sharing, I would go to the dir and start python3 -m http.server to copy the files from other machines via browser.

So I decided to create and and containerized fake movie download site.

The fake movie files are in the ./movies folder on my host machine which I bind mount.