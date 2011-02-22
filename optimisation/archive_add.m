function ark = archive_add(ark, args, objs)
% archive_add(ark, args, objs)
% Add data to an archive or cell array of archives.
% - objs is a column vector of objective function values
%   (this function assumes we are maximising)
% - each row of args should be the the parameters achieving the
%   corresponding value in objs

    if (length(ark) ~= 1)
        for i = 1:length(ark)
            ark{i} = archive_add(ark{i}, args, objs);
        end
        return;
    end
    
    if (size(objs, 2) ~= 1)
        error('objs should be a column vector');
    end
    if (size(objs, 1) ~= size(args, 1))
        error('objs should have the same number of rows as args');
    end
    if (~isempty(ark.args) && size(args, 2) ~= size(ark.args, 2))
        error('differing numbers of arguments in archive and data');
    end

    if strcmp(ark.type, 'best')
        unsorted_args = [ark.args; args];
        [sorted_objs, ix] = sort([ark.objs; objs], 'descend');
        
        new_size = min(ark.size, size(unsorted_args, 1));
        
        ark.objs = sorted_objs(1:new_size);
        ark.args = unsorted_args(ix(1:new_size), :);
    elseif strcmp(ark.type, 'complete')
        ark.objs = [ark.objs; objs];
        ark.args = [ark.args; args];
    elseif strcmp(ark.type, 'dissimilarity')
        
        for i = 1:length(objs)
            % Dissimilarity archiving as given in lecture notes.
            if (length(ark.objs) < ark.size)
                % archive not full: archive if dissimilar to entries so far
                if (all(row_dist(ark.args, args(i,:)) > ark.dmin))
                    ark.args = [ark.args; args(i,:)];
                    ark.objs = [ark.objs; objs(i)];
                end
            elseif (all(row_dist(ark.args, args(i,:)) > ark.dmin))
                % archive full, new entry dissimilar to all prev. entries
                % archive if better than worst
                [obj_worst, i_worst] = min(ark.objs);
                if (objs(i) > obj_worst)
                    ark.args(i_worst,:) = args(i,:);
                    ark.objs(i_worst) = objs(i);
                end
            elseif (all(ark.objs < objs(i)))
                % best so far: archive, replacing closest
                [~, i_closest] = min(row_dist(ark.args, args(i,:)));
                ark.args(i_closest,:) = args(i,:);
                ark.objs(i_closest) = objs(i);
            else
                % see if v. similar to a solution, and better than it
                similar = row_dist(ark.args, args(i,:)) < ark.dsim;
                can_replace = similar & (ark.objs < objs(i));
                if any(can_replace)
                    i_replace = find(can_replace, 1);
                    ark.args(i_replace,:) = args(i,:);
                    ark.objs(i_replace) = objs(i);  
                end
            end
        end
        
    else
        error(['Unknown archive type: ' ark.type]);
    end
end

function ans = row_dist(a, b)
    if ~isempty(a)
        ans = sqrt(sum(bsxfun(@minus, a, b) .^ 2, 2));
    else
        ans = [];
    end
    
end

    