function x = daterange(varargin)
% daterange  Use the colon operator to create date ranges.
%
% Syntax
% =======
%
%     startdate : enddate
%     startdate : increment : enddate
%
% Input arguments
% ================
%
% * `startdate` [ numeric ] - IRIS serial date number representing the
% startdate.
%
% * `enddate` [ numeric ] - IRIS serial date number representing the
% enddate; `startdate` and `enddate` must be the same frequency.
%
% * `increment` [ numeric ] - Number of periods (specific to each
% frequency) between the dates in the date vector.
%
% Description
% ============
%
% You can use the colon operator to create continuous date ranges because
% the IRIS serial date numbers are designed so that whatever the frequency
% two consecutive dates are represented by numbers that differ exactly by
% one.
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = colon(varargin{:});

end
