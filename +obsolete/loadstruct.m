function X = loadstruct(FName)
% loadstruct  Load object saved previously by SAVESTRUCT.
%
% Syntax
% =======
%
%     X = loadstruct(FName)
%
% Input arguments
% ================
%
% * `FName` [ char ] - File name.
%
% Output arguments
% =================
%
% * `X` [ ... ] - Object loaded.
%
% Description
% ============
%
% The functions `savestruct` and `loadstruct` were introduced to deal with
% some inefficiencies in standard saving and loading procedures in older
% Matlabs. In current versions of Matlab, this is no longer necessary, and
% `savestruct` and `loadstruct` functions are considered obsolete.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% ##### Jan 2014 OBSOLETE and scheduled for removal.
utils.warning('obsolete', ...
    ['The function loadstruct( ) is obsolete, and', ...
    'will be removed from IRIS in a future release. ', ...
    'Use save( ) and load( ), or saveasto( ) and loadasfrom( ) instead.']);

% Load all entries.
% Because keywords are loaded with underscores, fix their names.
list = who('-file',FName);
list = list(:).';
index = cellfun(@iskeyword,list);
if any(~index)
    % Silence warnings about unknown object classes.
    state = warning('query');
    warning('off'); %#ok<WNOFF>
    X = load('-mat',FName,list{~index});
    warning(state);
else
    X = struct( );
end
if any(index)
    state = warning('query');
    warning('off','MATLAB:load:loadingKeywordVariable');
    temp = load('-mat',FName,list{index});
    temp = struct2cell(temp);
    for i = find(index)
        X.(list{i}) = temp{i};
    end
    warning(state);
else
    state = warning('query');
    warning('off'); %#ok<WNOFF>
    X = load('-mat',FName);
    warning(state);
end

% Determine class of the saved object.
if isfield(X,'SAVESTRUCT_CLASS')
    cl = X.SAVESTRUCT_CLASS;
    X = rmfield(X,'SAVESTRUCT_CLASS');
else
    if isfield(X,'IRIS_MODEL')
        cl = 'model';
        X = rmfield(X,'IRIS_MODEL');
    elseif isfield(X,'IRIS_VAR')
        cl = 'VAR';
        X = rmfield(X,'IRIS_VAR');
    elseif isfield(X,'IRIS_RVAR')
        cl = 'VAR';
        X = rmfield(X,'IRIS_RVAR');
    elseif isfield(X,'IRIS_TSERIES') || ( ...
            isfield(X,'start') && isfield(X,'data'))
        cl = 'tseries';
        X = rmfield(X,'IRIS_TSERIES');
    elseif isfield(X,'IRIS_CONTAINER')
        cl = 'container';
        X = rmfield(X,'IRIS_CONTAINER');
    else
        cl = 'struct';
    end
end

switch cl
    case 'model'
        X = model.loadobj(X);
    case 'VAR'
        X = VAR.loadobj(X);
    case 'tseries'
        X = tseries(X);
    case 'container'
        X = container.loadobj(X);
end

end
