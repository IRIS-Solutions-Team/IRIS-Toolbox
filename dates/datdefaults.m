function opt = datdefaults(opt, isPlot)
% datdefaults  Set up defaults for date-related opt if they are `@config`.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try, isPlot; catch, isPlot = false; end %#ok<NOCOM,VUNUS>

%--------------------------------------------------------------------------

cfg = irisconfigmaster('get');

if ~isfield(opt,'dateformat') || isequal(opt.dateformat, @config)
    if ~isPlot
        opt.dateformat = cfg.dateformat;
    else
        opt.dateformat = cfg.plotdateformat;
    end
end

if ~isfield(opt,'freqletters') || isequal(opt.freqletters, @config)
    opt.freqletters = cfg.freqletters;
end

if ~isfield(opt,'months') || isequal(opt.months, @config)
    opt.months = cfg.months;
end

if ~isfield(opt, 'ConversionMonth') || isequal(opt.ConversionMonth, @config)
    opt.ConversionMonth = cfg.ConversionMonth;
end

if ~isfield(opt, 'Wday') || isequal(opt.Wday, @config)
    opt.Wday = cfg.Wday;
end

end
