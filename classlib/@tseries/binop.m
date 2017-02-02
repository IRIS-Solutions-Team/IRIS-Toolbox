function [X,varargout] = binop(Fn,A,B,varargin)
% binop  [Not a public function] Binary operators and functions on tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(A,'tseries') && isa(B,'tseries')
    aSize = size(A.data);
    bSize = size(B.data);
    A.data = A.data(:,:);
    B.data = B.data(:,:);
    [anper,ancol] = size(A.data);
    [bnper,bncol] = size(B.data);
    if ancol == 1 && bncol ~= 1
        % First input argument is tseries scalar; second tseries with
        % multiple columns. Expand the first tseries to match the size of the
        % second in 2nd and higher dimensions.
        A.data = A.data(:,ones([1,bncol]));
        xSize = bSize;
    elseif ancol ~= 1 && bncol == 1
        % First tseries non-scalar; second tseries scalar.
        B.data = B.data(:,ones([1,ancol]));
        xSize = aSize;
    else
        xSize = aSize;
    end
    startDate = min([A.start,B.start]);
    endDate = max([A.start+anper-1,B.start+bnper-1]);
    range = startDate : endDate;
    aData = rangedata(A,range);
    bBata = rangedata(B,range);
    % Evaluate the operator.
    [xData,varargout{1:nargout-1}] = Fn(aData,bBata,varargin{:});    
    % Create the reu
    X = A;
    try
        X.data = reshape(xData,[size(xData,1),xSize(2:end)]);
    catch %#ok<CTCH>
        utils.error('tseries:binop', ...
            ['The size of the resulting tseries object must match ', ...
            'the size of one of the input tseries objects.']);
    end
    X.start = range(1);
    X.Comment = cell([1,xSize(2:end)]);
    X.Comment(:) = {''};
    X = trim(X);
else
    bSize = size(B);
    aSize = size(A);
    fnStr = func2str(Fn);
    if isa(A,'tseries')
        X = A;
        A = A.data;
        
        if any(strcmp(fnStr, ...
                {'times','plus','minus','rdivide','mdivide','power'})) ...
                && bSize(1) == 1 && all(bSize(2:end) == aSize(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            B = B(ones([1,aSize(1)]),:);
            B = reshape(B,aSize);
        end
    else
        X = B;
        B = B.data;
        if any(strcmp(fnStr, ...
                {'times','plus','minus','rdivide','mdivide','power'})) ...
                && aSize(1) == 1 && all(aSize(2:end) == bSize(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            A = A(ones([1,bSize(1)]),:);
            A = reshape(A,bSize);
        end
    end
    [tmp,varargout{1:nargout-1}] = Fn(A,B,varargin{:});
    tmpSize = size(tmp);
    xSize = size(X.data);
    if tmpSize(1) == xSize(1)
        % Size of the numeric result in 1st dimension matches the size of the
        % input tseries object. Return a tseries object with the original
        % number of periods.
        X.data = tmp;
        if length(tmpSize) ~= length(xSize) ...
                || any(tmpSize(2:end) ~= xSize(2:end))
            X.Comment = cell([1,tmpSize(2:end)]);
            X.Comment(:) = {''};
        end
        X = trim(X);
    else
        % Size of the numeric result has changed in 1st dimension from the
        % size of the input tseries object. Return a numeric array.
        X = tmp;
    end
end

end
