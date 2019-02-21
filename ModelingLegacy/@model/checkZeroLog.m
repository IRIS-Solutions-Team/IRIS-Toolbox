function [flag, list] = checkZeroLog(this, variantsRequested)
% checkZeroLog  Check steady-state levels of log-variables for zeros
%
% Backend IRIS function
% No help provided 

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<2
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

inxOfLog = this.Quantity.InxOfLog;
absSteadyLevel  = abs(real(this.Variant.Values(:, :, variantsRequested)));

inxOfZeroLogs = inxOfLog ...
              & any(absSteadyLevel<=this.Tolerance.Steady, 3);

flag = ~any(inxOfZeroLogs);
list = this.Quantity.Name(inxOfZeroLogs);

if ~flag
    throw( exception.Base('Model:LOG_VARIABLE_ZERO_STEADY', 'warning'), ...
           list{:} );
end

end%

