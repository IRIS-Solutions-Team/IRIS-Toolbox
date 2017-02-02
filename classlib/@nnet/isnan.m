function out = isnan(This) 

% isnan  [Not a public function] Test whether some parameters in a neural
% network model object are NaN (e.g., to determine if these connections
% should be removed). 
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

params = [...
    get(This,'activation'); ...
    get(This,'output'); ...
    get(This,'hyper'); ...
    ];

if any(isnan(params))
    out = true ;
else
    out = false ;
end

end

