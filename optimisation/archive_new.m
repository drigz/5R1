function ark = archive_new(type, size, varargin)
% archive_new(type, size)
% Create a new archive struct of the given size and type.
    ark.type = type;
    ark.size = size;
    ark.objs = [];
    ark.args = [];
    
    if strcmp(type, 'dissimilarity')
        ark.dmin = varargin{1};
        ark.dsim = varargin{2};
    end