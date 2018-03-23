function This = prune(This,Data,varargin)

% prune  Eliminate weak connections between neurons.
%
% Syntax
% =======
%
%     M = prune(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `D` [ dbase ] - Input database.
%
% * `Range` [ numeric ] - Evaluation range.
%
% Output arguments
% =================
%
% * `M` [ nnet ] - Neural network model object.
%
% Options
% ========
%
% * `'Depth='` [ numeric ] - Check for anti-symmetry by considering removal
% of N connections simultaneously. 
% 
% * `'EstimationOpts='` [ cell ] - Cell array of options for
% `nnet/estimate` to be used when `Recursive=` is `true`. 
% 
% * `'Parallel='` [ `true` | *`false`* ] - Perform processing in parallel if possible.
% 
% * `'Progress='` [ `true` | *`false`* ] - Display progress bar if possible.
% 
% * `'Recursive='` [ numeric ] - Recursively prune and re-train network N
% times. 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Parse options
pp = inputParser( ) ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@(x) isa(x,'struct')) ;
pp.parse(This,Data) ;

if ~isempty(varargin) && isnumeric(varargin{1})
    Range = varargin{1} ;
    varargin(1) = [ ] ;
else
    Range = Inf ;
end
Range = myrange(This,Data,Range) ;
options = passvalopt('nnet.prune',varargin{:}) ;
if options.Parallel
    utils.warning('nnet:prune','Progress bar cannot be used with option parallel true.') ;
    options.Progress = false ;
end
if options.Progress
    progress = ProgressBar('IRIS nnet.prune progress');
end

% Get data
[InData,OutData] = datarequest('Inputs,Outputs',This,Data,Range) ;

% Body
if options.Recursive>1
    % switch options for recurisve calls
    for iArg = 1:2:numel(varargin)
        if strcmpi(varargin{iArg},'Recursive')
            varargin{iArg+1} = false ;
        end
    end
    
    % Prune and re-train
    for iter = 1:options.Recursive
        This = prune(This,Data,Range,varargin{:}) ;
        This = estimate(This,Data,Range,varargin{:}) ;
    end
else
    Pred = eval(This,InData,Range) ; %#ok<*GTARG>
    
    R2f = xxCorr(Pred,OutData)^2 ;
    switch options.Method
        case 'correlation'
            % For each possible permutation of removed connections (based
            % on depth option), calculate the correlation between the
            % predicted and actual
            index = get(This,'activationindex') ;
            possible = nchoosek(index,options.Depth) ;
            nP = size(possible,1) ;
            params = get(This,'activation') ;
            R2h = NaN(nP,1) ;
            if options.Parallel
                % minimize communication overhead with WorkerObjWrapper
                sThis = WorkerObjWrapper( This ) ;
                sInData = WorkerObjWrapper( InData ) ;
                sOutData = WorkerObjWrapper( OutData ) ;
                sRange = WorkerObjWrapper( Range ) ;
                soptions = WorkerObjWrapper( options ) ;
                pcell = cell(nP,1) ;
                for iP = 1:nP
                    params(possible(iP,:)) = 0 ;
                    pcell{iP} = params ;
                end
                parfor iP = 1:nP
                    [~,Pred] = objfunc(pcell{iP},...
                        sThis.Value,sInData.Value,sOutData.Value,sRange.Value,soptions.Value) ;
                    R2h(iP) = corr(Pred,OutData)^2 ;
                end
            else
                for iP = 1:nP
                    params(possible(iP,:)) = 0 ;
                    [~,Pred] = objfunc(params,This,InData,OutData,Range,options) ;
                    R2h(iP) = xxCorr(Pred,OutData)^2 ;
                    if options.Progress
                        update(progress,iP/nP);
                    end
                end
            end
            
            % Look for correlations such that removing one set of
            % parameters does not affect R2 much.
            dR2 = R2f - R2h ;
            [val,ind] = sort(dR2) ;
            
            % Remove these connections
            params(possible(ind(end),:)) = NaN ;
            This = set(This,'activation',params) ;
            This = rmnan(This) ;
            
        case 'obd'
            utils.error('nnet:prune','Optimal brain damage not yet supported.') ;
            % TBD...
            
        otherwise
            utils.error('nnet:prune','Pruning method not supported.') ;
    end
end

    function out = xxCorr(a,b)
        out = corr(vec(a),vec(b)) ;
    end

    function out = vec(x)
        sz = size(x) ;
        N = prod(sz) ;
        out = NaN(N,1) ;
        for iCol = 1:sz(2)
            out(1+(iCol-1)*sz(1):iCol*sz(1)) = x.data(:,iCol) ;
        end
    end

end




