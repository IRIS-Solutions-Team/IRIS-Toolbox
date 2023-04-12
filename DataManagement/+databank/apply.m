%{
% 
% # `databank.apply` ^^(+databank)^^
% 
% {== Apply function to a selection of databank fields ==}
% 
% 
% ## Syntax
% 
%     [outputDb, appliedToNames, newNames] = databank.apply(inputDb, func, ...) 
% 
% 
% ## Input arguments
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank to whose fields the `function` will be applied.
% > 
% 
% __`func`__ [ function_handle ]
% > 
% > Function (function handle) that will be applied to the selected fields of
% > the `inputDb`.
% > 
% 
% ## Output arguments
% 
% __`outputDb`__ [ struct | Dictionary ]
% > 
% > Output databank created from the `inputDb` with new fields or some fields
% > modified.
% > 
% 
% __`appliedToNames`__ [ string ] 
% > 
% > List of names to which the `function` has been actually applied.
% > 
% 
% __`newNames`__ [ string ] 
% > 
% > List of names under which the results are stored in the `outputDb`.
% > 
% 
% ## Options
% 
% __`StartsWith=""`__ [ string ] 
% > 
% > Apply the `function` to fields whose names start with this string.
% > 
% 
% __`EndsWith=""`__ [ string ] 
% > 
% > Apply the `function` to fields whose names end with this string.
% > 
% 
% __`RemoveStart=false`__ [ `true` | `false` ] 
% > 
% > If option `StartsWith=` was used, a new field will be created after the
% > `function` has been applied with its named derived from the original name
% > by removing the start of the string.
% > 
% 
% __`RemoveEnd=false`__ [ `true` | `false` ] 
% > 
% > If option `EndsWith=` was used, a new field will be created after the
% > `function` has been applied with its named derived from the original name
% > by removing the end of the string.
% > 
% 
% __`Prepend=""`__ [ char | string ] 
% > 
% > A new field will be created after the `function` has been applied with
% > its named derived from the original name by prepending this string to the
% > beginning of the original field name.
% > 
% 
% __`Append=""`__ [ char | string ] 
% > 
% > A new field will be created after the `function` has been applied with
% > its named derived from the original name by appending this string to the
% > end of the original field name.
% > 
% 
% __`RemoveSource=false`__ [ `true` | `false` ] 
% > 
% > Remove the source field from the `outputDb`; the source field is
% > the `inputDb` on which the `function` was run to create a new
% > field.
% > 
% 
% __`SourceNames=@all`__ [ `@all` | cellstr | string ] 
% > 
% > List of databank field names to which the name selection procedure will
% > be reduced.
% > 
% 
% __`TargetNames=@default`__ [ `@default` | cellstr | string ] 
% > 
% > New names for output databank fields.
% > 
% 
% __`TargetDb=@default`__ [ `@default` | struct | Dictionary ] 
% > 
% > Databank to which the transformed fields will be added;
% > `TargetDb=@default` means they will be kept in the `inputDb`.
% > 
% 
% __`WhenError="keep"`__ [ `"keep"` | `"remove"` | `"error"` ]
% > 
% > What to do when the function `func` fails with an error on a field:
% > 
% > * `"keep"` means the field will be kept in the `outputDb` unchanged;
% > 
% > * `"remove"` means the field will be removed from the `outputDb`;
% > 
% > * `"error"` means the execution of `databank.apply` will stop with an
% >   error.
% > 
% 
% ## Description
% 
% 
% ## Example
% 
% Add 1 to all databank fields, regardless of their types. Note that the
% addition also works for strings.
% 
% ```matlab
% d1 = struct( );
% d1.x = Series(1:10, 1:10);
% d1.b = 1:5;
% d1.y_u = Series(qq(2010,1):qq(2025,4), @rand);
% d1.s = "x";
% d2 = databank.apply(d1, @(x) x+1); 
% ```
% 
% ## Example
% 
% Seasonally adjust all time series whose name ends with `_u`.
% 
% ```matlab
% % Create random series, some with seasonal patterns
% 
% range = qq(2010,1):qq(2025,4);
% s1 = Series.seasonDummy(range, 1);
% s2 = Series.seasonDummy(range, 2);
% s3 = Series.seasonDummy(range, 3);
% 
% d = struct();
% d.x1_u = cumsum(Series(range, @randn)) + 4*s1 - 2*s2 + 2*s3;
% d.x2_u = cumsum(Series(range, @randn)) - 1*s1 + 3*s2 - 7*s3;
% d.x3_u = cumsum(Series(range, @randn)) + 7*s1 + 3*s2 - 5*s3;
% d.x4 = cumsum(Series(range, @randn));
% d.x5 = cumsum(Series(range, @randn));
% 
% databank.list(d)
% 
% % Apply the seasonal adjustment function to all fields whose name starts
% % with `_u`; the seasonally adjusted series will be added to the databank
% % under new names created by removing the `_u`
% func = @(x) x13.season(x, "x11_mode", "add");
% d = databank.apply(d, func, "endsWith", "_u", "removeEnd", true);
% 
% databank.list(d)
% ```
% 
%}
% --8<--


