function c = interp(c, varargin)
% interp  String interpolation from a collection of structs
%{
% ## Syntax ##
%
%
%     c = textual.interp(c, s1, s2, ...)
%
%
% ## Input Arguments ##
%
%
% __`c`__ [ char | cellstr | string ]
% >
% Text string(s) containing interpolation fields (valid Matlab names
% parenthesized and prefixed with `$`) that will be replaced with values
% found in the earliest input struct `s1`, `s2`, etc.
%
%
% __`s1`__ [ struct | char | cellstr | string ]
% >
% Structs or text strings that will be searched for interpolation fields
% occuring in the input string(s) `c`; the earliest value found will be
% used to replace the respective interpolation field in the input
% string(s); the value must be a string or a numeric scalar, otherwise no
% interpolation will be performed.
%
%
% ## Output Arguments ##
%
%
% __`c`__ [ char | cellstr | string ]
% >
% Interpolated output text string(s).
%
%
% ## Description ##
%
%
% Each occurrence of an interpolation field formatted as `$(key)` where
% `key` is a valid Matlab name (a string starting with a letter a
% containing alphanumeric characters and underscores) will trigger the
% following actions:
%
% * the inputs `s1`, `s2`, etc. will be searched (in the order of
% appearance) for the `key`;
%
% * the first occurrence of a struct field named `key` and containing a
% char or a string or a numeric scalar will be used to replace `$(key)` in
% the output string.
%
% * if none such field is found in any of the structs, `s1`, `s2`, etc.,
% the interpolation field will remain unchanged in output string.
%
% ### Text Strings ##
%
% The text strings may be one of the following four forms:
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
%
% The following string interpolation will fail because the `Count` field in
% the struct is not a char or string value:
%
%     >> s1 = struct('Count', 10);
%     >> c = 'X=$(Count)';
%     >> textual.interp(c, s1) 
%     ans =
%         'X=10'
%
%
% ## Example ##
%
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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

if ~ischar(c) && ~iscell(c) && ~isstring(c)
    return
end

inputs = varargin;

%
% Struct
%
inxStruct = cellfun(@isstruct, varargin);
% Do nothing

%
% Single char 'key:value' or string "key:value"
%
inxSingleString = cellfun(@(x) ischar(x) || (isa(x, 'string') && isscalar(x)), varargin);
for i = find(inxSingleString)
    tokens = cellstr(split(inputs{i}, ':'));
    if numel(tokens)==2 && ~isempty(tokens{1}) && ~isempty(tokens{2})
        tokens = strtrim(tokens);
        inputs{i} = struct( );
        inputs{i}.(tokens{1}) = tokens{2};
    end
end

%
% Two-element cell {'key:', 'value'} or {'key:', value}
% Colon is optional
%
inxDoubleCell = cellfun(@(x) iscell(x) && numel(x)==2 && ischar(x{1}), varargin);
for i = find(inxDoubleCell)
    temp = struct( );
    temp.(strtrim(replace(inputs{i}{1}, ':', ''))) = inputs{i}{2};
    inputs{i} = temp;
end

%
% Two-element string ["key:", "value"]
%
inxDoubleString = cellfun(@(x) isa(x, 'string') && numel(x)==2, varargin);
for i = find(inxDoubleString)
    inputs{i} = cellstr(inputs{i});
    temp = struct( );
    temp.(strtrim(replace(inputs{i}{1}, ':', ''))) = inputs{i}{2};
    inputs{i} = temp;
end

%
% Two-element cell with a key list and a value list {keys, values}
%
inxList = cellfun(@(x) iscell(x) && numel(x)==2 && iscellstr(x{1}) && iscell(x{2}) && numel(x{1})==numel(x{2}), varargin);
for i = find(inxList)
    inputs{i} = cell2struct(reshape(inputs{i}{2}, [], 1), cellstr(reshape(inputs{i}{1}, [], 1)), 1);
end 

inxValid = inxStruct | inxSingleString | inxDoubleCell | inxDoubleString | inxList;
if any(~inxValid)
    hereReportInvalidInput( );
end

replaceFunc = @hereInterpolate;
if iscell(c)
    inx = cellfun('isclass', c, 'char');
    c(inx) = regexprep(c(inx), '\$\([A-Za-z]\w*\)', '${replaceFunc($0)}');
else
    c = regexprep(c, '\$\([A-Za-z]\w*\)', '${replaceFunc($0)}');
end

return
    
    function c1 = hereInterpolate(c1)
        key = c1(3:end-1);
        for i = 1 : numel(inputs)
            if isstruct(inputs{i}) && isfield(inputs{i}, key)
                value = inputs{i}.(char(key));
                if validate.string(value)
                    c1 = strtrim(char(value));
                    return
                elseif validate.numericScalar(value)
                    c1 = sprintf('%g', value);
                    return
                end
            end
        end
    end%


    function hereReportInvalidInput( )
        thisError = [
            "Interpolate:InvalidaInput"
            "Each input into textual.interpolate() defining the key-value pairs "
            "must be struct, char, string, 1x2 string, 1x2 cellstr, or {cellstr, cell}."
        ];
        throw(exception.Base(thisError, 'error'));
    end%
end%

