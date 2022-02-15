function this = getVariant(this, variantsRequested)

nv = length(this);
inxOfValid = variantsRequested<=nv | ...
             variantsRequested>=1 | ...
             variantsRequested==round(variantsRequested);
if any(~inxOfValid)
    throw( exception.Base('Model:IndexExceedsVariants', 'error'), ...
           exception.Base.alt2str( sort(variantsRequested(~inxOfValid)) ) ); %#ok<GTARG>
end

this.Variant = subscripted(this.Variant, variantsRequested);

end%

