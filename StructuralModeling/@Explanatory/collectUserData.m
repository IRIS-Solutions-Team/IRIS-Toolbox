
function output = collectUserData(this, field, whenMissing)

    output = cell(size(this));
    for q = 1 : numel(this)
        if isfield(this(q).UserData, field)
            output{q} = this(q).UserData.(field);
        else
            output{q} = whenMissing;
        end
    end

end%

