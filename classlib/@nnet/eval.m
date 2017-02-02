function OutData = eval(This,InData,Range,varargin)

% eval  Evaluate neural network.
%
% Syntax
% =======
%
%     S = eval(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `D` [ dbase | tseries ] - Input data in the form of a database object
% or tseries object.
%
% * `Range` [ numeric ] - Evaluation range.
%
% Output arguments
% =================
%
% * `S` [ dbase ] - Neural network model object.
%
% Options
% ========
%
% * `'Ahead='` [ numeric ] - Produces k-step ahead predictions for neural
% networks with the same inputs and outputs (e.g., inputs {'x{-1}',x{-2}'}
% and output x). Default value is 1.
%
% * `'Output='` [ *`'tseries'`* | `'dbase'` ] - Display progress bar if possible.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin<3
    Range = Inf ;
end
if ischar(Range)
    varargin = [Range, varargin] ;
    Range = Inf ;
end
pp = inputParser( ) ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('InData',@(x) isa(x,'tseries') || isa(x,'struct')) ;
pp.addOptional('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,InData,Range) ;
if This.nAlt>1
    utils.error('nnet:eval',...
        'Eval does not support input neural network objects with multiple parameterizations.') ;
end
Range = myrange(This,InData,Range) ;

% Parse options
options = passvalopt('nnet.eval',varargin{:}) ;

% Handle data
if isstruct(InData)
    [InData] = datarequest('Inputs',This,InData,Range) ;
end
if options.Ahead>1 && This.nOutput>1
    options.Output = 'dbase' ;
end


% Body
if options.Ahead>1
    if mysameio(This)
        utils.error('nnet:eval','Input and output variables must be the same.') ;
    end
    kPred = InData ;
    for k = 1:options.Ahead
        kPred = eval(This,kPred,Range) ;
        for iOutput = 1:This.nOutput
            OutData.(This.Outputs{iOutput})(Range+k-1,k) = kPred(:,iOutput) ;
        end
    end
else
    OutData = myfwdpass(This,InData,Range) ;
end

if strcmpi(options.Output,'dbase')
    OutData = array2db(OutData,Range,This.Outputs) ;
end

end






