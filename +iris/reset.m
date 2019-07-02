function irisConfig = reset(options)
% iris.reset  Reset IRIS configuration options to start-up values
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

iris.Configuration.clear( );

irisConfig = iris.Configuration( );

if isequal(options.tseries, true)
    irisConfig.DefaultTimeSeriesConstructor = @tseries;
else
    irisConfig.DefaultTimeSeriesConstructor = @Series;
end

save(irisConfig);

end%

