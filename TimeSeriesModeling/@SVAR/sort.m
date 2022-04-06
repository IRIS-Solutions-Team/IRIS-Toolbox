function [This,Data,Inx,Crit] = sort(This,Data,SortBy,varargin)
% sort  Sort SVAR parameterisations by squared distance of shock reponses to median.
%
% Syntax
% =======
%
%     [B,~,Inx,Crit] = sort(A,[ ],SortBy,...)
%     [B,Data,Inx,Crit] = sort(A,Data,SortBy,...)
%
% Input arguments
% ================
%
% * `A` [ SVAR ] - SVAR object with multiple parameterisations that will
% be sorted.
%
% * `Data` [ struct | empty ] - SVAR database; if non-empty, the structural
% shocks will be re-ordered according to the SVAR parameterisations.
%
% * `SortBy` [ char ] - Text string that will be evaluated to compute the
% criterion by which the parameterisations will be sorted; see Description
% for how to write `SortBy`.
%
% Output arguments
% =================
%
% * `B` [ SVAR ] - SVAR object with parameterisations sorted by the
% specified criterion.
%
% * `Data` [ tseries | struct | empty ] - SVAR data with the structural
% shocks re-ordered to correspond to the order of parameterisations.
%
% * `Inx` [ numeric ] - Vector of indices so that `B = A(Inx)`.
%
% * `Crit` [ numeric ] - The value of the criterion based on the string
% `SortBy` for each parameterisation.
%
% Options
% ========
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% Description
% ============
%
% The individual parameterisations within the SVAR object `A` are sorted by
% the sum of squared distances of selected shock responses to the
% respective median reponses. Formally, the following criterion is
% evaluated for each parameterisation
%
% $$ \sum_{i\in I,j\in J,k\in K} \left[ S_{i,j}(k) - M_{i,j}(k) \right]^2 $$
%
% where $S_{i,j}(k)$ denotes the response of the i-th variable to the j-th
% shock in period k, and $M_{i,j}(k)$ is the median responses. The sets of
% variables, shocks and periods, i.e. `I`, `J`, `K`, respectively, over
% which the summation runs are determined by the user in the `SortBy`
% string.
%
% How do you select the shock responses that enter the criterion in
% `SortBy`? The input argument `SortBy` is a text string that refers to
% array `S`, whose element `S(i,j,k)` is the response of the i-th
% variable to the j-th shock in period k.
%
% Note that when you pass in SVAR data and request them to be sorted the
% same way as the SVAR parameterisations (the second line in Syntax), the
% number of parameterisations in `A` must match the number of data sets in
% `Data`.
%
% Example
% ========
%
% Sort the parameterisations by squared distance to median of shock
% responses of all variables to the first shock in the first four periods.
% The parameterisation that is closest to the median responses
%
%     S2 = sort(S1,[ ],'S(:,1,1:4)')
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('A',@(x) isa(x,'SVAR'));
pp.addRequired('Data',@(x) isempty(x) || isstruct(x));
pp.addRequired('SortBy',@ischar);
pp.parse(This,Data,SortBy);


Def.sort = {...
    'output','auto',@(x) validate.anyString(x,{'auto','dbase','tseries','array'}), ...
    'progress',false,@islogicalscalar, ...
};


opt = passvalopt('SVAR.sort',varargin{:});
isData = nargout>1 && ~isempty(Data);

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

% Handle residuals.
if isData
    % Get data.
    req = datarequest('e', This, Data, Inf);
    rng = req.Range;
    e = req.E;
    nData = size(e,3);
    if nData ~= nAlt
        utils.error('SVAR:sort', ...
            ['The number of data sets (%g) must match ', ...
            'the number of parameterisations (%g).'], ...
            nData,nAlt);
    end
end

% Look for the simulation horizon and the presence of asymptotic responses
% in the `SortBy` string.
[h,isY] = myparsetest(This,SortBy);

if opt.progress
    progress = ProgressBar('[IrisToolbox] @SVAR/sort Progress');
end

XX = [ ];
for iAlt = 1 : nAlt
    [S,Y] = doSimulate( ); %#ok<ASGLU>
    doEvalSort( );
    if opt.progress
        update(progress,iAlt/nAlt);
    end
end

Inx = doSort( );
This = subsalt(This,Inx);

if isData
    e = e(:,:,Inx);
    Data = myoutpdata(This, rng, e, [ ], This.ResidualNames, Data);
end


% Nested functions...


%**************************************************************************
    
    
    function [S,Y] = doSimulate( )
        % Simulate the test statistics.
        S = zeros(ny,ny,0);
        Y = nan(ny,ny,1);
        % Impulse responses.
        if h > 0
            S = timedom.var2vma(This.A(:,:,iAlt),This.B(:,:,iAlt),h);
        end
        % Asymptotic impulse responses.
        if isY
            A = polyn.var2polyn(This.A(:,:,iAlt));
            C = sum(A,3);
            Y = C\This.B(:,:,iAlt);
        end
    end % doSimulate( )


%**************************************************************************
    
    
    function doEvalSort( )
        % Evalutate the sort criterion.
        try
            X = eval(SortBy);
            XX = [XX,X(:)];
        catch err
            utils.error('SVAR:sort', ...
                ['Error evaluating the sort string ''%s''.\n', ...
                '\tUncle says: %s'], ...
                SortBy,err.message);
        end
    end % doEvalSort( )


%**************************************************************************
    
    
    function Inx = doSort( )
        % Sort by the distance from median.
        n = size(XX,2);
        if n > 0
            MM = median(XX,2);
            Crit = nan(1,n);
            for ii = 1 : n
                Crit(ii) = sum((XX(:,ii) - MM).^2 / n);
            end
            [Crit,Inx] = sort(Crit,'ascend');
        end
    end % doSort( )


end
