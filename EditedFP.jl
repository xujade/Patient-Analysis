using Pkg
using DataFrames
using CSV
using Plots
using DataStructures

orginial = CSV.File("Panel1-Interface-Interdistance\\Query for (interdist)cd3+cd82023-09-30.csv") |> DataFrame

df = sort(orginial, :14)
#df = CSV.File("testing.csv") |> DataFrame

patient = df[:, 1]
tEffector = (df[:, 14])
uniqueTF = unique(tEffector)
deleteat!(uniqueTF, findall(ismissing, uniqueTF))
uniquePatient = unique(patient) 

# making a dict
patient_data = OrderedDict{String, Vector{Float64}}()

parameter = 12
# Iterate through the data and organize values by patient ID
for row in eachrow(df)
    patient_id = row[1]  # Assuming patient ID is in the first column
    value = row[parameter]       # Assuming value is specified parameter coumn
    tEffectorLocation = row[14]
    # looking at the kbs value
    
    if haskey(patient_data, patient_id)
        push!(patient_data[patient_id], value)
    else
        patient_data[patient_id] = [value]
    end

    # Remove patients with missing values
    if haskey(patient_data, patient_id)
        if ismissing(tEffectorLocation)
            delete!(patient_data, patient_id)
        end
    end
end

# Convert the dictionary to a 2D array
result = [patient_data[patient_id] for patient_id in keys(patient_data)]


# Create a forest plot
#forestplot(patient, mean, cbs, ks)

# Specify the patient ID you want to find the vector for
patient_id_to_find = "SP07-7007"

# Check if the patient ID exists in the dictionary
if haskey(patient_data, patient_id_to_find)
    # Get the vector of points for the specified patient ID
    points_for_patient = patient_data[patient_id_to_find]
    println("Points for patient $patient_id_to_find: $points_for_patient")
else
    println("Patient $patient_id_to_find not found.")
end

function kForestPlot(ci; sourcelabel = "Source:", metriclabel = "OR", cilabel = "CBS Result", 
    source = nothing, metric = nothing, printci = false,
    summary = nothing, logscale = true, cimsz = -1, cimszwts = nothing, size = (1000, 600), kwargs...)

    #size=(800,400)
    lines = length(ci)+3
    if lines <= 6  lines = 8 end
    ylims = (0, lines)
    sty   = lines - 1
    

    if logscale 
        func = exp
    else
        func = identity
    end

    #maxx = func(round((maximum(x -> x[end], ci) - 0.1)/2, digits = 1)*2 + 0.2)
    #minx = func(round((minimum(x -> x[1], ci) - 0.1)/2, digits = 1)*2 )

    # set the x-axis limits to the minimum and maximum values of CBS
    minx = -0.01
    maxx = 0.6
    xlims = (minx, maxx)
   # ticks = collect(minx:0.2*floor((maxx - minx)/0.2/4):maxx)
   ticks = collect(minx:0.1:maxx)

    p = plot(size = size)

    for i = 1:length(ci)
        if length(ci[i]) == 1
            plot!(p, func.(ci[i]), fill(sty - i, 1), markershape = :vline, linecolor = :blue, markercolor = :blue)
        elseif length(ci[i]) == 2
            plot!(p, func.(ci[i]), fill(sty - i, 2), markershape = :vline, linecolor = :blue, markercolor = :blue)
        elseif length(ci[i]) == 3
            plot!(p, func.(ci[i]), fill(sty - i, 3), markershape = :vline, linecolor = :blue, markercolor = :blue)
        else
            error("Confidence intervals must be of size 1, 2 or 3.")
        end
    end

    if cimsz < 0 && (!isnothing(metric) || !isnothing(cimszwts)) 
        if isnothing(cimszwts) cimszwts = metric end
        minm = minimum(cimszwts)
        c = (maximum(cimszwts) - minm)/3 
        cimsz = @. (cimszwts - minm) / c + 3 
    end

    if !isnothing(metric)
        my = sty .- collect(1:length(metric))
        # turning off the display of teffector on graph
        # plot!(func.(metric), my, seriestype= :scatter, markershape = :rect, markercolor = :gray, markeralpha = 0.8, markersize = 2, legend = false)
    end
