# X12-ARIMA spec file default template.

# -The IRIS Toolbox.
# -Copyright (c) 2007-2013 IRIS Solutions Team.

series {
    data = (
    $series_data$
    )
    period = $series_freq$
    start = $series_startyear$.$series_startper$
    precision = 5
    decimals = 5
    $series_missingvaladj$
}

transform {
    function = $transform_function$
}

automdl {
    maxorder = ($maxorder$)
}

forecast {
    maxlead = $forecast_maxlead$
    maxback = $forecast_maxback$
    save = (forecasts backcasts)
}

estimate {
    tol = $tolerance$
    maxiter = $maxiter$
    save = (model)
}

#regression regression {
#regression #tdays     variables = ($tdays$)
#regression #dummy     start = $dummy_startyear$.$dummy_startper$
#regression #dummy     user = ($dummy_name$)
#regression #dummy     usertype = $dummy_type$
#regression #dummy     data = (
#regression #dummy     $dummy_data$
#regression #dummy     )    
#regression }

x11 {
    mode = $x11_mode$
    save = ($x11_save$)
    appendbcst = no
    appendfcst = no
}

