function i = interpAntMeas(o, i, e, f, m)
% i = interpAntMeas(o, i, e, f, m)
% Interpolates the data for later use.
%
% Inputs:
%		o		original (struct)
%		e		enable (struct)
%		f		function ('cubic', 'spline', 'linear' or 'nearest')	[optional]
%		m		method (1: R+1, 2: Lin+Ang or 3: Log+Ang)			[optional]
%
% Output:
%		i		interpolated (struct)

	% Defaults
	if (nargin < 3)
		f = 'cubic';
		m = 1;
	elseif (nargin < 4)
		m = 1;
	end
	
	ant = {}; pol = {};
	
	if e.eff
		ant = {'aut',	'aut',	'ref',		'ref'};
		pol = {'horiz', 'vert', 'horiz',	'vert'};
	else
		if e.horiz 
			ant = {'aut'};
			pol = {'horiz'};
		end
		if e.vert
			ant{end+1} = 'aut';
			pol{end+1} = 'vert';
		end
	end
	
	% See the documentation of interp3
	% Original state restored in the end
	warnOrig = warning;
	warning('off', 'MATLAB:griddedInterpolant:CubicUniformOnlyWarnId');
	
	% Note the order, it's due to meshgrid/interp3
	[pI, sI, fI] = meshgrid(i.sec, i.prim, i.freq);
	
	% Radiation pattern
	for j = 1 : length(ant)
		% Note the order, it's due to meshgrid/interp3
		[pO, sO, fO] = meshgrid(o.(ant{j}).(pol{j}).sec, ...
			o.(ant{j}).(pol{j}).prim, o.(ant{j}).(pol{j}).freq);
		
		switch (m)
			case 3 % Log & Ang
				i.(ant{j}).(pol{j}) = 10 .^ (1/20 * interp3(pO, sO, fO, ...
					20 * log10(abs(o.(ant{j}).(pol{j}).data)), ...
						pI, sI, fI, f)) .* ...
					exp(1i * interp3(pO, sO, fO, ...
						angle(o.(ant{j}).(pol{j}).data), ...
						pI, sI, fI, f));
					
			case 2 % Lin & Ang
				i.(ant{j}).(pol{j}) = interp3(pO, sO, fO, ...
					abs(o.(ant{j}).(pol{j}).data), ...
						pI, sI, fI, f) .* ...
					exp(1i * interp3(pO, sO, fO, ...
						angle(o.(ant{j}).(pol{j}).data), ...
						pI, sI, fI, f));
					
			otherwise % R + I
				i.(ant{j}).(pol{j}) = interp3(pO, sO, fO, ...
					real(o.(ant{j}).(pol{j}).data), ...
						pI, sI, fI, f) + ...
					1i * interp3(pO, sO, fO, ...
					imag(o.(ant{j}).(pol{j}).data), ...
						pI, sI, fI, f);
		end
	end
	clear ant pol j pI sI fI pO sO fO;
	
	% Efficiency & S-Params
	if e.eff
		i.ref.eff = interp1(o.ref.eff.freq, o.ref.eff.eff, i.freq, f);
		
		switch (m)
			case 3
				i.aut.sParam = 10 .^ (1/20 * interp1(o.aut.sParam.freq, ...
						20 * log10(abs(o.aut.sParam.s11)), i.freq, f)) .* ...
					exp(1i * interp1(o.aut.sParam.freq,  ...
						angle(o.aut.sParam.s11), i.freq, f));
			case 2
				i.aut.sParam = interp1(o.aut.sParam.freq, ...
						abs(o.aut.sParam.s11), i.freq, f) .* ...
					exp(1i * interp1(o.sParam.freq, ...
						angle(o.aut.sParam.s11), i.freq, f));
			otherwise
				i.aut.sParam = interp1(o.aut.sParam.freq, ...
						real(o.aut.sParam.s11), i.freq, f) + ...
					1i * interp1(o.aut.sParam.freq, ...
						imag(o.aut.sParam.s11), i.freq, f);
		end
	end
	
	warning(warnOrig);
	i.calc = true;
	
end