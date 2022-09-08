function [ch, info] = plot(db, list, varargin)

    ch = Chartpack();
    for i = 1 : 2 : numel(varargin)
        ch.(varargin{i}) = varargin{i+1};
    end

    ch.add(list);
    info = draw(ch, db);

end%

