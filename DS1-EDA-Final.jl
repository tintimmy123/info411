### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ a68477f0-5ecd-11ee-0a60-2b682976688c
using CSV, DataFrames, StatsPlots, Plots, Statistics, Clustering, StatsBase, CategoricalArrays, Random, PlutoUI, HypertextLiteral

# ╔═╡ b6ee7085-8cf6-45ea-80eb-2f25f6bc4cde
@htl("""
<article class="assignment">
	<h1>
		DS1 Exploratory Data Analysis
	</h1>
</article>
<style>

	article.assignment {
		background: #488af94f;
		padding: 1em;
		border-radius: 5px;
	}

	article.assignment h1::before {
		content: "👉";
	}

</style>
""")

# ╔═╡ 44a4036b-5ee4-47fa-b152-3e84b6e1f284
md"""
## 1. Dashboard
"""

# ╔═╡ 3d67e161-0b5d-4004-8686-fb6bf2242bd9
md"""
## 2. Data Preparation
"""

# ╔═╡ 0c717346-8f5a-4492-b37b-89697a975e87
column_names = ["age", "sex", "cp", "trestbps", "chol", "fbs", "restecg", "thalach", "exang", "oldpeak", "slope", "ca", "thal", "num"] 

# ╔═╡ f191fda3-3a10-4f5f-830c-c0470d819580
begin
	df = CSV.read("statlog-heart.data.txt", header=column_names, DataFrame)
	columns_to_convert = [2, 3, 6, 7, 9, 11, 13]
	for col in columns_to_convert
    	df[!, col] = categorical(df[!, col])
	end
	df
end

# ╔═╡ 52d48d83-d719-474b-a308-d0a1e29149ed
first(df, 5)

# ╔═╡ f2b78422-22b6-410b-8c4a-f4bb845cb31e
describe(df)

# ╔═╡ 1d3eaab0-d2d8-4376-8e32-c7f840a475d1
class_distribution = countmap(df.num)

# ╔═╡ 8b7b2b61-072c-4e88-871b-70c13c3382a2
md"""
## 3. Exploration & Plotting
"""

# ╔═╡ 25c76568-f514-4aec-8e71-cbc73c7b4442
md"""
### 3.1 Attributes Overview  
"""

# ╔═╡ 7b4c7531-b462-4bd2-bbc4-c30a6ecef573
attr_list = ["Age","Sex","Chest Pain Type","Resting Blood Sugar","Serum Cholestoral","Fasting Blood Sugar","Resting Electrocardiographic","Maximum Heart Rate Achieved","Excercise Induced Angina","Excercise Induced ST Depression","Slope ST Segment","Number of Major Vessels","Thalassemia"]

# ╔═╡ f1f6faa9-b23c-4a53-8804-c1d282117aa7
begin
	correlation_matrix0 = cor(Matrix(df[:, 1:13]))
	column_name0 = attr_list
	heatmap(column_name0, column_name0, correlation_matrix0, color=:coolwarm, title="Overall Correlation Heatmap", xrotation = 90)
	for i in 1:length(column_name0)
    	for j in 1:length(column_name0)
			annotate!([(i-0.5, j-0.5, text(round(correlation_matrix0[i, j], digits=2), 	10, :black, :center))])
    	end
	end
	corplot1 = plot!(size = (750,750)) 
end

# ╔═╡ ccdd3f38-2826-4fd5-adc3-df4bf0841269
md"""
### 3.2 Numeric Attributes  
"""

# ╔═╡ 71a5fdfc-365b-4172-ad8e-e40d8b67f259
numeric_attributes = [:age, :trestbps, :chol, :thalach, :oldpeak, :ca]

# ╔═╡ 2559a0f6-520c-47ac-8549-0d7947a53c21
numeric_attr_list = ["Age","Resting Blood Sugar","Serum Cholestoral","Maximum Heart Rate Achieved","Excercise Induced ST Depression","Number of Major Vessels"]

# ╔═╡ 5aa9a489-9013-47a6-b088-bd9de6b77737
begin
	plot_layout1 = Vector{Plots.Plot}(undef, length(numeric_attributes))
	for (i, attr) in enumerate(numeric_attributes)
		p = histogram(df[!, attr], legend=false, xlabel=numeric_attr_list[i], ylabel="Frequency")
    	plot!(p)
    	plot_layout1[i] = p
	end
	histo1 = plot(plot_layout1..., size=(750, 750))
end

# ╔═╡ e4a7cb22-b6a4-48a3-9367-6e1306f30061
begin
	correlation_matrix1 = cor(Matrix(df[:, numeric_attributes]))
	column_name1 = numeric_attr_list
	heatmap(column_name1, column_name1, correlation_matrix1, color=:cool, title="Numeric Correlation Heatmap", xrotation = 90)
	for i in 1:length(column_name1)
    	for j in 1:length(column_name1)
			annotate!([(i-0.5, j-0.5, text(round(correlation_matrix1[i, j], digits=2), 	10, :black, :center))])
    	end
	end
	corplot2 = plot!(size = (750,750)) 
