function cell2csv(C,FNAME,varargin)

def = { ...
    'format','%2g',@ischar, ...
    };

opt = passvalopt(def,varargin{:});

if ischar(C) && iscell(C)
    [C,FNAME] = deal(FNAME,C);
end

%**************************************************************************

if size(C,1) == 1 && all(cellfun(@iscell,C))
    type = 'cellofcell';
else
    type = 'array';
end

[nrow,ncol] = getsize( );
br = sprintf('\n');
c = '';
for row = 1 : nrow
    for col = 1 : ncol
        x = getcell(row,col);
        if isnumeric(x)
            x = sprintf(opt.format,x);
        elseif islogical(x)
            if x
                x = 'true';
            else
                x = 'false';
            end
        elseif ~ischar(x)
            x = '???';
        end
        c = [c,x]; %#ok<AGROW>
        if col < ncol
            c = [c,',']; %#ok<AGROW>
        end
    end
    if row < nrow
        c = [c,br]; %#ok<AGROW>
    end
end

char2file(c,FNAME);

    function [nrow,ncol] = getsize( )
        switch type
            case 'cellofcell'
                nrow = length(C);
                ncol = max(cellfun(@length,C));
            case 'array'
                [nrow,ncol] = size(C);
        end
    end

    function x = getcell(row,col)
        switch type
            case 'cellofcell'
                if row <= length(C) && col <= length(C{row})
                    x = C{row}{col};
                else
                    x = '';
                end
            case 'array'
                x = C{row,col};
        end
    end

end