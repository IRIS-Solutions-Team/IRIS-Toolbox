function RealSmall = getrealsmall(varargin)
% getrealsmall  [Not a public function] Context-specific tolerance.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin > 0
    context = varargin{1};
else
    context = '';
end

switch lower(context)
    case 'mse'
        RealSmall = eps^(7/9);
    otherwise
        RealSmall = eps^(5/9);
end

end
