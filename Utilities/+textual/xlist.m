% textual.xlist  Create list of all combinations of components
%{
% ## Syntax
%
%     output = textual.xlist(glue, component, component, etc...)
%
%
% ## Input arguments
% 
% __`glue`__ [ char | string ]
%
%>    String that will be used as a glue placed between individual components.
%
%
% __`component`__ [ char | cellstr | string | numeric ]
%
%>    Individual components from which the output string will be composed. Each
%>    `component` can be either a scalar (a char vector, a string scalar, or a
%>    numeric scalar) or a non-scalar (a cell array of chars, a string array,
%>    or a numeric array); see Description for how non-scalar inputs are
%>    combined into the final `output`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`output`__ [ string ]
%
%>    Horizontal string vector composed from the input components.
%
%
% ## Description
%
% If each of the inputs is a scalar (a char vector, a string scalar, or a
% numeric scalar), the final `output` is either a char vector or a string
% scalar consisting of the individual components separated by the `glue`.
%
% Any numeric input is converted to a char or string using the standard
% `sprintf(~)` function with a `%g` format.
% 
% The default type (class) of the `output` is string. The `output` is a
% char vector if neither any input nor the glue is a string, and at least
% one input is a char. The output is a cell array of chars if neither any
% input nor the glue is a string, and at least one input is a cell array of
% chars.
%
%
% ## Example
%
% Example of scalar components;  
%
%     >> textual.xlist("_", "my", "scalar", "xlist")
%     ans =
%         "my_scalar_xlist"
%
%     >> textual.xlist("_", 1, 2, 3) 
%     ans =
%         "1_2_3"
%
% Obviously, the same result can be here achieved by simply running
%
%     >> join(["my", "scalar", "xlist"], "_")
%
%
% ## Example
%
% Example of array components
%
%     >> textual.xlist("_", ["a", "b", "c"], ["1", "2", "3", "4"], ["#", $"])
%     ans =
%       1x24 string array
%       Columns 1 through 10
%         "a_1_#"    "a_1_$"    "a_2_#"    "a_2_$"    "a_3_#"    "a_3_$"    "a_4_#"    "a_4_$"    "b_1_#"    "b_1_$"
%       Columns 11 through 20
%         "b_2_#"    "b_2_$"    "b_3_#"    "b_3_$"    "b_4_#"    "b_4_$"    "c_1_#"    "c_1_$"    "c_2_#"    "c_2_$"
%       Columns 21 through 24
%         "c_3_#"    "c_3_$"    "c_4_#"    "c_4_$"
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = xlist(glue, varargin)
    glue = string(glue);
    varargin = cellfun(@local_ensureType, varargin, 'uniformOutput', false);
    output = varargin{end};
    for x = varargin(end-1:-1:1)
        output = reshape(x{:} + glue + reshape(output, [], 1), 1, []);
    end
end%


function c = local_ensureType(c)
    if isnumeric(c)
        c = arrayfun(@(x) sprintf('%g', x), c, 'UniformOutput', false);
        c = string(c);
    else
        try
            c = string(c);
        catch exc
            error('Inputs to textual.crosslist(~) must be char, cellstr, string or numeric');
        end
    end
    c = reshape(c, 1, [ ]);
end%

