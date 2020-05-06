function outp = lookup(this, query, varargin)
% lookup  Look up names or stdcorr names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

outp = struct( );

inxE = this.Type==TYPE(31) | this.Type==TYPE(32);
namesE = this.Name(inxE);
numE = numel(namesE);
numStdCorr = numE + numE*(numE-1)/2;

names = this.Name;
numQuantities = numel(names);
doStdCorr = true;
inxToKeep = true(1, numQuantities);
if ~isempty(varargin)
    inxToKeep = false(1, numQuantities);
    for i = 1 : numel(varargin)
        inxToKeep = inxToKeep | this.Type==varargin{i};
    end
    names(~inxToKeep) = {''};
    doStdCorr = any( [varargin{:}]==TYPE(4) );
end
outp.IxKeep = inxToKeep;

if iscellstr(query)
    % Input is a cellstr of names; return vector of positions or NaNs.
    numQueries = numel(query);
    outp.PosName = nan(1, numQueries);
    outp.PosStdCorr = nan(1, numQueries);
    outp.PosShk1 = nan(1, numQueries);
    outp.PosShk2 = nan(1, numQueries);
    outp.InxName = false(1, numQuantities);
    outp.InxStdCorr = false(1, numStdCorr);
    for i = 1 : numQueries
        inxName = [ ];
        inxStdCorr = [ ];
        inxShk1 = [ ];
        inxShk2 = [ ];
        if strlength(query{i})>=5 && startsWith(query{i}, 'std_')
            if doStdCorr
                [inxStdCorr, inxShk1] = hereGetStd(query{i});
                outp.InxStdCorr = outp.InxStdCorr | inxStdCorr;
            end
        elseif strlength(query{i})>=9 && startsWith(query{i}, 'corr_')
            if doStdCorr
                [inxStdCorr, inxShk1, inxShk2] = hereGetCorr(query{i});
                outp.InxStdCorr = outp.InxStdCorr | inxStdCorr;
            end
        else
            inxName = locallyCallStrcmpOrRegexp(names, query{i});
            outp.InxName = outp.InxName | inxName;
        end
        if any(inxName)
            outp.PosName(i) = find(inxName);
        end
        if any(inxStdCorr)
            outp.PosStdCorr(i) = find(inxStdCorr);
        end
        if any(inxShk1)
            outp.PosShk1(i) = find(inxShk1);
        end
        if any(inxShk2)
            outp.PosShk2(i) = find(inxShk2);
        end
    end
elseif ischar(query) || isa(query, 'rexp') || isa(query, 'string') || isa(query, 'Rxp')
    % Single input can be regular expression. Return logical index of all
    % possible matches. No shock1, shock2 indices needed.
    query = string(query);
    outp.InxName = false(1, numQuantities);
    outp.InxStdCorr = false(1, numStdCorr);
    if strlength(query)>=5 && startsWith(query, 'std_')
        if doStdCorr
            shkName = extractAfter(query, 4);
            outp.InxStdCorr(1:numE) = locallyCallStrcmpOrRegexp(namesE, shkName);
        end
    elseif strlength(query)>=9 && startsWith(query, 'corr_')
        if doStdCorr
            outp.InxStdCorr = hereGetCorr(query);
        end
    else
        outp.InxName = locallyCallStrcmpOrRegexp(names, query);
    end  
end

if isfield(outp, 'InxName')
    outp.IxName = outp.InxName;
end

if isfield(outp, 'InxStdCorr')
    outp.IxStdCorr = outp.InxStdCorr;
end

return


    function [inxStdCorr, inxShkInName] = hereGetStd(query)
        shkName = extractAfter(query, 4);
        inxStdCorr = false(1, numStdCorr);
        inxStdCorr(1:numE) = locallyCallStrcmpOrRegexp(namesE, shkName);
        inxShkInName = locallyCallStrcmpOrRegexp(names, shkName);
    end%


    function [inxStdCorr, inxShk1InName, inxShk2InName] = hereGetCorr(query)
        inxStdCorr = false(1, numStdCorr);
        inxShk1InName = false(1, numQuantities);
        inxShk2InName = false(1, numQuantities);
        % Break down the corr coeff names corr_SHOCK1__SHOCK2 into SHOCK1 and SHOCK2.
        shkName = regexp(extractAfter(query, 5), '^(.*?)__([^_].*)$', 'tokens', 'once');
        if isempty(shkName) || isempty(shkName{1}) || isempty(shkName{2})
            return
        end
        % Find positions of shock names within all names.
        inxShk1InName = locallyCallStrcmpOrRegexp(names, shkName{1});
        inxShk2InName = locallyCallStrcmpOrRegexp(names, shkName{2});        
        % Find positions of shock names within shocks.
        inxShk1InShk = locallyCallStrcmpOrRegexp(namesE, shkName{1});
        inxShk2InShk = locallyCallStrcmpOrRegexp(namesE, shkName{2});
        % Place all combinations of shocks in the cross-correlation matrix, and
        % back out the position in the stdcorr vector.
        ixCorrMat = false(numE);
        ixCorrMat(inxShk1InShk, inxShk2InShk) = true;
        ixCorrMat(inxShk2InShk, inxShk1InShk) = true;
        ixCorrMat = tril(ixCorrMat, -1);
        [posRow, posCol] = find(ixCorrMat);
        for k = 1 : numel(posRow)
            p = numE + sum((numE-1):-1:(numE-posCol(k)+1)) + (posRow(k)-posCol(k));
            inxStdCorr(p) = true;
        end
    end%
end%


function ix = locallyCallStrcmpOrRegexp(list, query)
    if isa(query, 'rexp') || ~isvarname(query)
        ix = ~cellfun(@isempty, regexp(list, query, 'once'));
    else
        ix = strcmp(list, query);
    end
end%

