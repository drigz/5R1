function [ark, diag] = sa(f, penalty, ark, ...
        step_method, init_step_size, ...
        penalty_weight, ...
        initial_temp, ...
        temp_length, ...
        temp_decay)
% sa(f, penalty, ark,
%       step_method, init_step_size,
%       penalty_weight,
%       initial_temp,
%       temp_length,
%       temp_decay)
% Performs a Simulated Annealing maximisation of the 2-D function f.
%
% f([x y]): the function to be minimised
% penalty([x y]): a function == 0 in allowable space, and < 0 in disallowed
%                space
% ark: a list of empty archives
% step_method: 'uniform' or 'parks' giving step size update method
% init_step_size: initial step size
% penalty_weight: constant factor on penalty function
% initial_temp: 'kirkpatrick', 'white' or a number giving initial temp
% temp_length: max number of steps before decreasing temp
% temp_decay: 'huang' or constant factor, controlling how temp decreases
%
% returns ark: a list of full archives
%         diag: information about progress of algorithm

    if any(strcmp(initial_temp, {'kirkpatrick', 'white'}))
        T = inf;
    else
        T = initial_temp;
    end

    step_size = init_step_size;
    position = [5 5];
    objective = f(position);

    samples_remaining = 5000-1;

    % used to determine when & how to reduce temperature
    objective_changes = [];
    num_trials = 0;
    num_acceptances = 0;
    initial_trials = 500;
    max_trials = temp_length;
    max_acceptances = 0.6*temp_length;

    % parameters controlling step size adaptation
    alpha = 0.1;
    omega = 2.1;

    % used to detect when to restart
    best_obj = objective;
    best_pos = position;
    best_time = samples_remaining;

    % tracking the behaviour of the algorithm
    ctemp = 1;
    diag.temps = [T];
    diag.trials = {[position objective]};
    diag.accepts = {[position objective]};
    diag.rejects = {[]};

    while samples_remaining > 0
        % consider restarting if we've been too long since seeing
        % the best observation
        if (best_time - samples_remaining) > 500
            best_time = samples_remaining;
            position = best_pos;
            objective = best_obj;
        end

        step = step_size .* (2*rand(1,2)-1);

        new_penalty = penalty_weight * penalty(position+step);

        % ignore all invalid solutions in the initial survey
        if T == inf && new_penalty ~= 0
            continue;
        end

        new_objective = f(position+step) + new_penalty / T;
        samples_remaining = samples_remaining - 1;

        diag.trials{ctemp} = [diag.trials{ctemp}; position+step new_objective];

        num_trials = num_trials + 1;

        % only archive valid solutions
        if new_penalty == 0
            ark = archive_add(ark, position+step, new_objective);
        end

        % update reset counters
        if objective > best_obj
            best_obj = objective;
            best_pos = position;
            best_time = samples_remaining;
        end

        % calculate acceptance probability
        if strcmp(step_method, 'parks')
            p = exp(- (objective - new_objective) / (T * norm(step)));
        else
            p = exp(- (objective - new_objective) / T);
        end

        % accept change with probability 1-p
        if rand() < p
            diag.accepts{ctemp} = [diag.accepts{ctemp}; position+step new_objective];

            num_acceptances = num_acceptances + 1;
            objective_changes = [objective_changes new_objective-objective];

            position = position + step;
            objective = new_objective;

            % update step size info (if out of initial survey)
            if T ~= inf && strcmp(step_method, 'parks')
                step_size = (1 - alpha) * step_size + ...
                       alpha * omega * abs(step);
            end
        else
            diag.rejects{ctemp} = [diag.rejects{ctemp}; position+step new_objective];
        end

        % consider reducing temperature
        reduced_T = false;
        if T == inf
            if num_trials >= initial_trials
                % set initial temperature
                if strcmp(initial_temp, 'kirkpatrick')
                    df_plus = mean(objective_changes(objective_changes > 0));
                    T = - df_plus / log(0.8);
                elseif strcmp(initial_temp, 'white')
                    T = std(objective_changes);
                else
                    error('unknown temp_method');
                end
                reduced_T = true;
            end
        elseif num_trials >= max_trials || num_acceptances >= max_acceptances
            if strcmp(temp_decay, 'huang')
                factor = exp(-0.7 * T / std(diag.accepts{ctemp}(:,3)));
                factor = max(0.5, factor);
                T = T * factor;
            else
                T = T * temp_decay;
            end
            reduced_T = true;
        end

        if reduced_T
            % reset counters
            objective_changes = [];
            num_trials = 0;
            num_acceptances = 0;

            ctemp = ctemp+1;
            diag.temps(ctemp) = T;
            diag.trials{ctemp} = [position objective];
            diag.accepts{ctemp} = [position objective];
            diag.rejects{ctemp} = [];
        end
    end
end

