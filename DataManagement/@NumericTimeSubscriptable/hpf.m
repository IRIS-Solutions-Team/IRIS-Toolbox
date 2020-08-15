function varargout = hpf(varargin)
% hpf  Hodrick-Prescott filter with conditioning information
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%
%     [T, C, cutoff, lambda] = hpf(X, ~range, ...)
%
%
% ## Syntax with Output Arguments Swapped ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [C, T, cutoff, lambda] = hpf2(X, ~range, ...)
%
%
% ## Input Arguments ##
%
%
% __`X`__ [ Series ]
% >
% Input time series that will be filtered.
%
%
% __`~range=@all`__ [ DateWrapper | char ]
% >
% Date range on which the input data will be filtered; `range` can be
% `@all`, `Inf`, `[startdata, Inf]`, or `[-Inf, enddate]`; if omitted,
% `@all` (i.e. the entire available range of the input time series) is
% used.
%
%
% ## Output Arguments ## 
%
%
% __`T`__ [ Series ]
% >
% Low-frequency (trend) component.
%
%
% __`C`__ [ Series ]
% >
% High-frequency (cyclical or gap) component.
%
%
% __`cutoff`__ [ numeric ]
% >
% Cut-off periodicity; periodicities above the cut-off are attributed to
% trends, periodicities below the cut-off are attributed to gaps.
%
%
% __`lambda`__ [ numeric ] 
% >
% Smoothing parameter actually used; this output argument is useful when
% `Lambda=@auto` or when the option `cutoff=` is used instead of `Lambda=`.
%
%
% ## Options ##
%
%
% __`Cutoff=[ ]`__ [ numeric ]
% >
% Cut-off periodicity in periods (depending on the time series frequency);
% this option can be specified instead of `Lambda=`; the smoothing
% parameter will be then determined based on the cut-off periodicity.
%
%
% __`CutoffYear=[ ]`__ [ numeric ]
% >
% Cut-off periodicity in years; this option can be specified instead of
% `Lambda=`; the smoothing parameter will be then determined based on the
% cut-off periodicity.
%
%
% __`Gamma=1`__ [ numeric | Series ]
% >
% Weight or weights on the deviations of the trend from observations; it
% only makes sense to use this option to make the signal-to-noise ratio
% time-varying; see the optimization problem below.
%
%
% __`InfoSet=2`__ [ `1` | `2` ]
% >
% Information set assumption used in the filter: `1` runs a one-sided
% filter, `2` runs a two-sided filter.
%
%
% __`Lambda=@auto`__ [ numeric | @auto ]
% >
% Smoothing parameter; needs to be specified for Series objects with
% indeterminate frequency; see Description for default values.
%
%
% __`Level=`__ [ Series ]
% >
% Time series with hard tunes and soft tunes on the level of the trend.
%
%
% __`Change=`__ [ Series ]
% >
% Time series with hard tunes and soft tunes on the change in the trend.
%
%
% __`Log=`__ [ `true` | *`false`* ]
% >
% Logarithmize the data before filtering, de-logarithmize afterwards.
%
%
% ## Description ##
%
%
% ### The Underlying Optimization Problem ###
%
% The function `hpf` solves a constrained optimization problem described by
% the following Lagrangian
%
% \[ \min_{\bar y_t, \omega_t, \sigma_t} \underbrace{ \sum \lambda \left(
% \Delta \bar y_t - \Delta \bar y_{t-1} \right)^2 + \sum \gamma_t \left(
% \bar y_t - y_t \right)^2}_\text{Plain HP with time-varying
% signal-to-noise ratio} + \cdots \]
%
% \[ \cdots + \underbrace{\sum u_t
% \left( \bar y_t - a_t \right)^2}_\text{Soft level tunes} +
% \underbrace{\sum v_t \left( \Delta \bar y_t - b_t \right)^2}_\text{Soft
% growth tunes} + \underbrace{\sum \omega_t \left( \bar y_t - c_t
% \right)}_\text{Hard level tunes} + \underbrace{\sum \sigma_t \left(
% \Delta \bar y_t - d_t \right)}_\text{Hard growth tunes}, \]
%
% where
% 
% * \( \Delta \) is the first-difference operator; 
%
% * \( \lambda \) is a
% (scalar) smoothing parameter; 
%
% * \( y_t \) are user-supplied observations;
% 
% * \( \bar y_t\) is the fitted trend; 
%
% * \( \gamma_t \) are user-supplied weights to modify the basic
% signal-to-noise ratio over time (the default setting is \(\gamma_t=1\)),
% entered in the option `gamma=`; 
%
% * \( a_t \) and \( u_t \) are soft tunes on the level of the trend and
% the weights associated with these soft level tunes, respectively, entered
% together as complex numbers in the option `Level=`; 
% 
% * \( b_t \) and \( v_t \) are soft tunes on the change in the level of
% the trend and the weights associated with these soft growth tunes,
% respectively, entered together as complex numbers in the option
% `Change=`; 
% 
% * \( c_t \) are hard tunes on the level of the trend, entered as real
% numbers in the option `Level=`; 
% 
% * \( d_t \) are hard tunes on the change in the level of the trend,
% entered as real numbers in the option `Change=`; 
% 
% * \( \omega_t \) are Lagrange multipliers on the hard level tunes (note
% that these are computed as part of the optimization problem, not entered
% by the user); 
% 
% * \( \sigma_t \) are Lagrange multipliers on the hard growth tunes (note
% that these are computed as part of the optimization problem, not entered
% by the user).
%
% Each of the summations in the above Lagrangian goes over those periods in
% which the respective bracketed terms are defined (observations or tunes
% exist). You can combine any number of any tunes in one run of `hpf`, 
% including out-of-sample tunes (see below).
%
%
% ### Imposing Tunes on Trend Level and Trend Change ###
%
%
% * The hard tunes and soft tunes on the level of the trend are entered as
% time series through the option `Level=`.
%
% * The hard tunes and soft tunes on the change in the trend are entered as
% time series through the option `change=`.
%
% * In the time series entered through `Level=` and/or `change=`, 
% you can combine any number of hard and soft tune. In each particular
% period, you can obviously specify only a hard tune or only a soft tune.
% You can think of hard tunes as a special case of soft tunes with
% infinitely large weights.
%
% * A hard tune is specified as a plain real number (i.e. a number with a
% zero complex part).
%
% * A soft tune must be entered as a complex number whose real part
% specifies the tune itself, and the imaginary part specifies the *inverse*
% of the weight, i.e. \( 1/v_t \) or \(1/u_t\), on that tune in that period. Note
% that if the weight goes to infinity, the imaginary part becomes zero and
% the tune becomes a hard tune.
%
%
% ### Out-of-Sample Tunes ###
%
% 
% Tunes can be imposed also at dates before the first observation of the
% input series, or after the last observation. In other words, the time
% series in `Level=` and/or `Change=` can have a more extended range
% (at either side) than the filtered input series.
%
%
% ### Default Smoothing Parameters ###
%
%
% If the smoothing parameter `Lambda=` is not specified (i.e.
% `Lambda=@auto`), a default value is computed. The default value is based
% on common practice and can be calculated using the date frequency of the
% input time series as \( \lambda = 100f \), where \( f \) is the frequency
% (yearly=1, half-yearly=2, quarterly=4, monthly=12).  This gives the
% following default values:
%
% * 100 for yearly time series (cut-off periodicity of 19.79 years);
%
% * 400 for half-yearly time series (cut-off periodicity of 14.02 years);
%
% * 1,600 for quarterly time series (cut-off periodicity of 9.92 years);
%
% * 3,600 for bi-monthly time series (cut-off periodicity of 8.11 years);
%
% * 14,400 for monthly time series (cut-off periodicity of 5.73 years).
%
% Note that there is no default value for data with indeterminate or daily
% frequency: for these types of time series, you must always use the option
% `Lambda=`.
%
%
% _Example_
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% BWF, HPF, LLF

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

order = 2;
[varargout{1:nargout}] = implementFilter(order, varargin{:});

end%

