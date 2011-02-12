function ark = archive_new(size, type)
% archive_new(size, type)
% Create a new archive struct of the given size and type.
    ark.size = size;
    ark.type = type;
    ark.objs = [];
    ark.args = [];