function c = interp(c, varargin)
% interp  String interpolation from a collection of structs
%{
% ## Syntax ##
%
%     c = textual.interp(c, s1, s2, ...)
%
%
% ## Input Arguments ##
%
% __`c`__ [ char | cellstr | string ] -
% Text string(s) containing interpolation fields (valid Matlab names
% parenthesized and prefixed with `$`) that will be replaced with values
% found in the earliest input struct `s1`, `s2`, etc.
%
% __`s1`__ [ struct ] -
% Structs that will be searched for interpolation fields occuring in the
% input string(s) `c`; the earliest value found will be used to replace the
% respective interpolation field in the input string(s); the value must be
% a string itself, otherwise no interpolation will be performed.
%
%
% ## Output Arguments ##
%
% __`c`__ [ char | cellstr | string ] -
% Interpolated output text string(s).
%
%
% ## Description ##
%
% Each occurrence of an interpolation field formatted as `$(name)` where
% `name` is a valid Matlab name (a string starting with a letter a
% containing alphanumeric characters and underscores) will trigger the
% following actions:
%
% * the input structs `s1`, `s2`, etc. will be searched (in the input
% order) for the `name`;
%
% * the first occurrence of a struct field named `name` and containing a
% char or string value will be used to replace `$(name)` in the output
% string.
%
% * if none such field is found in any of the structs, `s1`, `s2`, etc.,
% the interpolation field will remain unchanged in output string.
%
%
% ## Example ##
%
%     >> s1 = struct('Count', '10');
%     >> c = 'X=$(Count)';
%     >> textual.interp(c, s1) 
%     ans =
%         'X=10'
%
%
% ## Example ##
% 
% The following string interpolation will fail because the `Count` field in
% the struct is not a char or string value:
%
%     >> s1 = struct('Count', 10);
%     >> c = 'X=$(Count)';
%     >> textual.interp(c, s1) 
%     ans =
%         'X=$(Count)'
%
%
% ## Example ##
% 
% The following string interpolation will use the value of `name` from the second
% struct because it is the first char or string value found:
%
%     >> s1 = struct('Count', 10);
%     >> s2 = struct('Count', '20');
%     >> c = 'X=$(Count)';
%     >> textual.interp(c, s1, s2)
%     ans =
%         'X=20'
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

inputs = varargin;
replace = @hereInterolate;
c = regexprep(c, '\$\([A-Za-z]\w*\)', '${replace($0)}');

return
    
    function c1 = hereInterolate(c1)
        name = c1(3:end-1);
        for i = 1 : numel(inputs)
            if isfield(inputs{i}, name)
                value = getfield(inputs{i}, name);
                if Valid.string(value)
                    c1 = char(value);
                    return
                end
            end
        end
    end%
end%

