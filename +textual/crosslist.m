function outputList = crosslist(glue, varargin)
% crosslist  Create list of all combinations of components
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

outputList = hereEnsureCellstr(varargin{end});
for component = varargin(end-1:-1:1)
    add = hereEnsureCellstr(component{1});
    temp = cellfun(@(x) strcat(x, glue, outputList), add, 'UniformOutput', false);
    outputList = [temp{:}];
end
outputList = reshape(outputList, [ ], 1);

return

    function c = hereEnsureCellstr(c)
        if isnumeric(c)
            c = arrayfun(@(x) sprintf('%g', x), c, 'UniformOutput', false);
        else
            try, c = cellstr(c);
                catch, error('Inputs to crosslist must be char, cellstr, string or numeric'); end
        end
        c = reshape(c, 1, [ ]);
    end%
end%

