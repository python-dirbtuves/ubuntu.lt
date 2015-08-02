## init-scripts
---

These scripts are intended for the development environment initialisation.

For your convenience the creation of the virtual environment process has been squeesed to just you choosing a name for your virtual-env :)

I.e. if you have chosen to call it `ubnt`, simply issue following command in your linux terminal:

    ./cn_mkfs.sh ubnt

That's it. In a short while you will have base Debian Wheezy system installed to `/home/containers/ubnt`.

Don't worry, this system is really tiny and has only the basic components you need to start with.
In fact as tiny as ~400MB, so please make sure you have at least that much free space on you HDD.

    # du -sh ubnt/
    393M  ubnt/

On one of my test-servers it took 131 sec to complete, on other - 588 sec, your milage may also vary.

Please refer to the `cn_mkfs.log` to inspect the normal output during the installation.
