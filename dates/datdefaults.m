function opt = datdefaults(opt, isPlot)
% datdefaults  Set up defaults for date-related opt if they are `@config`.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

try, isPlot; catch, isPlot = false; end %#ok<NOCOM,VUNUS>

%--------------------------------------------------------------------------

irisConfig = iris.get( );

if ~isfield(opt,'dateformat') || isequal(opt.dateformat, @config)
    if ~isPlot
        opt.dateformat = irisConfig.dateformat;
    else
        opt.dateformat = irisConfig.plotdateformat;
    end
end

if ~isfield(opt,'freqletters') || isequal(opt.freqletters, @config)
    opt.freqletters = irisConfig.freqletters;
end

if ~isfield(opt,'months') || isequal(opt.months, @config)
    opt.months = irisConfig.months;
end

if ~isfield(opt, 'ConversionMonth')
    opt.ConversionMonth = iris.Configuration.ConversionMonth;
end

if ~isfield(opt, 'Wday')
    opt.Wday = iris.Configuration.WDay;
end

end%

