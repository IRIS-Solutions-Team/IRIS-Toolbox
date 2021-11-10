# !export

{== Create exportable file to be saved in working directory.==}

## Syntax

    !export(FileName)
        FileContents
    !end


## Description

You can include in the model file the contents of files you need or want
to carry around together with the model; a typical example is your own
m-file functions used in model equations.

The file or files are created and saved under the name specified in the
`!export` keyword at the time you load the model using the function
[`model`](model/model). The contents of the export files is are also
stored within the model objects. You can manually re-create and re-save
all exportable files by running the function [`export`](model/export).

If no filename is provided or `FileName` is empty, an error is thrown.



