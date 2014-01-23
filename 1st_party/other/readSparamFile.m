function [f, s, z] = readSparamFile(fname, debug)
% [f, s, z] = readSparamFile(fname, debug) 
% reads the data on an s#p file
%
% Inputs:
%	fname		Full filename of the file to be read
%	debug		Optional parameter to enable exception rethrowing 
%				if set to true
%
% Outputs (empty on failure):
%	f			Frequency in GHz
%	s			S-parameter matrix
%	z			Characteristic impedance
%
% RPV 25.8.2006 - 4.12.2009 / TPL 8.2.2013
%
% S-parameter file format from MACOM an3009
% the option line should be as follows (example):
% # GHZ S MA R 50
% 'GHZ' may be replaced with MHZ, KHZ or HZ (Z can also be in lowercase)
% 'S' means that the parameters in the file are s-parameters
% 'MA' (magnitude-angle) may be replaced also with 'RI' (real-imaginary) or
% with 'DB' (magnitude dB - angle) Angle is in degrees
% 'R 50' reveals the system reference impedance (in the example 50 ohm)
% Possible realistic non-50 ohm impedances are 75 ohm and 1 ohm
% The data in the file in terms of columns: 
% <freq> <S11[M/R/DB]> <S11[A/I/A]> ...


	if nargin < 2
		debug = false;
	end
	
	try

		% Read comments
		fid = fopen(fname);
		startline = 0;
		comment = 1;
		ports = str2double(fname(end-1));

		% Defaults:
		factor = 1e9; % freq factor(def. 1 GHz)
		format = 1; % format for the data 1 = MA, 2 = RI, 3 = DB
		Z0 = 50;

		% Read settings (i.e., find line like 'GHZ S MA R 50') and find the
		% start of the actual data
		while comment
			line = fgetl(fid);
			opt = sscanf(line, '%s');
			if isempty(line) || opt(1) == '#' || opt(1) == '!' || opt(1) == '$'
				startline = startline + 1;

				if numel(line)~=0 && line(1) == '#' && numel(line) > 1
					if opt(2) == 'M'
						factor = 1e6;
					elseif opt(2) == 'H'
						factor = 1;
						opt(6) = opt(5);
					elseif opt(2) == 'K' || opt(2) == 'k'
						factor = 1e3;
					end

					if opt(6) == 'M' || opt(5) == 'M'
						format = 1;
					elseif opt(6) == 'R' || opt(5) == 'R'
						format = 2;
					elseif opt(6) == 'D' || opt(6) == 'd'
						format = 3;
					end

					Z0 = str2double(opt(9:numel(opt)));
					if ~Z0
						Z0 = 50;
					end
				end

			else
				comment = 0;
			end
		end

		% Read actual data & close file
		data = textscan(fid, ['%f', repmat(' %f', 1, 2 * ports^2)], ...
			'headerlines', startline);
		fclose(fid);

		f = data{1} * factor;
		if size(f, 2) == length(f)
			f = f.';
		end

		s = zeros(length(f), ports^2);

		for k = 1 : ports^2
			switch format
				case 1	% MA
					S = data{2 * k} .* exp(1i * data{2 * k + 1} * (pi / 180));
				case 2	% RI
					S = data{2 * k} + 1i * data{2 * k + 1};
				case 3	% DB
					S = 10 .^ (data{2 * k} / 20) .* exp(1i * data{2 * k + 1} * (pi / 180));
			end

			% flip orientation (ensure col-vector)
			if size(S, 2) == length(S)
				s(:, k) = S.';
			else
				s(:, k) = S;
			end
		end

		z = Z0;
		
	catch err
		fclose('all');
		f = []; s = []; z = [];
		if debug
			rethrow(err);
		end
	end

end