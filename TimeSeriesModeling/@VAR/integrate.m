function This = integrate(This,varargin)
% integrate  Integrate VAR process and data associated with it.
%
% Syntax
% =======
%
%     V = integrate(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object whose variables will be integrated by one
% order.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the specified variables integrated by one
% order.
%
% Options
% ========
%
% * `'applyTo='` [ logical | numeric | *`Inf`* ] - Index of variables to
% integrate; Inf means all variables will be integrated.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ny = size(This.A,1);
nAlt = size(This.A,3);


defaults = {
    'applyto', Inf, @(x) isnumeric(x) || islogical(x)
};


opt = passvalopt(defaults, varargin{:});


% Make options.applyto logical index.
if isnumeric(opt.applyto)
    ApplyTo = false(1,ny);
    ApplyTo(opt.applyto) = true;
elseif isequal(opt.applyto,@all)
    ApplyTo = true(1,ny);
elseif islogical(opt.applyto)
    ApplyTo = opt.applyto(:).';
    ApplyTo = ApplyTo(1:ny);
end

%--------------------------------------------------------------------------

% Integrate the VAR object.
if any(ApplyTo)
    D = cat(3,eye(ny),-eye(ny));
    D(~ApplyTo,~ApplyTo,2) = 0;
    A = This.A;
    This.A(:,end+1:end+ny,:) = NaN;
    for iAlt = 1 : nAlt
        a = polyn.prod(polyn.var2polyn(A(:,:,iAlt)),D);
        This.A(:,:,iAlt) = polyn.polyn2var(a);
    end
    This = schur(This);
end

end
