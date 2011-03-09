function results = evaluate(f, n_iters, varargin)
    n_args = length(varargin);
    arg_counts = cellfun(@length, varargin);
    n_combinations = prod(arg_counts);

    results = struct('args', cell(n_combinations, 1), 'mean', 0, 'std', 0);

    p = progressbar();

    for arg_ind = 1:n_combinations
        [arg_sub{1:n_args}] = ind2sub(arg_counts, arg_ind);

        args = num2cell(arrayfun(@(i) varargin{i}(arg_sub{i}), 1:n_args));

        objs = zeros(n_iters, 1);
        for i = 1:n_iters
            stream = RandStream('mt19937ar', 'Seed', i);
            RandStream.setDefaultStream(stream);
            ark = f(args{:});
            objs(i) = ark.objs(1);
        end

        results(arg_ind).args = args;
        results(arg_ind).mean = mean(objs);
        results(arg_ind).std = std(objs);

        save('results.mat');

        p = setStatus(p, arg_ind/n_combinations);
        display(p);
    end
