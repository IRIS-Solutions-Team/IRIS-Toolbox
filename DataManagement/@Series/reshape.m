
function [this, sizeData] = reshape(this, newSize)

    sizeData = size(this.Data);
    if nargin<2
       newSize = prod(sizeData(2:end));
    else
       if ~isinf(newSize(1)) && newSize(1)~=sizeData(1)
          utils.error('Series:reshape', ...
             'First dimension of tseries objects must remain unchanged after RESHAPE.');
       end
       newSize(1) = sizeData(1);
    end

    % Reshape data and comments.
    this.Data = reshape(this.Data, newSize);
    this.Comment = reshape(this.Comment, [1, newSize(2:end)]);

end%

