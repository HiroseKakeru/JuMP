# 非線形計画で動画の総再生時間が１時間になり
# 標準偏差が最小になる計算を行う

using CSV, DataFrames, JuMP, Juniper, Statistics, Ipopt

#durations = [15,30,60,120,30]
durations = rand(15:120, 5)

# 目標再生時間
target_time = 60 * 60 # 1 hour in seconds

# モデルを作成
ipopt = optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0)
optimizer = optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt)
m = Model(optimizer)

# 再生回数を変数として定義
@variable(m, x[1:length(durations)] >= 0, Int)

# 目的関数:
@objective(m, Min, std(x))

### 制約条件:
@constraint(m, sum(x .* durations) == target_time)

# 最適化
optimize!(m)

# 結果を出力
play_counts = value.(x)
for i in 1:length(play_counts)
    println("動画: $(i)[$(durations[i])], 再生回数: $(round.(play_counts[i]))")
end
println("total: $(sum(round.(play_counts) .* durations)), std(x): $(std(play_counts))")
