function [f, p, s, d] = readAntPatt(fname, debug)
	% [f, p, s, d] = readAntPatt(fname, debug)
	% reads antenna pattern given in DataPro ASCII -format  
	% (using dBs and Degs) in the specified file(s). Returns:
	%	f	frequency vector [Hz]
	%	p	primary (or phi) angle [deg]
	%	s	secondary (or theta) angle [deg]
	%	d	3d-matrix with complex cells (containing both magnitude and
	%		phase information of the _field_ strength in linear format) 
	%		using following idexing: (p, s, f)
	%
	% Should an error arise, the function returns empty matrices and
	% rethrows the exception if the optional debug parameter is set to
	% true.
	
	if nargin < 2
		debug = false;
	end
	
	try

		N = 0;
		while (exist([fname(1 : end-3), num2str(N+1, '%03d')], 'file') == 2)
			N = N + 1;
		end

		fid = fopen(fname);

		if fid == -1	% Cannot be read
			f = []; p = []; s = []; d = [];
			return;
		end

		line = 0;
		while line ~= -1
			line = fgetl(fid);
			if ~isempty(strfind(line, 'Prim/Scndry'))
				break;
			end
		end

		if ~ischar(line)	% Wrong type
			fclose(fid);
			f = []; p = []; s = []; d = [];
			return;
		end

		% Frequencies
		Nf = N/2;
		f = zeros(Nf, 1);

		% Sec/Theta angle
		delim = '; ';
		idx = strfind(line, delim);
		line = line(idx(1)+1 : idx(end)-1);
		idx = idx(2 : end-1) - idx(1);
		Ns = length(idx) + 1;
		
		% Could also be done with regexp.split
		idx1 = [1, (idx + length(delim))];
		idx2 = [(idx - 1), length(line)];
		s = zeros(Ns, 1);

		for j = 1 : Ns
			s(j, 1) = str2double(line(idx1(j) : idx2(j)));
		end

		% Prim/Phi angle
		format = repmat(' %f;', 1, Ns + 1);
		data = textscan(fid, format);
		p = data{1};
		Np = length(p);

		data = [data{2:Ns+1}];
		data = data(:, isfinite(data(1,:)));
		Ns = size(data, 2);
		s = s(1:Ns);

		fclose(fid);
		
		% Now that all the vectors (prim, sec, freq) are determined, 
		% we can read the actual data matrix
		d = zeros(Np, Ns, Nf);
		coeffs = struct('h', 1, 'k', 1e3, 'm', ...
			1e6, 'g', 1e9, 't', 1e12);

		% Read two files (mag & pha) for each freq
		for i = 1 : Nf
			mag_fn = [fname(1 : end-3), num2str(i, '%03d')];
			pha_fn = [fname(1 : end-3), num2str(i+Nf, '%03d')];
			mag_f = -1;
			pha_f = -1;

			% Mag files
			mag_fid = fopen(mag_fn);
			mag_line = 0;
			while mag_line ~= -1
				mag_line = fgetl(mag_fid);
				if ~isempty(strfind(mag_line, 'Freq:'))
					mag_f = sscanf(mag_line, 'Freq: %f %c');
					mag_f = mag_f(1) * coeffs.(lower(char(mag_f(2))));
					break;
				end
			end

			% Phase files
			pha_fid = fopen(pha_fn);
			pha_line = 0;
			while pha_line ~= -1
				pha_line = fgetl(pha_fid);
				if ~isempty(strfind(pha_line, 'Freq:'))
					pha_f = sscanf(pha_line, 'Freq: %f %c');
					pha_f = pha_f(1) * coeffs.(lower(char(pha_f(2))));
					break;
				end
			end

			% For added robustness
			if (mag_f < 0 || pha_f < 0)
				fclose(mag_fid);
				fclose(pha_fid);
				f = []; p = []; s = []; d = [];
				return;
			end

			f(i, 1) = mag_f;

			% Read & align data
			mag_data = textscan(mag_fid, format, Np, 'headerlines', 1);
			pha_data = textscan(pha_fid, format, Np, 'headerlines', 1);

			mag_data = [mag_data{2:Ns+1}];
			pha_data = [pha_data{2:Ns+1}];

			% Not same measurement
			if ~isequal(size(mag_data), size(pha_data))
				fclose(mag_fid);
				fclose(pha_fid);
				f = []; p = []; s = []; d = [];
				return;
			end

			% Combine
			d(:, :, i) = 10.^(mag_data/20) .* exp(1i * pha_data/180 * pi);

			fclose(mag_fid);
			fclose(pha_fid);
		end
		
	catch err
		fclose('all');
		f = []; p = []; s = []; d = [];
		if debug
			rethrow(err);
		end
	end
	
end