end

# ╔═╡ d330aa8b-799f-4fbe-b9fc-eb910f2a8b4a
begin
	histogram(df[df.num .== 1, :age], alpha=0.6, label="Absence of Heart Disease", legend=:topright, bins=10, xlabel="Age", ylabel="Frequency", title="Age Distribution by Heart Disease Presence", titlefont=font(12), color=:lightsalmon)
	histo3 = histogram!(df[df.num .== 2, :age], alpha=0.6, label="Presence of Heart Disease", bins=10, color=:lightgreen)
end

# ╔═╡ e7552e6c-6b51-43e8-bbe6-4e82f9cdd3cf
begin
	histogram(df[df.num .== 1, :trestbps], alpha=0.6, label="Absence of Heart Disease", legend=:topright, bins=10, xlabel="Resting Blood Pressure (trestbps)", ylabel="Frequency", title="Resting Blood Pressure Distribution by Heart Disease Presence", titlefont=font(12))
	histo4 = histogram!(df[df.num .== 2, :trestbps], alpha=0.6, label="Presence of Heart Disease", bins=10)
end

# ╔═╡ 83fdaa74-3bf9-4d95-bda4-fa75d494bbb3
begin
	histogram(df[df.num .== 1, :chol], alpha=0.6, label="Absence of Heart Disease", legend=:topright, bins=10, xlabel="Serum Cholestoral (chol)", ylabel="Frequency", title="Serum Cholestoral Distribution by Heart Disease Presence", titlefont=font(12), color=:gray)
	histo5 = histogram!(df[df.num .== 2, :chol], alpha=0.6, label="Presence of Heart Disease", bins=10, color=:yellow)
end

# ╔═╡ d7b9f4eb-414a-46ca-9751-bf4a55ab4ddd
begin
	histogram(df[df.num .== 1, :thalach], alpha=0.6, label="Absence of Heart Disease", legend=:topleft, bins=10, xlabel="Maximum Heart Rate (thalach)", ylabel="Frequency", title="Maximum Heart Rate Distribution by Heart Disease Presence", titlefont=font(12), color=:aqua)
	histo6 = histogram!(df[df.num .== 2, :thalach], alpha=0.6, label="Presence of Heart Disease", bins=10, color=:brown)
end

# ╔═╡ 5f144b91-c205-4ccf-86f5-e4b13742fe65
begin
	histogram(df[df.num .== 1, :oldpeak], alpha=0.6, label="Absence of Heart Disease", legend=:topright, bins=10, xlabel="ST Depression (oldpeak)", ylabel="Frequency", title="ST Depression Distribution by Heart Disease Presence", titlefont=font(12), color=:purple)
	histo7 = histogram!(df[df.num .== 2, :oldpeak], alpha=0.6, label="Presence of Heart Disease", bins=10, color=:gold)
end

# ╔═╡ aac25c2b-7c36-41f1-9bf9-4f70ff18287d
begin
	ca_values = [0, 1, 2, 3]
	absenceca_counts = []
	presenceca_counts = []
	for ca in ca_values
   		absence_count = sum(df[df.num .== 1, :ca] .== ca)
    	presence_count = sum(df[df.num .== 2, :ca] .== ca)
   		push!(absenceca_counts, absence_count)
    	push!(presenceca_counts, presence_count)
	end
	ca_labels = ["CA Value $ca" for ca in ca_values]
	bar(ca_labels, absenceca_counts, color=:purple, alpha=0.7, label="Absence of Heart Disease", legend=:topright, xlabel="Number of Major Vessels (ca)", ylabel="Frequency", title="Number of Major Vessels Distribution by Heart Disease Presence", titlefont=font(10))
	histo14 = bar!(ca_labels, presenceca_counts, color=:lightpink, alpha=0.7, label="Presence of Heart Disease")
end

# ╔═╡ f6356900-2471-4bd3-9742-fe3ba3139a98
md"""
### 3.3 Nominal Attributes  
"""

# ╔═╡ d61d7924-aeae-4bb7-9f77-5e0c38177fd7
nominal_attributes = [:sex, :cp, :fbs, :restecg, :exang, :slope, :thal]

# ╔═╡ b75b2b23-8877-416f-b67f-c2edec4ee2ca
nominal_attr_list = ["Sex","Chest Pain Type","Fasting Blood Sugar","Resting Electrocardiographic","Excercise Induced Angina","Slope ST Segment","Thalassemia"]

# ╔═╡ 7243a28b-bfba-4571-b191-75f125c87db1
begin
	plot_layout2 = Vector{Plots.Plot}(undef, length(nominal_attributes))
	for (i, attr) in enumerate(nominal_attributes)
		p = bar(countmap(df[!, attr]), legend=false, xlabel=nominal_attr_list[i], ylabel="Frequency")
    	plot!(p)
    	plot_layout2[i] = p
	end
	histo2 = plot(plot_layout2..., size=(750, 750))
