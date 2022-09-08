
function [s, lg] = eval(this, s, varargin)

islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'append', true, islogicalscalar
};

opt = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

isOther = any(this.OtherContents);

% Contributions of shocks or measurement variables.
nGroup = numel(this.GroupNames);
nNewCol = nGroup + double(isOther) ;

% Number of old columns used in Grouping; the remaing old columns will
% be appended to the final data (this includes things like Init+Const, 
% Nonlinear, etc.).
nColUsed = length(this.List) ;

varNames = fields(this.IsLog) ;
for iVar = 1:numel(varNames)
    
    iName = varNames{iVar};
    
    % Contributions for log variables are multiplicative
    isLog = this.IsLog.(iName); 
    if isLog
        meth = @(x) prod(x, 2) ;
    else
        meth = @(x) sum(x, 2) ;
    end
    
    % Do grouping
    [oldData, startDate] = getDataFromTo(s.(iName));
    oldCmt = comment(s.(iName));
    nPer = size(oldData, 1) ;
    
    newData = nan(nPer, nNewCol) ;
    for iGroup = 1:nGroup
        ind = this.GroupContents{iGroup} ;
        newData(:, iGroup) = meth(oldData(:, ind)) ;
    end
    
    % Handle 'Other' group.
    if isOther
        ind = this.OtherContents ;
        newData(:, nGroup+1) = meth(oldData(:, ind)) ;
    end
    
    
    % Comment the new tseries( ) object.
    newCmt = cell(1, nNewCol) ;
    for iGroup = 1:nGroup
        newCmt{iGroup} = ...
            utils.concomment(iName, this.GroupNames{iGroup}, isLog) ;
    end
    if isOther
        newCmt{nGroup+1} = utils.concomment(iName, this.OTHER_NAME, isLog) ;
    end
    
    % Append remaining old data and old columns.
    if opt.append
        oldData(:, 1:nColUsed) = [ ] ;
        newData = [newData, oldData] ; %#ok<AGROW>
        oldCmt(:, 1:nColUsed) = [ ] ;
        newCmt = [newCmt, oldCmt] ; %#ok<AGROW>
    end
    
    s.(iName) = replace(s.(iName), newData, startDate, newCmt) ;
end

lg = this.GroupNames;
if isOther
    lg = [lg, {this.OTHER_NAME}];
end

end
