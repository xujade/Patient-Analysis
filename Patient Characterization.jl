# Panel1-Interface-Cutoff5-Hipergator1
# Interdistance
using ColorTypes
using Pkg
using DataFrames
using CSV
#using PrettyTables
using Plots
#using HypothesisTests
#using Query   // dont know if i gonna use theses
#using Statistics  
#using Dates
#using Test

df = CSV.File("Panel1-Interface-Interdistance\\Query for (interdist)cd3+cd82023-09-30.csv") |> DataFrame
#pretty_df = pretty_table(df)
patientId = df[:, 1] # reading from the file as a matrix
id = convert(Array, patientId) #array of all the patient ids
uniqueId = unique(id) 
nColors = length(uniqueId)

println("Amount of patients: ", nColors)

unique_colors = distinguishable_colors(nColors)

color_dict = Dict(uniqueId => i for (i, uniqueId) in enumerate(uniqueId))

color_dict = Dict{String, RGB}()
for (patient_id, color) in zip(uniqueId, unique_colors)
    color_dict[patient_id] = color
end

# create scatter plots

cbs_TEffector_plot = plot(title="CBS vs. TEffector", xlabel="TEffector", ylabel="CBS")
cbs_std_plot = plot(title="CBS vs. STD", xlabel="STD", ylabel="CBS")
cbs_size_plot = plot(title="CBS vs. Size", xlabel="Size", ylabel="CBS")
cbs_SarcomatoidStatus_plot = plot(title="CBS vs. SarcomatoidStatus", xlabel="SarcomatoidStatus", ylabel="CBS")

#used to make the labels idk how else to do it teheheheh
plot3 = plot(title="not real", xlabel="not real", ylabel="not real")
legend1 = plot()

# iterate over each patient ID
for patient_id in uniqueId
    # Filter data for the current patient ID
    filtered_df = filter(row -> row.patient == patient_id, df)

    # plot data points for the current patient with assigned color and label
    scatter!(cbs_TEffector_plot, filtered_df.Teffector, filtered_df.cbs_result, color=color_dict[patient_id], legendfont = 3, legend=false, markersize = 2 )
    scatter!(cbs_std_plot, filtered_df.std, filtered_df.cbs_result, color=color_dict[patient_id], legend=false, markersize = 2)
    scatter!(cbs_size_plot, filtered_df.Size, filtered_df.cbs_result, color=color_dict[patient_id], legend=false, markersize = 2)
    scatter!(cbs_SarcomatoidStatus_plot, filtered_df.SarcomatoidStatus, filtered_df.cbs_result, color=color_dict[patient_id], legend=false, markersize = 2)
    scatter!(plot3, filtered_df.mean, filtered_df.cbs_result, color=color_dict[patient_id], legend=true, markersize = 2)
    scatter!(legend1,filtered_df.mean , filtered_df.cbs_result, color=color_dict[patient_id], label=string(patient_id), markersize = 5, showaxis = false, grid = false, legend = true, legendfont = 2)
end

plot(cbs_std_plot, legend1)