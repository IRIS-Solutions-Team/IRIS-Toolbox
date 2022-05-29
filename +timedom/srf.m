function [Phi, sizeOfShocks] = srf(T, R, ~, Z, H, ~, U, ~, numOfPeriods, sizeOfShocks)
% srf  Shock response function (or VMA) for general state space
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%#ok<*CTCH>
%#ok<*VUNUS>
 
try
    sizeOfShocks;
catch 
    sizeOfShocks = 1;
end

%--------------------------------------------------------------------------

numOfY = size(Z, 1);
[numOfXi, numOfBwl] = size(T);
numOfFwl = numOfXi - numOfBwl;
numOfE = size(R, 2);

% Shock size
sizeOfShocks = sizeOfShocks(:).';
if length(sizeOfShocks)==1 && numOfE~=1
   sizeOfShocks = sizeOfShocks(1, ones(1, numOfE));
end

% Add a zero pre-sample period for transition variables
Phi = nan(numOfY+numOfXi, numOfE, numOfPeriods+1);
Phi(:, :, 1) = 0;

% Simulate measurement shocks first, then transition shocks
% First simulated period is page 2
if numOfY>0
    Phi(:, :, 2) = [ H.*sizeOfShocks(ones(1, numOfY), :)
                     R.*sizeOfShocks(ones(1, numOfXi), :) ];
else
    Phi(:, :, 2) = R.*sizeOfShocks(ones(1, numOfXi), :);
end

if numOfY>0
   Phi(1:numOfY, :, 2) = Phi(1:numOfY, :, 2) + Z*Phi(numOfY+numOfFwl+1:end, :, 2);
end

for t = 2 : numOfPeriods
   Phi(numOfY+1:end, :, t+1) = T*Phi(numOfY+numOfFwl+1:end, :, t);
   if numOfY>0
      Phi(1:numOfY, :, t+1) = Z*Phi(numOfY+numOfFwl+1:end, :, t+1);
   end
end

if ~isempty(U)
   for t = 1 : size(Phi, 3)
      Phi(numOfY+numOfFwl+1:end, :, t) = U*Phi(numOfY+numOfFwl+1:end, :, t);
   end
end

end%

