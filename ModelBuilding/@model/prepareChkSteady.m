function opt = prepareChkSteady(this, mode, varargin) %#ok<INUSL>
% prepareChkSteady  Prepare steady-state check.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if length(varargin)==1 && isequal(varargin{1}, false)
    opt = false;
    return
end

if length(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

opt = passvalopt('model.mychksstate', varargin{:});

%--------------------------------------------------------------------------

end