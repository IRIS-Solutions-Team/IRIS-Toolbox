function C = fprintf(This,FName,varargin)
% Fprintf  [Not a public function] Print model object back to model file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = sprintf(This,varargin{:});
char2file(C,FName);

end