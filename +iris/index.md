
# Setting up IrisT

This section describes how to start and quit an IrisT session, and how to
customise some of the IrisT configuration options.

The most common way of starting an IrisT session (after you have installed
the IrisT files on your disk) is to run the following line in the
Matlab command window:

```matlab
addpath C:\IrisT_Tbx; irisstartup();
```

The first command, `addpath`, adds the IrisT root folder to the Matlab
search path. The second command, `iris.startup()`, initialises IrisT and puts
the other necessary IrisT subfolders, classes, and internal packages on
the search path. *Neveradd these other subfolders, classes and packages
to the search path by yourself.


## Categorical list of functions 

### Starting and quitting IrisT


Function | Description 
---|---
[`iris.startup`](startup.md) | Start an IrisT session.
[`iris.finish`](finish.md) | Close the current IrisT session.
[`iris.cleanup`](cleanup.md) | Remove IrisT from Matlab and clean up.


### Getting information about IrisT configuration

Function | Description 
---|---
[`iris.get`](get.md) | Query current IrisT config options.
[`iris.man`](man.md) | Open IrisT Reference Manual PDF.
[`iris.root`](root.md) | Current IrisT root folder.
[`iris.required`](required.md) | Throw error if the installed version of IrisT fails to comply with the required minimum.
[`iris.version`](version.md) | Current IrisT version.


### Changes in configuration

Function | Description 
---|---
[`iris.set`](set.md) | Change configurable IrisT options
[`iris.reset`](reset.md) | Reset IrisT configuration options to start-up values

