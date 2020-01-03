function namesOfStd = getStdNames(this, request)
% getStdNames  Get names of standard deviations of shocks
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxOfShocks = this.Type==TYPE(31) | this.Type==TYPE(32);
namesOfStd = strcat('std_', this.Name(inxOfShocks));
if nargin>1
    namesOfStd = namesOfStd(request);
end

end%

