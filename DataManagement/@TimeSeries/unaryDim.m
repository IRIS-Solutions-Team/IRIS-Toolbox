function [outp, dim] = unaryDim(fun, dimArg, this, varargin)
% unaryDim  Unary operators on TimeSeries applied along selected dimension.
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

assert( ...
    ~iscell(this.Data), ...
    'TimeSeries:unaryDim', ...
    'Cannot apply function %s( ) to TimeSeries with cell array data.', ...
    fun ...
);
    
if length(varargin)<dimArg
    varargin(end+1:dimArg) = {[]};
    varargin{dimArg} = 1;
end
dim = varargin{dimArg};

sizeData = size(this.Data);
newData = feval(fun, this.Data, varargin{:});
sizeNewData = size(newData);

if dim==1
    outp = newData;
    return
end

assert( ...
    sizeData(1)==sizeNewData(1), ...
    'TimeSeries:unaryDim', ...
    'Function %s( ) applied along 2nd or higher dimension of TimeSeries object must preserve size in 1st dimension.', ...
    fun ...
);

this.Data = newData;
this.ColumnNames = "";
outp = this;

end
