function ark = archive_add(ark, args, objs)
% archive_add(ark, args, objs)
% Add data to an archive or list of archives.
% - objs is a column vector of objective function values
%   (this function assumes we are maximising)
% - each row of args should be the the parameters achieving the
%   corresponding value in objs

    if (length(ark) ~= 1)
        for i = 1:length(ark)
            ark(i) = archive_add(ark(i), data);
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

    if (ark.type == 'best')
        unsorted_args = [ark.args; args];
        [sorted_objs, ix] = sort([ark.objs; objs], 'descend');
        
        ark.objs = sorted_objs(1:ark.size);
        ark.args = unsorted_args(ix(1:ark.size), :);
    else
        error(['Unknown archive type: ' ark.type]);
    end
    