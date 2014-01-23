function [ e, f, s ] = antEfficiency( d )
% [ e, f, s ] = antEfficiency( d ) returns the efficiency 
% of the antenna under testing.
% 
% In:		d	Struct containing interpolated measurements:
% 				d	> aut	> horiz (indexing: p, s, f)
% 							> vert
% 							> sParam
% 					> ref	> horiz
% 							> vert
% 							> eff
% 					> freq
% 					> prim
% 					> sec
%
% Out:		e	Efficiency vector (in decimal)
%			f	Frequency vector (in Hz)
%			s	Absolute of the S11-parameter (linear magnitude)

	% Pre-allocation
	pAut = zeros(size(d.freq));
	pRef = zeros(size(d.freq));
	
	% Angular weighting (the angWt function returns N slices for N points, 
	% and initially there are only N-1 slices)
	dP = angWt(d.prim);
	dP = ((max(d.prim) - min(d.prim)) / length(d.prim)) / mean(dP) * dP;
	
	dS = angWt(d.sec);
	dS = ((max(d.sec) - min(d.sec)) / length(d.sec)) / mean(dS) * dS;

	% Calculate Ref & AUT power
	for i = 1 : length(d.freq)
		for j = 1 : length(d.prim)
			for k = 1 : length(d.sec)
				pAut(i) = pAut(i) + ...
					(abs(d.aut.horiz(j, k, i))^2 + ...
						abs(d.aut.vert(j, k, i))^2) * ...
					sin(d.sec(k) / 180 * pi) * dP(j) * dS(k);
				
				pRef(i) = pRef(i) + ...
					(abs(d.ref.horiz(j, k, i))^2 + ...
						abs(d.ref.vert(j, k, i))^2) * ...
					sin(d.sec(k) / 180 * pi) * dP(j) * dS(k);
			end
		end
	end

	% Return values
	e = d.ref.eff .* (pAut ./ pRef);
	f = d.freq;
	s = abs(d.aut.sParam);

	
	% Angular weighting
	function b = angWt(a)
		b = zeros(size(a));
		b(1) = a(2) - a(1);
		b(end) = a(end) - a(end-1);
		for n = 2 : length(a) - 1
			b(n) = (a(n+1) - a(n-1)) / 2;
		end
	end

end

