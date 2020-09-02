function disp(this)

ndimsData = ndims(this);
ref = repmat({':'}, 1, ndimsData);
dispND(this, ndimsData, ref);

end%

%
% Local Functions
%

function dispND(this, dim, ref)
    if dim>2
        sizeData = size(this, dim);
        for i = 1 : sizeData
            ref{dim} = i;
            dispND(this, dim-1, ref);
        end
    else
        if numel(ref)>2
            page = sprintf(', %g', ref{3:end});
            page = ['(:, :', page, ')'];
            fprintf('%s\n', page);
            textual.looseLine( );
        end
        disp2D(this, ref);
    end
end%


function disp2D(this, ref)
    disp(table(this, ref{3:end}));    
    textual.looseLine( );
    return
end%