% >=R2019b
%{
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, opt)

arguments
    inputDb (1, 1) {local_validateInputDbOrFunc}
    func (1, 1) {local_validateInputDbOrFunc}

    opt.StartsWith (1, 1) string = ""
        opt.HasPrefix__StartsWith = []
    opt.EndsWith (1, 1) string = ""
        opt.HasSuffix__EndsWith = []
    opt.Prepend (1, 1) string = ""
        opt.AddToStart__Prepend = []
        opt.AddPrefix__Prepend = []
    opt.Append (1, 1) string = ""
        opt.AddToEnd__Append = []
        opt.AddSuffix__Append = []
    opt.RemoveStart (1, 1) logical = false
        opt.RemovePrefix__RemoveStart = []
    opt.RemoveEnd (1, 1) logical = false
        opt.RemoveSuffix__RemoveEnd = []
    opt.RemoveSource (1, 1) logical = false
    opt.SourceNames {local_validateNames} = @all
    opt.TargetNames {local_validateNames} = @auto
    opt.TargetDb {local_validateDb} = @auto
        opt.AddToDatabank__TargetDb = []
    opt.WhenError (1, 1) string {mustBeMember(opt.WhenError, ["keep", "remove", "error"])} = "keep"
    opt.WhenSourceMissing (1, 1) string {mustBeMember(opt.WhenSourceMissing, ["error", "warning", "silent"])} = "error"
end
%}
% >=R2019b


