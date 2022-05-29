function C = prod(A,B)
% prod  [Not a public function] Product of polynomials.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = size(A,1);

pa = size(A,3) - 1;
pb = size(B,3) - 1;

pc = pa + pb;
C = zeros(n,n,pc+1);

A = cat(3,A,zeros(n,n,pc-pa));
B = cat(3,B,zeros(n,n,pc-pb));

for i = 0 : pc
    for j = 0 : i
        C(:,:,1+i) = C(:,:,1+i) + A(:,:,1+j) * B(:,:,1+(i-j));
    end
end

last = find(any(any(C ~= 0,1),2),1,'last');
if isempty(last)
    C = C(:,:,1);
else
    C = C(:,:,1:last);
end

end
