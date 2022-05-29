function [isFilter, filter, freq, applyFilterTo] = applyfilteropt(opt, freq, solutionVector)
% applyfilteropt  Pre-process filter options in ACF
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

nyxi = length(solutionVector);
filter = char(opt.Filter);
applyFilterTo = opt.ApplyTo;

% Linear filter applied to some variables.
if isequal(applyFilterTo, @all)
    applyFilterTo = true(1, nyxi);
elseif iscellstr(applyFilterTo) || ischar(applyFilterTo) || isstring(applyFilterTo)
    applyFilterTo = reshape(cellstr(applyFilterTo), 1, []);
    [pos, notFound] = textfun.findnames(solutionVector, applyFilterTo);
    if ~isempty(notFound)
        utils.error('freqdom:applyfilteropt', ...
            'This name does not exist in the state-space vectors: %s.', ...
            notFound{:});
    end
    applyFilterTo = false(1, nyxi);
    applyFilterTo(pos) = true;
elseif isnumeric(applyFilterTo)
    pos = applyFilterTo(:).';
    applyFilterTo = false(1, nyxi);
    applyFilterTo(pos) = true;
elseif islogical(applyFilterTo)
    applyFilterTo = applyFilterTo(:).';
    if length(applyFilterTo) > nyxi
        applyFilterTo = applyFilterTo(1:nyxi);
    elseif length(applyFilterTo) < nyxi
        applyFilterTo(end+1:nyxi) = false;
    end
end

if isfield(opt, 'NFreq') && isempty(freq)
    width = pi/opt.NFreq;
    freq = width/2 : width : pi;
elseif isfield(opt, 'NumFreq') && isempty(freq)
    width = pi/opt.NumFreq;
    freq = width/2 : width : pi;
end

if ~isempty(filter) && any(applyFilterTo)
    isFilter = true;
    filter = fdFilter(filter, freq);
else
    isFilter = false;
    filter = [ ];
    freq = [ ];
end

end


function filter = fdFilter(filterString, freq)
    numfreq = numel(freq);
    % Make these name available for user string evaluation:
    Freq = freq;
    frq = freq; %#ok<NASGU>
    % Vectorize *, /, \, ^ operators.
    filterString = textfun.vectorize(filterString);
    % Evaluate frequency response function of filter.
    l = exp(-1i*freq); %#ok<NASGU>
    per = 2*pi./freq; %#ok<NASGU>
    filter = eval(lower(filterString));
    if length(filter) == 1
        filter = ones(1, numfreq)*filter;
    end
    % Make sure the result is numeric.
    filter = +filter;
end 
