function [Y0,K0,Y1,G1] = mydummymat(This,varargin)
% mydummymat  [Not a public function] Create extra output arguments for bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

Ng = 0;
if numel(varargin)==1 
    if isa(varargin{1}, 'BaseVAR')
        model = varargin{1};
        Ny = model.NumEndogenous;
        P = model.Order;
        Ng = model.NumExogenous;
    else
        Ny = varargin{1}(1);
        P = varargin{1}(2);
        if length(varargin{1}) > 2
            Ng = varargin{1}(3);
        end
    end
else
    Ny = varargin{1};
    P = varargin{2};
    varargin(1:2) = [ ];
    if length(varargin) > 2
        Ng = varargin{3};
    end
end

%--------------------------------------------------------------------------

Y0 = This.y0(Ny,P,Ng,1);
K0 = This.k0(Ny,P,Ng,1);
Y1 = This.y1(Ny,P,Ng,1);
G1 = This.g1(Ny,P,Ng,1);

end%

