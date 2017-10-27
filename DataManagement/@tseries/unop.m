function [this, varargout] = unop(func, this, dim, varargin)
% unop  Unary operators and functions on tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if dim==0
    % Returns tseries of the same size.
    sz = size(this.data);
    if ischar(func)
        [this.data, varargout{1:nargout-1}] = ...
            feval(func, this.data(:,:), varargin{:});
    else
        [this.data,varargout{1:nargout-1}] = func(this.data(:,:), varargin{:});
    end
    if length(sz)>2
        this.data = reshape(this.data, [size(this.data,1),sz(2:end)]);
    end
    this = trim(this);
elseif dim==1
    % Returns numeric array as a result of applying FUNC in 1st dimension
    % (time).
    if ischar(func)
        [this, varargout{1:nargout-1}] = feval(func, this.data, varargin{:});
    else
        [this, varargout{1:nargout-1}] = func(this.data, varargin{:});
    end
else
    % Returns a tseries shrunk in DIM as a result of applying FUNC in that
    % dimension
    if ischar(func)
        [this.data, varargout{1:nargout-1}] = feval(func, this.data,varargin{:});
    else
        [this.data, varargout{1:nargout-1}] = func(this.data, varargin{:});
    end
    dim = size(this.data);
    this = resetColumnNames(this);
    this = trim(this);
end

end
