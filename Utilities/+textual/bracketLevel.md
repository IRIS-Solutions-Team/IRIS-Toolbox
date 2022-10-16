---
title: textual.bracketLevel
---

# `bracketLevel` ^^(+textual)^^


{== Return the nested bracket level for each character in a string ==}


## Syntax


    [level, allClosed] = textual.bracetLevel(inputString, bracketTypes)


## Input arguments


__`inputString`__ [ char | string ]
>
> Input string; for each of the characters in the `inputString`, a number
> greater than or equal to 0 will be returned indicating the level of
> nested brackets at the position.
> 


__`bracketTypes`__ [ cellstr | string ]
>
> List of bracket types that will be counted; can be any combination of the
> following four types of brackets: `()`, `[]`, `{}`, `<>`. In addition,
> the `bracketTypes` can be a single quote, `'`, or a double qoute, `"`;
> see Description.
> 


## Output arguments


__`level`__ [ numeric ]
>
> A vector of numbers greater than or equal to 0 indicating the the level
> of nested brackets at the respective position in the `inputString`; all
> opening and closing brackets are counted as inside themselves.
> 

__`allClosed`__ [ `true` | `false` ]
> 
> True if all brackets are closed by the end of the string.
> 


## Description


The output `level` will be as long as the input string. Its value will be

* increased by 1 for each opening bracket or an odd occurrence of a
  singleton mark on the `bracketTypes` list;

* decreased by 1 for each closing bracket or an even occurrence of a
  singleton mark on the `bracketTypes` list.


## Example


