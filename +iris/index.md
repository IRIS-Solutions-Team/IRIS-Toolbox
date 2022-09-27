
# Setting up Iris

This section describes how to [install Iris](install.md), start and quit
an Iris session, and how to customise some of the Iris configuration
options.

The most common way of starting an Iris session (after you have installed
the Iris files on your disk) is to run the following line in the
Matlab command window:

```matlab
addpath C:\IrisT_Tbx; irisstartup();
```

The first command, `addpath`, adds the Iris root folder to the Matlab
search path. The second command, `iris.startup()`, initialises Iris and puts
the other necessary Iris subfolders, classes, and internal packages on
the search path. *Neveradd these other subfolders, classes and packages
to the search path by yourself.


## Categorical list of functions 

### Starting and quitting Iris


Function | Description 
---|---
[`iris.startup`](startup.md) | Start an Iris session.
[`iris.finish`](finish.md) | Close the current Iris session.
[`iris.cleanup`](cleanup.md) | Remove Iris from Matlab and clean up.


### Getting information about Iris configuration

Function | Description 
---|---
[`iris.get`](get.md) | Get the current value of an Iris config setting.
[`iris.root`](root.md) | Current Iris root folder.
[`iris.required`](required.md) | Throw error if the installed release of Iris fails to comply with the required minimum.
[`iris.release`](release.md) | Current Iris release number.


### Changes in configuration

Function | Description 
---|---
[`iris.set`](set.md) | Change the value of an Iris config setting.
[`iris.reset`](reset.md) | Reset the values of all Iris config settings.