"""
    # TODO: summary - red line and red diamond, needs works (low priority)
    if !isnothing(summary) && haskey(summary, :ci) && haskey(summary, :est)
        if haskey(summary, :markershape)
            ms = summary[:markershape]
        else
            ms = :diamond
        end
        if haskey(summary, :markersize)
            msz = summary[:markersize]
        else
            msz = 5
        end
        if length(summary[:ci]) == 1
            plot!(p, func.(summary[:ci]), fill(1, 1), markershape = ms, markercolor = :red, legend = false, markersize = msz)
        elseif length(summary[:ci]) == 2
            plot!(p, func.(summary[:ci]), fill(1, 2), markershape = :vline, linecolor = :red, markercolor = :red)
            plot!([func(summary[:est])], [1], seriestype= :scatter, markershape = ms, markercolor = :red, legend = false, markersize = msz)
            if(haskey(summary, :vline) && summary[:vline] == false)
                plot!(p, func.([summary[:est], summary[:est]]),[0, 5.5], line = (:dash, 1.5), linealpha = 0.7, linecolor = :red)
            end
        elseif length(summary[:ci]) == 3
            plot!(p, func.(summary[:ci]), fill(1, 3), markershape = :vline, linecolor = :red, markercolor = :red)
            plot!([func(summary[:est])], [1], seriestype= :scatter, markershape = ms, markercolor = :red, legend = false, markersize = msz)
            if(haskey(summary, :vline) && summary[:vline] == false)
                plot!(p, func.([summary[:est], summary[:est]]),[0, 5.5], line = (:dash, 1.5), linealpha = 0.7, linecolor = :red)
            end
        end
        else
            error("Summary confidence interval must be of size 1, 2 or 3.")
    end
"""
  #  plot!(p, func.([1, 1]),[0, 5.5]; linetype=:line, linealpha = 0.7,  linecolor = :black, line = (:dot, 1.5))
    plot!(p; ylims = ylims, xlims = xlims, yshowaxis = false, ticks = (func.(ticks), ticks))

    if !isnothing(source)
        tp = plot(showaxis = false, xlims=(0, 2.5), ylims = ylims, size = size)
        t = Plots.text(sourcelabel, halign = :left, family = "Palatino Bold")
        annotate!(tp, 0, sty, t)
        for i = 1:length(source)
            t = Plots.text(source[i], halign = :left, family = "Palatino") # changes the patient name format
            annotate!(tp, 0, sty - i, t)
        end

        if !isnothing(metric) 
            t = Plots.text(metriclabel, halign = :left, family = "Palatino Bold")
            annotate!(tp, 1.6, sty, t)
            for i = 1:length(metric)
                t = Plots.text(string(round(metric[i], digits = 3)), halign = :left, family = "Palatino")
                annotate!(tp, 1.8, sty - i, t)
            end
        end

        if printci
            t = Plots.text(cilabel, halign = :left, family = "Palatino Bold")
            annotate!(tp, 2.3, sty, t)
            for i = 1:length(ci)
                if length(ci[i]) == 1
                    t = Plots.text(string("(",round([1][1], digits = 3), ")"), halign = :left, family = "Palatino")
                    annotate!(tp, 2.2, sty - i, t)
                else
                t = Plots.text(string("(",round(ci[i][1], digits = 3), "-", round(ci[i][2], digits = 3), ")"), halign = :left, family = "Palatino")
                annotate!(tp, 2.2, sty - i, t)
                end
            end
        end

        l = @layout [a b{0.7w}]
        return plot(tp, p; layout = l, legend = false, kwargs...)
    else
        return plot!(p; kwargs...)
    end
end


keys_array = collect(keys(patient_data))
values_array = collect(values(patient_data))

"""
kForestPlot( values_array, 
    metric = uniqueTF, source = keys_array,
    sourcelabel = "Patient:", metriclabel = "TEffector", 
    summary= Dict(:ci => [0.09, 0.3], :est => 0.2), # red line & red diamond
    logscale = false, printci = false, title = ["(interdist)cd3+cd82023-09-30" "CBS Result vs T-Effector" ], size = (1050, 1900)
)
"""

kForestPlot( values_array, 
    metric = uniqueTF, source = keys_array,
    sourcelabel = "Patient:", metriclabel = "TEffector", 
    summary= Dict(:ci => [0.09, 0.3], :est => 0.2), # red line & red diamond
    logscale = false, printci = false, title = ["(interdist)cd3+cd82023-09-30" "CBS Result vs T-Effector" ], size = (1050, 1900)
)

