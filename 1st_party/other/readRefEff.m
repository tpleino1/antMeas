function [f, e, s] = readRefEff(fname, debug)
% [f, e, s] = readRefEff(fname, debug) reads the efficiency data 
% of the reference antenna efficiency data.
%
% Inputs:
%	fname	File to be read. Following format assumed:
%			1) Freq in MHz, 2) Eff in %, 3) abs(S11) in dB
%	debug	Optional parameter to enable exception rethrowing 
%			if set to true
%	
% Outputs (empty on failure):
%	f		Frequency in Hz
%	e		Efficiency between [0, 1]
%	s		abs(S11) in linear

	if nargin < 2
		debug = false;
	end

	try
		fid = fopen(fname);
		data = textscan(fid, '%f %f %f', 'headerlines', 5);

		f = data{1, 1} * 1e6;
		e = data{1, 2} / 100;
		s = 10 .^ (data{1, 3} / 20);

		fclose(fid);
		
	catch err
		f = []; e = []; s = [];
		fclose('all');
		if debug
			rethrow(err);
		end
		
	end
end