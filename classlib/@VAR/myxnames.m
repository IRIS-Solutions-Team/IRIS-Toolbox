function varargout = myxnames(This,XNames)
% myxnames  [Not a public function] Assign exogenous names in VARX objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

pp = inputParser( );
pp.addRequired('XNames',@(x) isempty(XNames) ...
    || ischar(XNames) || iscellstr(XNames));
pp.parse(XNames);

%--------------------------------------------------------------------------

nx = length(This.XNames);

if ischar(XNames)
    XNames = regexp(XNames,'!ttrend|\w+','match');
end
XNames = XNames(:).';

if nx > 0 && nx ~= length(XNames)
    utils.error('VARX', ...
        'Incorrect number of exogenous input names supplied.');
end

aux = [This.YNames,XNames];
if length(aux) ~= length(aux)
    utils.error('VARX', ...
        'Names of variables and inputs must be unique.');
end

This.XNames = XNames(:).';
varargout{1} = This;

end