% <=R2019a
%(
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "StartsWith", "");
        addParameter(ip, "HasPrefix__StartsWith", []);
    addParameter(ip, "EndsWith", "");
        addParameter(ip, "HasSuffix__EndsWith", []);
    addParameter(ip, "Prepend", "");
        addParameter(ip, "AddToStart__Prepend", []);
        addParameter(ip, "AddPrefix__Prepend", []);
    addParameter(ip, "Append", "");
        addParameter(ip, "AddToEnd__Append", []);
        addParameter(ip, "AddSuffix__Append", []);
    addParameter(ip, "RemoveStart", false);
        addParameter(ip, "RemovePrefix__RemoveStart", []);
    addParameter(ip, "RemoveEnd", false);
        addParameter(ip, "RemoveSuffix__RemoveEnd", []);
    addParameter(ip, "RemoveSource", false);
    addParameter(ip, "SourceNames", @all);
    addParameter(ip, "TargetNames", @auto);
    addParameter(ip, "TargetDb", @auto);
        addParameter(ip, "AddToDatabank__TargetDb", []);
    addParameter(ip, "WhenError", "keep");
    addParameter(ip, "WhenSourceMissing", "error");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


    if validate.databank(func)
        [func, inputDb] = deal(inputDb, func);
    end

    if ~isa(opt.SourceNames, 'function_handle')
        if isa(opt.SourceNames, 'Rxp')
            opt.SourceNames = databank.filter(inputDb, 'name', opt.SourceNames);
        end
        opt.SourceNames = cellstr(opt.SourceNames);
    end

    opt.StartsWith = char(opt.StartsWith);
    opt.EndsWith = char(opt.EndsWith);

    opt.Prepend = char(opt.Prepend);
    opt.Append = char(opt.Append);

    here_checkInputOutputNames( );

    if isa(inputDb, 'Dictionary')
        namesFields = cellstr(keys(inputDb));
    elseif isstruct(inputDb)
        namesFields = fieldnames(inputDb);
    end

    numFields = numel(namesFields);
    newNames = repmat({''}, size(namesFields));

    if ~isa(opt.SourceNames, 'function_handle')
        missing = setdiff(opt.SourceNames, namesFields);
        if ~isempty(missing)
            missing = reshape(string(missing), 1, []);
            exception.(opt.WhenSourceMissing)([
                "Databank"
                "This source name does not exist in the databank: %s"
            ], missing);
        end
    end

    outputDb = opt.TargetDb;
    if isequal(outputDb, @auto)
        outputDb = inputDb;
    end

    inxApplied = false(1, numFields);
    inxToRemove = false(1, numFields);
    for i = 1 : numFields
        name__ = namesFields{i};
        if ~isa(opt.SourceNames, 'function_handle') && ~any(strcmpi(name__, opt.SourceNames))
           continue
        end 
        if ~isempty(opt.StartsWith) && ~startsWith(name__, opt.StartsWith)
            continue
        end
        if ~isempty(opt.EndsWith) && ~endsWith(name__, opt.EndsWith)
            continue
        end

        inxApplied(i) = true;

        %
        % Create output field name
        %
        if iscellstr(opt.TargetNames)
            inxName = strcmp(opt.SourceNames, name__);
            newName__ = opt.TargetNames{inxName};
        elseif isa(opt.TargetNames, 'function_handle') && ~isequal(opt.TargetNames, @auto)
            newName__ = opt.TargetNames(name__);
        else
            newName__ = name__;
            if opt.RemoveStart
                newName__ = extractAfter(newName__, strlength(opt.StartsWith));
            end
            if opt.RemoveEnd
                newName__ = extractBefore(newName__, strlength(newName__)-strlength(opt.EndsWith)+1);
            end
            if ~isempty(opt.Prepend)
                newName__ = [opt.Prepend, newName__];
            end
            if ~isempty(opt.Append)
                newName__ = [newName__, opt.Append];
            end
        end
        newNames{i} = newName__;

        field__ = inputDb.(name__);
        if ~isempty(func)
            success = true;
            try
                field__ = func(field__);
            catch exc
                success = false;
                if opt.WhenError=="error"
                    exception.warning([
                        "Databank:ErrorEvaluatingFunction"
                        "The function failed with an error on this field: %s"
                    ], name__);
                    rethrow(exc);
                end
            end
        end
        if isa(outputDb, 'Dictionary')
            store(outputDb, newName__, field__);
        else
            outputDb.(newName__) = field__;
        end
        inxToRemove(i) = (opt.RemoveSource && ~strcmp(name__, newName__)) ...
            || (opt.WhenError=="remove" && ~success);
    end

    if any(inxToRemove)
        outputDb = rmfield(outputDb, namesFields(inxToRemove));
    end

    appliedToNames = namesFields(inxApplied);
    newNames = newNames(inxApplied);

    return


    function here_checkInputOutputNames( )
        if isa(opt.TargetNames, 'function_handle')
            return
        end
        if validate.list(opt.SourceNames)
            opt.SourceNames = cellstr(opt.SourceNames);
        end
        if validate.list(opt.TargetNames)
            opt.TargetNames = cellstr(opt.TargetNames);
        end
        if iscellstr(opt.TargetNames) 
            if iscellstr(opt.TargetNames) && numel(opt.SourceNames)==numel(opt.TargetNames)
                return
            end
        end
        exception.error([
            "Databank:InconsistentInputOutputNames"
            "When used together in databank.apply(~), "
            "options SourceNames= and TargetNames= "
            "must be lists of the same size"
        ]);
    end%

end%


function local_validateInputDbOrFunc(input)
    if isempty(input) || validate.databank(input) || isa(input, 'function_handle')
        return
    end
    error("Validation:Failed", "Input value must empty, a databank or a function handle");
end%


function local_validateNames(input)
    if isa(input, 'function_handle') || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function local_validateDb(input)
    if isa(input, 'function_handle') || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%

