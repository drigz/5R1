function ark = sa(f, penalty, ark)
% sa(f, penalty, ark) performs a Simulated Annealing
% maximisation of the 2-D function f.
% f([x y]): the function to be minimised
% penalty([x y]): a function == 0 in allowable space, and < 0 in disallowed
%                space
% ark: a list of empty archives
%
% returns ark: a list of full archives

    T = inf;
    step_size = [1 1];
    position = [5 5];
    objective = f(position);
    
    % used to determine when & how to reduce temperature
    objective_changes = [];
    num_trials = 0;
    num_acceptances = 0;
    initial_trials = 500;
    max_trials = 100;
    max_acceptances = 60;
    temp_decay = 0.95;
    
    % parameters controlling step size adaptation
    alpha = 0.1;
    omega = 2.1;
    
    samples_remaining = 5000-1;
    
    while samples_remaining > 0
        step = step_size .* (2*rand(1,2)-1);
        
        % ignore all invalid solutions
        %if penalty(position+step) ~= 0
        %    continue;
        %end
        
        new_objective = f(position+step) + penalty(position+step);
        samples_remaining = samples_remaining - 1;
        
        num_trials = num_trials + 1;
        
        % only archive valid solutions
        if penalty(position+step) == 0
            ark = archive_add(ark, position+step, new_objective);
        end
        
        % calculate acceptance probability
        p = exp(- (objective - new_objective) / (T * norm(step)));
        
        % accept change with probability 1-p
        if rand() < p
            num_acceptances = num_acceptances + 1;
            objective_changes = [objective_changes new_objective-objective];
            
            position = position + step;
            objective = new_objective;

            % update step size info (if out of initial survey)
            if T ~= inf
                step_size = (1 - alpha) * step_size + ...
                       alpha * omega * abs(step);
            end
        end
        
        % consider reducing temperature
        reduced_T = false;
        if T == inf
            if num_trials >= initial_trials
                % set initial temperature
                T = std(objective_changes)
                reduced_T = true;
            end
        elseif num_trials >= max_trials || num_acceptances >= max_acceptances
            T = T * temp_decay;
            reduced_t = true;
        end
        
        if reduced_T
            % reset counters
            objective_changes = [];
            num_trials = 0;
            num_acceptances = 0;
        end
    end
end
            