function X = ishg2(Yes,No)
% ishg2  [Not a public function] Detect HG2 and implement a switch.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Yes; %#ok<VUNUS>
catch
    Yes = true;
end

try
    No; %#ok<VUNUS>
catch
    No = false;
end

%--------------------------------------------------------------------------

isHg2 = false;
try %#ok<TRYNC>
    isHg2 = ~verLessThan('matlab','8.4.0');
end

if isHg2
    X = Yes;
else
    X = No;
end

end
