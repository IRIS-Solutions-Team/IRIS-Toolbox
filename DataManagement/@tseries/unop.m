function [this, varargout] = unop(func, this, dim, varargin)
% unop  Unary operators and functions on tseries objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2017 IRIS Solutions Team

%--------------------------------------------------------------------------

if dim==0
    % Returns time series of the same size
    %sizeData = size(this.Data);
    %ndimsData = ndims(this.Data);
    %data = this.Data(:, :);
    data = this.Data;
    if ischar(func)
        [data, varargout{1:nargout-1}] = feval(func, data, varargin{:});
    else
        [data, varargout{1:nargout-1}] = func(data, varargin{:});
    end
    %if ndimsData>2
    %    sizeData(1) = size(data, 1);
    %    data = reshape(data, sizeData);
    %end
    this.Data = data;
    this = trim(this);
elseif dim==1
    % Return numeric array as a result of applying FUNC in 1st dimension
    if ischar(func)
        [this, varargout{1:nargout-1}] = feval(func, this.Data, varargin{:});
    else
        [this, varargout{1:nargout-1}] = func(this.Data, varargin{:});
    end
else
    % Return time series data shrunk in DIM as a result of applying FUNC in that
    % dimension
    if ischar(func)
        [this.Data, varargout{1:nargout-1}] = feval(func, this.Data, varargin{:});
    else
        [this.Data, varargout{1:nargout-1}] = func(this.Data, varargin{:});
    end
    this = resetColumnNames(this);
    this = trim(this);
end

end
