function This = horzcat(This,varargin)
% horzcat  Merge two or more compatible model objects into multiple parameterizations.
%
% Syntax
% =======
%
%     M = [M1,M2,...]
%
%
% Input arguments
% ================
%
% * `M1`, `M2` [ model ] - Compatible model objects that will be merged
% into one model with multiple parameterizations; the input models must be
% based on the same model file.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Output model object created by merging the input model
% objects into one with multiple parameterizations.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Load the same model file with two different sets of parameters (databases
% `P1` and `P2`), and merge the two model objects into one with multipler
% parameterizations.
%
%     m1 = model('my.model', 'assign=', P1);
%     m2 = model('my.model', 'assign=', P2);
%     m = [m1, m2]
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==1
    return
end

for i = 1 : numel(varargin)
    nAlt = length(This);
    nAltAdd = length(varargin{i});
    pos = nAlt + (1 : nAltAdd);
    This = subsalt(This, pos, varargin{i}, ':');
end

end
