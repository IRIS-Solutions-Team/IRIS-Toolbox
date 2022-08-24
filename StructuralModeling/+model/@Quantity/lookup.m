% lookup  Look up names of variables, std and corr in Quantity component
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = lookup(this, query, varargin)

output = struct( );

inxE = this.Type==31 | this.Type==32;
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
    doStdCorr = any([varargin{:}]==4);
end
output.IxKeep = inxToKeep;

if iscell(query)
    % Input is a cell of names (char or string), with each of them a single
    % name (not a pattern); return vector of positions or NaNs
    numQueries = numel(query);
    output.PosName = nan(1, numQueries);
    output.PosStdCorr = nan(1, numQueries);
    output.PosShk1 = nan(1, numQueries);
    output.PosShk2 = nan(1, numQueries);
    output.InxName = false(1, numQuantities);
    output.InxStdCorr = false(1, numStdCorr);
    for i = 1 : numQueries
        inxStdCorr = [ ];
        inxShk1 = [ ];
        inxShk2 = [ ];
        if strlength(query{i})>=5 && startsWith(query{i}, "std_")
            if doStdCorr
                [inxStdCorr, inxShk1] = hereGetStd(query{i});
                output.InxStdCorr = output.InxStdCorr | inxStdCorr;
            end
            if any(inxStdCorr)
                output.PosStdCorr(i) = find(inxStdCorr);
            end
            if any(inxShk1)
                output.PosShk1(i) = find(inxShk1);
            end
        elseif strlength(query{i})>=9 && startsWith(query{i}, "corr_")
            if doStdCorr
                [inxStdCorr, inxShk1, inxShk2] = hereGetCorr(query{i});
                output.InxStdCorr = output.InxStdCorr | inxStdCorr;
            end
            if any(inxStdCorr)
                output.PosStdCorr(i) = find(inxStdCorr);
            end
            if any(inxShk1)
                output.PosShk1(i) = find(inxShk1);
            end
            if any(inxShk2)
                output.PosShk2(i) = find(inxShk2);
            end
        else
            try
                posName = this.LookupTable.(query{i});
                output.InxName(posName) = true;
                output.PosName(i) = posName;
            end
        end
    end
elseif ischar(query) || isa(query, 'rexp') || isa(query, 'string') || isa(query, 'Rxp')
    % Single input can be regular expression. Return logical index of all
    % possible matches. No shock1, shock2 indices needed.
    query = string(query);
    output.InxName = false(1, numQuantities);
    output.InxStdCorr = false(1, numStdCorr);
    if startsWith(query, "std_")
        if doStdCorr
            shkName = extractAfter(query, 4);
            output.InxStdCorr(1:numE) = locallyCallStrcmpOrRegexp(namesE, shkName);
        end
    elseif startsWith(query, "corr_")
        if doStdCorr
            output.InxStdCorr = hereGetCorr(query);
        end
    else
        output.InxName = locallyCallStrcmpOrRegexp(names, query);
    end  
end

if isfield(output, "InxName")
    output.IxName = output.InxName;
end

if isfield(output, "InxStdCorr")
    output.IxStdCorr = output.InxStdCorr;
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
        shkName = regexp(extractAfter(query, 5), "^(.*?)__([^_].*)$", "tokens", "once");
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
        ix = ~cellfun(@isempty, regexp(list, query, "once"));
    else
        ix = string(query)==string(list);
        % ix = strcmp(list, query);
    end
end%

