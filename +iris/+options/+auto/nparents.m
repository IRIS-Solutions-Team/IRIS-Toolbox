function Opt = nparents(Opt)
% dtrends  [Not a public function] Auto value for option dtrends=.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch Opt.crossoverType
    case 'hill'
        Opt.nparents = 1 ;
    case {'one-point','two-point'}
        Opt.nparents = 2 ;
    otherwise
        Opt.nparents = 4 ;
end

end
