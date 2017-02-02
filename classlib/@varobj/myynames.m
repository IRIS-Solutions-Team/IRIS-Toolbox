function varargout = myynames(This,YNames)
% myynames [Not a public function] Get or set endogenous names in varobj variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    YNames; 
catch
    varargout{1} = This.YNames;
    return
end

pp = inputParser( );
pp.addRequired('V',@(x) isa(x,'varobj'));
pp.addRequired('YNames',@(x) isempty(YNames) ...
    || ischar(YNames) || iscellstr(YNames) || isfunc(YNames));
pp.parse(This,YNames);

%--------------------------------------------------------------------------

ny = myny(This);

if isempty(YNames)
    YNames = @(n) sprintf('y%g',n);
elseif ischar(YNames)
    YNames = regexp(YNames,'\w+','match');
end

if ny > 0 && iscellstr(YNames) && ny ~= length(YNames)
    utils.error('VAR', ...
        'Incorrect number of variable names supplied.');
end

if iscellstr(YNames)
    This.YNames = YNames(:).';
elseif isfunc(YNames) && ny > 0
    This.YNames = cell(1,ny);
    for i = 1 : ny
        This.YNames{i} = YNames(i);
    end
end

if length(unique(This.YNames)) ~= length(This.YNames)
    utils.error('VAR', ...
        'Names of variables must be unique.');
end

varargout{1} = This;

end