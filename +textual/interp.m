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
% __`s1`__ [ struct | char | cellstr | string ] -
% Structs or text strings that will be searched for interpolation fields occuring in the
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
% Each occurrence of an interpolation field formatted as `$(key)` where
% `key` is a valid Matlab name (a string starting with a letter a
% containing alphanumeric characters and underscores) will trigger the
% following actions:
%
% * the input structs `s1`, `s2`, etc. will be searched (in the input
% order) for the `key`;
%
% * the first occurrence of a struct field named `key` and containing a
% char or string value will be used to replace `$(key)` in the output
% string.
%
% * if none such field is found in any of the structs, `s1`, `s2`, etc.,
% the interpolation field will remain unchanged in output string.
%
% ### Text Strings ##
%
% The text strings may be have one of the following four forms:
%
% * a single character vector `'key: value'`;
%
% * a scalar string `"key: value"`;
%
% * a two element cellstr array `{'key', 'value'}` or `{'key:', 'value'}`;
%
% * a two element string array `["key", "value"]` or `["key:", "value"]`.
%
% The colon is optional in the last two forms.
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
% The following string interpolation will use the value of `key` from the second
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

if ~ischar(c) && ~iscell(c) && ~isa(c, 'string')
    return
end

inputs = varargin;

%
% Single char 'key:value' or string "key:value"
%
inxSingleString = cellfun(@(x) ischar(x) || (isa(x, 'string') && isscalar(x)), varargin);
for i = find(inxSingleString)
    tokens = regexp(inputs{i}, '(\<[A-Za-z]\w*\>):(.*)', 'tokens', 'once');
    if numel(tokens)==2 && ~isempty(tokens{1}) && ~isempty(tokens{2})
        tokens = strtrim(tokens);
        inputs{i} = struct(tokens{1:2});
    end
end

%
% Two-element cellstr {'key:', 'value'} or string ["key:", "value"]
% Colon is optional
%
inxDoubleString = cellfun(@(x) (iscellstr(x) || isa(x, 'string')) && numel(x)==2, varargin);
for i = find(inxDoubleString)
    tokens = cellstr(inputs{i});
    tokens{1} = strrep(tokens{1}, ":", "");
    tokens = strtrim(tokens);
    inputs{i} = struct(tokens{1:2});
end

replace = @hereInterpolate;
if iscell(c)
    inx = cellfun('isclass', c, 'char');
    c(inx) = regexprep(c(inx), '\$\([A-Za-z]\w*\)', '${replace($0)}');
else
    c = regexprep(c, '\$\([A-Za-z]\w*\)', '${replace($0)}');
end

return
    
    function c1 = hereInterpolate(c1)
        key = c1(3:end-1);
        for i = 1 : numel(inputs)
            if isstruct(inputs{i}) && isfield(inputs{i}, key)
                value = getfield(inputs{i}, key);
                if validate.string(value)
                    c1 = char(value);
                    return
                end
            end
        end
    end%
end%

