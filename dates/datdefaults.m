function opt = datdefaults(opt, isPlot)
% datdefaults  Set up defaults for date-related opt if they are `@auto`.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try, isPlot; catch, isPlot = false; end %#ok<NOCOM,VUNUS>

%--------------------------------------------------------------------------

irisConfig = iris.get( );

if ~isfield(opt,'dateformat') || isequal(opt.dateformat, @auto)
    if ~isPlot
        opt.dateformat = irisConfig.dateformat;
    else
        opt.dateformat = irisConfig.plotdateformat;
    end
end

% if ~isfield(opt,'freqletters') || isequal(opt.freqletters, @auto)
%     opt.freqletters = irisConfig.freqletters;
% end

if ~isfield(opt,'months') || isequal(opt.months, @auto)
    opt.months = irisConfig.months;
end

if ~isfield(opt, 'ConversionMonth')
    opt.ConversionMonth = iris.Configuration.ConversionMonth;
end

if ~isfield(opt, 'Wday')
    opt.Wday = iris.Configuration.WDay;
end

end%

