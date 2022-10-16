---
title: rephrase.Text
---

# `rephrase.Text` ^^(+rephrase)^^

{== Create a Text object for rephrase reports ==}


## Syntax 

    output = rephrase.Text.fromFile(title, fileName, varargin)
    output = rephrase.Text.fromString(title, text, varargin)

## Input arguments 

__`title`__ [ string ]
> 
> Title text for the text.
> 

__`fileName`__ [ string ]
> 
> File name with specified location.
> 

__`text`__ [ string ]
> 
> Text string to be inserted into the object.
> 

## Output arguments 

__`output`__ [ Table ]
> 
> Text type object with the assigned arguements to be passed
> into the rephrase objects.
> 

## Options 

__`ParseFormulas=true`__ [ `true*` | `false` ]
> 
> Flag which enables parsing formulas by default.
> 

__`HighlightCodeBlocks=true`__ [ `true*` | `false` ]
> 
> Flag which enables highlighting code blocks by default.
> 

## Possible children

None

## Description 

The function `+rephrase/Text` returns the Text object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Grid`.

## Examples

```matlab

% Using text strings from another file
txt1 = rephrase.Text.fromFile("" ,"text.md" )

% Using text strings
txt1 = rephrase.Text.fromString("" ,"Text" )

```
