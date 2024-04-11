# 動画の総再生時間が１時間に近づき且つ標準偏差が最小になるように計算を行う

using CSV, DataFrames, JuMP, Juniper, Statistics, Ipopt, MultiJuMP

content_len = 10
durations = rand(10:120, content_len)

target_time = 3600
# モデルを作成
ipopt = optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0)
optimizer = optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt)
m = multi_model(optimizer, linear = false)

x = @variable(m, x[1:length(durations)] >= 0, Int)
@constraint(m, (target_time - minimum(durations)) <= sum(x .* durations) <= target_time)
std_exp = @expression(m, std(x))
time_exp = @expression(m, sum(x .* durations))
std_obj = SingleObjective(std_exp, sense = MOI.MIN_SENSE)
time_obj = SingleObjective(time_exp, sense = MOI.MAX_SENSE)
md = get_multidata(m)
md.objectives = [time_obj, std_obj]
optimize!(m)

play_counts = value.(x)
println(typeof(x))
println(x)
println(value(x[1]))
for i in 1:length(play_counts)
    println("動画: $(i)[$(durations[i])], 再生回数: $(round.(play_counts[i]))")
end
println("total: $(sum(round.(play_counts) .* durations)), std(x): $(std(play_counts))")

