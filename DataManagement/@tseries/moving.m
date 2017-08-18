function This = moving(varargin)
% moving  Apply function to moving window of observations.
%
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = moving(X,~Range,...)
%
%
% Input arguments
% ================
%
%
% * `X` [ tseries ] - Tseries object on whose observations the function
% will be applied.
%
% * `~Range` [ numeric | char | *`@all`* ] - Date range from which input
% time series date will be used; `@all` means the entire range on which the
% input time series `X` is defined.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series.
%
% Options
% ========
%
%
% * `'function='` [ function_handle | `@mean` ] - Function to be applied to
% moving window of observations.
%
% * `'window='` [ numeric | *`@auto`* ] - The window of observations where
% 0 means the current date, -1 means one period lag, etc. `@auto` means
% that the last N observations (including the current one) are used, where
% N is the frequency of the input data.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[This,Range,varargin] = irisinp.parser.parse('tseries.filter',varargin{:});
opt = passvalopt('tseries.moving',varargin{:});

%--------------------------------------------------------------------------

if isequal(opt.window,@auto)
    freq = DateWrapper.getFrequencyFromNumeric(This.start);
    if freq == 0
        utils.error('tseries:moving', ...
            ['Option ''window='' must be used for tseries objects ', ...
            'with integer date frequency.']);
    else
        opt.window = -freq+1:0;
    end
end

if ~isequal(Range,@all)
    This = resize(This,Range);
end

% @@@@@ MOSW
This = unop(@(varargin) tseries.mymoving(varargin{:}), ...
    This,0,opt.window,opt.function);

end
