function required(Min)
% iris.required  Throw error if the installed version of IRIS fails to comply with the required minimum.
%
% __Syntax__
%
%     iris.required(V)
%
%
% __Input Arguments__
%
% * `V` [ char ] - Text string describing the oldest acceptable
% distribution of IRIS.
%
%
% __Description__
%
% If the version of IRIS present on the computer does not comply with the
% minimum requirement `V`, an error is thrown.
%
%
% __Example__
%
% All of the three calls are valid:
%
%     iris.required(20111222);
%     iris.required('20111222');
%     iris.required 20111222;
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Min)
    Min = sscanf(Min, '%g', 1);
end
if ~isnumeric(Min) || ~isscalar(Min) || ~isfinite(Min)
    error( 'config:iris:required', ...
           'Invalid input argument to iris.required' );
end

[vChar, vNum] = iris.version( );

if vNum<Min
    if round(Min)==Min
        dec = 0;
    else
        dec = 8;
    end
    error( 'config:iris:required', ...
           [ 'IRIS Toolbox Release %.*f or later is required. ', ...
             'Your are currently using IRIS Toolbox Release %s.' ], dec, Min, vChar );
end

end%

