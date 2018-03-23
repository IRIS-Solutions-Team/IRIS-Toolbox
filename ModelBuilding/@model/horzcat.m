function this = horzcat(this, varargin)
% horzcat  Merge two or more compatible model objects into multiple parameterizations.
%
% __Syntax__
%
%     M = [M1, M2, ...]
%
%
% __Input Arguments__
%
% * `M1`, `M2` [ model ] - Compatible model objects that will be merged
% into one model with multiple parameterizations; the input models must be
% based on the same model file.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Output model object created by merging the input model
% objects into one with multiple parameterizations.
%
%
% __Description__
%
%
% __Example__
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==1
    return
end

for i = 1 : numel(varargin)
    nv = length(this);
    nvToAdd = length(varargin{i});
    pos = nv + (1 : nvToAdd);
    assert( ...
        isa(varargin{i}, 'model') && iscompatible(this, varargin{i}), ...
        'model:horzcat', ...
        'Model objects A and B are not compatible in horizontal concatenation [A, B].' ...
    );
    this.Variant = subscripted(this.Variant, pos, varargin{i}.Variant, ':');
end

end
