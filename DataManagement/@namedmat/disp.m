function disp(this)

ndimsOfData = ndims(this);
ref = repmat({':'}, 1, ndimsOfData);
dispND(this, ndimsOfData, ref);

end%


%
% Local Functions
%


function dispND(this, dim, ref)
    if dim>2
        sizeOfData = size(this, dim);
        for i = 1 : sizeOfData
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
    try
        disp(table(this, ref{3:end}));    
    catch
        data = double(this);
        data = data(ref{:});
        rowNames = this.RowNames;
        colNames = this.ColNames;
        c = arrayfun(@(x) sprintf('%.7g', x), real(data), 'UniformOutput', false);
        c = [ colNames; c];
        maxLength = max(cellfun('length', c), [ ], 1);
        for i = 1 : size(data, 2);
            c(:, i) = pad(c(:, i), maxLength(i)+2, 'left');
            c(:, i) = strcat('    ', c(:, i));
        end
        s = '';
        for i = 1 : size(c, 1);
            s = [s; [c{i, :}]];
        end
        rowNames = [{''}, rowNames];
        rowNames = char(rowNames);
        rowNames = [rowNames, repmat(' | ', size(rowNames, 1), 1)];
        s = [rowNames, s];
        spaceColumn = repmat(' ', size(s, 1), 1);
        s = [spaceColumn, s, spaceColumn];
        dividerRow = repmat('-', 1, size(s, 2));
        s = [dividerRow; s(1, :); dividerRow; s(2:end, :); dividerRow];
        s = [repmat('    ', size(s, 1), 1), s];
        disp(s);
        disp(' ');
    end
    textual.looseLine( );

    return


end%

