---
title: textual.write
---

# `textual.write`

{== Write character string to text file ==}

## Syntax

    textual.write(c, fileName, ...)
    textual.write(c, fileName, precision, ...)


## Input Arguments

**c** [ char | string ] -
Character vector or string that will be written to the file.

**fileName** [ char ] -
Name of the destination file.

**~precision** [ char ] -
Form and precision of the data written to the file; if omitted,
`precision='char'`.


## Options

**MachineFormat='native'** [ char | string ] 
Format for writing bytes and bits in the destination file.

**Encoding=@auto** [ `@auto` | char | string ] -
Encoding scheme for writing in the destination file; `@auto` means the
operating system default scheme.


## Description


## Example



