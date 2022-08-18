---
title: export
---

# `export`

{== Save all export files associated with model object to current working folder ==}


## Syntax 

    export(m)


## Input arguments 

__`m`__ [ Model ] 
> 
> Model object whose export files will be saved to disk files.
> 


## Output arguments 



## Options 


## Description 

>
> Save all export files associated with the model objects to the current
> working folder. The export files, including their file names, are read
> from the underlying model file at the time of calling the `model( )`
> function. See [`!export`](ModelLang/export) for more on export files.
>
> If a file with the same name as one of the export files already exists in
> its destination folder, a warning is thrown and the file is mercilessly
> overwritten.
>


## Examples
