function [posSpace, posName, posSpaceLag, ixSpace] ...
    = myfindsspacepos(this, lsInp, varargin)
% myfindsspacepos  [Not a public function] Find position of variables in combined state-space vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

throwErr = any(strcmp(varargin,'-error'));

if ischar(lsInp)
    lsInp = regexp(lsInp,'[\w\{\}\(\)\+\-]+','match');
end

% Remove blank spaces.
lsInp = regexprep(lsInp,'\s+','');

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==1;
ixx = this.Quantity.Type==2;
nz = length(lsInp);

% Vector of measurement and transition variables.
yxVec = printSolutionVector(this, 'yx');

posSpace = nan(1, nz);
posName = nan(1, nz);
for i = 1 : nz
    % Position of the requested variable in the state-space vector.
    ix = strcmp(lsInp{i},yxVec);
    if ~any(ix)
        continue
    end
    posSpace(i) = find(ix);
    
    % Position of the requested variable in the list of model names.
    ix = strcmp(this.Quantity.Name, lsInp{i}) & (ixy | ixx);
    if ~any(ix)
        continue
    end
    posName(i) = find(ix);
end

if nargout==1
    ixNaN = isnan(posSpace);
    if throwErr && any(ixNaN)
        utils.error('model:myfindsspacepos', ...
            'Cannot find this variable in the state-space vectors: ''%s''.', ...
            lsInp{ixNaN});
    end
    return
end

if nargout==2
    ixNaN = isnan(posName);
    if throwErr && any(ixNaN)
        utils.error('model:myfindsspacepos', ...
            'Cannot find this variable in the state-space vectors: ''%s''.', ...
            lsInp{ixNaN});
    end
    return
end

posSpaceLag = sspacePosLag(this, lsInp, posSpace, ixx);

ixNaN = isnan(posSpaceLag);
if throwErr && any(ixNaN)
    utils.error('model:myfindsspacepos', ...
        'Cannot find this variable in the state-space vectors: ''%s''.', ...
        lsInp{ixNaN});
end

x = posSpace;
x(isnan(x)) = [ ];
ixSpace = false(1, length(yxVec));
ixSpace(x) = true;

end




function x = sspacePosLag(this, usrName, posSpace, ixx)
% xxsspaceposlag  Return position in the extended Vector.Solution for
% transition variables with a lag larger than the maximum lag present in
% Vector.Solution.
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
x = posSpace;
solutionVector = [ this.Vector.Solution{1:2} ];
name = this.Quantity.Name;
ixLog = this.Quantity.IxLog;
name(ixLog) = strcat('log(',name(ixLog),')');
for i = find(isnan(x))
    usrName = usrName{i};
    lag  = regexp(usrName, '\{.*?\}', 'match', 'once');
    usrName = regexprep(usrName, '\{.*?\}', '', 'once');
    if isempty(lag)
        continue
    end
    posName = strcmp(name, usrName) & ixx;
    if ~any(posName)
        continue
    end
    posName = find(posName, 1);
    % `lag` is a negative number.
    lag = sscanf(lag,'{%g}');
    if ~isnumericscalar(lag) || ~isfinite(lag)
        continue
    end
    % `maxlag` is a negative number.
    maxLag = min( imag(solutionVector(real(solutionVector)==posName)) );
    ix = solutionVector==(posName + 1i*maxLag);
    solutionPos = find(ix, 1);
    x(i) = solutionPos + 1i*round(lag - maxLag);
end
end
