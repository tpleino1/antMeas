function str = getFormattedFileName(path, file, count, debug)
% str = getFormattedFileName(path, file, count, debug)
% 	returns a string containing middle-cut URI (i.e., strcat(path, file))
% 	depending on the optional parameter count, showing at least the actual
% 	filename, its parent folder and the drive / mount location. Set debug
% 	to true if exceptions are to be rethrown.

	try
		% Default params
		if (nargin < 3)
			count = 50;
			debug = false;
		elseif (nargin < 4)
			debug = false;
		end

		% Strip URI if needed
		if (length([path, file]) < count)
			str = [path, file];
		elseif ~isempty(find(path == '\', 1, 'first'))	% Windows-style
			i = find(path == '\', 1, 'first');
			j = find(path(i+1 : end-1) == '\', 1, 'last') + i;
			str = [path(1 : i), '...', path(j : end), file];
		else % Linux/Mac-style
			i = find(path(3 : end-1) == '/', 1, 'first') + 2;
			j = find(path(i+1 : end-1) == '/', 1, 'last') + i;
			str = [path(1 : i), '...', path(j : end), file];
		end
		
	catch err
		str = '';
		if debug
			rethrow(err);
		end
	end
		
end