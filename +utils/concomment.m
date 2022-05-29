function C = concomment(To,From,IxLog)
% concomment  [Not a public function] Text string for contributions comments.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    IxLog; %#ok<VUNUS>
catch
    IxLog = false;
end

% Handle cell inputs.
if iscellstr(To) || iscellstr(From)
    if ischar(To)
        To = {To};
    end
    if ischar(From)
        From = {From};
    end
    nTo = numel(To);
    nFrom = numel(From);
    n = max(nTo,nFrom);
    C = cell(1,n);
    for i = 1 : n
        iTo = To{min(i,end)};
        iFrom = From{min(i,end)};
        C{i} = utils.concomment(iTo,iFrom,IxLog);
    end
    return
end
    
%--------------------------------------------------------------------------

if ~IxLog
    % Additive contributions.
    sign = '+';
else
    % Multiplicative contributions.
    sign = '*'; 
end

ptn = '%s <--[%s] %s';
C = sprintf(ptn,To,sign,From);

end
