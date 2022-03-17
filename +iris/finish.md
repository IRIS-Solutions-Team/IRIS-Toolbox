---
title: finish
---

# `iris.finish`

{== Close down the current IrisT session ==}

## Syntax

    iris.finish
    iris.finish -shutup


## Description

This function removes all IrisT subfolders from the temporary Matlab
search path, and clears persistent variables in some of the backend
functions. A short message is displayed with the list of subfolders
removed from the path unless you call use the option `-shutup`.  The IrisT
root folder stays on the permanent Matlab path.


## Example


