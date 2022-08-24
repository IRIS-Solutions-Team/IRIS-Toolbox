function [X, Pos, Select, NotFound] = select(X, Descript, Select)
% select  Return ACF, XSF, FFRF, IFRF submatrices for a selection of variables.
%
% __Syntax__
%
%     X = select(X, RowAndColumnNames, Selection)
%
%
% __Input Arguments__
%
% * `X` [ numeric ] - Array returned by one of the functions `acf`, `xsf`, 
% `ffrf`, or `ifrf`.
%
% * `RowAndColumnNames` [ cellstr | cell | string ] - Variable names in
% rows and columns of the input matrix.
%
% * `Selection` [ cell | cellstr | char ] - Selection of variables for
% which the corresponding submatrices will be returned.
%
%
% __Output Arguments__
%
% * `X` [ numeric ] - Submatrix extracted from the input matrix `X` with
% rows and columns corresponding to the selected variables.
%
%
% __Description__
%
%
% __Example__
%
% We first compute the autocovariance and autocorrelation fuctions for all
% variables of the model object `m` using the [`acf`](model/acf) function.
% This step gives us a potentially large matricex `C` and `R`. We only want
% to examine the ACF matrices for a subset of variables, namely `X`, `Y`, 
% and the first lag of `Z`. We call the `select` function and get a 3-by-3
% submatrix `C0`.
%
%     [C, R] = acf(m);
%     C0 = select(C, {'X', 'Y', 'Z', 'Z{-1}'});

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

pp = inputParser( );
pp.addRequired('X', @isnumeric);
pp.addRequired('RowColNames', @(x) iscellstr(x) ...
    || (iscell(x) && numel(x)==2 && iscellstr(x{1}) && iscellstr(x{2})));
pp.addRequired('selection', @(x) ischar(x) || iscellstr(x) ...
    || (iscell(x) && numel(x)==2 && iscellstr(x{1}) && iscellstr(x{2})));
pp.parse(X, Descript, Select);

%--------------------------------------------------------------------------

% Replace log(xxx) with xxx.
removelogfunc = @(x) regexprep(x, 'log\((.*?)\)', '$1');

if iscellstr(Descript)
    Descript = {Descript, Descript};
end
Descript{1} = removelogfunc(Descript{1});
Descript{2} = removelogfunc(Descript{2});

% Find names in char list.
if ischar(Select)
    Select = removelogfunc(Select);
    Select = regexp(Select, '\w+', 'match');
end
oneselection = false;
if iscellstr(Select)
    oneselection = true;
    Select = {Select, Select};
end
Select{1} = removelogfunc(Select{1});
Select{2} = removelogfunc(Select{2});

if isnumeric(X)
    Pos = cell(1, 2);
    NotFound = cell(1, 2);
    for i = 1 : 2
        for j = 1 : length(Select{i})
            k = strcmp(Descript{i}, Select{i}{j});
            if any(k)
                Pos{i}(end+1) = find(k, 1);
            else
                NotFound{i}{end+1} = Select{i}{j}; %#ok<*AGROW>
            end
        end
    end
    if oneselection
        NotFound = intersect(NotFound{1:2});
    else
        NotFound = union(NotFound{1:2});
    end
    if isempty(Pos{1})
        Pos{1} = 1 : size(X, 1);
    end
    if isempty(Pos{2})
        Pos{2} = 1 : size(X, 2);
    end
    subsref = cell(1, ndims(X));
    subsref(1:2) = Pos;
    subsref(3:end) = {':'};
    X = X(subsref{:});
elseif isstruct(X)
    [Pos, NotFound] = textfun.findnames(descriptor, Select);
    Pos(isnan(Pos)) = [ ];
    list = fieldnames(X);
    for i = 1 : length(list)
        if isa(X.(list{i}), 'Series')
            X.(list{i}) = X.(list{i}){:, Pos};
        end
    end
end

if ~isempty(NotFound)
    utils.error('utils:select', ...
        'Name ''%s'' not found in the description of rows or columns.', ...
        NotFound{:});
end

end
