function C = maxdisp(C,N)
% maxdisp  [Not a public function] Clip the string to the first N
% characters, showing an ellipsis in longer strings.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    N; %#ok<VUNUS>
catch
    N = 40;
end

%--------------------------------------------------------------------------

if length(C) > N
    C = C(1:N);
    C(end-2:end) = '...';
end

end
