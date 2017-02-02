function outp = myoutpdata(this, range, inpMean, inpMse, lsOutpNames, addDb) %#ok<INUSL>
% myoutpdata  [Not a public function] Output data for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

try, inpMse; catch, inpMse = [ ]; end %#ok<VUNUS,NOCOM>

try
    lsOutpNames; %#ok<VUNUS>
    ix = strcmp(lsOutpNames,'!ttrend');
    if any(ix)
        lsOutpNames(ix) = {'ttrend'};
    end
catch %#ok<CTCH>
    lsOutpNames = { };
end

try, addDb; catch, addDb = struct( ); end %#ok<VUNUS,NOCOM>

%--------------------------------------------------------------------------

nx = size(inpMean, 1);
if ~isempty(range)
    range = range(1) : range(end);
    nPer = numel(range);
    start = range(1);
else
    range = zeros(1, 0); %#ok<NASGU>
    nPer = 0;
    start = NaN;
end
nData3 = size(inpMean, 3);
nData4 = size(inpMean, 4);

% Prepare array of std devs if cov matrix is supplied.
if numel(inpMse) == 1 && isnan(inpMse)
    nStd = size(inpMean,1);
    std = nan(nStd,nPer,nData3,nData4);
elseif ~isempty(inpMse)
    inpMse = timedom.fixcov(inpMse);
    nStd = min(size(inpMean,1),size(inpMse,1));
    std = zeros(nStd,nPer,nData3,nData4);
    for i = 1 : nData3
        for j = 1 : nData4
            for k = 1 : nStd
                std(k,:,i,j) = permute(sqrt(inpMse(k,k,:,i,j)),[1,3,2,4,5]);
            end
        end
    end
end

outp = addDb;
for ii = 1 : nx
    name = lsOutpNames{ii};
    outp.(name) = replace( ...
        TEMPLATE_SERIES, ...
        permute(inpMean(ii,:,:,:), [2, 3, 4, 1]), ...
        start, ...
        name ...
        );
end

% Include std data in output database.
if ~isempty(inpMse)
    outp = struct( ...
        'mean', outp, ...
        'std', struct( ) ...
        );
    for ii = 1 : nStd
        name = lsOutpNames{ii};
        outp.std.(name) = replace( ...
            TEMPLATE_SERIES, ...
            permute(std(ii,:,:,:), [2, 3, 4, 1]), ...
            start, ...
            name ...
            );
        outp.std.(name) = trim(outp.std.(name));
    end
end

end