end

# ╔═╡ 65cb052c-79a1-470c-b84f-80fb6845d121
begin
	correlation_matrix2 = cor(Matrix(df[:, nominal_attributes]))
	column_name2 = nominal_attr_list
	heatmap(column_name2, column_name2, correlation_matrix2, color=:coolwarm, title="Nominal Correlation Heatmap", xrotation = 90)
	for i in 1:length(column_name2)
    	for j in 1:length(column_name2)
			annotate!([(i-0.5, j-0.5, text(round(correlation_matrix2[i, j], digits=2), 	10, :black, :center))])
    	end
	end
	corplot3 = plot!(size = (750,750)) 
end

# ╔═╡ cc6ca30e-dcab-499f-bb76-4075b8a87e0f
begin
	absence_female_count = sum(df[df.num .== 1, :sex] .== 0)
	absence_male_count = sum(df[df.num .== 1, :sex] .== 1)
	presence_female_count = sum(df[df.num .== 2, :sex] .== 0)
	presence_male_count = sum(df[df.num .== 2, :sex] .== 1)
	histo8 = bar(["Absence 0 (F)", "Absence 1 (M)", "Presence 0 (F)", "Presence 1 (M)"], [absence_female_count, absence_male_count, presence_female_count, presence_male_count], color=["pink", "lightblue", "pink", "lightblue"], alpha=0.5, legend=false, xlabel="Sex and Heart Disease", ylabel="Frequency", title="Sex Distribution by Heart Disease Presence", titlefont=font(12))
end

# ╔═╡ 32ff3964-ac15-48cf-97d8-4c3e2a05acda
begin
	cp_values = [1, 2, 3, 4]
	absencecp_counts = []
	presencecp_counts = []
	for cp in cp_values
   		absence_count = sum(df[df.num .== 1, :cp] .== cp)
    	presence_count = sum(df[df.num .== 2, :cp] .== cp)
   		push!(absencecp_counts, absence_count)
    	push!(presencecp_counts, presence_count)
	end
	cp_labels = ["CP Value $cp" for cp in cp_values]
	bar(cp_labels, absencecp_counts, color=:skyblue, alpha=0.7, label="Absence of Heart Disease", legend=:topleft, xlabel="Chest Pain Type (cp)", ylabel="Frequency", title="Chest Pain Type Distribution by Heart Disease Presence", titlefont=font(12))
	histo9 = bar!(cp_labels, presencecp_counts, color=:lightcoral, alpha=0.7, label="Presence of Heart Disease")
end

# ╔═╡ a20e4ffc-d5a9-43aa-8716-5f4564301239
begin
	absence_FBSF_count = sum(df[df.num .== 1, :fbs] .== 0)
	absence_FBST_count = sum(df[df.num .== 1, :fbs] .== 1)
	presence_FBSF_count = sum(df[df.num .== 2, :fbs] .== 0)
	presence_FBST_count = sum(df[df.num .== 2, :fbs] .== 1)
	histo10 = bar(["Absence 0 (F)", "Absence 1 (T)", "Presence 0 (F)", "Presence 1 (T)"], [absence_FBSF_count, absence_FBST_count, presence_FBSF_count, presence_FBST_count], color=["red", "lightgreen", "red", "lightgreen"], alpha=0.7, legend=false, xlabel="fbs and Heart Disease", ylabel="Frequency", title="Fasting Blood Sugar Distribution by Heart Disease Presence", titlefont=font(12))
end

# ╔═╡ 94f9a33a-223d-4b68-b16b-fc7e5b0d8bdd
begin
	restecg_values = [0, 1, 2]
	absencerecg_counts = []
	presencerecg_counts = []
	for restecg in restecg_values
   		absence_count = sum(df[df.num .== 1, :restecg] .== restecg)
    	presence_count = sum(df[df.num .== 2, :restecg] .== restecg)
   		push!(absencerecg_counts, absence_count)
    	push!(presencerecg_counts, presence_count)
	end
	restecg_labels = ["RestECG Value $restecg" for restecg in restecg_values]
	bar(restecg_labels, absencerecg_counts, color=:lightsalmon, alpha=0.7, label="Absence of Heart Disease", legend=:topleft, xlabel="Resting Electrocardiographic Results (restecg)", ylabel="Frequency", title="Resting Electrocardiographic Results Distribution by Heart Disease Presence", titlefont=font(10))
	histo11 = bar!(restecg_labels, presencerecg_counts, color=:lightgray, alpha=0.7, label="Presence of Heart Disease")
end

