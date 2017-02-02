function varargout = myenames(This,varargin)
% myenames  [Not a public function] Get or set names of varobj residuals.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

if isempty(varargin)
    varargout{1} = This.ENames;
    return
end

%--------------------------------------------------------------------------

ENames = varargin{1};

ny = size(This.A,1);
if ny == 0 && ~isempty(This.YNames)
    ny = length(This.YNames);
end

if ny == 0
    utils.error('varobj', ...
        'Cannot set the names of residuals before the names of variables.');
end

if isempty(ENames)
    ENames = @(yname,n) sprintf('res_%s',yname);
elseif ischar(ENames)
    ENames = regexp(ENames,'\w+','match');
elseif iscellstr(ENames)
    %
elseif isa(ENames,'function_handle') && ~isempty(This.YNames)
    %
else
    utils.error('VAR', ...
        'Invalid type of input for VAR residual names.');
end

if ny > 0 && iscellstr(ENames) && ny ~= length(ENames)
    utils.error('VAR', ...
        'Incorret number of residual names supplied.');
end

if iscellstr(ENames)
    This.ENames = ENames(:).';
elseif ~isempty(This.YNames) && isa(ENames,'function_handle')
    This.ENames = cell(1,ny);
    for i = 1 : ny
        This.ENames{i} = ENames(This.YNames{i},i);
    end
else
    This.ENames = cell(1,0);
end

if unique(length(This.ENames)) ~= length(This.ENames)
    utils.error('VAR', ...
        'Residual names must be unique.');
end

varargout{1} = This;

end