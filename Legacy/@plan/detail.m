function detail(this, inp)
% detail  Display details of a simulation plan.
%
% Syntax
% =======
%
%     detail(P)
%     detail(P, Inp)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `Inp` [ struct ] - Input database.
%
% Description
% ============
%
% If you supply also the second input argument, the input database `Inp`,
% both the dates and the respective values will be reported for exogenised
% and conditioning data points, and the values will be checked for the
% presence of NaNs (with a warning should there be found any).
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

try, inp; catch, inp = [ ]; end %#ok<NOCOM>

if isfield(inp,'mean') && isstruct(inp.mean)
    inp = inp.mean;
end
    
%--------------------------------------------------------------------------

nx = nnzexog(this);
[ans,nnreal,nnimag] = nnzendog(this); %#ok<NOANS,ASGLU>
nc = nnzcond(this);

textfun.loosespace( );
range = this.Range;

[xDetail,xNan] = getDetail(this.XAnch,this.XList,range,[ ],inp);
nRealDetail = ...
    getDetail(this.NAnchReal,this.NList,range,this.NWghtReal,[ ]);
nImagDetail = ...
    getDetail(this.NAnchImag,this.NList,range,this.NWghtImag,[ ]);
[cDetail,cNan] = getDetail(this.CAnch,this.CList,range,[ ],inp);

checkList = [ ...
    xDetail(1:2:end), ...
    nRealDetail(1:2:end), ...
    nImagDetail(1:2:end), ...
    cDetail(1:2:end)];
maxLen = max(cellfun(@length,checkList));
format = ['\t\t%-',sprintf('%g',maxLen+1),'s%s\n'];
empty = @( ) fprintf('\t-\n');

fprintf('\tExogenized: [%g]\n',nx);
if ~isempty(xDetail)
    fprintf(format,xDetail{:});
else
    empty( );
end

fprintf('\tEndogenized real: [%g]\n',nnreal);
if ~isempty(nRealDetail)
    fprintf(format,nRealDetail{:});
else
    empty( );
end

fprintf('\tEndogenized imag: [%g]\n',nnimag);
if ~isempty(nImagDetail)
    fprintf(format,nImagDetail{:});
else
    empty( );
end

fprintf('\tConditioned upon: [%g]\n',nc);
if ~isempty(cDetail)
    fprintf(format,cDetail{:});
else
    empty( );
end

textfun.loosespace( );

if xNan>0
    utils.warning('plan', ...
        ['A total of [%g] exogenized data points refer(s) to NaN(s) ', ...
        'in the input database.'], ...
        xNan);
end

if cNan>0
    utils.warning('plan', ...
        ['A total of [%g] conditioning data points refer(s) to NaN(s) ', ...
        'in the input database.'], ...
        cNan);
end

end




function [det, nNan] = getDetail(anch, list, range, W, D)
isData = ~isempty(D) && isstruct(D);
isWeight = ~isempty(W) && isnumeric(W);

dates = dat2str(range);
det = { };
nNan = 0;
for irow = find(any(anch,2)).'
    index = anch(irow,:);
    name = list{irow};
    if isData
        if isfield(D,name) && isa(D.(name),'Series')
            [~,ndata] = size(D.(name).data);
            values = nan(ndata, size(anch,2));
            for idata = 1 : ndata
                values(idata, index) = D.(name)(range(index), idata).';
                nNan = nNan + sum(isnan(values(idata, index)));
            end
        else
            ndata = 1;
            values = nan(ndata, size(anch, 2));
        end            
        row = '';
        for icol = find(index)
            row = [row, ' *', dates{icol}, '[=',num2str(values(:, icol).', ' %g'), ']'];
        end
    elseif isWeight
        row = '';
        for icol = find(index)
            row = [row, ' *', dates{icol}, '[@', num2str(W(irow,icol).', ' %g'), ']'];
        end
    else        
        row = sprintf(' *%s', dates{index});
    end
    det = [det, list(irow), {row}]; %#ok<*AGROW>
end
end
