---
title: iris.finish
---

# `iris.finish`

{== End the current Iris session ==}


## Syntax

    iris.finish


## Description

This function removes all Iris subfolders from the temporary Matlab search
path, and clears persistent variables in some of the backend functions. A
short message is displayed with the list of subfolders removed from the
path. The Iris root folder stays on the permanent Matlab path.


## Example

```matlab
>> iris.finish()
```


