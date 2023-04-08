using ProgressBars
using Plots
using Logging

N_SIMULATIONS = 100000
MAX_TRIALS = 10000
RANK_THRESHOLD = [0.30, 0.10, 0.05, 0.02] # C, B, A, S のドロップ率
RANK_SYMBOL = ['D', 'C', 'B', 'A', 'S']
MAX_RANK = 5
NUM_UPGRADE = [2, 3, 3, 4] # C, B, A, S への upgrade に必要な数


function drop()::Int

    trial = rand()
    criterion = 0.0

    for rank in length(RANK_THRESHOLD):-1:1
        criterion += RANK_THRESHOLD[rank]

        if trial <= criterion
            return rank + 1
        end
    end

    return 1
end

function test_drop(n_trials::Int)
    dropped = [0, 0, 0, 0, 0]
    for i in ProgressBar(1:n_trials)
        dropped[drop()] += 1
    end
    println(dropped / n_trials)
end


function upgrade!(hearts::Vector{Int})
    for rank in 1:length(NUM_UPGRADE)
        while true
            if hearts[rank] >= NUM_UPGRADE[rank]
                hearts[rank + 1] += 1
                hearts[rank] -= NUM_UPGRADE[rank]

                @info "- Upgrade: $(RANK_SYMBOL[rank]) -> $(RANK_SYMBOL[rank + 1])"
            else
                break
            end
        end
    end
end


function simulate!(hearts::Vector{Int})::Int
    
    for i in 1:MAX_TRIALS
        rank = drop()

        @info "Get: $(RANK_SYMBOL[rank])"

        hearts[rank] += 1
        upgrade!(hearts)

        if hearts[MAX_RANK] >= 1
            return i
        end
    end
end

function simulate_multiple_times!(n_trials::Int, hearts::Vector{Int})::Vector{Int}

    counts = zeros(MAX_TRIALS)
    max_count = 0
    # for i in ProgressBar(1:n_trials)
    for i in 1:n_trials

        count = simulate!(copy(hearts))
        counts[count] += 1
        if count > max_count
            max_count = count
        end
    end
    
    return counts[1:max_count]
end

function compute_probabilities(counts::Vector{Int})::Vector{Int}

    accum = Iterators.accumulate(+, counts)
    return collect(accum)

end

function run(mode::Int, hearts::Vector{Int} = [0, 0, 0, 0, 0])

    if mode == 0

        Logging.disable_logging(Logging.Debug)
        println("Trials:", simulate!(hearts))

    else

        Logging.disable_logging(Logging.Info)

        counts = simulate_multiple_times!(N_SIMULATIONS, hearts)
        p1 = plot(counts / N_SIMULATIONS, seriestype=:bar,
            xlabel="# of trials until `S`",
            ylabel="probability")

        probs = compute_probabilities(counts)
        p2 = plot(probs / N_SIMULATIONS, seriestype=:bar,
            xlabel="# of trials until `S`",
            ylabel="cumulative probability")
        plot(p1, p2)
        gui()

    end
end