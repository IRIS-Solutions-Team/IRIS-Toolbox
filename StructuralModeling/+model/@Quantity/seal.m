% seal  Validate names, add special names, populate transient
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function this = seal(this)

stringify = @(x) reshape(string(x), 1, []);

this = locallyAddSpecialExogenous(this); % Add special exogenous variables
this.OriginalNames = stringify(this.Name); % Store original names from source model code

validateNames(this);

% Populate transient properties after the placeholders for optimal policy
% variables have been created; the transient properties are needed in the
% rest of the parsing and postparsing process
this = populateTransient(this);

end%

%
% Local functions
%

function this = locallyAddSpecialExogenous(this)
    %(
    add = model.Quantity.fromNames(this.RESERVED_NAME_TTREND);
    add.Label(:) = { model.COMMENT_TTREND };
    this = insert(this, add, 5, 'last');
    %)
end%