# ╔═╡ a76e22e3-7271-4ee9-972a-3444914e2648
begin
	absence_exangN_count = sum(df[df.num .== 1, :exang] .== 0)
	absence_exangY_count = sum(df[df.num .== 1, :exang] .== 1)
	presence_exangN_count = sum(df[df.num .== 2, :exang] .== 0)
	presence_exangY_count = sum(df[df.num .== 2, :exang] .== 1)
	histo12 = bar(["Absence 0 (N)", "Absence 1 (Y)", "Presence 0 (N)", "Presence 1 (Y)"], [absence_exangN_count, absence_exangY_count, presence_exangN_count, presence_exangY_count], color=["aqua", "gold", "aqua", "gold"], alpha=0.7, legend=false, xlabel="exang and Heart Disease", ylabel="Frequency", title="Exercise Induced Angina Distribution by Heart Disease Presence", titlefont=font(10))
end

# ╔═╡ 013c4953-b8e4-4b7e-80ed-c3423d68707f
begin
	slope_values = [1, 2, 3]
	absenceslope_counts = []
	presenceslope_counts = []
	for slope in slope_values
   		absence_count = sum(df[df.num .== 1, :slope] .== slope)
    	presence_count = sum(df[df.num .== 2, :slope] .== slope)
   		push!(absenceslope_counts, absence_count)
    	push!(presenceslope_counts, presence_count)
	end
	slope_labels = ["Slope Value $slope" for slope in slope_values]
	bar(slope_labels, absenceslope_counts, color=:brown, alpha=0.7, label="Absence of Heart Disease", legend=:topright, xlabel="ST Segment (slope)", ylabel="Frequency", title="ST Segment Distribution by Heart Disease Presence", titlefont=font(12))
	histo13 = bar!(slope_labels, presenceslope_counts, color=:lightyellow, alpha=0.7, label="Presence of Heart Disease")
end

# ╔═╡ 7287f2a5-66d9-488e-8f01-db1ba592e6a1
begin
	thal_values = [3, 6, 7]
	absencethal_counts = []
	presencethal_counts = []
	for thal in thal_values
   		absence_count = sum(df[df.num .== 1, :thal] .== thal)
    	presence_count = sum(df[df.num .== 2, :thal] .== thal)
   		push!(absencethal_counts, absence_count)
    	push!(presencethal_counts, presence_count)
	end
	thal_labels = ["Thal Value $thal" for thal in thal_values]
	bar(thal_labels, absencethal_counts, color=:brown, alpha=0.7, label="Absence of Heart Disease", legend=:topright, xlabel="Thalassemia (thal)", ylabel="Frequency", title="Thalassemia Distribution by Heart Disease Presence", titlefont=font(12))
	histo15 = bar!(thal_labels, presencethal_counts, color=:lightgreen, alpha=0.7, label="Presence of Heart Disease")
end

# ╔═╡ 54137706-dc4f-4c4f-abd2-72040283ab49
md"""
### 3.4 Relationship Between Attributes 
"""

# ╔═╡ 1f1822e5-2a7d-4cda-b2cd-68f70ae1f4e1
begin
	thalach_absence = df[df.num .== 1, :thalach]
	thalach_presence = df[df.num .== 2, :thalach]

	trestbps_absence = df[df.num .== 1, :trestbps]
	trestbps_presence = df[df.num .== 2, :trestbps]
	
	scatter(trestbps_absence, thalach_absence, color=:blue, label="Absence of Heart Disease", legend=:topright, xlabel="Resting Blood Pressure (trestbps)", ylabel="Maximum Heart Rate (thalach)")
	scatter!(trestbps_presence, thalach_presence, color=:red, label="Presence of Heart Disease")
	scat1 = title!("Relationship between Resting Blood Pressure & Maximum Heart Rate by Heart Disease Presence", titlefont=font(7))
end

# ╔═╡ 210736c0-5084-4cfc-a67e-7fef7d6e7a9b
md"""
The scatter plot of Resting Blood Pressure (trestbps) versus Maximum Heart Rate (thalach) reveals no clear linear relationship between these two variables. Both individuals with and without heart disease exhibit a wide range of values for both attributes. The data points are scattered, suggesting that factors beyond Resting Blood Pressure and Maximum Heart Rate likely contribute to the presence or absence of heart disease. In summary, the plot does not indicate a strong, straightforward correlation between these attributes and heart disease status.
"""

# ╔═╡ c471268f-8e4a-4886-b1c0-68e8397ff51c
md"""
#### 3.4.1 Relationship Between Age and Numeric Attributes
"""

