function disp(this)

ndimsOfData = ndims(this);
higherRef = repmat({':'}, 1, ndimsOfData);
dispND(this, ndimsOfData, higherRef);

end%


%
% Local Functions
%


function dispND(this, dim, higherRef)
    if dim>2
        sizeOfData = size(this, dim);
        for i = 1 : sizeOfData
            higherRef{dim} = i;
            dispND(this, dim-1, higherRef);
        end
    else
        if numel(higherRef)>2
            page = sprintf(', %g', higherRef{3:end});
            page = ['(:, :', page, ')'];
            fprintf('%s\n', page);
            textual.looseLine( );
        end
        disp2D(this, higherRef);
    end
end%




function disp2D(this, higherRef)
    data = double(this);
    data = data(higherRef{:});
    rowNames = this.RowNames;
    c = arrayfun(@(x) sprintf('%.7g', x), real(data), 'UniformOutput', false);
    c = [ this.ColNames; c];
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
    textual.looseLine( );
end%

