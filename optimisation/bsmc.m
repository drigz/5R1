function ark = bsmc(f, x_range, y_range, penalty, ...
        m, initial_samples, pressure, ark)
% bsmc(f, x_range, y_range, penalty, ...
%       m, initial_samples, pressure, ark) performs a Biased
% Selection Monte Carlo maximisation of the 2-D function f.
% f(x, y): the function to be minimised
% x_range, y_range: 2-entry vectors indicating a bounding-box of the
%                   search space
% penalty(x, y): a function == 0 in allowable space, and < 0 in disallowed
%                space
% m: the number of intervals to divide each axis into (=> m^2 regions)
% initial_samples: the number of samples per region before biasing
%       (if m^2*initial_samples > 5000, the algorithm fails)
% pressure: a number >= 1 controlling how heavily we bias the selection
% ark: a list of empty archives
%
% returns ark: a list of full archives

    region_sum = zeros(m, m);
    region_n = zeros(m, m);
    region_p = [];
    M = m^2; % number of regions
    
    samples_remaining = 5000; % Enforces maximum number of samples

    % check for invalid parameters
    if M * initial_samples > samples_remaining
        ark = archive_add(ark, [0 0], 0);
        return
    end

    while samples_remaining > 0
        if isempty(region_p)
            % A constant number of initial samples in each square are
            % used to get initial estimate of region probabilities.
            [r,c] = meshgrid(1:m);
            r = reshape(r, [], 1);
            c = reshape(c, [], 1);
            r = repmat(r, initial_samples, 1);
            c = repmat(c, initial_samples, 1);
            samples_remaining = samples_remaining - initial_samples*M;
        else
            % Choose the number of samples to take before re-evaluating
            % region probabilities.
            samples = min(1000, samples_remaining);
            [r,c] = random_square(region_p, samples);
            samples_remaining = samples_remaining - samples;
        end
        
        % Sample within each chosen region.
        [x,y] = sample_in(x_range, y_range, m, r, c);

        % Calculate the objective function value at chosen sample points.
        assert(samples_remaining >= 0);
        val = f(x, y);
        pen = penalty(x, y);
        
        % Update region records.
        d_region_sum = accumarray({r, c}, val + pen);
        d_region_n = accumarray({r, c}, 1);
        % Make sure they're the same size as region_sum
        if any(size(d_region_sum) ~= size(region_sum))
            % Assign to lower-right corner to extend to full size
            d_region_sum(m, m) = 0;
            d_region_n(m, m) = 0;
        end
        region_sum = region_sum + d_region_sum;
        region_n = region_n + d_region_n;
        
        % Rank regions on average objective
        region_avg = region_sum ./ region_n;
        [~, ix] = sort(reshape(region_avg, [], 1), 'descend');
        rank = zeros(size(region_n));
        rank(ix) = 1:length(ix);

        % Calculate new probabilities from ranks
        region_p = pressure*(M+1-2*rank) + 2*(rank-1);
        region_p(region_p < 0) = 0;
        region_p = region_p / sum(sum(region_p));
        
        % Only archive valid solutions
        ark = archive_add(ark, [x(pen == 0) y(pen == 0)], val(pen == 0));
    end
end
    
function [rs,cs] = random_square(region_p, n)
% Returns a row,col indices of an entry in p, randomly chosen with
% probability equal to the contents of the cell (probabilities should
% sum to 1).
    cums = cumsum(reshape(region_p, [], 1));
    cums = cums/cums(end); % just in case they don't sum to 1

    [~, loc] = histc(rand(1,n),[0;cums]);

    k = size(region_p, 1);
    rs = rem(loc'-1, k)+1;
    cs = (loc'-rs)/k + 1;
end

function [x,y] = sample_in(x_range, y_range, m, r, c)
% Returns vectors of points chosen uniformly from within the square region
% r,c, itself a subset of the region x_range*y_range, each axis divided
% up m times.
    x_min = x_range(1);
    x_wid = x_range(2)-x_range(1);
    y_min = y_range(1);
    y_wid = y_range(2)-y_range(1);

    x = x_min + x_wid * (c-1 + rand(size(c)))/m;
    y = y_min + y_wid * (r-1 + rand(size(r)))/m;
end
    