# ╔═╡ 7524ebed-f0fc-4627-9724-6594bd17d30e
begin
	numeric_attributes1 = [:trestbps, :chol, :thalach, :oldpeak, :ca]
	target_attribute3 = :num
	plot_layout3 = Vector{Plots.Plot}(undef, length(numeric_attributes1))
	numeric_attr_list1 = ["Resting Blood Sugar","Serum Cholestoral","Maximum Heart Rate Achieved","Excercise Induced ST Depression","Number of Major Vessels"]
	common_xlabel3 = "Age"
	for (i, attr) in enumerate(numeric_attributes1)
		p = scatter(df[df.num .== 1, :age], df[df.num .== 1, attr], label="Absence of Heart Disease", legend=:topright, xlabel=common_xlabel3, ylabel=numeric_attr_list1[i], color=:blue)
		p = scatter!(df[df.num .== 2, :age], df[df.num .== 2, attr], label="Presence of Heart Disease", color=:red)
    	plot_layout3[i] = p
	end
	scat2 = plot(plot_layout3..., size=(800, 600))
end

# ╔═╡ a7423992-c436-45e4-9906-d59e162367d2
md"""
#### 3.4.2 Relationship Between Age and Nominal Attributes
"""

# ╔═╡ 9382f068-3f42-4ee4-a4d3-57d728f90096
begin
	nominal_attributes1 = [:sex, :cp, :fbs, :restecg, :exang, :slope, :thal]
	target_attribute4 = :num
	plot_layout4 = Vector{Plots.Plot}(undef, length(nominal_attributes1))
	common_xlabel4 = "Age"
	num_rows = div(length(nominal_attributes1), 2)
	num_cols = 3
	for (i, attr) in enumerate(nominal_attributes1)
		p = scatter(df[df.num .== 1, :age], df[df.num .== 1, attr], label="Absence of Heart Disease", legend=:topleft, xlabel=common_xlabel4, ylabel=nominal_attr_list[i], color=:blue)
		p = scatter!(df[df.num .== 2, :age], df[df.num .== 2, attr], label="Presence of Heart Disease", color=:red)
    	plot_layout4[i] = p
	end
	scat3 = plot(plot_layout4..., size=(900, 900), layout=(num_rows, num_cols))
end

# ╔═╡ 0710577d-5fe1-4154-84b3-e5712c452c66
md"""
#### 3.4.3 Clustering
"""

