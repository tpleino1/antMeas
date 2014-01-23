function [patchH, rayLineH, circLineH, rayTextH, circTextH] = ...
	initPolarPlot( axesH, varargin )
% initPolarPlot( axesH, varargin ) converts current axes suitable for polar
% plotting while the data is normalized to range [0, 1]
%
% Input:	axesH		axes handle
%			varargin	'key', value -pairs for configuration (case-sens). 
%						Available settings and their default values:
% 							'blocks',		12, ...
% 							'range',		[0 1], ...
% 							'log',			false, ...
% 							'half',			false,	...
% 							'step',			0.2, ...
% 							'ang',			1, ...
% 							'magAng',		90, ...
% 							'magXOff',		0, ...
% 							'magYOff',		0, ...
% 							'magAbsOff',	-0.04, ...
% 							'magRot',		true, ...
% 							'magFlip',		true, ...
% 							'angXOff',		0, ...
% 							'angYOff',		0, ...
% 							'angAbsOff',	0.05, ...
% 							'angRot',		true, ...
% 							'angFlip',		true, ...
% 							'deltaDeg',		1 ...
%
%	Normalize and plot as follows: 
%		plotMag = (mag - min(mag) / (max(mag) - min(mag));
%		plot(axesH, plotMag .* cos(ang), plotMag .* sin(ang), ...);

	cfg = configValues(varargin); % Config values

	% Initialization (auxiliary, angular plot variables)
	nPhiDeg = 0 : cfg.deltaDeg : 360 - cfg.deltaDeg;
	nPhi = nPhiDeg / 180 * pi;

	rPhiDeg = linspace(0, 360 * (1 - 1 / cfg.blocks), cfg.blocks);
	rPhi = rPhiDeg / 180 * pi;

	% Plotting settings
	cfg.magAng = mean([rPhi(find(rPhiDeg < cfg.magAng, 1, 'last')), ...
		rPhi(find(rPhiDeg >= cfg.magAng, 1, 'first'))]);

	if cfg.half
		nPhi = nPhi(nPhiDeg <= 180);
		rPhi = rPhi(rPhiDeg <= 180);
	end

	% Angular labels
	switch cfg.ang
		case 3 % Radians in decimal
			rStr = cellfun(@num2str, num2cell(rPhi), ...
			'UniformOutput', false);

		case 2 % Radians as a fraction of pi
			rStr = cell(size(rPhi));
			n = 2 * (0 : cfg.blocks - 1);
			d = cfg.blocks * ones(size(n));
			g = gcd(n, d);
			n = n ./ g;
			d = d ./ g;
			for i = 1 : length(rPhi)
				if ~isfinite(n(i) / d(i)) || n(i) == 0 % NaN, +Inf, -Inf or 0
					rStr{i} = num2str(n(i) / d(i));
				else
					rStr{i} = sprintf('%g\\pi%c%c%c%d', ...
						ones(n(i) ~= 1) * n(i), ...
						ones(d(i) ~= 1) * ' ', ...
						ones(d(i) ~= 1) * '/', ...
						ones(d(i) ~= 1) * ' ', ...
						ones(d(i) ~= 1) * d(i));
				end
			end
			clear n d g;

		otherwise % Degrees
			rStr = cellfun(@num2str, num2cell(rPhiDeg), ...
			'UniformOutput', false);
			rStr = [rStr(1), strcat(rStr(2 : end), ' �')];
	end
	
	if cfg.angShowRad && cfg.ang > 1
		rStr = [rStr(1), strcat(rStr(2 : end), ' rad')];
	end
	
	% Auxialiry magnitude variables
	cVal = max(cfg.range) : -cfg.step : min(cfg.range);
	cVal = cVal(cVal > min(cfg.range));
	cNorm = (cVal - min(cfg.range)) / (max(cfg.range) - min(cfg.range));
	cStr = cellfun(@num2str, num2cell(cVal), ...
			'UniformOutput', false);

	if ~isempty(cfg.magUnit) % Add magnitude unit
		cStr = strcat(cStr, [' ', cfg.magUnit]);
	end

	axes(axesH);
	% Avoid Title/XLabel/YLabel overlapping
	axis([-1 1 ~cfg.half * -1 1] * (1 + cfg.angAbsOff));
	axis equal;
	axis off;
	grid off;
	hold on;

	% Background
	patchH = patch(...
		'XData',		cos(nPhi), ...
		'YData',		sin(nPhi), ...
		'EdgeColor',	'Black', ...
		'FaceColor',	'White');

	% Circles
	circLineH = zeros(length(cNorm), 1);
	circTextH = zeros(size(circLineH));
	for i = 1 : length(circLineH)
		circLineH(i) = plot(cNorm(i) * cos(nPhi), cNorm(i) * sin(nPhi), 'k:');
		circTextH(i) = text(...
			(cNorm(i) + cfg.magAbsOff) * cos(cfg.magAng) + cfg.magXOff, ...
			(cNorm(i) + cfg.magAbsOff) * sin(cfg.magAng) + cfg.magYOff, ...
			cStr{i}, ...
			'HorizontalAlignment',	'Center', ...
			'VerticalAlignment',	'Middle', ...
			'Rotation',				...
				cfg.magRot * (cfg.magAng / pi * 180 - 90 - 180 * cfg.magFlip * (cfg.magAng > pi)));
	end

	% Rays
	rayLineH = zeros(length(rPhi), 1);
	rayTextH = zeros(size(rayLineH));
	r = [min(cNorm) max(cNorm)];
	for i = 1 : length(rayLineH)
		rayLineH(i) = plot(r * cos(rPhi(i)), r * sin(rPhi(i)), 'k:');
		rayTextH(i) = text(...
			(1 + cfg.angAbsOff) * cos(rPhi(i)) + cfg.angXOff, ...
			(1 + cfg.angAbsOff) * sin(rPhi(i)) + cfg.angYOff, ...
			rStr{i}, ...
			'HorizontalAlignment',	'Center', ...
			'VerticalAlignment',	'Middle', ...
			'Rotation',				...
				cfg.angRot * (rPhi(i) / pi * 180 - 90 - 180 * cfg.magFlip * (rPhi(i) > pi)));
	end
	clear r;

	hold off;

	
	function [cfg] = configValues(varargin)

		% Default Values
		cfg = struct( ...  
			'blocks',		12, ...
			'range',		[0 1], ...
			'half',			false,	...
			'step',			0.2, ...
			'ang',			1, ...
			'magUnit',		'', ...
			'magAng',		90, ...
			'magXOff',		0, ...
			'magYOff',		0, ...
			'magAbsOff',	-0.04, ...
			'magRot',		true, ...
			'magFlip',		true, ...
			'angShowRad',	false, ...
			'angXOff',		0, ...
			'angYOff',		0, ...
			'angAbsOff',	0.05, ...
			'angRot',		true, ...
			'angFlip',		true, ...
			'deltaDeg',		1 ...
			);

		if isempty(varargin)
			return;
		else
			varargin = varargin{1};
		end

		% User Overridden Values
		j = 1;
		while j <= length(varargin)
			if isfield(cfg, varargin{j})
				cfg.(varargin{j}) = varargin{j + 1};
				j = j + 2;
			else
				warning('myApp:UnknownProperty', ...
					['Property ''', varargin{j}, ''' unknown.'])
				j = j + 1;
			end
		end
		
		cfg.blocks = max(6, abs(round(cfg.blocks(1))));
		if (cfg.step <= 0) || (cfg.step > max(cfg.range) - min(cfg.range))
			cfg.step = (max(cfg.range) - min(cfg.range)) / 5;
		end
		cfg.ang = min(3, max(1, cfg.ang));
		
		% Used in calculations as 1 or 0
		cfg.half = logical(cfg.half);
		cfg.magRot = logical(cfg.magRot);
		cfg.magFlip = logical(cfg.magFlip);
		cfg.angShowRad = logical(cfg.angShowRad);
		cfg.angRot = logical(cfg.angRot);
		cfg.angFlip = logical(cfg.angFlip);

		if cfg.half
			cfg.magAng = 0;
			cfg.magAbsOff = 0;
			cfg.magYOff = -0.05;
			cfg.magRot = false;
		end

	end

end
