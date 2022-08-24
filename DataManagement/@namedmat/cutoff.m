%#ok<*VUNUS>
%#ok<*CTCH>

function [Cof, Cop] = cutoff(F, Freq, Cog)

try
    Cog; 
catch 
    Cog = 1/2;
end

nFreq = length(Freq);
if size(F, 3) ~= nFreq
    utils.error('namedmat:cutoff', ...
        ['Size of the frequency response matrix in 3rd dimension (%g) is not ', ...
        'consistent with the length of the vector of frequencies (%g).'], ...
        size(F, 3), nFreq);
end

%--------------------------------------------------------------------------

nx = size(F, 1);
ny = size(F, 2);
nAlt = size(F, 4);

rowNames = F.RowNames;
colNames = F.ColumnNames;
F = abs(double(F));

Cof = nan(nx, ny, nAlt);
for i = 1 : nx
    for j = 1 : ny
        for k = 1 : nAlt
            Cof(i, j, k) = xxCutOff(F(i, j, :, k), Freq, Cog);
        end
    end
end

Cop = 2*pi./Cof;
Cof = namedmat(Cof, rowNames, colNames);
Cop = namedmat(Cop, rowNames, colNames);

end


% Subfunctions...


%**************************************************************************


function C = xxCutOff(F, Freq, Cog)
F = F(:).';
F1 = F(1:end-1);
F2 = F(2:end);
C = NaN;
inx = (F1 >= Cog & F2 <= Cog) | (F1 <= Cog & F2 >= Cog);
if ~any(inx)
    return
end
pos = find(inx, 1);
d = abs(F1(pos) - F2(pos));
w1 = abs(F1(pos) - Cog) / d;
w2 = abs(F2(pos) - Cog) / d;
C = (1-w1)*Freq(pos) + (1-w2)*Freq(pos+1);
end % xxCutOff( )
