function varargout = get(This,varargin)
% get  Query neural network model object properties.
%
% Syntax
% =======
%
%     Ans = get(M,Query)
%     [Ans,Ans,...] = get(M,Query,Query,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `Query` [ char ] - Query to the model object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% Valid requests to neural network model objects
% ===============================================
% 
% * `'activation='`, `'activationlb='`, `'activationub='`, `'output='`,
% `'outputlb='`, `'outputub='`, `'hyper='`, `'hyperlb='`, `'hyperub='` - 
% Get parameter values or bounds for parameters. 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

P = inputParser( );
P.addRequired('Query',@iscellstr);
P.parse(varargin);

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@shared.GetterSetter(This,varargin{:});

end
