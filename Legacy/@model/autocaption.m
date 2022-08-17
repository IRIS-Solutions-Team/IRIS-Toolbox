function captions = autocaption(this, inp, template, varargin)

defaults = { ...
    'corr', 'Corr $shock1$ X $shock2$', @ischar, ...
    'std', 'Std $shock$', @ischar, ...
};

opt = passvalopt(defaults, varargin{:});
captions = generateAutocaption(this.Quantity, inp, template, opt);

end
