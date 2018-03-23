function [Cof,Cop] = cutoff(F,Freq,Cog)
% cutoff  Approximate cut-off frequency and periodicity from sample frequency response function.
%
% Syntax
% =======
%
%     [Cof,Cop] = cutoff(F,Freq)
%     [Cof,Cop] = cutoff(F,Freq,Cog)
%
% Input arguments
% ================
%
% * `F` [ namedmat ] - Frequency response function (FRF), i.e. the first
% output argument from [`model/ffrf`](model/ffrf) or
% [`VAR/ffrf`](VAR/ffrf).
%
% * `Freq` [ numeric ] - Vector of frequencies on which the FFRF has been
% evaluated.
%
% * `Cog` [ numeric ] - Definition of the cut-off gain; if not specified,
% `Cog=1/2`.
%
% Output arguments
% =================
%
% * `Cof` [ numeric ] - Cut-off frequency for each of the FFRF, i.e. the
% frequency at which the gain of the FRF equals `X`.
%
% * `Cop` [ numeric ] - Cut-off periodicity.
%
% Description
% ============
%
% Because the function `cutoff` calculates the cut-off frequencies based on
% a vector of discrete points describing the frequency response function,
% it uses simple interpolation between two neighbouring points.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Cog; 
catch 
    Cog = 1/2;
end

nFreq = length(Freq);
if size(F,3) ~= nFreq
    utils.error('namedmat:cutoff', ...
        ['Size of the frequency response matrix in 3rd dimension (%g) is not ', ...
        'consistent with the length of the vector of frequencies (%g).'], ...
        size(F,3),nFreq);
end

%--------------------------------------------------------------------------

nx = size(F,1);
ny = size(F,2);
nAlt = size(F,4);

rowNames = rownames(F);
colNames = colnames(F);
F = abs(double(F));

Cof = nan(nx,ny,nAlt);
for i = 1 : nx
    for j = 1 : ny
        for k = 1 : nAlt
            Cof(i,j,k) = xxCutOff(F(i,j,:,k),Freq,Cog);
        end
    end
end

Cop = 2*pi./Cof;
Cof = namedmat(Cof,rowNames,colNames);
Cop = namedmat(Cop,rowNames,colNames);

end


% Subfunctions...


%**************************************************************************


function C = xxCutOff(F,Freq,Cog)
F = F(:).';
F1 = F(1:end-1);
F2 = F(2:end);
C = NaN;
inx = (F1 >= Cog & F2 <= Cog) | (F1 <= Cog & F2 >= Cog);
if ~any(inx)
    return
end
pos = find(inx,1);
d = abs(F1(pos) - F2(pos));
w1 = abs(F1(pos) - Cog) / d;
w2 = abs(F2(pos) - Cog) / d;
C = (1-w1)*Freq(pos) + (1-w2)*Freq(pos+1);
end % xxCutOff( )