# ╔═╡ d26ef1a1-f677-4702-9b40-cf13bd6b4923
begin
	numeric_att = [:age, :trestbps]
	mean_values = mean.(eachcol(df[:, numeric_att]))
	std_values = std.(eachcol(df[:, numeric_att]))

	standardized_features = (Matrix(df[:, numeric_att]) .- mean_values') ./ std_values'

	k = 2
	result = kmeans(standardized_features', k)
	clust1 = scatter(df.age, df.trestbps, marker_z=result.assignments, xlabel="Age", ylabel="Resting Blood Pressure", title = "Clustering Attempt: Age VS Resting Blood Pressure", legend=false)
end

# ╔═╡ 38022a05-8337-4fd0-aa96-9f376e5a2fcc
@htl("""
<article class="assignment">
	<h1>
		Appendix - Codes for Dashboard
	</h1>
<p>This indicates the end of the main body, and below codes are prepared for the dashboard:

</article>
<style>

	article.assignment {
		background: #488af94f;
		padding: 1em;
		border-radius: 5px;
	}

	article.assignment p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}

</style>
""")

# ╔═╡ 10721f1a-bab4-49e6-8f64-e177eaa6e665
notebook = PlutoRunner.notebook_id[] |> string

# ╔═╡ ab4fd954-13dd-48a5-a5e0-eaf0ec86200b
begin
	@info PlutoRunner.currently_running_cell_id
	md"""# DS1 Exploratory Data Analysis Dashboard"""
end

# ╔═╡ ef8420fa-68cd-467c-96ee-800ec5547a98
begin
	@info PlutoRunner.currently_running_cell_id
	md"""## 1. Correlation Plots"""
end

# ╔═╡ e1d213bd-def8-4415-9cda-78eefc0670e2
select1 = @bind vis_list1 Select(["Overall Correlation","Numerical Correlation","Nominal Correlation"])

# ╔═╡ b19dfeb0-b2f7-4b55-b93b-a563607f6d30
corplots = Dict(
    "Overall Correlation" => corplot1,
    "Numerical Correlation" => corplot2,
    "Nominal Correlation" => corplot3
)

# ╔═╡ 608e91de-2866-480d-8fc3-f0e8193ca9d6
begin
	@info PlutoRunner.currently_running_cell_id
	PlutoUI.ExperimentalLayout.hbox([select1, corplots[vis_list1]])
end

# ╔═╡ d5ac191d-f2cd-4ff8-9419-9bc800ea3bb4
select2 = @bind vis_list2 Select(["Numeric Attributes Distribution","Nominal Attributes Distribution"])

# ╔═╡ de956107-1a8d-403c-abf5-c33bdb480256
select3 = @bind vis_list3 Radio([
	"Age",
	"Resting Blood Pressure",
	"Serum Cholestoral",
	"Maximum Heart Rate",
	"ST Depression",
	"Number of Major Vessels"
], default = "Age")

# ╔═╡ 3da7ceab-69f0-42d7-a391-8af20d7f20df
vis_list3

# ╔═╡ 459c4bff-04db-40f1-bba8-be97117a57b5
select4 = @bind vis_list4 Radio([
	"Sex",
	"Chest Pain Type",
	"Fasting Blood Sugar",
	"Resting Electrocardiographic Results",
	"Excercise Induced Angina",
	"ST Segment",
	"Thalassemia"
], default = "Sex")

# ╔═╡ 9af312a4-8c63-4c1a-843b-2448277023f0
histos = Dict(
	"Numeric Attributes Distribution" => histo1,
	"Nominal Attributes Distribution" => histo2
)

# ╔═╡ 58e677dc-a7f6-4f7f-8e25-0982c524744c
histos2 = Dict(
	"Age"=> histo3,
	"Resting Blood Pressure"=> histo4,
	"Serum Cholestoral" => histo5,
	"Maximum Heart Rate" => histo6,
	"ST Depression" => histo7,
	"Number of Major Vessels" => histo14
)

# ╔═╡ 9d5080c8-50b4-46b4-96b0-b767263802ad
histos2[vis_list3]

# ╔═╡ 0f94d2f8-7d29-4d24-85e1-5807fd8a5b1d
histos3 = Dict(
	"Sex" => histo8,
	"Chest Pain Type" => histo9,
	"Fasting Blood Sugar" => histo10,
	"Resting Electrocardiographic Results" => histo11,
	"Excercise Induced Angina" => histo12,
	"ST Segment" => histo13,
	"Thalassemia" => histo15
)

# ╔═╡ 65f5640f-5e63-4b8b-99c7-409d14899d8d
begin
	@info PlutoRunner.currently_running_cell_id
	md"""## 2. Distribution Plots"""
end

# ╔═╡ 452fdeee-4d53-4df4-a755-4bb846c9e7fe
begin
	@info PlutoRunner.currently_running_cell_id
	md"""### 2.1 - Overall Attributes Distributions:"""
end

# ╔═╡ 7b23bc9d-4cf8-4d9a-97bf-12d6957a431b
begin
	@info PlutoRunner.currently_running_cell_id
	PlutoUI.ExperimentalLayout.hbox([select2, histos[vis_list2]])
end

# ╔═╡ 490b5b02-e783-433a-93fe-110cf5713641
begin
	@info PlutoRunner.currently_running_cell_id
	md"""### 2.2 - Numeric Attributes Distributions by Heart Disease Prescence:"""
end

# ╔═╡ a55cab8a-95cd-4efe-9d9c-49aa5d7f5078
begin
	@info PlutoRunner.currently_running_cell_id
	PlutoUI.ExperimentalLayout.hbox([select3, histos2[vis_list3]])
end

# ╔═╡ 1142e791-f453-40f9-94d4-93f442f732c9
begin
	@info PlutoRunner.currently_running_cell_id
	md"""### 2.3 - Nominal Attributes Distributions by Heart Disease Prescence:"""
end

# ╔═╡ c93ddab8-04d3-4bbd-906b-6c12127ba318
begin
	@info PlutoRunner.currently_running_cell_id
	PlutoUI.ExperimentalLayout.hbox([select4, histos3[vis_list4]])
end

# ╔═╡ 3d022c9c-2320-4002-bdf7-0e142ef30f18
select5 = @bind vis_list5 Select([
	"Age VS Numeric Attributes",
	"Age VS Nominal Attributes",
	"Resting Blood Pressure VS Maximum Heart Rate",
])

# ╔═╡ ef8a93fd-6b45-449a-9fbb-9931a4f6e136
scats = Dict(
	"Age VS Numeric Attributes" => scat2,
	"Age VS Nominal Attributes" => scat3,
	"Resting Blood Pressure VS Maximum Heart Rate" => scat1
)

# ╔═╡ e6f0df54-1037-4574-88a8-1520872a54b0
begin
	@info PlutoRunner.currently_running_cell_id
	md"""## 3. Scatter Plots"""
end

# ╔═╡ 0463e747-8004-4117-8604-2a4d421b02f8
begin
	@info PlutoRunner.currently_running_cell_id
	PlutoUI.ExperimentalLayout.hbox([select5, scats[vis_list5]])
end

# ╔═╡ 75bf109c-36ba-488d-a3d3-d6ace5610c8d
begin
	@info PlutoRunner.currently_running_cell_id
	md"""## 4. Clustering Plot"""
end

# ╔═╡ c237eb3f-d07c-477e-a03e-50049dde0477
begin
	@info PlutoRunner.currently_running_cell_id
	clust1
end

# ╔═╡ 58dcb655-e897-4201-8bca-7d1629a1dc24
celllist=[
	"ab4fd954-13dd-48a5-a5e0-eaf0ec86200b",
	"ef8420fa-68cd-467c-96ee-800ec5547a98",
	"608e91de-2866-480d-8fc3-f0e8193ca9d6",
	"65f5640f-5e63-4b8b-99c7-409d14899d8d",
	"452fdeee-4d53-4df4-a755-4bb846c9e7fe",
	"7b23bc9d-4cf8-4d9a-97bf-12d6957a431b",
	"490b5b02-e783-433a-93fe-110cf5713641", 
	"a55cab8a-95cd-4efe-9d9c-49aa5d7f5078", 
	"1142e791-f453-40f9-94d4-93f442f732c9", 
	"c93ddab8-04d3-4bbd-906b-6c12127ba318",
	"e6f0df54-1037-4574-88a8-1520872a54b0",
	"0463e747-8004-4117-8604-2a4d421b02f8",
	"75bf109c-36ba-488d-a3d3-d6ace5610c8d",
	"c237eb3f-d07c-477e-a03e-50049dde0477"
]

# ╔═╡ 236c7af9-d766-497c-a5e9-2cd7064ddae5
dashboard_url="http://localhost:1234/edit?" * "id=$notebook&" * join(["isolated_cell_id=$cell" for cell in celllist], "&")

# ╔═╡ 640e0c92-e9b2-41a1-a6a9-d950d9e1bd51
@htl("""
<a href="$dashboard_url" style="font_size=20">Please click here for the dashboard :)</a>
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Clustering = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.10.11"
CategoricalArrays = "~0.10.8"
Clustering = "~0.15.4"
DataFrames = "~1.6.1"
HypertextLiteral = "~0.9.4"
Plots = "~1.39.0"
PlutoUI = "~0.7.52"
StatsBase = "~0.34.2"
StatsPlots = "~0.15.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "664de527ee07a6295807d59b0c4d25c329ed376d"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "9b9b347613394885fd1c8c7729bfc60528faa436"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.4"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e30f2f4e20f7f186dc36529910beaedc60cfa644"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.16.0"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "b86ac2c5543660d238957dbde5ac04520ae977a7"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "b6def76ffad15143924a2199f72a5cd883a2e8a9"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.9"
weakdeps = ["SparseArrays"]

    [deps.Distances.extensions]
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "3d5873f811f582873bb9871fc9c451784d5dc8c7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.102"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "b4fbdd20c889804969571cc589900803edda16b7"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.7.1"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "a20eaa3ad64254c61eeb5f230d9306e937405434"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.6.1"
weakdeps = ["SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ad37c091f7d7daf900963171600d7c1c5c3ede32"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2023.2.0+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "90442c50e202a5cdf21a7899c66b240fdef14035"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.7"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "0d097476b6c381ab7906460ef1ef1638fbce1d91"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.2"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "eb006abbd7041c28e0d16260e50a24f8f9104913"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2023.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "68bf5103e002c44adfd71fea6bd770b3f0586843"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.2"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "2c3726ceb3388917602169bed973dbc97f1b51a8"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.13"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "bf6085e8bd7735e68c210c6e5d81f9a6fe192060"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.19"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "7c29f0e8c575428bd84dc3c72ece5178caa67336"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.2+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9ebcd48c498668c7fa0e97a9cae873fbee7bfee1"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "0adf069a2a490c47273727e029371b31d44b72b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.5"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "NaNMath", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "9115a29e6c2cf66cf213ccc17ffd61e27e743b24"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.15.6"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "a72d22c7e13fe2de562feda8645aa134712a87ee"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.17.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "24b81b59bd35b3c42ab84fa589086e19be919916"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.11.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cf2c7de82431ca6f39250d2fc4aacd0daa1675c0"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─b6ee7085-8cf6-45ea-80eb-2f25f6bc4cde
# ╠═a68477f0-5ecd-11ee-0a60-2b682976688c
# ╟─44a4036b-5ee4-47fa-b152-3e84b6e1f284
# ╟─640e0c92-e9b2-41a1-a6a9-d950d9e1bd51
# ╟─3d67e161-0b5d-4004-8686-fb6bf2242bd9
# ╠═0c717346-8f5a-4492-b37b-89697a975e87
# ╠═f191fda3-3a10-4f5f-830c-c0470d819580
# ╠═52d48d83-d719-474b-a308-d0a1e29149ed
# ╠═f2b78422-22b6-410b-8c4a-f4bb845cb31e
# ╠═1d3eaab0-d2d8-4376-8e32-c7f840a475d1
# ╟─8b7b2b61-072c-4e88-871b-70c13c3382a2
# ╟─25c76568-f514-4aec-8e71-cbc73c7b4442
# ╠═7b4c7531-b462-4bd2-bbc4-c30a6ecef573
# ╠═f1f6faa9-b23c-4a53-8804-c1d282117aa7
# ╟─ccdd3f38-2826-4fd5-adc3-df4bf0841269
# ╠═71a5fdfc-365b-4172-ad8e-e40d8b67f259
# ╠═2559a0f6-520c-47ac-8549-0d7947a53c21
# ╠═5aa9a489-9013-47a6-b088-bd9de6b77737
# ╠═e4a7cb22-b6a4-48a3-9367-6e1306f30061
# ╠═d330aa8b-799f-4fbe-b9fc-eb910f2a8b4a
# ╠═e7552e6c-6b51-43e8-bbe6-4e82f9cdd3cf
# ╠═83fdaa74-3bf9-4d95-bda4-fa75d494bbb3
# ╠═d7b9f4eb-414a-46ca-9751-bf4a55ab4ddd
# ╠═5f144b91-c205-4ccf-86f5-e4b13742fe65
# ╠═aac25c2b-7c36-41f1-9bf9-4f70ff18287d
# ╟─f6356900-2471-4bd3-9742-fe3ba3139a98
# ╠═d61d7924-aeae-4bb7-9f77-5e0c38177fd7
# ╠═b75b2b23-8877-416f-b67f-c2edec4ee2ca
# ╠═7243a28b-bfba-4571-b191-75f125c87db1
# ╠═65cb052c-79a1-470c-b84f-80fb6845d121
# ╠═cc6ca30e-dcab-499f-bb76-4075b8a87e0f
# ╠═32ff3964-ac15-48cf-97d8-4c3e2a05acda
# ╠═a20e4ffc-d5a9-43aa-8716-5f4564301239
# ╠═94f9a33a-223d-4b68-b16b-fc7e5b0d8bdd
# ╠═a76e22e3-7271-4ee9-972a-3444914e2648
# ╠═013c4953-b8e4-4b7e-80ed-c3423d68707f
# ╠═7287f2a5-66d9-488e-8f01-db1ba592e6a1
# ╟─54137706-dc4f-4c4f-abd2-72040283ab49
# ╠═1f1822e5-2a7d-4cda-b2cd-68f70ae1f4e1
# ╟─210736c0-5084-4cfc-a67e-7fef7d6e7a9b
# ╟─c471268f-8e4a-4886-b1c0-68e8397ff51c
# ╠═7524ebed-f0fc-4627-9724-6594bd17d30e
# ╟─a7423992-c436-45e4-9906-d59e162367d2
# ╠═9382f068-3f42-4ee4-a4d3-57d728f90096
# ╟─0710577d-5fe1-4154-84b3-e5712c452c66
# ╠═d26ef1a1-f677-4702-9b40-cf13bd6b4923
# ╟─38022a05-8337-4fd0-aa96-9f376e5a2fcc
# ╠═10721f1a-bab4-49e6-8f64-e177eaa6e665
# ╠═ab4fd954-13dd-48a5-a5e0-eaf0ec86200b
# ╠═ef8420fa-68cd-467c-96ee-800ec5547a98
# ╠═e1d213bd-def8-4415-9cda-78eefc0670e2
# ╠═b19dfeb0-b2f7-4b55-b93b-a563607f6d30
# ╠═608e91de-2866-480d-8fc3-f0e8193ca9d6
# ╠═d5ac191d-f2cd-4ff8-9419-9bc800ea3bb4
# ╠═de956107-1a8d-403c-abf5-c33bdb480256
# ╠═3da7ceab-69f0-42d7-a391-8af20d7f20df
# ╠═9d5080c8-50b4-46b4-96b0-b767263802ad
# ╠═459c4bff-04db-40f1-bba8-be97117a57b5
# ╠═9af312a4-8c63-4c1a-843b-2448277023f0
# ╠═58e677dc-a7f6-4f7f-8e25-0982c524744c
# ╠═0f94d2f8-7d29-4d24-85e1-5807fd8a5b1d
# ╠═65f5640f-5e63-4b8b-99c7-409d14899d8d
# ╠═452fdeee-4d53-4df4-a755-4bb846c9e7fe
# ╠═7b23bc9d-4cf8-4d9a-97bf-12d6957a431b
# ╠═490b5b02-e783-433a-93fe-110cf5713641
# ╠═a55cab8a-95cd-4efe-9d9c-49aa5d7f5078
# ╠═1142e791-f453-40f9-94d4-93f442f732c9
# ╠═c93ddab8-04d3-4bbd-906b-6c12127ba318
# ╠═3d022c9c-2320-4002-bdf7-0e142ef30f18
# ╠═ef8a93fd-6b45-449a-9fbb-9931a4f6e136
# ╠═e6f0df54-1037-4574-88a8-1520872a54b0
# ╠═0463e747-8004-4117-8604-2a4d421b02f8
# ╠═75bf109c-36ba-488d-a3d3-d6ace5610c8d
# ╠═c237eb3f-d07c-477e-a03e-50049dde0477
# ╠═58dcb655-e897-4201-8bca-7d1629a1dc24
# ╠═236c7af9-d766-497c-a5e9-2cd7064ddae5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
