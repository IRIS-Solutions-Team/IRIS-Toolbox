---
title: iris.startup
---

# `iris.startup`

{== Start an Iris session ==}

## Syntax

    iris.startup
    iris.startup(flag, flag, ...)


## Flags

__`"silent"`__ 
> 
> Do not print introductory message on the screen.
> 

__`"tseries"`__ 
> 
> Use the old `tseries` class as the default time series class.
> 

__`"noIdCheck"`__
> 
> Do not verify the Iris release check file.
> 

__`"noTeX"`__
> 
> Do not look up TeX executables.
> 

__`"noMatlabCheck"`__
> 
> Do not perform verification of the minimum required Matlab release.
> 


## Description

We recommend that you keep the IRIS root directory on the permanent
Matlab search path. Each time you wish to start working with IRIS, you
run `iris.startup` form the command line. At the end of the session, you
can run [`iris.finish`](./finish.md) to remove IRIS
subfolders from the temporary Matlab search path, and to clear persistent
variables in some of the backend functions.

The `iris.startup` performs the following steps:

* Adds necessary IRIS subdirectories to the temporary Matlab search
path.

* Removes redundant IRIS folders (e.g. other or older installations) from
the Matlab search path.

* Resets IRIS configuration options to default and updates the location
of TeX/LaTeX executables.


## Examples


### Plain vanilla startup

```matlab
iris.startup
```


### Startup with no intro message 

```matlab
iris.startup("silent")
```

