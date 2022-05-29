function varargout = redim(x, dim, redimStruct)
% redim  Reshape numeric array for columnwise application
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin==2
    sizeX = size(x);
    ndimsX = ndims(x);
    prm = [ ];
    if dim>1
        if dim>ndimsX
            ndimsX = dim;
        end
        prm = [dim:ndimsX, 1:dim-1];
        x = permute(x, prm);
        sizeX = size(x);
    end
    x = x(:, :);
    redimStruct = struct( );
    redimStruct.Size = sizeX;
    redimStruct.NDims = ndimsX;
    redimStruct.Permute = prm;
    varargout = { x, redimStruct };
else
    ndimsX = redimStruct.NDims;
    sizeX = redimStruct.Size;
    prm = redimStruct.Permute;
    if ndimsX>2
        x = reshape(x, [size(x, 1), sizeX(2:end)]);
    end
    if dim>1
        x = ipermute(x, prm);
    end
    varargout = { x };
end

end%

