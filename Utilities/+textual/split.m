
%{
---
title: split
---

# `split`

{== Split strings and reorganized output arguments ==}

## Syntax

    [part1, part2, ___] = textual.split(inputString, ___)


## Input arguments

__`inputString`__ [ string ]
>
> Input string or string array.
>

## Output arguments

__`partK`__ [ string ]
>
> K-th part of the `inputString` when split by the builtin `split`
function, reshaped to conform with the size of the `inputString`.
>

## Options

Any options valid in the builtin `split`.

## Description

Use the builtin function `split` to split a string (or an array of strings)
at a given character, and reorganize the input arguments into a more
convenient form.


## Example

```matlab
[a, b] = textual.split(["1234-56", "abcd-ef"], "-")

a = 
  1×2 string array
    "1234"    "abcd"
b = 
  1×2 string array
    "56"    "ef"
```

%}

%---8<---

function varargout = split(input, varargin)

input = string(input);
sizeInput = size(input);
input = reshape(input, 1, [ ]);
temp = split(input, varargin{:});
if isscalar(input)
    numOutputs = numel(temp);
    varargout = cell(1, numOutputs);
    for i = 1 : numOutputs
        varargout{i} = temp(i);
    end
else
    numOutputs = size(temp, 3);
    varargout = cell(1, numOutputs);
    for i = 1 : numOutputs
        varargout{i} = reshape(temp(:, :, i), sizeInput);
    end
end

end%



