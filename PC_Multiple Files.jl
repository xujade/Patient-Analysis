using ColorTypes
using Pkg
using DataFrames
using CSV
using PrettyTables
using Plots

# Function to load data for one patient from several spreadsheets

function plot_patient_data(patient_id::String, filenames::Vector{String})
    # applies unique color for each spreadsheet
    colors = distinguishable_colors(length(filenames))
    plot_data = plot(xlabel="std", ylabel="cbs results", legend=:right, title= "SP06-10053")
    
    for (filename, color) in zip(filenames, colors)
        df = CSV.File(filename) |> DataFrame
        patient_data = filter(row -> row.patient == patient_id, df)
        scatter!(plot_data, patient_data.std, patient_data.cbs_result, label=filename, color=color, legend= true, markersize = 4, legendfont = 3)
    end
    
    return plot_data
end
# choose the patient
patient_id = "SP06-10053"  


folder_path = "Panel1-Interface-Interdistance\\"
panel = "Panel1-Interface-Interdistance/"
files = readdir(folder_path)
new_array = map(x -> panel * x, files)

patient1_plot = plot_patient_data("SP06-10053", new_array)
patient2_plot = plot_patient_data("SP06-9299", new_array)

plot(patient1_plot, patient2_plot, layout = (1,2))
