function outp = lookup(this, query, varargin)
% lookup  Look up names or stdcorr names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

outp = struct( );

ixe = this.Type==TYPE(31) | this.Type==TYPE(32);
lse = this.Name(ixe);
ne = length(lse);
nStdCorr = ne + ne*(ne-1)/2;

names = this.Name;
numQuantities = length(names);
doStdCorr = true;
ixKeep = true(1, numQuantities);
if ~isempty(varargin)
    ixKeep = false(1, numQuantities);
    for i = 1 : length(varargin)
        ixKeep = ixKeep | this.Type==varargin{i};
    end
    names(~ixKeep) = {''};
    doStdCorr = any( [varargin{:}]==TYPE(4) );
end
outp.IxKeep = ixKeep;

if iscellstr(query)
    % Input is a cellstr of names. Return vector of positions or NaNs.
    nQuery = length(query);
    outp.PosName = nan(1, nQuery);
    outp.PosStdCorr = nan(1, nQuery);
    outp.PosShk1 = nan(1, nQuery);
    outp.PosShk2 = nan(1, nQuery);
    outp.IxName = false(1, numQuantities);
    outp.IxStdCorr = false(1, nStdCorr);
    for i = 1 : nQuery
        ixName = [ ];
        ixStdCorr = [ ];
        ixShk1 = [ ];
        ixShk2 = [ ];
        if length(query{i})>=5 && strncmp(query{i}, 'std_', 4)
            if doStdCorr
                [ixStdCorr, ixShk1] = getStd(query{i});
                outp.IxStdCorr = outp.IxStdCorr | ixStdCorr;
            end
        elseif length(query{i})>=9 && strncmp(query{i}, 'corr_', 5)
            if doStdCorr
                [ixStdCorr, ixShk1, ixShk2] = getCorr(query{i});
                outp.IxStdCorr = outp.IxStdCorr | ixStdCorr;
            end
        else
            ixName = callStrcmpOrRegexp(names, query{i});
            outp.IxName = outp.IxName | ixName;
        end
        if any(ixName)
            outp.PosName(i) = find(ixName);
        end
        if any(ixStdCorr)
            outp.PosStdCorr(i) = find(ixStdCorr);
        end
        if any(ixShk1)
            outp.PosShk1(i) = find(ixShk1);
        end
        if any(ixShk2)
            outp.PosShk2(i) = find(ixShk2);
        end
    end
elseif ischar(query) || isa(query, 'rexp')
    % Single input can be regular expression. Return logical index of all
    % possible matches. No shock1, shock2 indices needed.
    outp.IxName = false(1, numQuantities);
    outp.IxStdCorr = false(1, nStdCorr);
    if length(query)>=5 && strncmp(query, 'std_', 4)
        if doStdCorr
            shkName = query(5:end);
            outp.IxStdCorr(1:ne) = callStrcmpOrRegexp(lse, shkName);
        end
    elseif length(query)>=9 && strncmp(query, 'corr_', 5)
        if doStdCorr
            outp.IxStdCorr = getCorr(query);
        end
    else
        outp.IxName = callStrcmpOrRegexp(names, query);
    end  
end

return


    function [ixStdCorr, ixShkInName] = getStd(query)
        shkName = query(5:end);
        ixStdCorr = false(1, nStdCorr);
        ixStdCorr(1:ne) = callStrcmpOrRegexp(lse, shkName);
        ixShkInName = callStrcmpOrRegexp(names, shkName);
    end


    function [ixStdCorr, ixShk1InName, ixShk2InName] = getCorr(query)
        ixStdCorr = false(1, nStdCorr);
        ixShk1InName = false(1, numQuantities);
        ixShk2InName = false(1, numQuantities);
        % Break down the corr coeff names corr_SHOCK1__SHOCK2 into SHOCK1 and SHOCK2.
        shkName = regexp(query(6:end), '^(.*?)__([^_].*)$', 'tokens', 'once');
        if isempty(shkName) || isempty(shkName{1}) || isempty(shkName{2})
            return
        end
        % Find positions of shock names within all names.
        ixShk1InName = callStrcmpOrRegexp(names, shkName{1});
        ixShk2InName = callStrcmpOrRegexp(names, shkName{2});        
        % Find positions of shock names within shocks.
        ixShk1InShk = callStrcmpOrRegexp(lse, shkName{1});
        ixShk2InShk = callStrcmpOrRegexp(lse, shkName{2});
        % Place all combinations of shocks in the cross-correlation matrix, and
        % back out the position in the stdcorr vector.
        ixCorrMat = false(ne);
        ixCorrMat(ixShk1InShk, ixShk2InShk) = true;
        ixCorrMat(ixShk2InShk, ixShk1InShk) = true;
        ixCorrMat = tril(ixCorrMat, -1);
        [posRow, posCol] = find(ixCorrMat);
        for k = 1 : length(posRow)
            p = ne + sum((ne-1):-1:(ne-posCol(k)+1)) + (posRow(k)-posCol(k));
            ixStdCorr(p) = true;
        end
    end
end


function ix = callStrcmpOrRegexp(list, query)
    if isa(query, 'rexp') || ~isvarname(query)
        ix = ~cellfun(@isempty, regexp(list, query, 'once'));
    else
        ix = strcmp(list, query);
    end
end
