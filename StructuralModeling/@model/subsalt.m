function this = subsalt(this, varargin)
% subsalt  Implement subscripted reference and assignment for model objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if numel(varargin)==1
    ixLhs = varargin{1};
    % Subscripted reference this(lhs).
    this.Variant = this.Variant(ixLhs);
    
    for i = 1 : length(this.solution)
        this.solution{i} = this.solution{i}(:, :, ixLhs);
    end
    for i = 1 : length(this.Expand)
        this.Expand{i} = this.Expand{i}(:, :, ixLhs);
    end

elseif numel(varargin)==2 && isempty(varargin{2})
    ixLhs = varargin{1};
    % Empty subscripted assignment this(lhs) = [ ]
    this.Variant(ixLhs) = [ ];
    
    for i = 1 : length(this.solution)
        this.solution{i}(:, :, ixLhs) = [ ];
    end
    for i = 1 : length(this.Expand)
        this.Expand{i}(:, :, ixLhs) = [ ];
    end

elseif numel(varargin)==3 && isa(this, 'model') && isa(varargin{2}, 'model')
    ixLhs = varargin{1};
    obj = varargin{2};
    ixRhs = varargin{3};
    % Proper subscripted assignment this(ixLhs) = obj(ixRhs).
    this.Variant(ixLhs) = obj.Variant(ixRhs);
    
    for i = 1 : length(this.solution)
        this.solution{i}(:, :, ixLhs) = obj.solution{i}(:, :, ixRhs);
    end
    for i = 1 : length(this.Expand)
        this.Expand{i}(:, :, ixLhs) = obj.Expand{i}(:, :, ixRhs);
    end

else
    throw( ...
        exception.Base('General:INVALID_REFERENCE', 'error'), ...
        'model' ...
        ); %#ok<GTARG>
end

end
