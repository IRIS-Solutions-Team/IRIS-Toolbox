function C = sum(A,B)
% sum  [Not a public function] Sum of polynomials.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = size(A,1);

pa = size(A,3) - 1;
pb = size(B,3) - 1;

pc = max(pa,pb);
C = zeros(n,n,pc+1);

A = cat(3,A,zeros(n,n,pc-pa));
B = cat(3,B,zeros(n,n,pc-pb));

for i = 0 : pc
    C(:,:,1+i) = A(:,:,1+i) + B(:,:,1+i);
end

aux = find(any(any(C ~= 0,1),2));
if isempty(aux)
    C = C(:,:,1);
else
    C = C(:,:,1:aux(end));
end

end
