function output_txt = dataTipSmith(~, event_obj)
	% Display useful information on dataTip on a Smith chart
	% (S = MAG /_ ANG, z = Re + j Im, RL = __ dB)
	% obj          Currently not used (empty)
	% event_obj    Handle to event object
	% output_txt   Data cursor text string (string or cell array of strings).

	pos = get(event_obj, 'Position');
	
	S = pos(1) + 1i * pos(2);
	Z = (1 + S) ./ (1 - S);
	
	% S = MAG /_ ANG
	strS = ['S = ', num2str(abs(S), 3), ' /_ ', ...
		num2str(angle(S) / pi * 180, 3), ' °'];
	
	% z = Re + j Im
	strZ = ['z = ', num2str(real(Z), 3)];
	if imag(Z) < 0
		strZ = [strZ, ' - j'];
	else
		strZ = [strZ, ' + j'];
	end
	
	strZ = [strZ, num2str(abs(imag(Z)), 3)];
	
	% RL = ___ dB
	strDB = ['RL = ', num2str(-20*log10(abs(S)), 3), ' dB'];
	
	output_txt = { strS, strZ, strDB };

end