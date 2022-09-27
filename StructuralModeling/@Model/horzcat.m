%{
% 
% # `horzcat` ^^(Model)^^
% 
% {== Merge two or more compatible model objects into multiple parameterizations ==}
% 
% 
% ## Syntax 
% 
%      m = [m1, m2, ...]
% 
% 
% ## Input arguments
% 
% __`m1`, `m2`__ [ Model ]
% > 
% > Compatible model objects that will be merged
% > into one model with multiple parameterizations; the input models must be
% > based on the same model file.
% > 
% 
% ## Output arguments
% 
% __`m`__ [ Model ]
% >
% > Output model object created by merging the input model
% > objects into one with multiple parameterizations.
% > 
% 
% 
% ## Description 
% 
% 
% ## Examples
% 
%  Load the same model file with two different sets of parameters (databases
%  `P1` and `P2`), and merge the two model objects into one with multipler
%  parameterizations.
% 
% ```matlab
%  m1 = Model.fromFile("my.model", assign=P1);
%  m2 = Model.fromFile("my.model", assign=P2);
%  m = [m1, m2]
%  ```
% 
% 
%}
% --8<--


function this = horzcat(this, varargin)

if nargin==1
    return
end

for i = 1 : numel(varargin)
    nv = length(this);
    nvToAdd = length(varargin{i});
    pos = nv + (1 : nvToAdd);
    assert( ...
        isa(varargin{i}, 'model') && testCompatible(this, varargin{i}), ...
        'model:horzcat', ...
        'Model objects A and B are not compatible in horizontal concatenation [A, B].' ...
    );
    this.Variant = subscripted(this.Variant, pos, varargin{i}.Variant, ':');
end

end%

