function [IsFilter,Filter,Freq,ApplyTo] = applyfilteropt(Opt,Freq,SspaceVec)
% applyfilteropt  [Not a public function] Pre-process filter options in ACF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Nx = length(SspaceVec);
Filter = Opt.filter;
ApplyTo = Opt.applyto;
if ischar(ApplyTo)
    ApplyTo = regexp(ApplyTo,'\w+','match');
end

% Linear filter applied to some variables.
if isequal(ApplyTo,@all)
    ApplyTo = true(1,Nx);
elseif iscellstr(ApplyTo) || ischar(ApplyTo)
    ApplyTo = ApplyTo(:).';
    [pos,notFound] = textfun.findnames(SspaceVec,ApplyTo);
    if ~isempty(notFound)
        utils.error('freqdom:applyfilteropt', ...
            'This name does not exist in the state-space vectors: %s.', ...
            notFound{:});
    end
    ApplyTo = false(1,Nx);
    ApplyTo(pos) = true;
elseif isnumeric(ApplyTo)
    pos = ApplyTo(:).';
    ApplyTo = false(1,Nx);
    ApplyTo(pos) = true;
elseif islogical(ApplyTo)
    ApplyTo = ApplyTo(:).';
    if length(ApplyTo) > Nx
        ApplyTo = ApplyTo(1:Nx);
    elseif length(ApplyTo) < Nx
        ApplyTo(end+1:Nx) = false;
    end
end

if isfield(Opt,'nfreq') && isempty(Freq)
    width = pi/Opt.nfreq;
    Freq = width/2 : width : pi;
end

if ~isempty(Filter) && any(ApplyTo)
    IsFilter = true;
    Filter = xxFdFilter(Filter,Freq);
else
    IsFilter = false;
    Filter = [ ];
    Freq = [ ];
end

end


% Subfunctions...


%**************************************************************************


function Filter = xxFdFilter(FString,Freq)
nFreq = length(Freq);
frq = Freq; %#ok<NASGU>

% Vectorize *, /, \, ^ operators.
FString = textfun.vectorize(FString);

% Evaluate frequency response function of filter.
l = exp(-1i*Freq); %#ok<NASGU>
per = 2*pi./Freq; %#ok<NASGU>
Filter = eval(lower(FString));
if length(Filter) == 1
    Filter = ones(1,nFreq)*Filter;
end

% Make sure the result is numeric.
Filter = +Filter;
end % xxFdFilter( )
